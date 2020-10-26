/**
 * @author Jewelslyn Shama P
 * @company Tata Consultancy Services
 * @date 
 * 
 */

public with sharing class OLCM_UserTriggerHandler {
    public static list<Account> accList;
    public static map<string,list<user>> mapUserIdCountryCode=new map<string,list<user>>();
    /************************************************************************************************************
    * Method to Insert Sharing access for Users
    *************************************************************************************************************/
    @Future
    public static void handleAfterInsertUpdate(Set<Id> userIds){
       set<string> countryCodes= new set<string>();
        List<AccountShare> sharesToCreate = new List<AccountShare>();
        list<User> userList=[Select Id,OLCM_Country_Code__c from User where Id IN:userIds and OLCM_Country_Code__c!=null];
        for(user u:userList){
           if(u.OLCM_Country_Code__c !=null ){
               countryCodes.add(u.OLCM_Country_Code__c);
               if(!mapUserIdCountryCode.containsKey(u.OLCM_Country_Code__c)){
                   mapUserIdCountryCode.put(u.OLCM_Country_Code__c,new list<user>{u});
               } 
               else{
                   mapUserIdCountryCode.get(u.OLCM_Country_Code__c).add(u);
               }
            }  
        }
        accList=new list<account>([select id,Country_ISO_Code__c from account where Country_ISO_Code__c IN:countryCodes]);
        for(account acc:accList){
            AccountShare accShare=new AccountShare();
            if(mapUserIdCountryCode.containskey(acc.Country_ISO_Code__c)){
                for(user u:mapUserIdCountryCode.get(acc.Country_ISO_Code__c)){
                    system.debug('countrycode::'+mapUserIdCountryCode.get(acc.Country_ISO_Code__c));
            		accShare.AccountAccessLevel = 'Edit';
                    accShare.OpportunityAccessLevel = 'Read';
        			accShare.AccountId = acc.Id;                    
        			accShare.UserOrGroupId = u.Id;
        			sharesToCreate.add(accShare);
                    system.debug('userId::'+accShare.UserOrGroupId);
                }
            }            
        }
        if (!sharesToCreate.isEmpty()){
            insert sharesToCreate;
        }      	
    }
}