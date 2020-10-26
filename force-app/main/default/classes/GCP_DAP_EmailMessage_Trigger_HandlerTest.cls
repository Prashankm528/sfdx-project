/*****************************************************************************************
*   Date: 16/12/2019 
*   Author: Subin M Nair   
*   Description: Test Class for GCP_DAP_EmailMessage_Trigger_Handler
*******************************************************************************************/
@isTest
private with sharing class GCP_DAP_EmailMessage_Trigger_HandlerTest 
{
    @testSetup static void testdataSetup() 
    {
        Case c1 = new Case();
        c1.Subject = 'Test Case';
        c1.Description = 'Test Description';
        c1.recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('GCP_DAP_Deal_Request').getRecordTypeId();
        insert c1;
    } 

    static testMethod void unitTest1()
    {
        Case c1 = new Case();
        c1=[Select Id,Casenumber from Case where recordtype.developername=:'GCP_DAP_Deal_Request'];
        Test.StartTest();
        EmailMessage em = new EmailMessage();
        em.ToAddress = 'subin.nair@bp.com';
        em.subject='test Case';
        em.TextBody = 'test';
        em.parentid= c1.id;
        em.Incoming = false;
        insert em;
        Test.StopTest();

        List<EmailMessage> emailList = [Select Id from EmailMessage where ParentId =: c1.id];
        system.assertequals(emailList.size(),1);        
    }
}