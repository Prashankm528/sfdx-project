/********************************************************************************
* Date          : 15-APR-2020
* Author        : Roselin Hephzibah
* Description   : Genesys Inbound Outbound Email creation methods in API.
* Modifications : 15-APR-2020 Roselin - Initial
********************************************************************************/
@RestResource(urlMapping='/GSYSNonVoice/*')  
global with sharing class GCM_GSYS_NonVoice_API {
    
/****************************************************************************************************
Post method to update record in Salesforce.
****************************************************************************************************/ 
    @HttpPost 
    global static ResponseWrapper doPost() 
    {  
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper resw = new ResponseWrapper();
        String jsonBody = req.requestBody.toString();
            system.debug('JsonBody'+jsonBody);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        String method = (String) m.get('method');
        List<Object> objList = (List<Object>) m.get('requestParams');
        system.debug('ReqParams**'+ objList );
        Map<String, Object> reqMap = new Map<String, Object>();
        
        if(!objList.isEmpty()){
            for(Object obj : objList){
                reqMap = (Map<String, Object>)obj; 
                system.debug('reqMap **'+ reqMap );
                
                //Create task instance
                Task tsk = new Task();
                tsk.subject = (String) reqMap.get('subject');
                tsk.GCM_Call_From__c = 'testfromaddr@bp.com';
                tsk.GCM_Call_To__c = 'testtoaddr@bp.com';
                tsk.callType = method;
                tsk.GCM_Match_Type__c = (String) reqMap.get('subject');
                tsk.softphone_it__IWS_Interaction_ID__c = (String) reqMap.get('interactionId');
                tsk.softphone_it__IWS_Media_Name__c = 'email';
                tsk.Description = (String) reqMap.get('messageText');
                tsk.GCM_BU__c = 'Fuels - Dealer';
                tsk.GCM_Sales_Organisation__c = 'GCM_Fuels_Dealer';
                
                Case cs = null;
                String caseRecType = 'GCM_Fuels_Dealer';
                
                if(String.valueof(reqMap.get('createSR')) == 'Y' && method != 'Outbound'){
                    cs = new case();
                    cs.Type = 'Consumer Support';
                    cs.Area__c = 'BP Internal';
                    cs.Sub_Area__c = 'Fleet Card Inquiry';
                }
                system.debug('CAse***'+cs);
                if(method == 'Inbound'){
                    Task t1 = GCM_CTIController.createTaskforInboundEmail(tsk, (String) reqMap.get('accountId'), (String) reqMap.get('contactId'), (String) reqMap.get('matchType'), (String) reqMap.get('defaultAccountId'), (String) reqMap.get('defaultContactId'), (String) reqMap.get('startDate'), (String) reqMap.get('subject'), (String) reqMap.get('messageText'), (String) reqMap.get('createSR'), cs, (String) reqMap.get('commMethod'), (String) reqMap.get('caseId'), (String) reqMap.get('hasAttachment'), '', caseRecType );
                    if( t1 != null){
                        resw.status = 'Sucess';
                        resw.statusCode = '200';
                        resw.recordId = t1.Id;
                    } else {
                        resw.status = 'Error';
                        resw.statusCode = '404';
                        resw.recordId = null;
                    }
                } else if(method == 'Outbound'){
                Task t2 = GCM_CTIController.createTaskforOutboundEmail(tsk, (String) reqMap.get('accountId'), (String) reqMap.get('contactId'), (String) reqMap.get('matchType'), (String) reqMap.get('defaultAccountId'), (String) reqMap.get('defaultContactId'), (String) reqMap.get('startDate'), (String) reqMap.get('subject'), (String) reqMap.get('messageText'), (String) reqMap.get('createSR'), null, (String) reqMap.get('commMethod'), (String) reqMap.get('caseId'), 'OutboundNew' , null, (String) reqMap.get('hasAttachment'), '');
                    if( t2 != null){
                        resw.status = 'Success';
                        resw.statusCode = '200';
                        resw.recordId = t2.Id;
                    } else {
                        resw.status = 'Error';
                        resw.statusCode = '404';
                        resw.recordId = null;
                    }
                }
            }
        }else {
                resw.status = 'Error - Request Params not found';
                resw.statusCode = '404';
                resw.recordId = null;
              }
        return resw;
    }
    
    global class RequestWrapper {
        public String method;
        public String requestParams;
        public RequestWrapper(){}
    }
    global class ResponseWrapper {
        public String status;
        public String statusCode;
        public String recordId;
        public ResponseWrapper(){}
    }
}