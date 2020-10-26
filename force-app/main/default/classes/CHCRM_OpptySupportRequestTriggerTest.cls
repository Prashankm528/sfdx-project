/***********************************************************************************************
 * @author           
 * @date             2020/07/01
 * @group            CHCRM
 * @description      Test class for CHCRM_OpptySupportRequestTriggerHandler

 * history
 * 2020/07/01    Created 
 ************************************************************************************************/
@isTest
private with sharing class CHCRM_OpptySupportRequestTriggerTest {
    
    private static testMethod void testBeforeInsert(){
        Account castrolAcc = SFO_TestDataService.createCustomerAccount();
        insert castrolAcc;     
        system.debug('castrolAcc Id:'+castrolAcc.Id);
        Opportunity opp = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Opportunity').getRecordTypeId();
        opp.Name = 'Test';
        opp.StageName = 'Test';
        opp.CloseDate = System.today();
        insert opp;
        system.debug('opp Id:'+opp.Id);
		Contact testContact = SFO_TestDataService.createContact(castrolAcc.Id);
        insert testContact;
        system.debug('testContact Id:'+testContact.Id);
        CHCRM_Opportunity_Support_Request__c oppsr = new CHCRM_Opportunity_Support_Request__c();
        oppsr.RecordTypeId = Schema.SObjectType.CHCRM_Opportunity_Support_Request__c.getRecordTypeInfosByDeveloperName().get('CHCRM_C_E_Opportunity_Support_Request').getRecordTypeId();
        oppsr.CHCRM_Comment_From_Approver__c = 'Test CHCRM Comment Support';
        oppsr.CHCRM_Opportunity__c = opp.id;
        insert oppsr;
        CHCRM_Opportunity_Support_Request__c result = [SELECT ID, 
                                                              CHCRM_Has_Comment__c 
                                                         FROM CHCRM_Opportunity_Support_Request__c 
                                                        WHERE ID =: oppsr.Id];
        System.assertEquals(true,result.CHCRM_Has_Comment__c);
    } 
    
    private static testMethod void testBeforeUpdate(){
        Account caAcc = SFO_TestDataService.createCustomerAccount();
        insert caAcc;        
        Contact con = SFO_TestDataService.createContact(caAcc.Id);
        insert con;
        Opportunity oppty = SFO_TestDataService.createCastrolOpportunity(caAcc.Id);
        oppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CHCRM_ILS_Opportunity').getRecordTypeId();
        oppty.StageName = 'Test';
        oppty.CloseDate = System.today().addDays(1);
        oppty.Name = 'Test';
        insert oppty;
        CHCRM_Opportunity_Support_Request__c osr = new CHCRM_Opportunity_Support_Request__c();
        osr.CHCRM_Comment_From_Approver__c = 'Comment ABCDEDFG';
        osr.CHCRM_Opportunity__c = oppty.id;
        osr.RecordTypeId = Schema.SObjectType.CHCRM_Opportunity_Support_Request__c.getRecordTypeInfosByDeveloperName().get('CHCRM_C_E_Opportunity_Support_Request').getRecordTypeId();
        insert osr;
        CHCRM_Opportunity_Support_Request__c updateOpp = new CHCRM_Opportunity_Support_Request__c();
        updateOpp.CHCRM_Comment_From_Approver__c = null;
        updateOpp.id = osr.Id;
        update updateOpp;
        CHCRM_Opportunity_Support_Request__c rst = [SELECT CHCRM_Has_Comment__c, ID FROM CHCRM_Opportunity_Support_Request__c WHERE ID =: updateOpp.Id];
        System.assertEquals(false,rst.CHCRM_Has_Comment__c);
    } 

}