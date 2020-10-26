/**
*___________________________________________________
*@Name:     CDM_StaticUtils
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for Static Utils Class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class CDM_StaticUtils {


 /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields meta data.
    *————————————————————————————————————————————————————
   
    **/ 
 public with sharing class fieldsMetaData {
        @AuraEnabled
        public List<CDM_C_D_Note_Eform_Template__c> cdnFormTemplate{get;set;}
        @AuraEnabled
        public List<SObject> cdnFormSalesDocType{get;set;}
        @AuraEnabled
        public SObject material{get;set;}
        @AuraEnabled
        public Map<String,List<String>> cdnFormTaxEndUse{get;set;}
        @AuraEnabled
        public Map<String,List<String>> recPicklistMap{get;set;}
        @AuraEnabled
        public Map<String,String> recordTypeMap{get;set;}
        @AuraEnabled
        public Map<String,Map<String,List<String>>> depPicklistMap {get;set;}
        @AuraEnabled
        public Map<String,List<CDM_C_D_Note_Eform_FieldRule__c>> fieldRule{get;set;}
        @AuraEnabled
        public List<CDM_Split_Amount__c> splitAmountRecs{get;set;}
        @AuraEnabled
        public Map<String,List<String>> taxCodes{get;set;}
        @AuraEnabled
        public Map<String,List<String>> payMethods{get;set;}
        @AuraEnabled
        public Boolean recordEditAccess{get;set;}
        
     
    }
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform save data from lightning component.
    *————————————————————————————————————————————————————
   
    **/ 
    
    public with sharing class datawrap {
        public Map<String,String> recDataMap{get;set;}
        public String recordId{get;set;}
        public String splitAmountRecs{get;set;}
        public String btnName{get;set;}
        
    
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  get picklists fields meta for display in lighitng component.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static Map <String, Schema.SObjectType> cdmSchema = Schema.getGlobalDescribe();
    public static List<String> getPicklistValues(String ObjectApiName, String FieldName) {
        try {
            List<String> lstPickVals = new List<String>();
            Schema.SObjectType targetType = cdmSchema.get(ObjectApiName);                                //From the Object Api name retrieving the SObject
            Sobject objectName = targetType.newSObject();
            Schema.sObjectType sobjectType = objectName.getSObjectType();                                                //grab the sobject that was passed
            Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();                                   //describe the sobject
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();                               //get a map of fields for the passed sobject
            List<Schema.PickListEntry> pickListValLst = fieldMap.get(FieldName).getDescribe().getPickListValues();    //grab the List of pickList values for the passed field on the sobject
            for (Schema.PickListEntry a : pickListValLst) {                                                           //for all values in the pickList List
                lstPickVals.add(a.getValue());                                                                       //add the value  to our final List
            }

            return lstPickVals;
        }
        catch(Exception ex) {
            return new List<String>();
        }
    }    
    
      /**
    *————————————————————————————————————————————————————
    * @Name: dynamicQuery
    * @Description :  This method will be used for generate the dynamic query for dynamic record Id
    * Returns Sobject -- Object
    *  
    
    *————————————————————————————————————————————————————
    **/   
    
    public static Sobject dynamicQuery(String recId, String whereClause) {
        try {
            Map <String, Schema.SObjectType> schemaMap = cdmSchema;
            String sObjName;
            if(isValidId(recId)) {
                sObjName = ((Id) recId).getSObjectType().getDescribe().getName();
            } else {
                sObjName = recId;
            }
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
            String query= 'SELECT ';
            query += String.join(new List<String>(fieldMap.keyset()),',');
            query = query.removeend(',');
            
            for(String field: fieldMap.keySet()) {
                if(String.valueOf(fieldMap.get(field).getDescribe().getType())== 'REFERENCE')
                   if(fieldMap.get(field).getDescribe().isCustom()) {
                       String newField=field.replace('__c', '__r') ;
                       newField= newField+'.Name';
                       query += ',' + newField;
                       System.debug(newField);
                   } 
            }
            query = query+ ' FROM '+ sObjName + whereClause;
            system.debug('=-===' + query);
            list <SObject> sObjeList = database.query(query);
            return (!sObjeList.isEmpty()) ? sObjeList[0] : null;        
            
        } catch(Exception exp) { System.debug(exp.getMessage()); return null; } 
        
    }  
     
         /**
    *————————————————————————————————————————————————————
    * @Name: isValidId
    * @Description :  This method will be used for Check Id value is valid or not, if we are received id than return true or else false
    * Returns Sobject -- Boolean
    *  
    
    *————————————————————————————————————————————————————
    **/  
    private static Boolean isValidId(String tempString) {
        ID tempId;
        try {
            tempId = tempString;
            return true;
        }
        catch(Exception ex) { 
            return false;
        }
    }
    
      /**
    *————————————————————————————————————————————————————
    * @Name: isValidId
    * @Description :  This method will be used for get dynamic records using where and order clause
    * Returns : List<Sobject> 
    *  
    
    *————————————————————————————————————————————————————
    **/  
    
     public static List<Sobject> dynamicQueryListType(String sObjName, String whereClause, String orderclause) {
        
         try{
            Map <String, Schema.SObjectType> schemaMap = cdmSchema;
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
            String query='SELECT ';
            query += string.join(new List<String>(fieldMap.keyset()),',');
            query = query.removeend(',');
             for(String field: fieldMap.keySet()) {
                if(String.valueOf(fieldMap.get(field).getDescribe().getType())== 'REFERENCE')
                   if(fieldMap.get(field).getDescribe().isCustom()) {
                       String newField=field.replace('__c', '__r') ;
                       newField= newField+'.Name';
                       query += ',' + newField;
                       System.debug(newField);
                     
                           
                   } else {
                       String newField=field.replace('id', '') ;
                       if(newField.equalsIgnoreCase('CreatedBy')) {
                            query += ',' + newField+'.Email';
                            query += ',' + newField+'.Name';
                            query += ',' + newField+'.Phone';
                        } else            
                           query += ',' + newField+'.Name';
                       
                   }
            }
            
            query = query+ ' FROM '+ sObjName;
            if(whereClause!=null)
            query = query+ whereClause;
            if(orderclause!=null)
                query = query+ orderclause;
            System.debug(query);
            List<SObject> sObjeList = database.query(query);
            return (!sObjeList.isEmpty()) ? sObjeList : null;        
            
         } catch(Exception exp) { System.debug(exp.getMessage()); return null; } 
        
    }  
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  get dynamic list records for sobject.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    
     public static Sobject dynamicQueryType(String sObjName, String whereClause, String orderclause) {
        try {
            Map <String, Schema.SObjectType> schemaMap = cdmSchema;
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
            String query='SELECT ';
            query += string.join(new List<String>(fieldMap.keyset()),',');
            query = query.removeend(',');
            query = query+ ' FROM '+ sObjName;
            if(whereClause!=null)
            query = query+ whereClause;
            if(orderclause!=null)
            query = query+ orderclause;
            SObject sObjeList = database.query(query);
            return  sObjeList;        
            
        } catch(Exception exp) { System.debug(exp.getMessage()); return null; } 
        
    }  
     
     
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  get dynamic currency rates value.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static string currencyRes = '{"rates":{"CAD":1.4679,"HKD":8.6525,"ISK":136.3,"PHP":56.235,"DKK":7.4727,"HUF":334.29,"CZK":25.513,"AUD":1.6287,"RON":4.7741,"SEK":10.6265,"IDR":15575.19,"INR":79.271,"BRL":4.6313,"RUB":70.4361,"HRK":7.4365,"JPY":120.03,"THB":33.39,"CHF":1.0994,"SGD":1.5072,"PLN":4.2977,"BGN":1.9558,"TRY":6.3119,"CNY":7.7834,"NOK":10.1083,"NZD":1.7236,"ZAR":16.2718,"USD":1.1058,"MXN":21.4472,"ILS":3.8332,"GBP":0.8598,"KRW":1303.07,"MYR":4.6123},"base":"AUD","date":"2019-11-22"}';
     public static decimal getCurrencyRateValue(String base, String convertingCur) {
        Http h = new Http();
    
         // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.CDM_Currency_Api+'?base='+base);
        req.setMethod('GET');
        String resCurrecys;
        // Send the request, and return a response
        if(!test.isrunningtest()) {
        HttpResponse res = h.send(req);
        resCurrecys = res.getBody();
        } else {
        
        resCurrecys = currencyRes ;
        }
        if(resCurrecys!=null) {
        system.debug(base);
        system.debug(resCurrecys);
        CurrencyRate cr =  (CurrencyRate)JSON.deserialize(resCurrecys, CurrencyRate.class);
        system.debug(cr);
        if(cr.base.equalsIgnoreCase(base) && convertingCur == 'USD')
            return cr.rates.USD;
        //EUR, AUD;NZD;USD;GBP
        }
       return 1;
        
    }     
     
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields meta data.
    *————————————————————————————————————————————————————
   
    **/
     
      public with sharing class recDataWrap {
      @AuraEnabled
      public String FieldName{get;set;}
      @AuraEnabled
      public String Fieldvalue{get;set;}
      @AuraEnabled
      public String TargetObject{get;set;}
      @AuraEnabled
      public String DataType{get;set;}
      @AuraEnabled
      public String FieldId{get;set;}
      @AuraEnabled
      public String TargetField{get;set;}
      @AuraEnabled
      public String Required{get;set;}
      @AuraEnabled
      public String LookValId{get;set;}
      @AuraEnabled
      public String LookVal{get;set;}
      @AuraEnabled
      public Boolean ReadOnly{get;set;}
      @AuraEnabled
      public String DepDataType{get;set;}
      
             
                        }
                        
                        /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields response meta data.
    *————————————————————————————————————————————————————
   
    **/
    public with sharing class responsewrp {
    @AuraEnabled
    public string success{get;set;}
    @AuraEnabled
    public string error{get;set;}
    @AuraEnabled
    public string formStatus{get;set;}
    
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields meta data.
    *————————————————————————————————————————————————————
   
    **/
public with sharing class CDMEformsStatusUpdate {
    public String FIDocumentDate{ get; set; }
    public String FIDocumentNumber{ get; set; }
    public String ProcessingError{ get; set; }
    public String RecordId{ get; set; }

}    


/**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields meta data and send to RPA.
    *————————————————————————————————————————————————————
   
    **/ 

    
global with sharing class CDMSuportingNote {
@AuraEnabled
public String SupportingNotes_RC{get;set;}
@AuraEnabled
public String SupportingNotes_SD{get;set;}
@AuraEnabled
public String SupportingNotes_SG{get;set;}
public String RecordName{get;set;}
public String RecordId{get;set;}
public Decimal AmountLimit{get;set;}

public String RequestType{get;set;}


}
/**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform fields meta data and send to RPA.
    *————————————————————————————————————————————————————
   
    **/ 

    
public with sharing class CDMEforms {
public String Name{get;set;}
public String Id{get;set;}
public String RequesterName{get;set;}
public datetime CreatedDate{get;set;}
public String ApprovalStatus{get;set;}
public String Approver{get;set;}
public String CompanyCode{get;set;}
public String Country{get;set;}
public String CustomerNumber{get;set;}
public datetime DocumentDate{get;set;}
public String GroupCompany{get;set;}
public String InvoiceNumber{get;set;}
public String ApproverEmail{get;set;}
public datetime BlineDate{get;set;}
public datetime TaxReportDate{get;set;}
public datetime PostingDate{get;set;}    
public datetime OperationDate{get;set;} 
public String Description{get;set;}
public datetime DueDate{get;set;}
public String FIDocumentDate{get;set;}
public String FIDocumentNumber{get;set;}
public decimal GrossAmount{get;set;}
public datetime InvoiceDate{get;set;}
public String Location{get;set;}
public String LocType{get;set;}
public decimal NetAmount{get;set;}
public String PaymentBlock{get;set;}
public String PaymentTerm{get;set;}
public String ProfitCenter{get;set;}
public String RequesterEmail{get;set;}
public string RequesterPhone{get;set;}
public String ProjectCode{get;set;}
public decimal Quantity{get;set;}
public String Remarksifany{get;set;}
public String SignatoryRequired{get;set;}
public String Source{get;set;}
public String SplitRequired{get;set;}
public decimal TaxAmount{get;set;}
public String TaxCode{get;set;}
public decimal UnitPrice{get;set;}
public String WhatCode{get;set;}
public String WhoCode{get;set;}
public String WhyCode{get;set;}
public String PaymentMethod{get;set;}
public String RequestType{get;set;}
public String GLAccount{get;set;}
public decimal vAdminFeeCreditAmount{get;set;}
public String vAircraftRegistration{get;set;}
public String CDMReviewerComments{get;set;}
public String FlightNumber{get;set;}
public String Material{get;set;}
public Boolean Include_AdminFee{get;set;}
public String MaterialDescription{get;set;}
public String MaterialNumber{get;set;}
public String MaterialType1{get;set;}
public String MaterialType2{get;set;}
public String Billto{get;set;}
public String Plant{get;set;}
public String SalesDocType{get;set;}  
public String ChannelCode{get;set;}  
public String CustomerPONumber{get;set;}  
public String DistributionChannel{get;set;} 
public String Division{get;set;}  
public String Payer{get;set;}  
public String SalesOrganisation{get;set;}  
public String Ship_To_Party{get;set;}  
public String TaxEndUse{get;set;}  
public String CostCenter{get;set;}  
public Decimal TaxRate{get;set;}
public datetime BillingDate{get;set;}
public String CustomerVatNumber{get;set;} 
public String ItemText{get;set;}
public String RequesterComments{get;set;}
public String vCurrency{get;set;}
//public String DefaultGLAccount{get;set;}
//public String DefaultProfitCentre{get;set;}
//public String DefaultCostCentre{get;set;}
public String BulkUpload{get;set;}
public String CreditDebitNoteParent{get;set;}
public String BusinessDetails{get;set;}
public String DedicatedToDocumentType{get;set;}
public String GLDocumentNumber{get;set;}
public String OrderDate{get;set;}
public String OrderNumber{get;set;}
public String CDMRecordType{get;set;}
public integer CountOfChildCDM{get;set;}
public String CompanyName{get;set;}
public String ProcessingError{get;set;}
public String FormStatus{get;set;}
public String DocumentName{get;set;}
//public String CompanyName{get;set;}
public List<Amounts> Amounts{get;set;}
}


/**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform line meta data and send to RPA.
    *————————————————————————————————————————————————————
   
    **/ 
public with sharing class Amounts {
    public String GLAccount{get;set;}
    public String ProfitCenter{get;set;}
    public string CostCenter{get;set;}  
    public Decimal SubGrossAmount{get;set;}
    public Decimal SubNetAmount{get;set;}
    public String SubTaxCode{get;set;}
    public Decimal SubTaxAmount{get;set;} 
    public String SubItemText{get;set;}
    public decimal SubTaxRate{get;set;}
    public String D_C{get;set;}


}
/**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get currency rate data.
    *————————————————————————————————————————————————————
   
    **/ 

public with sharing class CurrencyRate {
    public rates rates{get;set;}
    public String base{get;set;}
    }
   
   /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get currency rate data.
    *————————————————————————————————————————————————————
   
    **/  
public with sharing class rates {
    public Decimal EUR{get;set;}
    public Decimal NZD{get;set;}
    public Decimal INR{get;set;}
    public Decimal ZAR{get;set;}
    public Decimal USD{get;set;}
    public Decimal AUD{get;set;}
    public Decimal CAD{get;set;}
}

 /**
    *————————————————————————————————————————————————————
    * @Description
    *  get dynamic currency rates value.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    public static String authResponse = '{    "token_type": "Bearer",    "expires_in": "3600",    "ext_expires_in": "3600",    "expires_on": "1574846196",    "not_before": "1574842296",    "resource": "https://mule-dofa-delegates-proxy-dev.ir-e1.cloudhub.io",    "access_token": "eyJ"}';
     public static String getDofaApiAccessToken() {
        Http h = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.CDM_Dofa_Auth_Url);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        //system.debug(generateAuthBody());
        req.setBody('grant_type=client_credentials&client_id='+EncodingUtil.urlEncode(Label.CDM_Dofa_Auth_ClientId,'UTF-8')+'&client_secret='+ EncodingUtil.urlEncode(Label.CDM_Dofa_Auth_ClientSecret,'UTF-8') +'&resource='+Label.CDM_Dofa_Auth_Resource_Url);
        String authRes;
        // Send the request, and return a response
        if(!test.isrunningtest()) {
        HttpResponse res = h.send(req);
        authRes = res.getBody();
        system.debug(res.getBody());
        } else {
        
        authRes = authResponse;
        }
        if(authRes !=null) {
       
        AuthResponse ares =  (AuthResponse)JSON.deserialize(authRes, AuthResponse.class);
        system.debug(ares);
        if(ares!=null)
            return ares.access_token;
       
        }
       return null;
        
    }     
   
   public static string generateAuthBody() {
       AuthReqBody req = new AuthReqBody();
       req.client_id = Label.CDM_Dofa_Auth_ClientId;
       req.client_secret = Label.CDM_Dofa_Auth_ClientSecret;
       req.grant_type = 'client_credentials';
       req.resource = Label.CDM_Dofa_Auth_Resource_Url;
       return JSON.serialize(req);
   }  

  /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa authorisation.
    *————————————————————————————————————————————————————
   
    **/ 
    
public with sharing class AuthReqBody{
        public String client_id{get;set;}
        public String client_secret{get;set;}
        public String grant_type{get;set;}
        public String resource{get;set;}
      
}
 
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa authorisation.
    *————————————————————————————————————————————————————
   
    **/ 
    
public with sharing class AuthResponse{
        public String expires_on{get;set;}
        public String not_before{get;set;}
        public String ext_expires_in{get;set;}
        public String resource{get;set;}
        public String expires_in{get;set;}
        public String access_token{get;set;}
        public String token_type{get;set;}
}

  // public listDelegates listDelegates{get;set;}
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class listDofaUser{
        public listDelegates listDelegates{get;set;}
    }

   // public listDelegates listDelegates{get;set;}
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class listDelegates{
        public Delegates Delegates{get;set;}
    }
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class Delegations {
        public String AuthorisationName{get;set;}
        public String GPIDForDelegator{get;set;}
        public String AuthorisationType{get;set;}
        public String NTLoginForDelegator{get;set;}
        public String USDAmount{get;set;}
        public String DelegatorName{get;set;}
        public String ApprovalAmount{get;set;}
        public String Organisation{get;set;}
        public String Currency1{get;set;}
        public String LastChangedDate{get;set;}
        public String UnlimitedAmount{get;set;}
        public String SupportingNotes{get;set;}
        public list<AuthorityAmount> AuthorityAmount{get;set;}
    } /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class Delegates{
       
        public String GPID{get;set;}
        public String EmailAddressForDelegate{get;set;}
        public String NTLoginForDelegate{get;set;}
        public String Country{get;set;}
        public String EmployeeNumber{get;set;}
        public String SegmentName{get;set;}
        public String LastName{get;set;}
        public list<Delegations> Delegations{get;set;}
        public String FirstName{get;set;}
    }
    
    public class DoffaDollerValue {
       public List<AuthorityDollerAmount> DoffaDollerValue{get;set;}
    
    }
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class AuthorityDollerAmount{
        public String RecordId{get;set;}
        public String DollerValue{get;set;}
        public boolean UnlimitedAmount{get;set;}
        public boolean LuisError{get;set;}
    }
    
      /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class AuthorityAmount{
        public String SAPCompanyCode{get;set;}
        public String SAPApprovalAmount{get;set;}
        public String SAPUSDAmount{get;set;}
    }
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for get dofa data.
    *————————————————————————————————————————————————————
   
    **/ 
    public with sharing class ValidApproverRes{
        public Boolean status{get;set;}
        public String statusRes{get;set;}
        public String formStatus{get;set;}
   
    }


/**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform records meta data.
    *————————————————————————————————————————————————————
   
    **/ 

global with sharing class CDMEformRec {
    global List<CDMEforms> CDMEforms{get;set;}
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    *  Wrapper class for cdm eform records meta data.
    *————————————————————————————————————————————————————
   
    **/ 

global with sharing class CDMSupportingNotes {
    global List<CDMSuportingNote> CDMSuportingNote{get;set;}
    }

 

}