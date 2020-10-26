/*Description : This Handler class is to cover the functionalities for ESA_Account_Trigger
*Project      : ESA Fuels
*Copyright    : Tata Consultancy Services Ltd
*Last Modified Date : 4/08/2020
*/

public with sharing class ESA_AccountTriggerHandler
{
    /* Description :-handlerBeforeInsert
    Below method is used to mapped ESA sales org value in OLCM required fields based on ESA's permission
    if they dont have ESA permission but they have OLCM permission then will create record org work as per the existing credit logic
    and also there is no mapping inside ESA fields
    */
    
        public static void handlerBeforeInsert(list<Account> listAcc){
          try{
            //for exception handling             
            List<Account> ESArecordList=new List<Account>();            
            List<Account> OLCMrecordList=new List<Account>();            
            for(Account a: listAcc) {
                OLCM_constant.chkBPBase =true;                   
                    if(String.isnotblank(a.ESA_Sales_Organisation__c) && (a.BillingPostalCode==null||a.BillingPostalCode=='' )) {
                        a.BillingPostalCode.addError('Please provide value in postal code');                
                        break;
                    }                    
                    if(String.isnotblank(a.ESA_Sales_Organisation__c) && (a.BillingCountry==null||a.BillingCountry==''))   {
                        a.BillingCountry.addError('Please provide a valid Value in Country');                
                        break;
                    }                    
                    if(a.ESA_Sales_Organisation__c != null && String.isnotblank(a.ESA_Sales_Organisation__c) && a.ESA_Relationship_Type__c != System.Label.ESA_Vendor )  {                
                        String str = a.ESA_Sales_Organisation__c.removeStart('ESA_');
                        string [] strA = str.split('/');                                   
                        a.OLCM_Sales_Division_Description__c=strA[2];
                        a.OLCM_Distribution_Channel_Description__c=strA[1];
                        a.OLCM_Sales_Organisation_Description__c= strA[0];  
                         if(a.Account_ERP_ID__c != null && String.isnotblank(a.Account_ERP_ID__c) && a.OLCM_Account_ERP_ID_Check__c)
                        {  
                            a.ESA_Customer_Id__c = a.Account_ERP_ID__c;
                        }                                                   
                        ESArecordList.add(a);
                    }else if(a.ESA_Sales_Organisation__c != null && String.isnotblank(a.ESA_Sales_Organisation__c) && a.ESA_Relationship_Type__c == System.Label.ESA_Vendor ){
                        a.OLCM_Sales_Division_Description__c='';
                        a.OLCM_Distribution_Channel_Description__c='';
                        a.OLCM_Sales_Organisation_Description__c='';
                        a.Sales_Division_Code__c='';
                        a.Sales_Distribution_Code__c='';
                        a.Sales_Organisation__c='';
                        a.Country_ISO_Code__c='';
                        a.OLCM_Credit_Control_Area__c='';
                        a.OLCM_Credit_Segment__c='';                                    
                    }else{      
                   //If OLCM user create ESA related sales area record then It will work as per the existing logic                            
                    if(String.isnotblank(a.OLCM_Sales_Division_Description__c)&& String.isnotblank(a.OLCM_Distribution_Channel_Description__c)&& String.isnotblank(a.OLCM_Sales_Organisation_Description__c)){                        
                        OLCMrecordList.add(a);
                    } 
                }
                
                
            }//End For
                       
            if(ESArecordList.size()>0){               
                OLCM_AccountTriggerHandler.handleBeforeInsertUpdate(ESArecordList);
                if(OLCM_constant.chkboolean==false){
                    System.enqueuejob(new OLCM_AccountTriggerHandlerQueueable(ESArecordList));  
                }
                OLCM_constant.chkboolean=true;            
            }
            
            if(OLCMrecordList.size()>0){
                OLCM_AccountTriggerHandler.checkValidate(OLCMrecordList);
            }
            
        }catch(Exception ex){ 
        //to catch the exception
        system.debug('Error'+ex);
        
        }
        
        }//End Method           
     /*
     get all Sales are which are related to ESA and based on that further logic will be executed
     */
     public static set<String> getESABussSalesarea(){    
       set<String> setofUnit = new set<String>();
        Schema.DescribeFieldResult fieldResult = Account.ESA_Sales_Organisation__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            setofUnit.add(pickListVal.getValue().removeStart('ESA_'));
        }        
        return setofUnit;
    }    
}