/*****************************************************************************************
*	    Date:		    25NOV2019
*       Author:         Rahma Belghouti - Infosys
*       Description:    Test class for SFO_EventValidationTriggerHandler
*       Modifications:  10DEC2019 Rahma Belghouti - Restrict the validation for only selected users under SFO_Configuration_Settings__mdt
                        (settings with 'Event Tracker Validation' grouping name)
****************************************************************************************/
@isTest
public with sharing class SFO_EventValidationTriggerHandlerTest {
    
    @isTest
    private static void itShouldReturnErrorOnInsert(){
        try{
            User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
            testCastrolUser.Sales_Organisation__c = 'US01';
            testCastrolUser.isActive = True;
            insert testCastrolUser;
            
            System.runAs(testCastrolUser) 
            {
                Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
                newEvent.CASFO_Visit_Completed__c = True;
                newEvent.ownerId = testCastrolUser.Id; 
                insert newEvent;
            }
        }Catch(Exception e){           
            Boolean expectedThrownException = e.getMessage().contains(SFO_Constant.VALIDATION_MESSAGE) ? true : false;
            System.assertEquals(expectedThrownException, true);
        }
    }
    
    @isTest
    private static void itShouldReturnErrorOnUpdate(){
        try{
            User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
            testCastrolUser.Sales_Organisation__c = 'US01';
            testCastrolUser.isActive = True;
            insert testCastrolUser;
            System.runAs(testCastrolUser) 
            {
                Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
                newEvent.ownerId = testCastrolUser.Id;            
                insert newEvent;
                newEvent.CASFO_Visit_Completed__c = True;
                update newEvent;
            }
        }Catch(Exception e){           
            Boolean expectedThrownException = e.getMessage().contains(SFO_Constant.VALIDATION_MESSAGE) ? true : false;
            System.assertEquals(expectedThrownException, true);
        }
    }
    
    @isTest
    private static void itShouldMarkEventCompletedUsingDescription(){
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.isActive = True;    
        insert testCastrolUser;
        System.runAs(testCastrolUser) 
        {
            Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));           
            newEvent.ownerId = testCastrolUser.Id; 
            insert newEvent;
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.Description = 'Test Description';
            update newEvent;
            System.Assert(newEvent.Description != null, 'Description should not be null');
        }
        
    }
    
    @isTest
    private static void itShouldMarkEventCompletedUsingNotes(){ 
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.isActive = True;    
        insert testCastrolUser;
        System.runAs(testCastrolUser) 
        {
            Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.ownerId = testCastrolUser.Id;           
            insert newEvent;
            
            ContentVersion content = SFO_TestDataService.createContent();
            insert content;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink note = SFO_TestDataService.createDocumentLink(documents[0].Id, newEvent.Id);
            insert note;
            
            
            newEvent.CASFO_Visit_Completed__c = True;
            update newEvent;
            System.Assert(newEvent.Description == null, 'It should be ok for description to be null');
        }
        
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}