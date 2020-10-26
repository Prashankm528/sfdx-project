/**
 * @author          Jan Majling
 * @date            07/09/2018
 * @group           CAJBP
 * @description     controller for lightning component CAJBP_RebateList
 *
 * history
 * 07/09/201    Jan Majling         Created 
 */
public with sharing class CAJBP_RebateListController {
    /**
     * Returns a list of rebates for a particular JBP with access controls.
     **/
    @AuraEnabled
    public static Map<String, Object> getData(Id jbpId) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('rebates', getRebates(jbpId));

        Map<String, Object> rebateDescribeInfo = new Map<String, Object>();
        Schema.DescribeSObjectResult rebateDescribeResult = Schema.SObjectType.CAJBP_Rebate__c;
        rebateDescribeInfo.put('isUpdateable', rebateDescribeResult.isUpdateable());
        rebateDescribeInfo.put('isDeletable', rebateDescribeResult.isDeletable());

        response.put('rebateDescribeInfo', rebateDescribeInfo);
        return response;
    }


    /**
     * @description gets a list of rebates for a particular JBP
     * @param jbpId the id of the JBP
     * @return List<CAJBP_Rebate__c>
     */
    public static List<CAJBP_Rebate__c> getRebates(Id jbpId) {
        List<CAJBP_Rebate__c> rebates = new List<CAJBP_Rebate__c>();

        List<String> fieldNamesToQuery = new List<String>{
            'RecordType.Name',
            'RecordType.DeveloperName'
        };

        for (SObjectField fieldToken :Schema.SObjectType.CAJBP_Rebate__c.fields.getMap().values()) {
            DescribeFieldResult fieldDescribe = fieldToken.getDescribe();

            if (fieldDescribe.isAccessible()) {
                fieldNamesToQuery.add(fieldDescribe.getName());
            } else {
                System.debug('No access to field: ' + fieldDescribe.getName());
            }
        }

        if (!fieldNamesToQuery.isEmpty()) {
            rebates.addAll(new List<CAJBP_Rebate__c>(
                (List<CAJBP_Rebate__c>)Database.query(
                    'SELECT ' + String.join(fieldNamesToQuery, ',')
                        + ' FROM CAJBP_Rebate__c'
                        + ' WHERE CAJBP_Scorecard__r.CAJBP_Joint_Business_Plan__c = :jbpId'
                        + ' ORDER BY CreatedDate DESC'
                )
            ));
        }

        return rebates;
    }
}