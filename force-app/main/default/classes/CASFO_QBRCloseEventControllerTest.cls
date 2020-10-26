/*****************************************************************************************
*	    Date:		    24April2020
*       Author:         Narasimha Datla 
*       Description:    Test class for CASFO_QBRCloseEventController
****************************************************************************************/

@isTest()
public class CASFO_QBRCloseEventControllerTest 
{
    @testSetup
    static void createAccountContactTestData() {
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.Sales_Organisation__c = 'US01';
        testCastrolUser.isActive = True;
        insert testCastrolUser;
        System.RunAs(testCastrolUser)
        {
            Account testAccount = SFO_TestDataService.createCustomerAccount();
            testAccount.Business_Unit__c = 'Lubricants - Automotive';
            testAccount.Sales_Organisation__c = 'UK01';
            insert testAccount;
            
            List<Contact> contactlist = new List<Contact>();
            contactlist.add(SFO_TestDataService.createContact(testAccount.Id));
            contactlist.add(SFO_TestDataService.createContact(testAccount.Id));
            for(Integer i=0; i<contactlist.size(); i++)
            {
                contactlist[i].Survey_Opt_Out__c = false;
                contactlist[i].Email = i+'testEmail@test121.com';
            }
            insert contactlist;
            
            Event newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.CASFO_Visit_Completed__c = True;
            newEvent.ownerId = testCastrolUser.Id; 
            newEvent.WhatId = testAccount.Id;
            newEvent.Description = 'Test description';
            insert newEvent;
            
            List<EventRelation> eventRelationList = new List<EventRelation>();
            for(Contact testContact : contactlist)
            {
                eventRelationList.add(new EventRelation(RelationID =testContact.Id,eventId = newEvent.Id ));    
            }
            insert eventRelationList;
            
            Survey__c testTemplate = new Survey__c (
                name = 'testtest',
                Active__c =true,
                CALCF_Brand__c = 'castrol',
                lcf_Channel__c = 'Quarterly Business Review',
                Sales_Organization__c = 'UK01',
                Language_Code__c = 'EN'
            );
            insert testTemplate;
            
            Survey_Question__c newQuestion = new Survey_Question__c(
                Survey__c = testTemplate.id,
            	OrderNumber__c = 5,
            	Question__c = 'How likely is it that you would recommend Castrol to a friend or colleague?',
            	CALCF_Question_Short_Name__c = 'NPS'
            );
            insert newQuestion;
        }
    }
    
    @isTest
    static void UpdateEventOnlyTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        Test.startTest();
        testEvent.Description = 'Description is updated';
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        testEvent = [Select Id,Description,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        system.assertEquals('Description is updated', testEvent.Description);
        List<SurveyTaker__c> testSurveryList = [Select Id From SurveyTaker__c Where Account__c =: testEvent.AccountId limit 1];
        system.assertEquals(0, testSurveryList.size(), 'SurveyTaker__c shouldn\'t have created when the Event.CASFO_QBR_Meeting_Status__c is not equal to completed ');
        
    }
    
    @isTest
    static void createSurveyTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        testEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
        Test.startTest();
        testEvent.Description = 'Description is updated';
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        testEvent = [Select Id,Description,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        system.assertEquals('Description is updated', testEvent.Description);
        List<SurveyTaker__c> testSurveryList = [Select Id From SurveyTaker__c Where Account__c =: testEvent.AccountId limit 1];
        system.assertEquals(1, testSurveryList.size(), 'SurveyTaker__c create when the Event.CASFO_QBR_Meeting_Status__c is not equal to completed ');
    }

