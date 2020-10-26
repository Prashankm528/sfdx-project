/*****************************************************************************************
*       Date:           01JUL19
*       Author:         Quentin Lebastard - IBM
*       Description:    Aura Enabled class to create a new Case from Community.
*****************************************************************************************/
public without sharing class TKT_createNewCaseController {


    /*****************************************************************************************
    *       Date:           01JUL19
    *       Author:         Quentin Lebastard - IBM
    *       Description:    Retrieve picklist help options on case object.
    *****************************************************************************************/
    @AuraEnabled
    public static List<String> getHelpOptions(String field) {
        System.debug('getHelpOptions');

        List<String> pickListValuesList= new List<String>();

		//Schema.DescribeFieldResult fieldResult = Case.theField.getDescribe();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(field).getDescribe();

		List<Schema.PicklistEntry> pickListvalues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListValue : pickListvalues){
			pickListValuesList.add(pickListValue.getLabel());
		}
        System.debug('pickListValuesList size : ' + pickListValuesList.size());

        if (pickListValuesList.isEmpty())
        {
            String message = 'Configuration Error: Picklist values not found';
            throw new AuraHandledException(message);
        }
		return pickListValuesList;
    }

    /*****************************************************************************************
    *       Date:           01JUL19
    *       Author:         Quentin Lebastard - IBM
    *       Description:    Retrieve picklist business options on case object.
    *****************************************************************************************/
    @AuraEnabled
    public static List<String> getBusinessOptions() {

        System.debug('getHelpOptions');
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.TKT_Primary_Commodity_Business_with_BP__c.getDescribe();
		List<Schema.PicklistEntry> pickListvalues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListValue : pickListvalues){
			pickListValuesList.add(pickListValue.getLabel());
		}
        System.debug('pickListValuesList size : ' + pickListValuesList.size());

        if (pickListValuesList.isEmpty())
        {
            String message = 'Configuration Error: Help options not found';
            throw new AuraHandledException(message);
        }
		return pickListValuesList;
    }

    /*****************************************************************************************
    *       Date:           01JUL19
    *       Author:         Quentin Lebastard - IBM
    *       Description:    Retrieve picklist TKT Commodity Team options on case object.
    *****************************************************************************************/
    @AuraEnabled
    public static List<String> getCommodityTeam() {

        System.debug('getCommodityTeam');
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.TKT_Commodity_Team__c.getDescribe();
		List<Schema.PicklistEntry> pickListvalues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListValue : pickListvalues){
			pickListValuesList.add(pickListValue.getLabel());
		}
        System.debug('pickListValuesList size : ' + pickListValuesList.size());

        if (pickListValuesList.isEmpty())
        {
            String message = 'Configuration Error: Help options not found';
            throw new AuraHandledException(message);
        }
		return pickListValuesList;
    }

    /*****************************************************************************************
    *       Date:           01JUL19
    *       Author:         Quentin Lebastard - IBM
    *       Description:    Retrieve current base url.
    *****************************************************************************************/
    @AuraEnabled
    public static string getDomain() {
        //String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
        String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().toExternalForm());

        return urlInstance;
    }

    /*****************************************************************************************
    *       Date:           01JUL19
    *       Author:         Quentin Lebastard - IBM
    *       Description:    Save case record, insert case record.
    *****************************************************************************************/
    @AuraEnabled
    public static Case saveCase(Case newCase) {
        System.debug('saveCase newCase ' + newCase);
        List<Case> cases = new List<Case>();
        try
            {
                Database.insert(newCase);
            }
        catch (DMLException dmx)
            {
                throw new AuraHandledException(dmx.getMessage());
            }
        if (newCase.Id != null){
            cases = [SELECT CaseNumber FROM Case WHERE Id =: newCase.Id];
        }
        system.debug('saveCase cases : ' + cases);
        return cases[0];
    }
}