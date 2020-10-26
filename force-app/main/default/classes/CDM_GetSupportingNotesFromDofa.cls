/**
*___________________________________________________
*@Name:     CDM_GetSupportingNotesFromDofa
*@Author:   Chandra Kanchi
*@Created:  Mar 01, 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: get CDM_GetSupportingNotesFromDofa.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_GetSupportingNotesFromDofa {

  /**
    *————————————————————————————————————————————————————
    * @Description
    * GEt supporting notes from DOFA.
                                                       
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static string dofaRes = '{   "listDelegates": {      "Delegates": { "Delegations": [{ "AuthorisationType": "IN","AuthorisationName": "Requisition","USDAmount": "50000","ApprovalAmount": "41500","SupportingNotes": "" }]}}}';
  
      public static Map<String,resWrapper> resWMap = new Map<String,resWrapper>();
      @AuraEnabled
      public static CDM_StaticUtils.ValidApproverRes getCDM_GetSupportingNotes(CDM_Credit_Debit_Note__c cdnRec, String comments) {
       
            List<CDM_Credit_Debit_Note__c> cdnUpdate = new List<CDM_Credit_Debit_Note__c>();
            CDM_StaticUtils.ValidApproverRes rWrp = new CDM_StaticUtils.ValidApproverRes();
            String accessToken = CDM_StaticUtils.getDofaApiAccessToken();
          
                String ntId = cdnRec.CDM_Approver__r.CDM_Approver_User__r.ntid__c;
                if(String.isNotBlank(ntId)) {
                    if(cdnRec.CDM_Request_Type__c == CDM_UtilConst.Credit_Note) {
                        getSupportingNotes(CDM_UtilConst.RC, ntId, accessToken);
                        getSupportingNotes(CDM_UtilConst.SD, ntId, accessToken);
                    }
                    if(cdnRec.CDM_Request_Type__c == 'Debit_Note')
                        getSupportingNotes('SG', ntId, accessToken);
                } else {
                     rWrp.status = false;
                     rWrp.statusRes = 'Check Approver NTID';
                }
                system.debug('resWMap' + resWMap);
             if(resWMap != null)   
                 if(!resWMap.isEmpty()) {
                     decimal amount = cdnrec.CDM_Split_Required__c == 'Yes' && cdnrec.CDM_Total_Sub_Gross_Amount__c!= null? cdnrec.CDM_Total_Sub_Gross_Amount__c :cdnrec.CDM_Gross_Amount__c;
                     if(cdnRec.CDM_Request_Type__c == 'Credit_Note') {
                        
                              resWrapper rw = resWMap.get('RC');
                              resWrapper rw1 = resWMap.get('SD');
                              system.debug(rw1);
                              system.debug(rw);
                              if((rw.InvalidApprover == true && rw1.InvalidApprover ==  true)) {
                                  system.debug(rw);
                                  rWrp.status = false;
                                  decimal ratecurrency = CDM_StaticUtils.getCurrencyRateValue(cdnrec.CurrencyIsoCode,'USD');
                                  rWrp.statusRes = getApproveralAmount_DifferentCurrencty(cdnrec.CurrencyIsoCode,'USD', amount,0.0,cdnrec.CDM_ApproverName__c, amount * ratecurrency).statusRes;// rWrp.formStatus;
                                  return rWrp;
                              }
                              if(rw.UnlimitedApprover == true || rw1.UnlimitedApprover == true) {
                           
                                  rWrp.status = true;
                                  rWrp.statusRes = 'Request was successfully submitted';
                                  rWrp.formStatus = 'Submitted';
                                  cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                  cdnRec.CDM_Approval_Unlimited_Amount__c = true;
                                  cdnRec.CDM_Requester_Comments__c = comments;
                                  
                              } else { if(rw.AmountLimit != 0 || rw1.AmountLimit != 0) {
                                          decimal aLimit = 0;
                                          if(rw.AmountLimit != 0)
                                              aLimit = rw.AmountLimit;
                                          if(rw1.AmountLimit != 0)
                                              aLimit = rw1.AmountLimit;     
                                          if(amount<=aLimit) {
                                              rWrp.status = true;
                                              rWrp.statusRes = 'Request was successfully submitted';
                                              rWrp.formStatus = 'Submitted';
                                              cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                              cdnRec.CDM_Approval_Unlimited_Amount__c = true;
                                              cdnRec.CDM_Requester_Comments__c = comments;
                                          } else {
                                                  rWrp.status = false;
                                                  system.debug(aLimit);
                                                  decimal ratecurrency = CDM_StaticUtils.getCurrencyRateValue(cdnrec.CurrencyIsoCode,'USD');
                                                  rWrp.statusRes = getApproveralAmount_DifferentCurrencty(cdnrec.CurrencyIsoCode,'USD', amount,aLimit,cdnrec.CDM_ApproverName__c, amount * ratecurrency).statusRes;// rWrp.formStatus;
                                                 // return rWrp;
                                              }
                              
                                         } else {
                                
                                                 if(String.isNotBlank(rw.SupportingNotes) || String.isNotBlank(rw1.SupportingNotes)) {
                                                   
                                                      rWrp.status = true;
                                                      rWrp.statusRes = 'Request was successfully submitted';
                                                      rWrp.formStatus = 'Review';
                                                      cdnRec.CDM_Amount_Limit__c = rw.AmountLimit != 0? rw.AmountLimit : cdnRec.CDM_Amount_Limit__c;
                                                      cdnRec.CDM_Amount_Limit__c = rw1.AmountLimit != 0? rw1.AmountLimit : cdnRec.CDM_Amount_Limit__c;
                                                      cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                                      cdnrec.CDM_Supporting_Notes_SD__c = rw1.SupportingNotes != null && rw1.AuthorisationType =='SD' ? rw1.SupportingNotes : cdnrec.CDM_Supporting_Notes_SD__c;
                                                      cdnrec.CDM_Supporting_Notes_RC__c = rw.SupportingNotes != null && rw.AuthorisationType =='RC' ? rw.SupportingNotes : cdnrec.CDM_Supporting_Notes_RC__c;
                                                      cdnRec.CDM_Requester_Comments__c = comments;
                                                      return rWrp;
                                                    
                                                  }
                                              }    
                                   }   
                         }     
                    
                       if(cdnRec.CDM_Request_Type__c == 'Debit_Note') {
                        
                              resWrapper rw = resWMap.get('SG');
                             
                              if((rw.InvalidApprover == true)) {
                                  rWrp.status = false;
                                   decimal ratecurrency = CDM_StaticUtils.getCurrencyRateValue(cdnrec.CurrencyIsoCode,'USD');
                                  rWrp.statusRes = getApproveralAmount_DifferentCurrencty(cdnrec.CurrencyIsoCode,'USD', amount,0.0,cdnrec.CDM_ApproverName__c, amount * ratecurrency).statusRes;// rWrp.formStatus;
                                  //rWrp.statusRes = rWrp.formStatus;
                                  return rWrp;
                              }
                              if(rw.UnlimitedApprover == true) {
                                    rWrp.status = true;
                                  rWrp.statusRes = 'Request was successfully submitted';
                                  rWrp.formStatus = 'Submitted';
                                  cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                  cdnRec.CDM_Approval_Unlimited_Amount__c = true;
                                  cdnRec.CDM_Requester_Comments__c = comments;
                                  
                              } else {
                                      if(rw.AmountLimit != 0) {
                                          decimal aLimit = 0;
                                          if(rw.AmountLimit != 0)
                                              aLimit = rw.AmountLimit;
                               
                                          if(amount<=aLimit) {
                                              rWrp.status = true;
                                              rWrp.statusRes = 'Request was successfully submitted';
                                              rWrp.formStatus = 'Submitted';
                                              cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                              cdnRec.CDM_Approval_Unlimited_Amount__c = true;
                                              cdnRec.CDM_Requester_Comments__c = comments;
                                           } else {
                                                  rWrp.status = false;
                                                  decimal ratecurrency = CDM_StaticUtils.getCurrencyRateValue(cdnrec.CurrencyIsoCode,'USD');
                                                  rWrp.statusRes = getApproveralAmount_DifferentCurrencty(cdnrec.CurrencyIsoCode,'USD', amount,aLimit,cdnrec.CDM_ApproverName__c, amount * ratecurrency).statusRes;// rWrp.formStatus;
                                                 // return rWrp;
                                              }
                                      } else {      
                                
                                               if(String.isNotBlank(rw.SupportingNotes) || rw.AmountLimit != 0) {
                                                      rWrp.status = true;
                                                      rWrp.statusRes = 'Request was successfully submitted';
                                                      rWrp.formStatus = 'Review';
                                                    
                                                      cdnRec.CDM_Amount_Limit__c = rw.AmountLimit != 0? rw.AmountLimit : cdnRec.CDM_Amount_Limit__c;
                                                      cdnrec.CDM_Supporting_Notes_SG__c = rw.SupportingNotes != null && rw.AuthorisationType =='SG' ? rw.SupportingNotes : cdnrec.CDM_Supporting_Notes_SG__c;
                                                      cdnRec.CDM_Form_Status__c = rWrp.formStatus;
                                                      cdnRec.CDM_Requester_Comments__c = comments;
                                                      return rWrp;
                                                 
                                              }
                                          } 
                                   }          
                          }
                        cdnRec.CDM_Requester_Comments__c = comments;
                       update cdnRec;
                    if(rWrp.formStatus == 'Submitted') {    
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();          
                        req1.setComments(comments);
                        req1.setObjectId(cdnRec.id);
                        req1.setNextApproverIds(new String[]{cdnRec.CDM_Approver__r.CDM_Approver_User__r.Id});
                        cdnRec.CDM_Requester_Comments__c = comments;
                        Approval.ProcessResult result1 = Approval.process(req1);  
                    }  
                 }
            return rWrp;
         }   
    
   
    public static String getSupportingNotes(String authType,String ntId, String accessToken) {
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.CDM_Dofa_Api_Url+ntId.toUpperCase() + '?authorisationType='+authType);
        request.setMethod('GET');
        request.setHeader('client_id', Label.CDM_Dofa_ClientId);
        request.setHeader('client_secret', Label.CDM_Dofa_ClientSecret);
        request.setHeader(Label.CDM_Authorization, Label.CDM_Bearer+' ' +accessToken);
        
       String res;
       CDM_StaticUtils.listDofaUser dofaApprovers;
       try {
           if(!test.isrunningtest()) {
                HttpResponse response = http.send(request);
                res = response.getBody();
                system.debug(response.getBody());
            } else { res = dofaRes;   }
           
         
           dofaApprovers = (CDM_StaticUtils.listDofaUser) JSON.deserialize(res.replace('\\',''),CDM_StaticUtils.listDofaUser.class);
        } catch(exception e) {  return ''; }
         resWrapper rWr = new resWrapper();
         rWr.AuthorisationType = authType;
         rWr.AmountLimit = 0;
            if(dofaApprovers != null) { 
                if(dofaApprovers.listDelegates!=null) {
                    if(dofaApprovers.listDelegates.Delegates!=null) {
                        if(dofaApprovers.listDelegates.Delegates.Delegations!=null) {
                            Decimal sumAmount = 0;
                            String appendSupNotes = '';
                            
                            if(dofaApprovers.listDelegates.Delegates.Delegations.size() > 1) {
                                rWr.AmountLimit = getMaximumApprovalAmount(dofaApprovers.listDelegates.Delegates.Delegations);
                                rWr.SupportingNotes = getAppeningSupporting(dofaApprovers.listDelegates.Delegates.Delegations);
                            
                            } else {    
                        
                                    for(CDM_StaticUtils.Delegations d : dofaApprovers.listDelegates.Delegates.Delegations) {
                                       
                                    
                                       if(String.isNotBlank(d.SupportingNotes)) {
                                           rWr.SupportingNotes = d.SupportingNotes;
                                       } else {
                                           if(String.isNotBlank(d.USDAmount)) {
                                               if(d.USDAmount != '0')  
                                                   rWr.AmountLimit = integer.valueOf(d.USDAmount);
                                               else rWr.UnlimitedApprover = true;
                                           } else rWr.UnlimitedApprover = true;
                                           
                                         }        
                                     }
                              }   
                                 
                          } else rWr.InvalidApprover = true;      
                     } else rWr.InvalidApprover = true;         
                 } else rWr.InvalidApprover = true;             
            } else rWr.InvalidApprover = true;
                resWMap.put(authType,rWr);
            return 'Success';       
     }  
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * get hieghest amount for approver when no of deligations are there.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
     public static Decimal getMaximumApprovalAmount(List<CDM_StaticUtils.Delegations> duser) {
          decimal usdApprovalAmount = 0; 
          for(CDM_StaticUtils.Delegations du: duser)
              if(usdApprovalAmount <= Decimal.valueOf(du.USDAmount)) 
                  usdApprovalAmount = Decimal.valueOf(du.USDAmount);
            
      return usdApprovalAmount;
     } 
     
      /**
    *————————————————————————————————————————————————————
    * @Description
    * get appending supporting notes.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
     public static String getAppeningSupporting(List<CDM_StaticUtils.Delegations> duser) {
          String sNotes = ''; 
          for(CDM_StaticUtils.Delegations d: duser) {
              if(String.isNotBlank(d.SupportingNotes)) 
                  sNotes = sNotes + d.SupportingNotes;
          }  
      return sNotes;
     } 
   
    
      /**
    *————————————————————————————————————————————————————
    * @Description
    * generate return type response for in valid approver.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/   
       public static CDM_StaticUtils.ValidApproverRes getApproveralAmount_DifferentCurrencty(String reqCurency,String approvalCurency,Decimal reqAmount,Decimal authUSDAmount,String approver,Decimal reqUSDAmount) {
            String res = + approver +' does not have the appropriate level of delegation in DofA to approve this Credit/Debit request. \n Please select different approver or alternatively contact DofA controller to review amount and/or supporting notes for your current selection. \n For CDN tool support please refer to MyIT support tickets';
                    
           return validateUserReturn(false,res);
      } 
      
     /**
    *————————————————————————————————————————————————————
    * @Description
    * generate return type response.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
     public static CDM_StaticUtils.ValidApproverRes validateUserReturn(Boolean status,String res) {
        CDM_StaticUtils.ValidApproverRes vUserRes = new CDM_StaticUtils.ValidApproverRes(); 
        vUserRes.status = Status;
        vUserRes.statusRes = res;
        return vUserRes;
      
      }   
           
   public class resWrapper {
       public Decimal AmountLimit{get;set;}
       public boolean UnlimitedApprover{get;set;}
       public boolean InvalidApprover{get;set;}
       public String SupportingNotes {get;set;}
       public String AuthorisationType{get;set;}
     
   
   }        
       }