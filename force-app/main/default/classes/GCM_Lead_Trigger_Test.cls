/****************************************************************************************************
 *  Date          : 25-AUG-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Lead_Trigger
 * Modifications  : 25-AUG-2020 SYAP - Initial
****************************************************************************************************/
@isTest
public with sharing class GCM_Lead_Trigger_Test 
{
/****************************************************************************************************
 * Test Queue Team Name
 ****************************************************************************************************/  
    @isTest static void validateQueueTeamName() {
		Test.startTest();
        User thisUser = (User) BPG_Error_Logger.queryFirstRecord('select Id, GCM_Team_Name__c, Sales_Organisation__c, Business_Unit__c from User where Id = \'' + UserInfo.getUserId() + '\'');
        System.runAs(thisUser) {
            thisUser.Sales_Organisation__c = 'AU0A';
            thisUser.Business_Unit__c = 'Lubricants - Automotive';
            update thisUser;
            
			// Create Test Queue
			Group testQueue = new Group(Type = 'Queue', Name = 'GCM Test Queue', DeveloperName = 'GCM_Test_Queue');
			insert testQueue;
			QueueSObject testQueueObject = new QueueSObject(SObjectType = 'Lead', QueueId = testQueue.Id);
			insert testQueueObject;

			// Create Unmapped Queue
			Group unmappedQueue = new Group(Type = 'Queue', Name = 'GCM Test Unmapped Queue', DeveloperName = 'GCM_Test_Unmapped_Queue');
			insert unmappedQueue;
			QueueSObject unmappedQueueObject = new QueueSObject(SObjectType = 'Lead', QueueId = unmappedQueue.Id);
			insert unmappedQueueObject;

			// Create Lead
			Lead newLead = new Lead();
			newLead.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'SFR_Site_Acquisition\' and SObjectType = \'Lead\'').Id;
			newLead.FirstName = 'Test';
            newLead.LastName = 'Test';
            newLead.Company = 'Test';
            newLead.OwnerId = testQueue.Id;
			Database.insert(newLead);
			System.assert(newLead.Id != null, 'Lead Created');
        
			List<Lead> leadList = [select Id, GCM_Owner_Team_Name__c, OwnerId from Lead where OwnerId = :testQueue.Id];
			System.assert(leadList.size() > 0, 'Lead Test Data Created');
			System.assert(leadList[0].GCM_Owner_Team_Name__c == 'Test', 'Team Name Assigned');
          
			// Change Owner
			leadList[0].OwnerId = unmappedQueue.Id;
			Database.update(leadList);
            
            // Update Current User Team Name
            thisUser.GCM_User_Team__c = 'Test_User';
            update thisUser;
            leadList[0].OwnerId = thisUser.Id;
            Database.update(leadList);

			leadList = [select Id, GCM_Owner_Team_Name__c, OwnerId from Lead where OwnerId = :thisUser.Id];
			System.assert(leadList.size() > 0, 'Lead Test Data Reassigned');
			System.assert(leadList[0].GCM_Owner_Team_Name__c == 'Test_User', 'User Team Name Assigned');
        }
        Test.stopTest();
    }
}