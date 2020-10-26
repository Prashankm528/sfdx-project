/**
*___________________________________________________
*@Name:     CDM_EformStatusUpdate
*@Author:   Chandra Kanchi
*@Created:  July 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get update cdm eform status field from RPA system.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@RestResource(urlMapping='/CDMEformStatus/*')
global with sharing class CDM_EformStatusUpdate {

       /**
    *————————————————————————————————————————————————————
    * @Description
    * get update from RPA system.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    @HttpPost
    global static String cdmStatusUpdate() {
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String resBody = RestContext.request.requestBody.toString();
    
    List<CDM_StaticUtils.CDMEformsStatusUpdate> cdmeformList = (List<CDM_StaticUtils.CDMEformsStatusUpdate>)JSON.deserialize(
       resBody, List<CDM_StaticUtils.CDMEformsStatusUpdate>.class);
    
    List<CDM_Credit_Debit_Note__c> cdmUpdateList = new List<CDM_Credit_Debit_Note__c>();
    
    for(CDM_StaticUtils.CDMEformsStatusUpdate cdmRec : cdmeformList) 
        if(cdmRec.RecordId != null) {
           cdmUpdateList.add(new CDM_Credit_Debit_Note__c(id = cdmRec.RecordId, CDM_FI_Document_number__c = cdmRec.FIDocumentNumber,
                                                           CDM_FI_Document_Date__c = cdmRec.FIDocumentDate,CDM_Processing_Error__c = cdmRec.ProcessingError));   
    
    
        } 
    
     update  cdmUpdateList;  
     return 'Success';
    }

    
    
}