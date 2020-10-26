/**
* @author Nazim Aliyev & Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 12/2018
* 
* This class is used for Community User deactivation and anonymization
* 
*/

public class REIDP_DataAnonymization {
    
    @AuraEnabled
    public static void DeleteAndAnonymizeCommunityUser(String accountId) {
        List<String> uidList = new List<String>();
        List<User> uList = [SELECT Id, Email FROM User WHERE Contact.AccountId = :accountId];
        
        if(uList.size() > 0) {
            uidList.add(uList.get(0).Id);
            deleteAndAnonymizeCommunityUsers(uidList);
        }
        else
            throw new AuraHandledException('This account/contact is not assigned to Portal User');
    }
    
    public static void deleteAndAnonymizeCommunityUsers(List<String> uidList) {
        List<User> uList = new List<User>();
        List<Account> accs = new List<Account>();
        List<REIDP_Application_Access_Request__c> userAppRequests = new List<REIDP_Application_Access_Request__c>(); //  user app requests to delete them later
        List<REIDP_User_Consent__c> userCons = new List<REIDP_User_Consent__c>(); // user consents to delete them later
        
        // iterate through list of users we've got
        for(User u : [SELECT Id, Contact.AccountId, 
                      (SELECT Id, Name FROM User_Consents__r),
                      (SELECT Id FROM Application_Access_Requests__r)
                      FROM User 
                      WHERE Profile.Name LIKE 'RE IDP External Identity%'
                      AND Id in :uidList 
                      LIMIT 50000]) {
                          // list of user accounts
                          uList.add(u);
                          accs.add(new Account(Id = u.Contact.AccountId));

                          userCons.addAll(u.User_Consents__r);
                          userAppRequests.addAll(u.Application_Access_Requests__r);
                      }
        
        if(accs.size() > 0) {
            System.enqueueJob(new REIDP_BulkDeleteUserData(userCons, userAppRequests, uList, accs));
        }
    }
}