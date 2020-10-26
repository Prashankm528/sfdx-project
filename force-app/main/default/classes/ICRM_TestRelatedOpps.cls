/* @author            Palash Awasthi
*  @date              15th July, 2019
*  @description       Get all the related opportunities to the account and contacts ignoring the sharing rules.
*/

@isTest
public with sharing class ICRM_TestRelatedOpps {
    
    /*
Test Data Setup for related Opportunities
*/
    @testsetup
    static void testDataSetup(){
        
        //Insert Account
        Account acc = new Account();
        List<Opportunity> lstOppty = new List<Opportunity>();
        List<OpportunityShare> lstOpptyShare = new List<OpportunityShare>();
        string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = recTypeid;
        acc.Name = 'Test Account for related opportunities';
        insert acc;
        
        //Insert Opprtunities related to the above account
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        string recTypeidOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();
        opp1.RecordTypeId = recTypeidOpp;
        opp1.Name = 'Opportunity 1';
        opp1.ICRM_Client_Order__c = True;
        opp1.StageName = 'Early Stages';
        opp1.ICRM_RBU__c = 'NAGP Gas';
        opp1.ICRM_Phy_Fin__c = 'Physical';
        opp1.CloseDate = Date.today()+1;
        lstOppty.add(opp1);
        
        insert lstOppty;
        
    }
    
    /*
test method to fetch the Related Opportunities
*/
    
    @isTest
    public static void testRelatedOpptys(){
        
        Account acc = [select id from Account where Name = 'Test Account for related opportunities'];
        Integer size;
        
        //Positive test for Account related Opportunities
        List<Opportunity> oppList1 = ICRM_RelatedOpps.getAccountRelatedOpportunities(acc.Id);
        if(oppList1 == NULL){
            size = 0;
        }
        else {
            size = oppList1.size();
        }
        System.assertEquals(0, size,'Test Not Passed');
        
    }
}