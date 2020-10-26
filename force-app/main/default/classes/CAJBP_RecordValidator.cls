/*
* Handles specific validation for JBP related objects, currently validates
* if a record relating to an active JBP can be deleted.
*/
public with sharing class CAJBP_RecordValidator {
    @TestVisible
    private static CAJBP_RecordValidator instance = new CAJBP_RecordValidator();

    //Dependency inject providers if available.
    @TestVisible
    private Map<String, Object> providers = new Map<String, Object>();

    @TestVisible
    private CAJBP_RecordValidator() {
        //Inject default providers for default constructor.
        providers.put('ErrorProvider', new RecordErrorProvider());
        providers.put('DAOProvider', new DAOProvider());
    }

    @TestVisible
    private CAJBP_RecordValidator(Map<String, Object> providers) {
        this.providers = providers;
    }

    /*
    * Validates if the current record can be deleted, only if the JBP is in valid delete states.
    * The valid delete states are configured in CAJBP_Valid_Delete_State__mdt.
    *
    * @param jbpIdField the target parent JBP Id field relating to this record, *** does not span multiple
    *           levels (use formula field if spanning multiple levels) ***.
    * @param targetRecords the current records being deleted.
    */
    public static void validateDeleteWithJointBusinessPlanState(SObjectField jbpIdField, List<sObject> targetRecords) {
        instance.validateDelete(jbpIdField, targetRecords);
    }

    /*
    * Generates a unique value and assigns it the ignore validation field for a specific record.
    */
    public static void ignoreValidation(SObject record) {
        String hex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        String guid = hex.SubString(0,8)+ '-' + hex.SubString(8,12) + '-' + hex.SubString(12,16) + '-' + hex.SubString(16,20) + '-' + hex.substring(20);

        record.put('CAJBP_Ignore_Validation__c', (System.now().getTime() + '-' + guid));
    }

    @TestVisible
	private void validateDelete(SObjectField jbpIdField, List<sObject> targetRecords) {
	    if (jbpIdField == null
	            || targetRecords == null
	            || targetRecords.isEmpty()
            	|| !providers.containsKey('DAOProvider')
	            || !providers.containsKey('ErrorProvider')) {

	        return ;
	    }
        
        DAOProvider daoProvider = (DAOProvider)providers.get('DAOProvider');
        RecordErrorProvider errorProvider = (RecordErrorProvider)providers.get('ErrorProvider');
        Set<String> validDeleteStates = daoProvider.getValidDeleteStates();

        //If no valid delete states are configured then skip.
        if (validDeleteStates.isEmpty()) {
            return ;
        }

        Set<Id> jbpIdsToValidate = new Set<Id>();

        for (SObject record :targetRecords) {
            //Get the parent JBP Id value.
            Id jbpId = String.valueOf(record.get(jbpIdField));

            if (String.isNotBlank(jbpId)) {
                jbpIdsToValidate.add(jbpId);
            }
        }

        //If nothing to validate then skip validation.
        if (jbpIdsToValidate.isEmpty()) {
            return ;
        }

        //Remove all valid JBP's found in valid delete states from jbpIdsToValidate, this will
        //only contain JBP's that are invalid to delete.
        jbpIdsToValidate.removeAll(
            daoProvider.getJointBusinessPlansInDeleteState(
                jbpIdsToValidate,
                validDeleteStates
            ).keySet()
        );

        //If nothing to validate then skip validation.
        if (jbpIdsToValidate.isEmpty()) {
            return ;
        }

        for (SObject record :targetRecords) {
            Id jbpId = String.valueOf(record.get(jbpIdField));
        
            //Show error message if current record related JBP is not in a valid delete state.
            if (String.isNotBlank(jbpId) && jbpIdsToValidate.contains(jbpId)) {
                errorProvider.addError(
                    record,
                    getDeleteErrorMessage(validDeleteStates)
                );
            }
        }
    }

    @TestVisible
    private String getDeleteErrorMessage(Set<String> validDeleteStates) {
        return String.format(
            //Get custom label for error message.
            System.Label.CAJBP_InvalidDeleteRecordMsg,
            //Replace placeholder with the valid states allowed.
            new List<String>{
                String.join((Iterable<String>)validDeleteStates, ',')
            }
        );
    }

    /*
    * Data provider to help with data access. Can easily mock or provide different variations.
    */
    public virtual class DAOProvider {
        /*
        * Returns a set of JBP's that are in valid delete states.
        */
        public virtual Map<Id, CAJBP_Joint_Business_Plan__c> getJointBusinessPlansInDeleteState(Set<Id> jbpIds, Set<String> validDeleteStates) {
            return new Map<Id, CAJBP_Joint_Business_Plan__c>([
                SELECT Id
                FROM CAJBP_Joint_Business_Plan__c
                WHERE Id IN :jbpIds AND CAJBP_State__c IN :validDeleteStates
            ]);
        }
    
        /*
        * Returns a set of configured valid delete states.
        */
        public virtual List<CAJBP_Valid_Delete_State__mdt> getValidDeleteStateRecords() {
            return new List<CAJBP_Valid_Delete_State__mdt>([
                SELECT DeveloperName
                FROM CAJBP_Valid_Delete_State__mdt
            ]);
        }
    
        public virtual Set<String> getValidDeleteStates() {
            Set<String> validDeleteStates = new Set<String>();
    
            for (CAJBP_Valid_Delete_State__mdt state :getValidDeleteStateRecords()) {
                validDeleteStates.add(state.DeveloperName);
            }
    
            return validDeleteStates;
        }   
    }

    /*
    * Error provider to help with bubbling up errors. Can easily mock or provide different variations.
    */
    public virtual class RecordErrorProvider {
        public virtual void addError(SObject record, String message) {
            record.addError(message);
        }
    }
}