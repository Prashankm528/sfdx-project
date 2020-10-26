/* @author            Amir Hafeez
*  @date              August 18, 2019
*  @description       provides helper methods for opportunity record types and filtering opportunity targets.
*  @Modifications     11DEC2019 Rahma Belghouti - Added validation constants
*  @Modifications     Jit: added Account Record Type by Developer Name
*  @Modifications     Jit: added Account Record Type by Id
*/
public without sharing class SFO_Constant
{
    public static final String VALIDATION_MESSAGE = 'Please Enter a Description or Add Notes Before Marking This Activity as Complete';
    public static final String VALIDATION_GROUP = 'Event Tracker Validation';
    public static final String VULNERABILITY = 'Vulnerability';
    public static Map<string, Id> sfoAccountRecordTypeByDeveloperNameMap = new Map<string, Id>();
    public static Map<Id, string> sfoAccountRecordTypeByIdMap = new Map<Id, string>();

    /*
    * Returns SFO specific record types, used to identify SFO opportunities.
    */
    public static Set<Id> VALID_RECORD_TYPES {
        get {
            if (VALID_RECORD_TYPES == null) {
                Map<String,RecordTypeInfo> recordTypeInfosByDeveloperName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

                VALID_RECORD_TYPES = new Set<Id>{
                    recordTypeInfosByDeveloperName.get('FWS_SG').getRecordTypeId(),
                    recordTypeInfosByDeveloperName.get('General').getRecordTypeId(),
                    recordTypeInfosByDeveloperName.get('CASFO_Vulnerability').getRecordTypeId()
                };
            }

            return VALID_RECORD_TYPES;
        }

        private set;
    }

    /*
    * Returns SFO Account Record Types by Developer Name.
    */    
    public static Map<string, Id> getSfoAccountRecordTypeByDeveloperNameMap()
    {
        if(sfoAccountRecordTypeByDeveloperNameMap.size() <= 0)
        {
            Map<string, RecordTypeInfo> recordTypeInfosByDeveloperName = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            for(string accountRecordTypeDeveloperName : recordTypeInfosByDeveloperName.keySet())
            {
                if(accountRecordTypeDeveloperName.equalsIgnoreCase('Customer') || accountRecordTypeDeveloperName.equalsIgnoreCase('Prospect') || accountRecordTypeDeveloperName.containsIgnoreCase('SFO'))
                {
                    sfoAccountRecordTypeByDeveloperNameMap.put(accountRecordTypeDeveloperName, recordTypeInfosByDeveloperName.get(accountRecordTypeDeveloperName).getRecordTypeId());
                }
            }
        }

        return sfoAccountRecordTypeByDeveloperNameMap;
    }

    /*
    * Returns SFO Account Record Types by Id.
    */    
    public static Map<Id, string> getSfoAccountRecordTypeByIdMap()
    {
        if(sfoAccountRecordTypeByIdMap.size() <= 0)
        {
            Map<string, RecordTypeInfo> recordTypeInfosByDeveloperName = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            for(string accountRecordTypeDeveloperName : recordTypeInfosByDeveloperName.keySet())
            {
                if(accountRecordTypeDeveloperName.equalsIgnoreCase('Customer') || accountRecordTypeDeveloperName.equalsIgnoreCase('Prospect') || accountRecordTypeDeveloperName.containsIgnoreCase('SFO'))
                {
                    sfoAccountRecordTypeByIdMap.put(recordTypeInfosByDeveloperName.get(accountRecordTypeDeveloperName).getRecordTypeId(), accountRecordTypeDeveloperName);
                }
            }
        }

        return sfoAccountRecordTypeByIdMap;
    }    

    public static Map<Id, string> targetEnabledOpportunityRecordTypeMap = new Map<Id, string>();

    /*
    * Returns target enabled opportunity record types.
    */
    public static Map<Id, string> TargetEnabledOpportunityRecordType()
    {
        if(targetEnabledOpportunityRecordTypeMap.size() <= 0) {
            Map<String, RecordTypeInfo> recordTypeInfosByDeveloperName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

            for (SFO_Target_Enable_OpportunityRecordType__mdt targetEnableOpportunityRecordType
                    : [SELECT Opportunity_Record_Type_Developer_Name__c FROM SFO_Target_Enable_OpportunityRecordType__mdt])
            {
                if (recordTypeInfosByDeveloperName.containsKey(targetEnableOpportunityRecordType.Opportunity_Record_Type_Developer_Name__c)) {
                    RecordTypeInfo foundRecordTypeInfo = recordTypeInfosByDeveloperName.get(targetEnableOpportunityRecordType.Opportunity_Record_Type_Developer_Name__c);

                    targetEnabledOpportunityRecordTypeMap.put(foundRecordTypeInfo.getRecordTypeId(), foundRecordTypeInfo.getDeveloperName());
                }
            }
        }

        return targetEnabledOpportunityRecordTypeMap;
    }
}