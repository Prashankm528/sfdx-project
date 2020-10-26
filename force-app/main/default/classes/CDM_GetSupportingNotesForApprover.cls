/**
*___________________________________________________
*@Name:     CDM_GetSupportingNotesForApprover
*@Author:   Chandra Kanchi
*@Created:  Mar 01, 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: get CDM_GetSupportingNotesForApprover when select approver in record edit or new.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_GetSupportingNotesForApprover {

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
  
      @AuraEnabled
      public static CDM_StaticUtils.CDMSuportingNote getCDM_GetSupportingNotes(String ntId , String requestType) {
       
           CDM_StaticUtils.CDMSuportingNote sNote = new CDM_StaticUtils.CDMSuportingNote();
            String accessToken = CDM_StaticUtils.getDofaApiAccessToken();
              
                if(String.isNotBlank(ntId)) {
                    if(requestType == CDM_UtilConst.CreditNote) {
                        sNote.SupportingNotes_RC = getSupportingNotes(CDM_UtilConst.RC, ntId, accessToken);
                        sNote.SupportingNotes_SD = getSupportingNotes(CDM_UtilConst.SD, ntId, accessToken);
                    }
                    if(requestType == CDM_UtilConst.DebitNote)
                        sNote.SupportingNotes_SD = getSupportingNotes('SG', ntId, accessToken);
                } 
               
         return  sNote; 
    }
   
    public static String getSupportingNotes(String authType,String ntId, String accessToken) {
        String supNotes = '';
        String res = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.CDM_Dofa_Api_Url+ntId.toUpperCase() + '?authorisationType='+authType);
        request.setMethod('GET');
        request.setHeader('client_id', Label.CDM_Dofa_ClientId);
        request.setHeader('client_secret', Label.CDM_Dofa_ClientSecret);
        request.setHeader(Label.CDM_Authorization, Label.CDM_Bearer+' ' +accessToken);
        CDM_StaticUtils.listDofaUser dofaApprovers;
       try {
           if(!test.isrunningtest()) {
                HttpResponse response = http.send(request);
                res = response.getBody();
                system.debug(response.getBody());
            } else { res = dofaRes;   }
           
           String resStr = res.replace('\\','');
                  
           dofaApprovers = (CDM_StaticUtils.listDofaUser) JSON.deserialize(res.replace('\\',''),CDM_StaticUtils.listDofaUser.class);
        } catch(exception e) {  return ''; }
       
            if(dofaApprovers != null) { 
                if(dofaApprovers.listDelegates!=null) {
                    if(dofaApprovers.listDelegates.Delegates!=null) {
                        if(dofaApprovers.listDelegates.Delegates.Delegations!=null) {
                            for(CDM_StaticUtils.Delegations d : dofaApprovers.listDelegates.Delegates.Delegations)
                                if(d.AuthorisationType == authType) { 
                                   if(d.AuthorisationType == authType) {
                                   
                                       if(String.isNotBlank(d.SupportingNotes))
                                           supNotes = supNotes + d.SupportingNotes;
                                           
                                    }
                                 }
                          }       
                     }         
                 }             
            } 
               
            return supNotes;       
     }  
    
          
       }