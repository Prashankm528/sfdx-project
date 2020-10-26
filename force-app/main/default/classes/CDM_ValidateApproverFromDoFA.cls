/**
*___________________________________________________
*@Name:     CDM_ValidateApproverFromDoFA
*@Author:   Chandra Kanchi
*@Created:  Nov 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get dofa user aand validate approvers.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_ValidateApproverFromDoFA {

  /**
    *————————————————————————————————————————————————————
    * @Description
    * get valid approvers based on country,countrycode and request type.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static string dofaRes = '{  "listDelegates": {    "Delegates": {      "FirstName": "Tronje",      "LastName": "Schneider-Pungs",      "EmployeeNumber": "",      "NTLoginForDelegate": "BP1\\SCTN0Q",      "GPID": "HH99IT59",      "EmailAddressForDelegate": "tronje.schneider-pungs@de.bp.com",      "Country": "Germany",      "Currency": "EUR",      "SegmentName": "Downstream",      "Delegations": [        {          "Organisation": "Downstream",          "DelegatorName": "Rigas, Thanasis",          "NTLoginForDelegator": "BP1\\RIGASA",          "GPIDForDelegator": "DQ49GN02",          "AuthorisationType": "IN",          "AuthorisationName": "Requisition",          "USDAmount": "50000",          "ApprovalAmount": "41500",          "AuthorityAmount": [            {              "SAPCompanyCode": "",              "SAPUSDAmount": "",              "SAPApprovalAmount": ""            }          ],          "UnlimitedAmount": "",          "Currency": "EUR",          "LastChangedDate": "10112014",          "SupportingNotes": ""        }      ]    }  }}';
     @AuraEnabled
     public static CDM_StaticUtils.ValidApproverRes getValidateApprover(String authType, decimal amount,String ntId,String cuy) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.CDM_Dofa_Api_Url+ntId.toUpperCase() + '?authorisationType='+authType);
        request.setMethod('GET');
        request.setHeader('client_id', Label.CDM_Dofa_ClientId);
        request.setHeader('client_secret', Label.CDM_Dofa_ClientSecret);
        request.setHeader(Label.CDM_Authorization, Label.CDM_Bearer+' ' +CDM_StaticUtils.getDofaApiAccessToken());
        
       String res;
       if(!test.isrunningtest()) {
            HttpResponse response = http.send(request);
            res = response.getBody();
            system.debug(response.getBody());
        } else {
           res = dofaRes;
        }
       system.debug(amount);
       system.debug(cuy);
       decimal ratecurrency = CDM_StaticUtils.getCurrencyRateValue(cuy,'USD');
       system.debug(ratecurrency);
        decimal usdAmount = amount * ratecurrency;
        system.debug(usdAmount);
      system.debug(res.replace('\\',''));
        res = res.replace('Currency','Currency1');
        CDM_StaticUtils.listDofaUser dofaApprovers = (CDM_StaticUtils.listDofaUser) JSON.deserialize(res.replace('\\',''),CDM_StaticUtils.listDofaUser.class);
            if(dofaApprovers !=null) {
                if(dofaApprovers.listDelegates != null) {
                   if(dofaApprovers.listDelegates.Delegates != null) {
                   getApprovalAmount am = getMaximumApprovalAmount(dofaApprovers.listDelegates.Delegates.Delegations);
                   system.debug(am);
                   String Currency1 = am.rCurrency;
                    Decimal approvalAmount = am.approvalAmount;
                    Decimal usdApprovalAmount = am.usdApprovalAmount;
                   
                     if(Currency1 == cuy) {
                        if(approvalAmount != null) {
                          
                            if(approvalAmount >= amount) {
                                return validateUserReturn(true,'The record has been submitted for Approval successfully.');
                               
                            } else { 
                                    return getApproveralAmount_SameCurrencty(cuy,amount,approvalAmount,authType,dofaApprovers.listDelegates.Delegates.FirstName+ ' ' +dofaApprovers.listDelegates.Delegates.LastName);
                                   
                                }//'Please Select Valid Approver.'); 
                         } 
                     } else {
                            if(usdApprovalAmount != null) {
                           
                                if(usdApprovalAmount >= usdAmount) {
                                    return validateUserReturn(true,'The record has been submitted for Approval successfully.');
                                   
                                } else { 
                                    return getApproveralAmount_DifferentCurrencty(cuy,Currency1,amount, usdApprovalAmount ,authType,dofaApprovers.listDelegates.Delegates.FirstName+ ' ' +dofaApprovers.listDelegates.Delegates.LastName,usdAmount);
                                   
                                    }
                               
                            } else { return validateUserReturn(false,'There is an issue in Dofa Approvers Data.');}
                        }
                     } else { return validateUserReturn(false,'Please Select Valid Approver'); }   
              } else { return validateUserReturn(false,'Please Select Valid Approver'); }
             
           } else { return validateUserReturn(false,'There is an issue in Dofa Api.');}
     
      return validateUserReturn(false,'There is an issue in Dofa Api.');
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
      
        /**
    *————————————————————————————————————————————————————
    * @Description
    * generate return type response for in valid approver.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
       public static CDM_StaticUtils.ValidApproverRes getApproveralAmount_SameCurrencty(String Curency,Decimal reqAmount,Decimal ApprovalAmount,String AuthType,String approver) {
       
       String res = 'The DOFA system reports that '+ approver +' does not have the \n delegate authority for the amount requested\n';
       reqAmount = reqAmount.round(System.RoundingMode.CEILING);
       ApprovalAmount = ApprovalAmount.round(System.RoundingMode.CEILING);    
       res = res +' Requested amount in '+ Curency + ': '+ formatCurr(reqAmount) + '\n';
       res = res +' Authorised amount in '+ Curency + ': '+ formatCurr(ApprovalAmount) + '\n';
       res = res +' Authority Type Required: '+ AuthType + ' - '+ getAuthorityType(AuthType) + '\n';
       
       return validateUserReturn(false,res);
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
       public static CDM_StaticUtils.ValidApproverRes getApproveralAmount_DifferentCurrencty(String resCurency,String approvalCurency,Decimal reqAmount,Decimal authUSDAmount,String AuthType,String approver,Decimal reqUSDAmount) {
           String res = 'The DOFA system reports that '+ approver +' does not have the \n delegate authority for the amount requested.\n\n';
           reqAmount = reqAmount.round(System.RoundingMode.CEILING);
           reqUSDAmount = reqUSDAmount.round(System.RoundingMode.CEILING);
           authUSDAmount = authUSDAmount.round(System.RoundingMode.CEILING);
           res = res +' Requested amount in '+ resCurency +': '+ formatCurr(reqAmount) + '\n';
           if(resCurency != 'USD')
           res = res +' Requested amount in USD: '+ formatCurr(reqUSDAmount) + '\n';
           res = res +' Authorised amount in USD: '+ formatCurr(authUSDAmount) + '\n';
           res = res +'\n Authority Type Required: '+ AuthType + ' - '+ getAuthorityType(AuthType) + '\n';
           
           return validateUserReturn(false,res);
      }
        /**
    *————————————————————————————————————————————————————
    * @Description
    * get proper number type with separators.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
     public static string formatCurr(Decimal damount) {
        string regex = '(\\d)(?=(\\d{3})+(?!\\d))';
        Pattern objPt = Pattern.compile('(\\d)(?=(\\d{3})+(?!\\d))');
        Matcher regMatcher = objPt.matcher(String.valueOf(damount));
        String formattedCur;
        if(regMatcher.find()) {
            formattedCur = String.valueOf(damount).replaceAll(regex, '$1,');
        }
        return formattedCur;

     }
     
     /**
    *————————————————————————————————————————————————————
    * @Description
    * get valid authorsation type description.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/  
     public static string getAuthorityType(String authType) {
     system.debug(authType);
     List<CDM_Authority_Types__mdt> aType = [SELECT Authorisation_Name__c FROM CDM_Authority_Types__mdt WHERE Authority_Type__c =: authType];
     if(!aType.isEmpty())
         return aType[0].Authorisation_Name__c;
     //  system.debug(aType[0].Authorisation_Name__c);  
     
     return '';
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
     public static getApprovalAmount getMaximumApprovalAmount(List<CDM_StaticUtils.Delegations> duser) {
          getApprovalAmount am = new getApprovalAmount();
          am.usdApprovalAmount = 0; 
          am.approvalAmount = 0; 
          for(CDM_StaticUtils.Delegations du: duser) {
              if(am.usdApprovalAmount <= Decimal.valueOf(du.USDAmount)) {
                  am.usdApprovalAmount = Decimal.valueOf(du.USDAmount);
                  am.approvalAmount = Decimal.valueOf(du.ApprovalAmount);
                  am.rCurrency = du.Currency1;
               }   
            
                      
          }
      return am;
     } 
   
   public class getApprovalAmount {
       public String rCurrency{get;set;}
       public Decimal usdApprovalAmount{get;set;}
       public Decimal approvalAmount{get;set;}
       public String Name{get;set;}
   
   }
    
     
    }