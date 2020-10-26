/**
*___________________________________________________
*@Name:     CDM_GetValidate_Approvers_ZNCRFromDoFA
*@Author:   Chandra Kanchi
*@Created:  Jan 01, 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: get validate Authorisation type for sales doc is ZNCR.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_GetValidate_Approvers_ZNCRFromDoFA {

  /**
    *————————————————————————————————————————————————————
    * @Description
    * get validate Authorisation type for sales doc is ZNCR and Inovice Reference value.
                                                       
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static string dofaRes = '{  "listDelegates": {    "Delegates": {      "FirstName": "Tronje",      "LastName": "Schneider-Pungs",      "EmployeeNumber": "",      "NTLoginForDelegate": "BP1\\SCTN0Q",      "GPID": "HH99IT59",      "EmailAddressForDelegate": "tronje.schneider-pungs@de.bp.com",      "Country": "Germany",      "Currency": "EUR",      "SegmentName": "Downstream",      "Delegations": [        {          "Organisation": "Downstream",          "DelegatorName": "Rigas, Thanasis",          "NTLoginForDelegator": "BP1\\RIGASA",          "GPIDForDelegator": "DQ49GN02",          "AuthorisationType": "IN",          "AuthorisationName": "Requisition",          "USDAmount": "50000",          "ApprovalAmount": "41500",          "AuthorityAmount": [            {              "SAPCompanyCode": "",              "SAPUSDAmount": "",              "SAPApprovalAmount": ""            }          ],          "UnlimitedAmount": "",          "Currency": "EUR",          "LastChangedDate": "10112014",          "SupportingNotes": ""        }      ]    }  }}';
     @AuraEnabled
    // public static CDM_StaticUtils.ValidApproverRes getValidateAuthType(String authType, decimal amount,String ntId,String cuy) {
     @future(callout=true)
     public static void getValidateAuthType(List<Id> RecIds) {
        
        List<CDM_Credit_Debit_Note__c> cdnUpdate = new List<CDM_Credit_Debit_Note__c>();
        List<CDM_Credit_Debit_Note__c> cdnRec = [SELECT id,CDM_Invoice_Number__c,CurrencyIsoCode,CDM_Approver__r.CDM_Approver_User__r.ntid__c,CDM_Net_Amount__c FROM CDM_Credit_Debit_Note__c WHERE Id=:recIds ];
        for(CDM_Credit_Debit_Note__c c: cdnRec) {
        if((c.CDM_Invoice_Number__c == null || c.CDM_Invoice_Number__c == '') && 
            c.CDM_Approver__r.CDM_Approver_User__r.ntid__c != null) {
        String authType = 'SG';
        String ntId  = c.CDM_Approver__r.CDM_Approver_User__r.ntid__c;       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.CDM_Dofa_Api_Url+ntId.toUpperCase() + '?authorisationType='+authType);
        request.setMethod('GET');
        request.setHeader('client_id', Label.CDM_Dofa_ClientId);
        request.setHeader('client_secret', Label.CDM_Dofa_ClientSecret);
        request.setHeader(Label.CDM_Authorization, Label.CDM_Bearer+' ' +CDM_StaticUtils.getDofaApiAccessToken());
        
       String res;
       CDM_StaticUtils.listDofaUser dofaApprovers;
       try {
       if(!test.isrunningtest()) {
            HttpResponse response = http.send(request);
            res = response.getBody();
            system.debug(response.getBody());
        } else {
           res = dofaRes;
        }
       
     
       dofaApprovers = (CDM_StaticUtils.listDofaUser) JSON.deserialize(res.replace('\\',''),CDM_StaticUtils.listDofaUser.class);
         } catch(exception e) {
                   
            c.CDM_Authorisation_Type__c = 'IP';
         
        }
            if(dofaApprovers != null) {
             if(dofaApprovers.listDelegates!=null) {
                                                                                                                                                                                      
                 if(dofaApprovers.listDelegates.Delegates!=null) {
                     c.CDM_Authorisation_Type__c = 'SG';
                 } else
                     c.CDM_Authorisation_Type__c = 'IP';
                    
                                
                                                                                                                 
                          
                                                                                                           
            
              } else
                   c.CDM_Authorisation_Type__c = 'IP';
            } else
                 c.CDM_Authorisation_Type__c = 'IP';
    
      } else
           c.CDM_Authorisation_Type__c = 'IP';
     cdnUpdate.add(c);
     } 
   
     update cdnUpdate;
   } 
                              
                                                                   
                                                                                
   
    
                                
                                                                    
                                                                                
   
    }