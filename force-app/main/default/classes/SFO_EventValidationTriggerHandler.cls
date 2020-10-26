/*****************************************************************************************
*	    Date:		    25NOV2019
*       Author:         Rahma Belghouti - Infosys
*       Description:    Validation before marking the Event as complete
*       Modifications:  10DEC2019 Rahma Belghouti - Restrict the validation for only selected users under SFO_Configuration_Settings__mdt
                        (settings with 'Event Tracker Validation' grouping name)
****************************************************************************************/
public with sharing class SFO_EventValidationTriggerHandler extends BPG_Trigger_Handler_Utilities {
        
    
    /*
    * Generates an error if the event assigned to the user (which sales organisation
    * is configured under SFO_Configuration_Settings__mdt with 'Event Tracker Validation' grouping name)
    * is completed without a description 
    */
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {      
        Set<Id> userIds = new Set<Id>();
        
        for(Event event: (List<Event>)newList){           
            userIds.add(event.OwnerId);            
        }
        Set<Id> selectedUsers = getSelectedUsers(userIds);
        for(Event event: (List<Event>)newList){
            
            if(event.CASFO_Visit_Completed__c == True && String.isBlank(event.Description)){
                if(selectedUsers.contains(event.OwnerId)){
                    event.addError(SFO_Constant.VALIDATION_MESSAGE);
                }
            }
        }     
    }
    
    
    /*
    * Generates an error if the event assigned to the user (which sales organisation
    * is configured under SFO_Configuration_Settings__mdt with 'Event Tracker Validation' grouping name)
    * is completed without a description or a note
    */
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        
        Set<Id> eventIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        for(Event event: (List<Event>)newList){           
            userIds.add(event.OwnerId);            
        }
        Set<Id> selectedUsers = getSelectedUsers(userIds);
        for(Event event: (List<Event>)newList){
            if(selectedUsers.contains(event.OwnerId)){
                eventIds.add(event.Id);
            }
        }
        if(eventIds.size()>0){
            Map<Id,AggregateResult> eventsAndNotes = new Map<Id,AggregateResult>([
                SELECT LinkedEntityId Id, COUNT(Id) notesCount
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :eventIds
                GROUP BY LinkedEntityId
                Having COUNT(Id) >= 1]);
            
            for(Event event: (List<Event>)newList){
                
                if(event.CASFO_Visit_Completed__c == True && String.isBlank(event.Description) && eventsAndNotes.get(event.Id) == null){
                    event.addError(SFO_Constant.VALIDATION_MESSAGE);
                }
            }   
        } 
    }
    
    /*
    * Returns the users with sales organisations matching
    * the configured ones under SFO_Configuration_Settings__mdt with 'Event Tracker Validation' grouping name
    */
    public static Set<Id> getSelectedUsers(Set<Id> userIds){
        List<String> salesOrganisationList;
        if(Test.isRunningTest()){
            salesOrganisationList = new List<String>{'US01', 'ZA0A'};
        }else{
            salesOrganisationList = SFO_CustomMetadataUtility.getConfigSettingStringVal(SFO_Constant.VALIDATION_GROUP);
        }
        Set<Id> resultIds = new Map<Id, User>([SELECT Id FROM User WHERE isActive = true AND Sales_Organisation__c IN :salesOrganisationList AND Id IN :userIds]).keySet();
        return resultIds;
    }
}