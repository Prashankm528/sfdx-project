/****************************************************************************************************
 *  Date          : 08-MAY-2020
 *  Author        : Roselin Hephzibah
 *  Description   : Test class for GCM_Update_Record_API
 * Modifications  : 08-MAY-2020 Roselin - Initial (Group test data creation fails when isParallel = true)
 ****************************************************************************************************/
@isTest
public with sharing class GCM_Update_Record_API_Test {
/****************************************************************************************************
  Test Update Record
 ****************************************************************************************************/
    @isTest static void testUpdateRecord() {
        
        Case newCase = new Case();
        newCase.Type = 'Test';
        newCase.Status = 'Open';
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert newCase;
        System.assert(newCase.Id != null, 'Test Case Created');
        
        Case newCase1 = new Case();
        newCase1.Type = 'Test';
        newCase1.Status = 'Open';
        newCase1.OwnerId = UserInfo.getUserId();
        newCase1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert newCase1;
        
        Case newCase2 = new Case();
        newCase2.Type = 'Test';
        newCase2.Status = 'Open';
        newCase2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert newCase2;
        
        Contact con = new Contact();
        con.firstname = 'Test';
        con.LastName = 'Contact';
        insert con;
        
        Group gp = new Group();
        gp.Name = 'Test Account';
        gp.DeveloperName = 'GCM_Test_Account';
        gp.Type = 'Queue';
        insert gp;
        
        GCM_Update_Record_API.RequestWrapper reqw = new GCM_Update_Record_API.RequestWrapper();
        GCM_Update_Record_API.ResponseWrapper resw = new GCM_Update_Record_API.ResponseWrapper();
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/UpdateRecord/';
        req.httpMethod = 'POST';
        String s = '{"source": "VOC Bot","requestParams": [{"recordId":"'+newCase.Id+'","fieldNamesandValues": {"Type" : "Invoice Management","Area__c" : "Manual & Misc Requests","Sub_Area__c" : "Misc Credit / Debit","Status" : "Closed","Sub_Status__c" : "Completed","Resolution_Code__c" : "Credit Note Raised","SR_Resolutions__c" : "C0111/s0111","GCM_ByPassValidation_Timestamp__c" : "2020-03-26 08:15:33","GCM_EmailToAddress__c" : "roselin.hephzibah@bp.com"}}]}';
        req.requestBody = blob.valueOf(s);
        RestContext.request = req;
        RestContext.response= res;
        GCM_Update_Record_API.doPost();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();             
        req1.requestURI = '/services/apexrest/UpdateRecord/';
        req1.httpMethod = 'POST';
        String exp = '{"source": "VOC Bot","requestParams":[{"recordId":"'+newCase1.Id+'","fieldNamesandValues":{"Exception":"True","QueueName":"GCM_ANZ_CUSTOMER_SERVICE_ADMIN_LUBES_VOC1"}}]}';
        req1.requestBody = blob.valueOf(exp);
        RestContext.request = req1;
        RestContext.response= res1;
        GCM_Update_Record_API.doPost();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req2.requestURI = '/services/apexrest/UpdateRecord/';
        req2.httpMethod = 'POST';
        String expt = '{"source": "VOC Bot","requestParams":[{"recordId":"'+newCase.Id+'","fieldNamesandValues":{"Exception":"True","QueueName":"GCM_Test_Account"}}]}';
        req2.requestBody = blob.valueOf(expt);
        RestContext.request = req2;
        RestContext.response= res2;
        GCM_Update_Record_API.doPost();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();             
        req3.requestURI = '/services/apexrest/UpdateRecord/';
        req3.httpMethod = 'POST';
        String s1 = '{"source": "Apex Test Class","requestParams": [{"recordId":"'+newCase2.Id+'","fieldNamesandValues": {"GCM_Automatic_Closed_Case__c" : "true","GCM_Approx_Delivery_Date__c" : "'+String.valueOf(Date.today())+'","Sub_Area__c" : "Misc Credit / Debit","Status" : "Closed","Sub_Status__c" : "Completed","Resolution_Code__c" : "Credit Note Raised","SR_Resolutions__c" : "C0111/s0111","GCM_ByPassValidation_Timestamp__c" : "2020-03-26 08:15:33"}}]}';
        req3.requestBody = blob.valueOf(s1);
        RestContext.request = req3;
        RestContext.response= res3;
        GCM_Update_Record_API.doPost();
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();             
        req4.requestURI = '/services/apexrest/UpdateRecord/';
        req4.httpMethod = 'POST';
        String s2 = '{"source": "Apex Test Class","requestParams": [{"recordId":"'+newCase.Id+'","fieldNamesandValues": {"Type" : "Invoice Management","Area__c" : "Manual & Misc Requests","Sub_Area__c" : "Misc Credit / Debit","Status" : "Closed","Sub_Status__c" : "Completed","Resolution_Code__c" : "Credit Note Raised","SR_Resolutions__c" : "C0111/s0111","GCM_EmailToAddress__c" : "roselin.hephzibah@bp.com"}}]}';
        req.requestBody = blob.valueOf(s2);
        RestContext.request = req4;
        RestContext.response= res4;
        GCM_Update_Record_API.doPost();
        
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();             
        req5.requestURI = '/services/apexrest/UpdateRecord/';
        req5.httpMethod = 'POST';
        String s3 = '{"source": "Apex Test Class","requestParams": []}';
        req5.requestBody = blob.valueOf(s3);
        RestContext.request = req5;
        RestContext.response= res5;
        GCM_Update_Record_API.doPost(); 
        
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();             
        req6.requestURI = '/services/apexrest/UpdateRecord/';
        req6.httpMethod = 'POST';
        String s4 = '{"source": "Apex Test Class","requestParams": [{"recordId":"'+newCase2.Id+'","fieldNamesandValues": {"GCM_Automatic_Closed_Case__c" : "true","GCM_Approx_Delivery_Date__c" : "(Wrong date","Sub_Area__c" : "Misc Credit / Debit","Status" : "Closed","Sub_Status__c" : "Completed","Resolution_Code__c" : "Credit Note Raised","SR_Resolutions__c" : "C0111/s0111","GCM_ByPassValidation_Timestamp__c" : "2020-03-26 08:15:33"}}]}';
        req6.requestBody = blob.valueOf(s4);
        RestContext.request = req6;
        RestContext.response= res6;
        GCM_Update_Record_API.doPost();
        
        Test.stopTest();
        
        //Assert Statements
        System.assert(newCase.Status != 'Closed', 'Test Case not updated');
        System.assert(!String.valueof(newCase1.OwnerId).startswith('00G'), 'Test Case owner not updated');
    }
}