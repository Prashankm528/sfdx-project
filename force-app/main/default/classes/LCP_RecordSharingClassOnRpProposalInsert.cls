/*****************************************************************************************
*        Date:          6th June 2020
*       Author:         Praneeth Indraganti
*       Description:    
*       Modifications:  
****************************************************************************************/
public with sharing class LCP_RecordSharingClassOnRpProposalInsert{

    @InvocableMethod(label='RpProp_SharingRules' description='Creating Sharing Rules for Project and Reporting Period Proposal')
    public static void creatingSharingRulesBasedonRpProposal(List<Id> rpIds) {
        Set<String> groupStrings = new Set<String>();
        List<Id> userIds = new List<Id>();
        List<Id> rpId = new List<Id>();
        List<Id> projectId = new List<ID>();
       for(LCP_Reporting_Period_Proposal__c rpPropWithGrouping:[select Id,LCP_Reporting_Period__r.LCP_Grouping__c,LCP_Reporting_Period__r.LCP_Project__c from LCP_Reporting_Period_Proposal__c where ID IN: rpIds limit 10000]){
           rpId.add(rpPropWithGrouping.Id);
           projectId.add(rpPropWithGrouping.LCP_Reporting_Period__r.LCP_Project__c);
           groupStrings.add(rpPropWithGrouping.LCP_Reporting_Period__r.LCP_Grouping__c);
       }
       for(User userWithGrouping:[select Id from User where LCP_Grouping__c IN:groupStrings]){
           userIds.add(userWithGrouping.Id);
       }
       LCP_CreateRPPropObjectSharingRulesBatch createSharingRules = new LCP_CreateRPPropObjectSharingRulesBatch(userIds,rpId,projectId); 
       database.executeBatch(createSharingRules);
    }
    
}