    @isTest
    static void noAccountEventTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
		testEvent.WhatId = null;
        testEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
        testEvent.Description = 'Description is updated';
		update testEvent;
        testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];

        Test.startTest();
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        
        testEvent = [Select Id,CALCF_QBR_Surveyed__c,CALCF_QBR_Not_Surveyed__c,CALCF_QBR_Not_Surveyed_Reason__c
                           From Event Where Id=:testEvent.Id limit 1];
        system.assertEquals(FALSE, testEvent.CALCF_QBR_Surveyed__c,'CALCF_QBR_Surveyed__c value should be equal to false');
        system.assertEquals(TRUE, testEvent.CALCF_QBR_Not_Surveyed__c,'CALCF_QBR_Not_Surveyed__c should be equal to true');
        system.assertEquals('Survey Error 04', testEvent.CALCF_QBR_Not_Surveyed_Reason__c,'CALCF_QBR_Not_Surveyed_Reason__c should be equal to Survey Error 04');
    }
    
    @isTest
    static void noContactEventTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        testEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
        testEvent.Description = 'Description is updated';
		update testEvent;
        
		List<Contact> contactList = [Select Id,AccountId From Contact limit 2];  
        contactList[0].accountId = null;
        contactList[1].accountId = null;
        Update contactList;
        
        Test.startTest();
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        
        testEvent = [Select Id,CALCF_QBR_Surveyed__c,CALCF_QBR_Not_Surveyed__c,CALCF_QBR_Not_Surveyed_Reason__c
                           From Event Where Id=:testEvent.Id limit 1];
        system.assertEquals(FALSE, testEvent.CALCF_QBR_Surveyed__c,'CALCF_QBR_Surveyed__c value should be equal to false');
        system.assertEquals(TRUE, testEvent.CALCF_QBR_Not_Surveyed__c,'CALCF_QBR_Not_Surveyed__c should be equal to true');
        system.assertEquals('Survey Error 01', testEvent.CALCF_QBR_Not_Surveyed_Reason__c,'CALCF_QBR_Not_Surveyed_Reason__c should be equal to Survey Error 04');
    }
    
    @isTest
    static void noMatchingBusinessUnitEventTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        testEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
        testEvent.Description = 'Description is updated';
		update testEvent;
        
		Account testAccount = [Select Id From Account Where Id =: testEvent.AccountId];  
        testAccount.Business_Unit__c = '';
        Update testAccount;
        
        Test.startTest();
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        
        testEvent = [Select Id,CALCF_QBR_Surveyed__c,CALCF_QBR_Not_Surveyed__c,CALCF_QBR_Not_Surveyed_Reason__c
                           From Event Where Id=:testEvent.Id limit 1];
        system.assertEquals(FALSE, testEvent.CALCF_QBR_Surveyed__c,'CALCF_QBR_Surveyed__c value should be equal to false');
        system.assertEquals(TRUE, testEvent.CALCF_QBR_Not_Surveyed__c,'CALCF_QBR_Not_Surveyed__c should be equal to true');
        system.assertEquals('Survey Error 03', testEvent.CALCF_QBR_Not_Surveyed_Reason__c,'CALCF_QBR_Not_Surveyed_Reason__c should be equal to Survey Error 04');
    }

    @isTest
    static void noSurveysEventTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];

        Survey__c testSurvey = [Select Id From Survey__c limit 1];  
        testSurvey.Language_Code__c = 'Test';
        Update testSurvey;

        Test.startTest();
        testEvent.CASFO_QBR_Meeting_Status__c = 'Completed';
        testEvent.Description = 'Description is updated';
        CASFO_QBRCloseEventController.updateEvent(testEvent);
        Test.stopTest();
        
        testEvent = [Select Id,CALCF_QBR_Surveyed__c,CALCF_QBR_Not_Surveyed__c,CALCF_QBR_Not_Surveyed_Reason__c
                           From Event Where Id=:testEvent.Id limit 1];
        system.assertEquals(FALSE, testEvent.CALCF_QBR_Surveyed__c,'CALCF_QBR_Surveyed__c value should be equal to false');
        system.assertEquals(TRUE, testEvent.CALCF_QBR_Not_Surveyed__c,'CALCF_QBR_Not_Surveyed__c should be equal to true');
        system.assertEquals('Survey Error 02', testEvent.CALCF_QBR_Not_Surveyed_Reason__c,'CALCF_QBR_Not_Surveyed_Reason__c should be equal to Survey Error 04');
    }
    
    @isTest
    static void getContactsTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        Test.startTest();
        List<Contact> contactList = CASFO_QBRCloseEventController.getContacts(testEvent.Id);
        Test.stopTest();
        system.assert(!contactList.isEmpty() ,'getContacts should return contatcs');
    }

    @isTest
    static void getEventTest()
    {
        Event testEvent = [Select Id,CASFO_QBR_Meeting_Status__c,AccountId From Event limit 1];
        Test.startTest();
        testEvent = CASFO_QBRCloseEventController.getEvent(testEvent.Id);
        Test.stopTest();
        system.assert(testEvent != null,'getEvent should return an Event');
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}