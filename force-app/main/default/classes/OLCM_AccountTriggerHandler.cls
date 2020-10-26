/**
* @author Jewelslyn Shama P
* @company Tata Consultancy Services
* @date 
* 
* @ author - Steven Edwards
* @ company - BP Salesforce C4E
* @ date - 28/02/2020
* @ reason - INC000001202178 remediation of null pointer exceptions seen in IDP testing of Guest User registration after Remove View All Users Permission from Guest User Profiles update (see https://bpcustomer.lightning.force.com/lightning/setup/SecurityUpdates/home)
*@ Date Modified : 17/08/2020 :- ESA Project Changes added for credit requirement
*/
public with sharing class OLCM_AccountTriggerHandler {
// Properties defined   
public static list<OLCM_Country_ISO_Code__mdt> countIsoCode;    
public static list<OLCM_Credit_Segments__mdt> creditControl;
public static  map<string,OLCM_Country_ISO_Code__mdt> mapCountryWithIsoCode=new map<string,OLCM_Country_ISO_Code__mdt>();    
public static map<string,OLCM_Credit_Segments__mdt> mapcreditControlArea=new map<string,OLCM_Credit_Segments__mdt>();

/************************************************************************************************************
* Method to populate CountryIsoCodes
* Method to populate Currency ISO Codes based on Sales Area, Credit Segment and Credit Control Area
*************************************************************************************************************/ 

public static void handleBeforeInsertUpdate(list<Account> listAcc){ 
    Olcm_Switch_cmf__mdt[] switchchk= [SELECT switch__c FROM Olcm_Switch_cmf__mdt limit 1];
    if(switchchk[0].switch__c ){
        countIsoCode=[select OLCM_Country__c, OLCM_Country_ISO_Code__c from OLCM_Country_ISO_Code__mdt limit 10000];
        creditControl=[Select id,OLCM_Credit_Control_Area__c,OLCM_Credit_Segment__c,
                       OLCM_Sales_Area__c,OLCM_Currency_ISO_Code__c from OLCM_Credit_Segments__mdt where OLCM_Sales_Area__c !='' ];
        for(OLCM_Country_ISO_Code__mdt isoCode:countIsoCode){
            if(isoCode.OLCM_Country__c.toUpperCase() != null && isoCode.OLCM_Country_ISO_Code__c != null){
                if(!mapCountryWithIsoCode.containskey(isoCode.OLCM_Country__c.toUpperCase())){
                    mapCountryWithIsoCode.put(isoCode.OLCM_Country__c.toUpperCase(),isoCode);
                }
            }                
        }
        for(OLCM_Credit_Segments__mdt creditControl:creditControl){
            if(!mapcreditControlArea.containsKey(creditControl.OLCM_Sales_Area__c)){
                mapcreditControlArea.put(creditControl.OLCM_Sales_Area__c,creditControl);
            }
        }
        for(Account acc:listAcc){   
          Boolean IsFuels_Customers=false;
          Boolean IsFuels_Card_Customers=false;
          if(acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_01|| acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_03||acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_04||acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_05||acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_06 ){
                IsFuels_Customers=true;
            }            
             if(acc.OLCM_Sales_Division_Description__c==System.Label.OLCM_sales_Division_Description_01&&  acc.OLCM_Distribution_Channel_Description__c==System.Label.OLCM_sales_Division_Description_05){
          
                    if(acc.Sales_Organisation__c==System.Label.OLCM_Sales_Organisation_DAVG ||acc.Sales_Organisation__c==System.Label.OLCM_Sales_Organisation_DE01||acc.Sales_Organisation__c==System.Label.OLCM_Sales_Organisation_AT0H ||acc.Sales_Organisation__c==System.Label.OLCM_Sales_Organisation_NL01||acc.Sales_Organisation__c==System.Label.OLCM_Sales_Organisation_PL0N){
                        IsFuels_Card_Customers=true;                   
                    }
              }
          
           if((IsFuels_Customers==true||IsFuels_Card_Customers==true)&&(acc.OLCM_Sales_Division_Description__c!=null))
            {
                acc.Sales_Division_Code__c=acc.OLCM_Sales_Division_Description__c;
            }
            if((IsFuels_Customers==true||IsFuels_Card_Customers==true)&&(acc.OLCM_Distribution_Channel_Description__c!=null))
            {
                acc.Sales_Distribution_Code__c=acc.OLCM_Distribution_Channel_Description__c;
            }   
            
            if((IsFuels_Customers==true||IsFuels_Card_Customers==true)&&(acc.OLCM_Sales_Organisation_Description__c!=null&&acc.OLCM_Sales_Organisation_Description__c!='')){
                acc.Sales_Organisation__c=acc.OLCM_Sales_Organisation_Description__c;                
            }           
            acc.Country_ISO_Code__c=null;
            if(acc.BillingCountry !=null){
                if(mapCountryWithIsoCode.containskey(acc.BillingCountry.toUpperCase())){
                    acc.Country_ISO_Code__c=mapCountryWithIsoCode.get(acc.BillingCountry.toUpperCase()).OLCM_Country_ISO_Code__c;
                }
                if((acc.Country_ISO_Code__c==null||acc.Country_ISO_Code__c=='')&& OLCM_constant.chkBPBase){
                    acc.BillingCountry.addError('Please provide a valid Value in Country');
                    break;
                }
            }                   
            String salesArea ;
               salesArea = acc.Sales_Organisation__c+acc.Sales_Distribution_Code__c+acc.Sales_Division_Code__c;  
                       
            if(salesArea !=null){
                acc.OLCM_Credit_Control_Area__c=null;
                acc.OLCM_Credit_Segment__c=null;               
               if(mapcreditControlArea.containskey(acc.Sales_Organisation__c+acc.Sales_Distribution_Code__c+acc.Sales_Division_Code__c)){
                    acc.OLCM_Credit_Control_Area__c=mapcreditControlArea.get(acc.Sales_Organisation__c+acc.Sales_Distribution_Code__c+acc.Sales_Division_Code__c).OLCM_Credit_Control_Area__c;
                    acc.OLCM_Credit_Segment__c=mapcreditControlArea.get(acc.Sales_Organisation__c+acc.Sales_Distribution_Code__c+acc.Sales_Division_Code__c).OLCM_Credit_Segment__c;
                    acc.CurrencyIsoCode=mapcreditControlArea.get(acc.Sales_Organisation__c+acc.Sales_Distribution_Code__c+acc.Sales_Division_Code__c).OLCM_Currency_ISO_Code__c;                                                       
                }                  
             if((acc.OLCM_Credit_Segment__c==null||acc.OLCM_Credit_Segment__c=='')&& OLCM_constant.chkBPBase && String.isnotblank(acc.OLCM_Sales_Division_Description__c) && String.isnotblank(acc.OLCM_Distribution_Channel_Description__c) && String.isnotblank(acc.OLCM_Sales_Organisation_Description__c)){
                    acc.OLCM_Credit_Segment__c.addError('Credit Segment calculated will be blank. Please review the combination of Sales Division Description , Sales Distribution Channel and, Sales Division Description which is used to derive the Credit Segment.');
                    break;
                }                                           
            } 
            
        }
    }//end for
} //end Method

public static void updateSalesforceID(list<Account> Acclist){
    // List<Account> updatedaccList=new List<Account>();
    for(Account acc:Acclist)
    {
        acc.Salesforce_ID__c=acc.Id;
       
    }  
}
public static void checkValidate(List <Account> accList){

    try{
    Profile profileName = [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()];
    
    Boolean isOLCMUser = FeatureManagement.checkPermission('OLCM_User');
    Boolean isOLCMcreditManageUser = FeatureManagement.checkPermission('OLCM_Credit_Management_User');
    
    List<Account> recordList=new List<Account>();           
    for(Account a:accList){
        if(profileName.name.equalsIgnoreCase('System Administrator'))
        {
            recordList.add(a);
        }
        if(isOLCMcreditManageUser){
            OLCM_constant.chkBPBase =true;
            if(isOLCMUSer && String.isnotblank(a.OLCM_Sales_Division_Description__c) && String.isnotblank(a.OLCM_Distribution_Channel_Description__c) && String.isnotblank(a.OLCM_Sales_Organisation_Description__c) &&  (a.BillingPostalCode==null||a.BillingPostalCode=='') ){
                a.BillingPostalCode.addError('Please provide value in postal code');
                
                break;
            }
           if(isOLCMUSer && String.isnotblank(a.OLCM_Sales_Division_Description__c) && String.isnotblank(a.OLCM_Distribution_Channel_Description__c) && String.isnotblank(a.OLCM_Sales_Organisation_Description__c) && (a.BillingCountry==null||a.BillingCountry=='') ){
                a.BillingCountry.addError('Please provide a valid Value in Country');                
                break;
            }
            recordList.add(a);
        }
        
    }
    if(recordList.size()!=0)
    {
        OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(recordList);
        if(OLCM_constant.chkboolean==false){
            System.enqueuejob(new OLCM_AccountTriggerHandlerQueueable(recordList));    }
        OLCM_constant.chkboolean=true;
        
    }
    }catch(Exception ex){system.debug('**Error **checkValidate**OLCM_AccountTriggerHandler**'+ex);}
}   
/************************************************************************************************************
* Method to send requests
*************************************************************************************************************/ 
public static void sendrequest(List <Account> accList){
try{
if(OLCM_constant.chkqueue ==false){
             System.enqueuejob(new OLCM_AccountTriggerHandlerQueueable(accList));   
    }
        OLCM_constant.chkqueue=true;
   }catch(Exception ex){system.debug('**Error **sendrequest**OLCM_AccountTriggerHandler**'+ex);}    
}

/************************************************************************************************************
* Method for Sharing record
*Method for sharing record based on sales org
*************************************************************************************************************/ 
    public static void sharingAccountpubgroup(List <Account> accList){
        try{
        system.debug('sharingAccountpubgroup**'+accList);
        Boolean isOLCMUser = FeatureManagement.checkPermission('OLCM_User');
        Boolean isOLCMcreditManageUser = FeatureManagement.checkPermission('OLCM_Credit_Management_User');
        List<group> gpid=new List<group> ();
        Group gpval;
        
        Profile profileName=[select name from profile where id =: userinfo.getProfileId()];            
       
        if(isOLCMUser&&isOLCMcreditManageUser || profileName.name.equalsIgnoreCase(System.Label.ESA_Profile_name) )
        {       
        gpid=[select id,name from group where name like 'OLCM_%' limit 10000]; 
        gpval=[select id from group where name=:system.Label.OLCM_parent_group];
        }
        for(Account a:accList){        
            if((isOLCMUser&&isOLCMcreditManageUser&& string.isnotblank(a.Sales_Organisation__c) && String.isnotblank(a.OLCM_Sales_Organisation_Description__c) )||( profileName.name.equalsIgnoreCase(System.Label.ESA_Profile_name) && string.isnotblank(a.Sales_Organisation__c) )){
                
                Olcm_recordSharing.ShareEditAcc(a.id, a.Sales_Organisation__c,gpid,gpval);
            }
            
        }
        }catch(Exception ex){system.debug('**Error **sharingAccountpubgroup**OLCM_AccountTriggerHandler**'+ex);}
    }
/************************************************************************************************************
* Method for deleting AccountShare record
*************************************************************************************************************/
   public static void sharingAccountpubgroupdel(List<Account> accList){
       try{       
        Boolean isOLCMUser = FeatureManagement.checkPermission('OLCM_User');
        Boolean isOLCMcreditManageUser = FeatureManagement.checkPermission('OLCM_Credit_Management_User');
        Map<String,id> pugpdel=new Map<String,id>();
        Map<id,Account> accmap=new Map<id,Account>();
        List<group> pubgpids=new List<group>();
        Profile profileName=[select name from profile where id =: userinfo.getProfileId()];
             
       
        
        if(isOLCMUser&&isOLCMcreditManageUser || profileName.name.equalsIgnoreCase(System.Label.ESA_Profile_name))
        {            
        pubgpids=[select id,name from group where name like 'OLCM_%' limit 10000];
        }
        if(pubgpids.size()!=0&&isOLCMcreditManageUser&&isOLCMUser || profileName.name.equalsIgnoreCase(System.Label.ESA_Profile_name)){
            for(Group g:pubgpids){
                pugpdel.put(g.name,g.id);     
            }
            for(Account a:accList){
            
                if(isOLCMUser && isOLCMcreditManageUser && pugpdel.size()!=0 ||(profileName.name.equalsIgnoreCase(System.Label.ESA_Profile_name) && pugpdel.size()!=0) )
                {                
                    accmap.put(a.id,a);
                }
            }           
            if(accmap.size()>0){
                Olcm_recordSharing.ShareDelAcc(accmap,pugpdel);
            }
        }
        
        }catch(Exception ex){system.debug('**Error **sharingAccountpubgroupdel**OLCM_AccountTriggerHandler**'+ex);}
    }//End method
}