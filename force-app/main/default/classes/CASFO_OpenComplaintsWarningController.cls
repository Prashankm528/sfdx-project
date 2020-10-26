/************************************************************************************************************
* Description : Controller for custom lightning commponents to warn user when there are 5 or more open 
* complaints related to account.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-AUG-02   1.0                 Maros Zilka         Initial version
*
*************************************************************************************************************/

public without sharing class CASFO_OpenComplaintsWarningController {

    /************************************************************************
    * showOpenComplaintsWarning
    * ------------------------
    * Method used to determine whether to show warning on Account  
    ************************************************************************/

    @AuraEnabled
    public static Boolean showOpenComplaintsWarning(Id accountId) {
        List<Case> cases = [
            SELECT Id
            FROM Case
            WHERE AccountId = :accountId
            AND Complaint__c = TRUE
            AND IsClosed = FALSE
        ];
        
        return cases.size() >= 3;
    }

    /************************************************************************
    * getAccounts
    * ------------------------
    * Method used get List of all Accounts which are owned by logged in user
    * and for which there are 3 or more open complaints.
    ************************************************************************/
    
    @AuraEnabled
    public static List<Account> getAccounts() {
        Id userId = UserInfo.getUserId();
        List<Id> accountIds = new List<Id>();
        List<Account> accounts = new List<Account>();
        
        List<AggregateResult> aggregateResult = [
            SELECT AccountId
            FROM Case
            WHERE Complaint__c = TRUE AND IsClosed = FALSE AND Account.OwnerId = :userId
            GROUP BY AccountId
            HAVING COUNT(ID) >= 3
        ];
	
        for (AggregateResult result : aggregateResult) {
            accountIds.add((Id)result.get('AccountId'));
        }
        
        if (accountIds.isEmpty()) {
            return null;
        } else {
            return [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        }
    }
}