/* @author            Karishma Gurjar
*  @date              27/01/2020
*  @description       handles trigger events on Notes object for IST CRM Project
*  @ -----------------------------------
*/
public with sharing class ICRM_Staff_Trigger_Handler extends BPG_Trigger_Handler_Utilities{
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Create user in custom Object ICRM Staff */  
    {
        List<User> listNewUser = new List<User>(); 
        listNewUser=n;
        Set<Id> setOfUsers = new Set<Id>();
        map<id,Profile> mapOfProfileIds= new map<id,Profile>([SELECT Id, Name from Profile WHERE Name in ('ICRM Base','ICRM_Chatter')]);
        for (User ISTUser : listNewUser){
            
            if(!mapOfProfileIds.isEmpty() && mapOfProfileIds.containsKey(ISTUser.Profileid))            {
                if((mapOfProfileIds.get(ISTUser.Profileid).name == 'ICRM Base' || mapOfProfileIds.get(ISTUser.Profileid).name == 'ICRM_Chatter') && ISTUser.NTID__c != ' ')     
                {
                    setOfUsers.add(ISTUser.id);   
                }
            }
        }
        if(!System.isFuture() && !System.isBatch() && !setOfUsers.isEmpty()){
            userCreate(setOfUsers);
        }
    }
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Update user in custom Object ICRM Staff */ 
    {
        List<User> listNewUser = new List<User>(); 
        map<id,Profile> mapOfProfileIds= new map<id,Profile>([SELECT Id, Name from Profile WHERE Name in ('ICRM Base','ICRM_Chatter')]);
        Set<Id> setOfUsersToUpdate=new Set<Id>();
        Set<Id> setOfUsersToInsert = new Set<Id>();
        Set<Id> NonISTSetToUpdate = new Set<Id>();
        listNewUser=n;
        for (User ISTUser : listNewUser){
            if(!mapOfProfileIds.isEmpty() && mapOfProfileIds.containsKey(ISTUser.Profileid)){
                if((mapOfProfileIds.get(ISTUser.Profileid).name == 'ICRM Base' || mapOfProfileIds.get(ISTUser.Profileid).name == 'ICRM_Chatter')&& ISTUser.NTID__c != ' ' && (((User)nMap.get(ISTUser.id)).isActive != ((User)oMap.get(ISTUser.id)).isActive || ((User)nMap.get(ISTUser.id)).firstname != ((User)oMap.get(ISTUser.id)).firstname || ((User)nMap.get(ISTUser.id)).lastname != ((User)oMap.get(ISTUser.id)).lastname || ((User)nMap.get(ISTUser.id)).UserName != ((User)oMap.get(ISTUser.id)).UserName || ((User)nMap.get(ISTUser.id)).Title != ((User)oMap.get(ISTUser.id)).Title || ((User)nMap.get(ISTUser.id)).Department != ((User)oMap.get(ISTUser.id)).Department || ((User)nMap.get(ISTUser.id)).Email != ((User)oMap.get(ISTUser.id)).Email || ((User)nMap.get(ISTUser.id)).ProfileId != ((User)oMap.get(ISTUser.id)).ProfileId))
                {
                    setOfUsersToUpdate.add(ISTUser.id);
                } 
            }
            
            if(((User)nMap.get(ISTUser.id)).ProfileId != ((User)oMap.get(ISTUser.id)).ProfileId && !mapOfProfileIds.containsKey(((User)oMap.get(ISTUser.id)).ProfileId) && mapOfProfileIds.containsKey(((User)nMap.get(ISTUser.id)).ProfileId)){
                setOfUsersToInsert.add(ISTUser.id);    
            }
            if(((User)nMap.get(ISTUser.id)).ProfileId != ((User)oMap.get(ISTUser.id)).ProfileId && !mapOfProfileIds.containsKey(((User)nMap.get(ISTUser.id)).ProfileId) && mapOfProfileIds.containsKey(((User)oMap.get(ISTUser.id)).ProfileId)){
                NonISTSetToUpdate.add(ISTUser.id);
            }
        }
        
        if(!System.isFuture() && !System.isBatch() && !setOfUsersToUpdate.isEmpty()){
            userUpdate(setOfUsersToUpdate);
        }     
        if(!System.isFuture() && !System.isBatch() && !setOfUsersToInsert.isEmpty()){
            userCreate(setOfUsersToInsert);
        }
        if(!System.isFuture() && !System.isBatch() && !NonISTSetToUpdate.isEmpty()){
            NonISTUserUpdate(NonISTSetToUpdate);
        }
    } 
    @future
    public static void userCreate(Set<Id> recordIds) {
        /* Future method to Create user in custom Object ICRM Staff */ 
        List<ICRM_Staff__c> traderUserList = new List<ICRM_Staff__c>();
        map<id,Profile> mapProfile= new map<id,Profile>([SELECT Id, Name from Profile WHERE Name in ('ICRM Base','ICRM_Chatter')]);
        for(User ISTUser : [Select id,NTID__c,Title,Department,Email,Username,ProfileId,firstname,lastname,isActive FROM user where id in : recordIds]){
            
            ICRM_Staff__c T= new ICRM_Staff__c();
            T.Name=ISTUser.firstname + ' ' + ISTUser.lastname;
            T.ICRM_NTID__c=ISTUser.NTID__c;
            T.ICRM_Title__c=ISTUser.Title;
            T.ICRM_Department__c=ISTUser.Department;
            T.ICRM_Email__c=ISTUser.Email;
            T.ICRM_Username__c=ISTUser.Username;
            T.ICRM_Trader_IsActive__c=ISTUser.isActive;
            T.ICRM_IST_User__c=True;
            T.ICRM_Profile__c=mapProfile.get(ISTUser.ProfileId).name;
            traderUserList.add(T);     
        }
        if(!traderUserList.isEmpty()){
            Insert traderUserList; 
        }       
    }
    
    @future
    public static void userUpdate(Set<Id> UserIdToUpdate) {
        /* Future Method to Update user in custom Object ICRM Staff */ 
        Map<String,User> mapUsertoUpdate= new Map<String,User>();
        List<ICRM_Staff__c> traderUserListtoUpdate = new List<ICRM_Staff__c>();
        for(User ISTUser : [Select id,UserName,isActive,NTID__c,Title,Department,Email,Profileid FROM User where Id in : UserIdToUpdate]){
            mapUsertoUpdate.put(ISTUser.NTID__c,ISTUser);
        }
        
        map<id,Profile> mapProfile= new map<id,Profile>([SELECT Id, Name from Profile WHERE Name in ('ICRM Base','ICRM_Chatter')]);
        ICRM_Staff__c T= new ICRM_Staff__c();
        for(ICRM_Staff__c traderUser : [Select id,Name,ICRM_NTID__c,ICRM_Title__c,ICRM_Email__c,ICRM_Trader_IsActive__c,ICRM_Department__c,ICRM_Profile__c,ICRM_Username__c FROM ICRM_Staff__c where ICRM_NTID__c in : mapUsertoUpdate.keyset()]){
            
            T.id=traderUser.id;
            T.ICRM_Trader_IsActive__c=mapUsertoUpdate.get(traderUser.ICRM_NTID__c).isActive;
            T.ICRM_Username__c=mapUsertoUpdate.get(traderUser.ICRM_NTID__c).UserName;
            T.ICRM_Title__c=mapUsertoUpdate.get(traderUser.ICRM_NTID__c).Title;
            T.ICRM_Department__c=mapUsertoUpdate.get(traderUser.ICRM_NTID__c).Department;
            T.ICRM_Email__c=mapUsertoUpdate.get(traderUser.ICRM_NTID__c).Email;
            T.ICRM_Profile__c=mapProfile.get(mapUsertoUpdate.get(traderUser.ICRM_NTID__c).Profileid).name;
            traderUserListtoUpdate.add(T);
            
        }
        if(!traderUserListtoUpdate.isEmpty()){
            Update traderUserListtoUpdate;  
        }
    }
   
    @future
    public static void NonISTUserUpdate(Set<Id> NonISTSetToUpdate) {
        /* Future Method to Update Non IST user in custom Object ICRM Staff */ 
        Map<String,User> mapNonISTUsertoUpdate= new Map<String,User>();
        List<ICRM_Staff__c> NonISTTraderList = new List<ICRM_Staff__c>();
        for(User ISTUser : [Select id,NTID__c,Profileid FROM User where Id in : NonISTSetToUpdate]){
            mapNonISTUsertoUpdate.put(ISTUser.NTID__c,ISTUser);
        }
        
        ICRM_Staff__c T= new ICRM_Staff__c();
        for(ICRM_Staff__c traderUser : [Select id,ICRM_IST_User__c FROM ICRM_Staff__c where ICRM_NTID__c in : mapNonISTUsertoUpdate.keyset()]){  
            T.id=traderUser.id;
            T.ICRM_IST_User__c=False;
            NonISTTraderList.add(T);  
        }
        if(!NonISTTraderList.isEmpty()){
            update NonISTTraderList;  
        }
    }
}