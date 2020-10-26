/****************************************************************************************************
 * Date          : 05-MAR-2020
 * Author        : Sunny Yap
 * Description   : Test class for Post Chatter.
 * Modifications : 05-MAR-2020 Initial
 ****************************************************************************************************/
@isTest(SeeAllData=true)
public with sharing class GCM_Post_Chatter_Test {
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

		List<GCM_Post_Chatter.InputData> inputDataList = new List<GCM_Post_Chatter.InputData>();
		GCM_Post_Chatter.InputData inputData = new GCM_Post_Chatter.InputData(request.Id, UserInfo.getUserId(), 'Test {!Link}');
		inputDataList.add(inputData);
		GCM_Post_Chatter.post(inputDataList);
		
        List<FeedItem> items = [select Id from FeedItem where ParentId = :request.Id];
        System.assert(items.size() > 0, 'Chatter Posted');
        
        Test.stopTest();
    }
}