/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 1/2019
*
* Data Anonymization class that is used to delete bulk Acoounts asynchronously
* 
*/
public class REIDP_BulkDeleteUserData implements Queueable {
    
    private List<REIDP_User_Consent__c> consents;
    private List<REIDP_Application_Access_Request__c> appRequests;
    private List<User> users;
    private List<Account> accounts;
    
    
    public REIDP_BulkDeleteUserData(List<REIDP_User_Consent__c> consents, List<REIDP_Application_Access_Request__c> appRequests, List<User> users, List<Account> accounts) {
        this.consents = consents;
        this.appRequests = appRequests;
        this.users = users;
        this.accounts = accounts;
    }
    
    public void execute(QueueableContext context) {
        
        List<REIDP_User_Consent__c> extraConsent = (List<REIDP_User_Consent__c>) deleteList(consents);
        if(extraConsent.size() > 0) {
            System.enqueueJob(new REIDP_BulkDeleteUserData(extraConsent, appRequests, users, accounts));
            return;
        }

        List<REIDP_Application_Access_Request__c> extraAppRequests = (List<REIDP_Application_Access_Request__c>) deleteList(appRequests);
        if(extraAppRequests.size() > 0) {
            System.enqueueJob(new REIDP_BulkDeleteUserData(extraConsent, extraAppRequests, users, accounts));
            return;
        }
        
        //Since user can not be obfuscated in same transaction and we can't chain jobs in Test context rest of the code is skipped
        //Also System.UserManagement.obfuscateUser(Id) does not currently work in Test: 
        //https://success.salesforce.com/issues_view?id=a1p3A000001HlDPQA0&title=usermanagement-obfuscateuser-gacks-in-test-context-tries-to-db-commit-when-it-s-not-allowed 
        if(Test.isRunningTest())
            return;
        
        // starting a new transaction for user deletion, user obfuscation does not work if previously related objs were deleted in same transaction
        if(consents.size() > 0 || appRequests.size() > 0) {
            System.enqueueJob(new REIDP_BulkDeleteUserData(extraConsent, extraAppRequests, users, accounts));
            return;
        }
        
        //Obfuscating each user in a separate transaction to avoid limits
        if(users != null && users.size() > 0) {
            //System.UserManagement.obfuscateUser(users.get(0).Id);
            //As per following Case - https://help.salesforce.com/mysuccesshub?id=supportCases&caseId=5000M00000oINzpQAG
            //System.UserManagement.obfuscateUser can only be used by Users with "Manage Users" permission
            //But since IDP Support Administrators have only "Manage External User" we're using custom method to obfuscate PII fields
            deactivateAndAnonymizeUser(users.get(0));
            users.remove(0);
            
            System.enqueueJob(new REIDP_BulkDeleteUserData(extraConsent, extraAppRequests, users, accounts));
            return;
        }
        
        List<Account> extraAccounts = (List<Account>) deleteList(accounts);
        if(extraAccounts.size() > 0) {
            System.enqueueJob(new REIDP_BulkDeleteUserData(extraConsent, extraAppRequests, users, extraAccounts));
            return;
        }
        
    }
    
    private List<sObject> deleteList(List<sObject> objs) {
        List<sObject> extraObjects = new List<sObject>(); 
        List<sObject> objectsToDelete = new List<sObject>(); 
        if(objs != null && objs.size() > 0) {
            for(sObject c : objs) {
                if(objectsToDelete.size() < (Limits.getLimitDmlRows() - Limits.getDMLRows())) 
                    objectsToDelete.add(c);
                else
                    extraObjects.add(c);
            }
            delete objectsToDelete;
        }
        return extraObjects;
    }
    
    private User deactivateAndAnonymizeUser(User u) {
        String email = 'dummy=' + System.now().getTime() + '=' + '@example.com';
        u.IsPortalEnabled = FALSE;
        u.CommunityNickname = 'dummy=' + System.currentTimeMillis();
        u.IsActive = FALSE;
        u.Alias = 'DELETED';
        u.Username = email;
        u.Birthdate__c = System.today();
        u.Street = null;
        u.Address_Line_2__c = null;
        u.City = null;
        u.PostalCode = null;
        u.State = null;
        u.Country = null;
        u.Email = email;
        u.REIDP_New_Email__c = email;
        u.Phone = null;
        u.REIDP_Verified_Phone__c = null;
        u.REIDP_Devices__c = null;
        u.REIDP_Country_of_App__c = null;
        u.REIDP_Loyalty_Card__c = null;
        u.FirstName = 'DELETED';
        u.LastName = 'DELETED';
        update u;
        return u;
    }
}