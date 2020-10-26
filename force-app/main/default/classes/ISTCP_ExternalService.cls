/**
 * @description       : Builds callouts to external systems
 * @author            : sebas.canseco@slalom.com
 * @group             : 
 * @last modified on  : 08-03-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-19-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_ExternalService {
    
    /**
    * @description Builds callout to external system based on configuration in provided from custom metadata and with given request.
    * @author sebas.canseco@slalom.com | 07-19-2020 
    * @param ISTCP_Service__mdt sm 
    * @param String body 
    * @return HttpResponse 
    **/
    public static HttpResponse makeExternalCallout(ISTCP_Service__mdt sm, String body){
        
        String endpoint = 'callout:' + sm.ISTCP_Named_Credential__c;
        
        if (String.isNotBlank(sm.ISTCP_Relative_Endpoint__c)) {

            // Check if relative endpoint needs to have Endur Id appended
            String relativeEndpoint = sm.ISTCP_Relative_Endpoint__c;
            Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);
            
            if (relativeEndpoint.contains('EndurId') && bodyMap.containsKey('EndurId')) {
                relativeEndpoint = relativeEndpoint.replace('EndurId', 'EndurId=' + bodyMap.get('EndurId'));
            }
            endpoint += relativeEndpoint;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        System.debug('request.getEndpoint(): ' + request.getEndpoint());

        if (sm.ISTCP_Time_Out_Milliseconds__c != null) {
            request.setTimeout((Integer)sm.ISTCP_Time_Out_Milliseconds__c);
            System.debug('request timeout: ' + sm.ISTCP_Time_Out_Milliseconds__c);
        }

        if (String.isNotBlank(sm.ISTCP_External_Service_Method_Type__c)) {
            request.setMethod(sm.ISTCP_External_Service_Method_Type__c);
        }
        System.debug('request.getMethod(): ' + request.getMethod());

        if (String.isNotBlank(sm.ISTCP_Additional_Headers__c)) {
            Map<String, Object> headers = (Map<String, Object>) JSON.deserializeUntyped(sm.ISTCP_Additional_Headers__c);
            for (String key : headers.keySet()) {
                request.setHeader(key, (String)headers.get(key));
                System.debug('request.getHeader(): ' + request.getHeader(key));
            }
        }

        if (String.isNotBlank(body)) {
            request.setBody(body);
        }
        System.debug('request.getBody(): ' + request.getBody());
        
        HttpResponse response = http.send(request);
        System.debug('>>> response.getStatus: ' + response.getStatus());
        System.debug('>>> response.getStatusCode: ' + response.getStatusCode());
        System.debug('>>> response.getBody: ' + response.getBody());  
        
        String responseBody = response.getBody();
        if (responseBody.contains('Response code 500 mapped as failure')) {
            throw new ExternalServiceException('{"ErrorList":[{"External system doesn\'t seem to be accepting requests at this time.":"External system doesn\'t seem to be accepting requests at this time."}]}');
        } else if (responseBody.contains('Error sending HTTP request') || responseBody.contains('ErrorList') 
                || responseBody.contains('org.mule.api.expression.ExpressionRuntimeException')
                || responseBody.contains('Message')) {
            throw new ExternalServiceException(response.getBody());
        }
        return response;
    }

     with sharing class ExternalServiceException extends System.Exception{}
}