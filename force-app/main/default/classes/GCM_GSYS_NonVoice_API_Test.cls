/****************************************************************************************************
 *  Date          : 07-MAY-2020
 *  Author        : Roselin Hephzibah
 *  Description   : Test class for GCM_GSYS_NonVoice_API
 * Modifications  : 07-MAY-2020 Roselin - Initial
 ****************************************************************************************************/
@isTest
public with sharing class GCM_GSYS_NonVoice_API_Test{
/****************************************************************************************************
  Test Update Record
 ****************************************************************************************************/
    @isTest static void testdoPost() {
        
        Case newCase = new Case();
        newCase.Type = 'Test';
        newCase.Status = 'Open';
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert newCase;
        System.assert(newCase.Id != null, 'Test Case Created');
        
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Sales_Organisation__c = 'MX02';
        acc.Type = 'Business';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'Test';
        con.LastName = 'Contact';
        insert con;
        
        GCM_GSYS_NonVoice_API.RequestWrapper reqw = new GCM_GSYS_NonVoice_API.RequestWrapper();
        GCM_GSYS_NonVoice_API.ResponseWrapper resw = new GCM_GSYS_NonVoice_API.ResponseWrapper();
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/GSYSNonVoice/';
        req.httpMethod = 'POST';
        String sin = '{"method": "Inbound","requestParams":[{"accountId":"'+acc.Id+'","contactId":"'+con.Id+'","matchType":"NoMatch","defaultAccountId":"'+acc.Id+'","defaultContactId":"'+con.Id+'","startDate":"2020-03-16T19:34:23+08:00","subject":"Test Subject","messageText":"Test email","createSR":"Y","commMethod":"Email","caseId":"","hasAttachment":"false","interactionId": "2000000023"}]}';
        req.requestBody = blob.valueOf(sin);
        RestContext.request = req;
        RestContext.response= res;
        GCM_GSYS_NonVoice_API.doPost();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();             
        req1.requestURI = '/services/apexrest/GSYSNonVoice/';
        req1.httpMethod = 'POST';
        String sout = '{"method": "Outbound","requestParams":[{"accountId":"'+acc.Id+'","contactId":"'+con.Id+'","matchType":"NoMatch","defaultAccountId":"'+acc.Id+'","defaultContactId":"'+con.Id+'","startDate":"2020-03-16T19:34:23+08:00","subject":"Test Subject","messageText":"Test email","createSR":"N","commMethod":"Email","caseId":"","hasAttachment":"false","interactionId": "2000000024"}]}';
        req1.requestBody = blob.valueOf(sout);
        RestContext.request = req1;
        RestContext.response= res1;
        GCM_GSYS_NonVoice_API.doPost();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req2.requestURI = '/services/apexrest/GSYSNonVoice/';
        req2.httpMethod = 'POST';
        String sin1 = '{"method": "Inbound","requestParams":[{"accountId":"'+con.Id+'","contactId":"'+con.Id+'","matchType":"NoMatch","defaultAccountId":"'+acc.Id+'","defaultContactId":"'+con.Id+'","startDate":"2020-03-16T19:34:23+08:00","subject":"Test Subject","messageText":"Test email","createSR":"Y","commMethod":"Email","caseId":"","hasAttachment":"false","interactionId": "2000000023"}]}';
        req2.requestBody = blob.valueOf(sin1);
        RestContext.request = req2;
        RestContext.response= res2;
        GCM_GSYS_NonVoice_API.doPost();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();             
        req3.requestURI = '/services/apexrest/GSYSNonVoice/';
        req3.httpMethod = 'POST';
        String sin2 = '{"method": "Inbound","requestParams":[]}';
        req3.requestBody = blob.valueOf(sin2);
        RestContext.request = req3;
        RestContext.response= res3;
        GCM_GSYS_NonVoice_API.doPost();
        
        Test.stopTest();
        
        //Assert Statements
        List<Task> tasList = [Select Id from Task];
        System.assert(tasList.size() == 2, 'Tasks not Created');
    }
}