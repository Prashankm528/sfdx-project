/****************************************************************************************************
 * Date          : 08-FEB-2020
 * Author        : Sunny Yap
 * Description   : Invocable class for Dynamic Apex.
 * Modifications : 08-FEB-2020 Initial
 ****************************************************************************************************/
@RestResource(urlMapping='/GCM/*')
global with sharing class GCM_Dynamic_Apex {
/****************************************************************************************************
 * Run Anonymous Code Passed In
 ****************************************************************************************************/
    @HttpPost
    global static String run(String code) {
        if (code != null) {
            HttpRequest httpRequest = new HttpRequest();  
            String encoded = EncodingUtil.urlEncode(code, 'UTF-8');
            httpRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/tooling/executeAnonymous/?anonymousBody=' + encoded);  
            httpRequest.setMethod('GET');
            httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
            httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            try {
                Http http = new Http();
                HttpResponse httpResponse = null;

                Boolean testPositive = false;
                if (Test.isRunningTest()) {
                    httpResponse = new HttpResponse();
                    if (code == 'Syntax Error') {
                        httpResponse.setStatusCode(404);
                        httpResponse.setBody('Error');
                    } else {
						testPositive = true;
                        httpResponse.setStatusCode(200);
                        httpResponse.setBody('{"Test": "Test"}');
                    }
                }
                else {
                    httpResponse = http.send(httpRequest);
                }
                
                if (httpResponse.getStatusCode() == 200 ) {  
                    return (JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody())));
                } 
                else {  
                    return httpResponse.getBody(); 
                }   
            } catch (Exception exceptionObject) {  
                throw exceptionObject;
            }
        }        
        return null;
    }
}