/**************************************************************************************************************************************
* Description : test the different scenarios to SFO_Set_Opportunity_Offer_Date_Presented.flow
*
*
* Date          Version #           Author                  Description
* -----------------------------------------------------------------------------------------------------------
*
* 30-04-2020   1.0                 Varma Datla       Initial version
***************************************************************************************************************************************/
@isTest
private class SFO_SetOpportunityOfferDatePresentedTest 
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    
    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
    }
    
    @isTest
    static void eventswithOffersonlyTest()
    {
        User testUser = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
        
        Account testCustomerAccount = SFO_TestDataService.createCustomerAccount();
        insert testCustomerAccount;
        
        Opportunity testOpportunity = SFO_TestDataService.createCastrolOpportunity(testCustomerAccount.Id);
        insert testOpportunity;

        SFO_Offer__c Offer = SFO_TestDataService.createOffer(testOpportunity.Id);
        insert offer;
        
        SFO_Opportunity_Offer__c opportunityOffer = SFO_TestDataService.createOpportunityOffer(testOpportunity.Id,offer.Id);
        insert opportunityOffer;
       
        Event newEvent;
        Test.startTest();
        system.runAs(testUser) 
        {
            newEvent =  SFO_TestDataService.createEvent(returnRecordTypeId('SFO Event'));
            newEvent.ownerId = testUser.Id; 
            newEvent.whatId = testOpportunity.Id;
            newEvent.SFO_Opportunity_Offer__c = opportunityOffer.Id;
            newEvent.StartDateTime = datetime.now();
            newEvent.EndDateTime = datetime.now();
            insert newEvent;
        }
        Test.stopTest();
        opportunityOffer = [Select Id,SFO_Date_Presented__c  From SFO_Opportunity_Offer__c Where Id =: newEvent.SFO_Opportunity_Offer__c limit 1];
        System.assertEquals(newEvent.EndDateTime.date(), opportunityOffer.SFO_Date_Presented__c,'Opportunity Offer SFO_Date_Presented__c value should be equal to Event EndDateTime');
    }

     private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}