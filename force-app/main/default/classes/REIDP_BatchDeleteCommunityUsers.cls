/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 4/2019
*
*/
global class REIDP_BatchDeleteCommunityUsers implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Email, Contact.AccountId, LastLoginDate, CreatedDate ' +
            			'FROM User WHERE IsActive = TRUE AND Profile.Name LIKE \'RE IDP External Identity%\'';
        
        //Limiting result to one, cause no more than one executeBatch can be called from within test method
        if(Test.isRunningTest())
            query += ' LIMIT 1';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> users) {
        List<String> communityUsers = new List<String>();

        for (User u : users){
            communityUsers.add(u.Id);
        }
        
        REIDP_DataAnonymization.deleteAndAnonymizeCommunityUsers(communityUsers);
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    
}