@isTest
public with sharing class ISTCP_ExternalServiceTest implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        ISTCP_Service__mdt sm = queryCustomMetadata();
        String endpoint = 'callout:' + sm.ISTCP_Named_Credential__c + sm.ISTCP_Relative_Endpoint__c;
        System.assertEquals(endpoint, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

    static ISTCP_Service__mdt queryCustomMetadata() {
        return [SELECT ISTCP_Additional_Headers__c,
                ISTCP_Custom_Data_Provider_Class__c,
                DeveloperName,
                ISTCP_Direct_Callout_Authenticators__c,
                ISTCP_External_Service_Method_Type__c,
                Id,
                Label,
                Language,
                MasterLabel,
                ISTCP_Named_Credential__c,
                NamespacePrefix,
                ISTCP_Object_API_Name__c,
                QualifiedApiName,
                ISTCP_Query__c,
                ISTCP_Relative_Endpoint__c,
                ISTCP_Request_Definition__c,
                ISTCP_Response_Definition__c,
                ISTCP_Service_Type__c,
                ISTCP_Time_Out_Milliseconds__c
                FROM ISTCP_Service__mdt WHERE DeveloperName = 'getTestItems'];
    }

    @IsTest
    static void makeExternalCallout(){
        
        Test.setMock(HttpCalloutMock.class, new ISTCP_ExternalServiceTest());
        
        ISTCP_Service__mdt sm = queryCustomMetadata();
        
        String body = '{"EndurId":"sampleEndurId"}';
        HttpResponse res = ISTCP_ExternalService.makeExternalCallout(sm, body);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
}