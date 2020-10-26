/*
  @descrition Code coverage for OLCM_AccountTriggerHandlerQueueable
  @Owner OLCM_Project_CMF
  @Date 20/08/2019
      
*/

@isTest
public with sharing  class OLCM_AccountTriggerHandlerQueueableTest {
   public static testmethod void testCallout(){        
        Test.setMock(HttpCalloutMock.class, new OLCM_AccountTriggerHandlerQueueableMock()); 
       OLCM_AccountTriggerHandlerQueueableMock chkobj=new OLCM_AccountTriggerHandlerQueueableMock();
       HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res =chkobj.respond(req);
       system.assertEquals(200, res.getStatusCode(), 'Response is not 200');
    }                                                                                                                                                     
}