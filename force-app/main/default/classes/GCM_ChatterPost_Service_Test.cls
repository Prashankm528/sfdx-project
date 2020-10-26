/****************************************************************************************************
 * Date          : 28-MAY-2020
 * Author        : IBM
 * Description   : Test class for GCM_ChatterPost_Service class.
 * Modifications : 28-MAY-2020 Initial
 ****************************************************************************************************/
@isTest(SeeAllData=true)
public with sharing class GCM_ChatterPost_Service_Test {
/******************************************************************************************
  Test Post Chatter
 ******************************************************************************************/
	@isTest static void testPostChatter() {
        Test.startTest();
        
		// Create Case
        Case request = new Case();
        request.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        request.Type = 'Test';
        request.Area__c = 'Test';
        request.Sub_Area__c = 'Test';
        request.Description = 'Test';
        request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert request;
        System.assert(request.Id != null, 'Case Created');
		
        GCM_ChatterPost_Service.notifyCaseOwner(new List<Id>{request.Id});
		
        List<FeedItem> items = [select Id from FeedItem where ParentId = :request.Id];
        System.assert(items.size() > 0, 'Chatter Posted');
        
        Test.stopTest();
    }
}