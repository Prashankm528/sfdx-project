public with sharing class getContacts {
    
    @AuraEnabled
    public static list<case> getContactsList(){
        return [SELECT  id  from case WHERE accountId != null];
    }

    @AuraEnabled
    public static void addCaseToOpportunities(list<id> caseId , string AccountId){
        
        for(case c : [SELECT id from case WHERE id in: caseId]){
            c.accountId = AccountId;
            update c;
        }
    }
}