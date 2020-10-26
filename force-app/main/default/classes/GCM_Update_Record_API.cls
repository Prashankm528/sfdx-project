/********************************************************************************
* Date          : 20-MAR-2020
* Author        : Roselin Hephzibah
* Description   : Generic Update Record API.
* Modifications : 06-APR-2020 Roselin - Bulkified update requests
********************************************************************************/
@RestResource(urlMapping='/UpdateRecord/*')  
global with sharing class GCM_Update_Record_API {
    
/****************************************************************************************************
Post method to update record in Salesforce.
****************************************************************************************************/ 
    @HttpPost 
    global static List<ResponseWrapper> doPost() 
    {  
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<ResponseWrapper> responseWrapperList = new List<ResponseWrapper>();
        
        try{
            Blob reqBlob = req.requestBody;
            String jsonBody = reqBlob.toString();
            system.debug('JsonBody'+jsonBody);
            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
            String sourceSystem = (String) m.get('source');
            List<Object> objList = (List<Object>) m.get('requestParams');
            Map<String, Object> reqMap = new Map<String, Object>();
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
            system.debug('source***'+sourceSystem);
            system.debug('m***'+m);
            
            Map<Id, Map<String, String>> updateCaseMap = new Map<Id, Map<String, String>>();
            List<GCM_Update_Record.ResponseWrapper> reswpList = new List<GCM_Update_Record.ResponseWrapper>();
            
            if(!objList.isEmpty()){
                Id recordId = null;
                for(Object ob : objList) {
                    reqMap = (Map<String, Object>)ob; 
                    recordId = (Id) reqMap.get('recordId');
                    system.debug('RecordId**'+recordId);
                    Map<String, Object> fieldValuesMap = new Map<String, Object>();
                    fieldValuesMap = (Map<String, Object>)reqMap.get('fieldNamesandValues');
                    system.debug('fieldValuesMap**'+fieldValuesMap );
                    map<string,string> newMap= new Map<string,string>();
                    for(String strKey: fieldValuesMap.keyset()){
                        newMap.put(strKey, String.valueof(fieldValuesMap.get(strKey)));
                    } 
                    if(!newMap.isEmpty()){
                        system.debug('newMAp***'+newMap);
                        updateCaseMap.put(recordId, newMap);
                        system.debug('updateCaseMap***'+updateCaseMap);
                    }
                }
                system.debug('updateCaseMap***'+updateCaseMap);
                reswpList = GCM_Update_Record.updateRecords(updateCaseMap, false);
               
                if(!reswpList.isEmpty()){
                    system.debug('Inside Resp list'+reswpList);
                    for(GCM_Update_Record.ResponseWrapper reswp : reswpList){
                        if(reswp.isSuccess == true){
                            //Response wrapper - success
                            ResponseWrapper resw = new ResponseWrapper ();
                            resw.status = reswp.message;
                            resw.statusCode = '200';
                            resw.recordId = reswp.recId;
                            responseWrapperList.add(resw);
                        } else {
                            //Response wrapper - Exception in record update
                            ResponseWrapper resw = new ResponseWrapper ();
                            resw.status = reswp.message;
                            resw.statusCode = '500';
                            resw.recordId = recordId;
                            responseWrapperList.add(resw);
                        } 
                        system.debug('responseWrapperList***'+responseWrapperList);
                    }
                } else {
                    for(Id recId : updateCaseMap.keyset()){
                        ResponseWrapper resw = new ResponseWrapper ();
                        resw.status = 'Error: Update failed';
                        resw.statusCode = '500';
                        resw.recordId = recId;
                        responseWrapperList.add(resw);
                    }
                }
            } else {
                ResponseWrapper resw = new ResponseWrapper ();
                resw.status = 'No Request parameters found';
                resw.statusCode = '404';
                resw.recordId = null;
                responseWrapperList.add(resw);
            }
        }catch (Exception e) {
            ResponseWrapper resw = new ResponseWrapper ();
            resw.status = e.getMessage();
            resw.statusCode = '500';
            resw.recordId = null;
            responseWrapperList.add(resw);
            system.debug('Exception###'+e);
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_Update_Record_API', 'doPost', new Id[]{}, 'GCM_Application_Administrator');
        }
        system.debug('responseWrapperList***'+responseWrapperList);
        return responseWrapperList;
        
    }
    
    
/****************************************************************************************************
Response wrapper class.
****************************************************************************************************/     
    global class ResponseWrapper {
        public String status;
        public String statusCode;
        public String recordId;
/****************************************************************************************************
* ResponseWrapper Constructor
****************************************************************************************************/
        public ResponseWrapper(){}
    }
    
/****************************************************************************************************
Response wrapper class.
****************************************************************************************************/  
    global class RequestWrapper {
        public String source;
        public String requestParams;
/****************************************************************************************************
* RequestWrapper Constructor
****************************************************************************************************/
        public RequestWrapper(){}
    }
}

/********************************************************************************
Sample Request :
 {
    "source": "VOC Bot",
    "requestParams": [
        {
            "recordId":"5007E000009e6ZRQAY",
            "fieldNamesandValues": {
                            "Type" : "Invoice Management",
                            "Area__c" : "Manual & Misc Requests",
                            "Sub_Area__c" : "Misc Credit / Debit",
                            "Status" : "Closed",
                            "Sub_Status__c" : "Completed",
                            "Resolution_Code__c" : "Credit Note Raised",
                            "SR_Resolutions__c" : "C0XXX/s0xxx",
                            "GCM_ByPassValidation_Timestamp__c" : "2020-03-26 08:15:33",
                            "GCM_EmailToAddress__c" : "roselin.hephzibah@bp.com"
                          }
        },
        {
            "recordId":"5007E000009drIxQAI",
            "fieldNamesandValues": {
                            "Type" : "Invoice Management",
                            "Area__c" : "Manual & Misc Requests",
                            "Sub_Area__c" : "Misc Credit / Debit",
                            "Status" : "Closed",
                            "Sub_Status__c" : "Completed",
                            "Resolution_Code__c" : "Credit Note Raised",
                            "SR_Resolutions__c" : "C0XXX/s0xxx",
                            "GCM_ByPassValidation_Timestamp__c" : "2020-03-26 08:15:33",
                            "GCM_EmailToAddress__c" : "roselin.hephzibah@bp.com"
                          }
        },
        {
            "recordId":"5007E000009drIxQAI",
            "fieldNamesandValues": {
                            "OwnerId" : "00G7E0000051xPN"
                          }
        }
        ]  
}
 
 Sample Response :
[
    {
        "statusCode": "200",
        "status": "Successfull",
        "recordId": "5007E000008xoDYQAY"
    },
    {
        "statusCode": "200",
        "status": "Successfull",
        "recordId": "5007E000008zvRrQAI"
    }
]

********************************************************************************/