/**
 * @author Jewelslyn Shama P
 * @company Tata Consultancy Services
 * @date 
 * 
 */
@isTest
global with sharing class OLCM_AccountTriggerHandlerQueueableMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('GET', req.getMethod());                
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }      
}