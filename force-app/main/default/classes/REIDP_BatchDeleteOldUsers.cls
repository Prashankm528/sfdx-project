/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 1/2019
*
*/
global class REIDP_BatchDeleteOldUsers implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Test.isRunningTest() ? Database.getQueryLocator([SELECT Id, Contact.AccountId, LastLoginDate, CreatedDate
                                                                FROM User 
                                                                WHERE Profile.Name LIKE 'RE IDP External Identity%'
                                                                AND (LastLoginDate < LAST_N_YEARS:1 OR LastLoginDate = NULL)
                                                                AND CreatedDate < LAST_N_YEARS:2
                                                                AND Username LIKE 'REIDP_BatchDeleteOldUsersSchedulerTest%' LIMIT 1])
                                    : Database.getQueryLocator([SELECT Id, Contact.AccountId, LastLoginDate, CreatedDate
                                                                FROM User 
                                                                WHERE Profile.Name LIKE 'RE IDP External Identity%'
                                                                AND (LastLoginDate < LAST_N_YEARS:1 OR LastLoginDate = NULL)
                                                                AND CreatedDate < LAST_N_YEARS:2]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> users) {
        List<String> inactiveUsers = new List<String>();

        for (User u : users){
            inactiveUsers.add(u.Id);
        }
        REIDP_DataAnonymization.deleteAndAnonymizeCommunityUsers(inactiveUsers);
    }
    
    global void finish(Database.BatchableContext BC) {}
}