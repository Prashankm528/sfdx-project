/************************************************************************************************************
* Description : Controller for QBR Event Closer component.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-08-10    1.0					Maros Zilka			Initial version
*
*************************************************************************************************************/

public with sharing class CASFO_QBRCloseEventController {
    
    @AuraEnabled
    public static Event getEvent(Id recordId) {
        return [SELECT Id, Subject, Type, CASFO_QBR_Meeting_Status__c, CASFO_QBR_Closed__c, AccountId
                FROM Event
                WHERE Id = :recordId];
    }
    
    @AuraEnabled
    public static void updateEvent(Event e) {
        system.debug('Update Event...');
        
        if (e.CASFO_QBR_Meeting_Status__c == 'Completed') {
        	createSurveys(e);
        } else {
            update e;
        }
    }
    
    @AuraEnabled
    public static List<Contact> getContacts(Id recordId) {
        Set<Id> relationIds = new Set<Id>();
        
        List<EventRelation> relations = [SELECT Id, RelationID FROM EventRelation WHERE EventId = :recordId];

        for (EventRelation er : relations) {
            relationIds.add(er.RelationID);
        }
        
        return [SELECT Id, Name, Survey_Opt_Out__c FROM Contact WHERE Id IN :relationIds];
    }
    
    private static void createSurveys(Event event) {
        Account account;
        List<Account> accounts = getAccounts(event);
        
        // Check if there is Account related
        if (accounts.isEmpty()) {
            setEventAsSurveyed(event, false, 'Survey Error 04');
            return;
        }
        
        account = accounts[0];
        
        event.CALCF_QBR_Account_ERP_ID__c = account.Account_ERP_ID__c;
        
        // Check if Account has supported BU
        if (account.Business_Unit__c != 'Lubricants - Automotive' &&
            account.Business_Unit__c != 'Lubricants - Industrial') {
        	
            setEventAsSurveyed(event, false, 'Survey Error 03');
            return;
        }
        
        List<Contact> contacts = getSurveyableContacts(event);
        
        // Check if there are surveyable contacts
        if (contacts.isEmpty()) {
            system.debug('No contacts found...');
            setEventAsSurveyed(event, false, 'Survey Error 01');
            return;
        }
        
        Map<String, Survey__c> surveyTemplatesMap;
        surveyTemplatesMap = getSurveyTemplatesMap(account.Sales_Organisation__c);
        
        system.debug(surveyTemplatesMap);
        Id recordTypeID = Schema.SObjectType.SurveyTaker__c.getRecordTypeInfosByName()
            .get('Quarterly Business Review').getRecordTypeId();
        
        system.debug('Record Type Id ' + recordTypeId);
        
        List<SurveyTaker__c> surveys = new List<SurveyTaker__c>();
        
        for (Contact c : contacts) {
            if (surveyTemplatesMap.containsKey(c.Prefered_Language_Code__c)) {
                SurveyTaker__c st = new SurveyTaker__c();
                
				st.RecordTypeId = recordTypeID;
                st.Account__c = account.Id;
                st.CALCF_QBR_Event_Id__c = event.Id;
                st.CALCF_QBR_Sales_CES__c = event.CALCF_QBR_Sales_CES__c;
                st.CALCF_QBR_Sales_NPS__c = event.CALCF_QBR_Sales_NPS__c;
                st.CALCF_QBR_Sales_Q_Not_Filled_Reason__c = event.CALCF_QBR_Sales_Q_Not_Filled_Reason__c;
                st.CALCF_QBR_Sales_Questions_Filled__c = event.CALCF_QBR_Sales_Questions_Filled__c;
                st.Contact__c = c.Id;
                st.Mode__c = 'Batch';
                st.Sales_Organisation__c = account.Sales_Organisation__c;
                st.Source_System__c = 'SalesForce';
                st.Survey__c = surveyTemplatesMap.get(c.Prefered_Language_Code__c).Id;
                st.CALCF_QBR_Requester__c = account.CASFO_QBR_Requester__c;
                st.CALCF_QBR_Closed_By__c = UserInfo.getUserId();
                
                surveys.add(st);
                
                system.debug('Survey added ' + st);
                
                c.CALCF_QBR_Surveyed_Date__c = datetime.now();
            }            
        }
        
        if (surveys.isEmpty()) {
            setEventAsSurveyed(event, false, 'Survey Error 02');
        } else {
            setEventAsSurveyed(event, true, 'Survey Error 00');

            update contacts;
            insert surveys;
        }
    }
    
    private static List<Account> getAccounts(Event event) {
        return [SELECT Id, Sales_Organisation__c, Business_Unit__c, CASFO_QBR_Requester__c, Account_ERP_ID__c
                FROM Account 
                WHERE Id = :event.AccountId];
    }
    
    private static List<Contact> getSurveyableContacts(Event event) {
        List<EventRelation> eventRelations = [SELECT Id, RelationId 
                                              FROM EventRelation 
                                              WHERE EventId = :event.Id];
        Set<Id> RelationIds = new Set<Id>();
        
        for (EventRelation er : eventRelations) {
            RelationIds.add(er.RelationId);
        }
        
        return [SELECT Id, Name, Prefered_Language_Code__c
                                  FROM Contact
                                  WHERE Email != null
                                  AND Survey_Opt_Out__c = false
                                  AND Id IN :RelationIds];
    }
    
    private static Map<String, Survey__c> getSurveyTemplatesMap(String SalesOrg) {
        Map<String, Survey__c> templatesMap = new Map<String, Survey__c>();
        List<Survey__c> surveys = [SELECT Id, Language_Code__c FROM Survey__c 
                           WHERE Active__c = true
                           AND CALCF_Brand__c = 'castrol'
                           AND Sales_Organization__c = :SalesOrg
                           AND lcf_Channel__c = 'Quarterly Business Review'];
        
        for (Survey__c s : surveys) {
            templatesMap.put(s.Language_Code__c, s);
        }
        
        return templatesMap;
    }
    
    private static void setEventAsSurveyed(Event event, Boolean surveyed, String error) {
    	event.CALCF_QBR_Surveyed__c = surveyed;
        event.CALCF_QBR_Not_Surveyed__c = !surveyed;
        event.CALCF_QBR_Not_Surveyed_Reason__c = error;
        
        update event;
    }
}