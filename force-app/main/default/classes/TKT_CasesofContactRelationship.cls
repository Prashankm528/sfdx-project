/*****************************************************************************************
*       Date:           22Jul2020
*       Author:         Himanshu Bansal
*       Description:    Created for My Relationship Contact Open Cases component
*****************************************************************************************/
public with sharing class TKT_CasesofContactRelationship {

    @AuraEnabled
    public static List<CaseWrapper> getCaseRecords(){
        List<CaseWrapper> fewCaseToDisplay = new List<CaseWrapper>();
        List<CaseWrapper> allCase = new List<CaseWrapper>();
        allCase.addAll(getAllCaseRecords());
        Integer maxInt = 5;
        
        if(allCase.size() > maxInt){
            for(Integer i = 0; i<maxInt; i++){
                fewCaseToDisplay.add(allCase[i]);
            }
            return fewCaseToDisplay;
        }
        else{
            return allCase;
        }
        
    }
    
    @AuraEnabled
    public static List<CaseWrapper> getAllCaseRecords(){
        Id userId = UserInfo.getUserId();
        Set<Id> contactIdsFromRelation = new Set<Id>();
        List<CaseWrapper> caseToDisplay = new List<CaseWrapper>();
        
        List<ICRM_Contact_Relationship__c> userRelationship = [SELECT ICRM_Contact__c FROM ICRM_Contact_Relationship__c WHERE ICRM_Active__c = True AND ICRM_User_Name__c = :userId];
        for(ICRM_Contact_Relationship__c relation : userRelationship){
            contactIdsFromRelation.add(relation.ICRM_Contact__c);
        }
         List<Case> caseList = [SELECT Id, CaseNumber, Status,Priority, Subject,TKT_Case_Age__c, TKT_Company__c, ContactEmail, Origin, CreatedDate FROM Case WHERE ContactId IN :contactIdsFromRelation AND status != 'Closed' AND RecordType.DeveloperName = 'TKT_Ticketing' Order By CaseNumber DESC];
          if(caseList!= null && !caseList.isEmpty()){
            for(Case caseRec : caseList){
                caseToDisplay.add(createCaseColumns(caseRec));
            }
            
        }
            return caseToDisplay;
        
    }
    
    public static CaseWrapper createCaseColumns(Case caseList){
        CaseWrapper csWrap = new CaseWrapper();
        csWrap.caseNumber = caseList.CaseNumber;  
        csWrap.caseNumberUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/'+caseList.Id;
        csWrap.caseStatus = caseList.status;
        csWrap.caseWebemail = caseList.ContactEmail;
        csWrap.caseOrigin = caseList.Origin;
        csWrap.caseCreatedate = caseList.CreatedDate;
        csWrap.casePriority = caseList.Priority;
    csWrap.caseSubject = caseList.Subject;
        csWrap.caseCompany = caseList.TKT_Company__c;
        csWrap.caseAge = caseList.TKT_Case_Age__c;
       return csWrap;
    }
    
    public with sharing class CaseWrapper{
         @AuraEnabled public String caseNumber {get;set;}
         @AuraEnabled public String caseNumberUrl {get;set;}
         @AuraEnabled public String caseStatus {get;set;}
         @AuraEnabled public String caseWebemail {get;set;}
         @AuraEnabled public String caseOrigin {get;set;} 
         @AuraEnabled public Datetime caseCreatedate {get;set;}
         @AuraEnabled public String casePriority {get;set;}
         @AuraEnabled public String caseSubject {get;set;}
         @AuraEnabled public String caseCompany {get;set;}
         @AuraEnabled public String caseAge {get;set;}
}
}