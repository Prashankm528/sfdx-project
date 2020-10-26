public without sharing class DUP_FAQ_RecordsController {
	@AuraEnabled(cacheable=true)
    public static list<DUP_FAQ__c> getRelatedRecords(){
        
        list<DUP_FAQ__c> FAQsearchresult = [SELECT Id,DUP_Title__c from DUP_FAQ__c ORDER BY DUP_Record_views__c DESC LIMIT 5];
        return FAQsearchresult;
    }
    @AuraEnabled(cacheable=true)
    public static list<DUP_FAQ__c> getSearchedRecords(string searchTerm){
        string searchKey = '%'+searchTerm+'%';
        list<DUP_FAQ__c> FAQsearchResult = [SELECT Id,DUP_Title__c FROM DUP_FAQ__c WHERE DUP_Title__c LIKE :searchKey LIMIT 5];
        return FAQsearchresult;
    }
    
    @AuraEnabled(cacheable=false)
    public static DUP_FAQ__c updateRecordViews(ID FAQ_recordid){
        DUP_FAQ__c FAQ_record = [SELECT id,DUP_Record_views__c FROM DUP_FAQ__c WHERE id =: FAQ_recordid][0];
        
            FAQ_record.DUP_Record_views__c +=1;
       
        //system.debug(FAQ_record.Record_views__c);
        update FAQ_record;
        return FAQ_record;
    }
}