/****************************************************************************************************
 *  Date          : 25-AUG-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Opportunity_Trigger
 * Modifications  : 25-AUG-2020 SYAP - Initial
****************************************************************************************************/
@isTest
public with sharing class GCM_Opportunity_Trigger_Test 
{
/****************************************************************************************************
 * Test Queue Team Name
 ****************************************************************************************************/  
    @isTest static void validateQueueTeamName() {
        Test.startTest();
        User thisUser = (User) BPG_Error_Logger.queryFirstRecord('select Id, GCM_Team_Name__c from User where Id = \'' + UserInfo.getUserId() + '\'');
        System.runAs(thisUser) {          
			// Create Test Account
        	Account testAccount = new Account();
        	testAccount.Name = 'Test';
			testAccount.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'Customer\' and SObjectType = \'Account\'').Id;
			insert testAccount;

			// Update Current User Team Name
        	thisUser.GCM_User_Team__c = 'Test_User';
        	update thisUser;
            
			// Create Opportunity
        	Opportunity newOpty = new Opportunity();
        	newOpty.RecordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'SFR_Site_Opportunity\' and SObjectType = \'Opportunity\'').Id;
        	newOpty.Name = 'Test';
        	newOpty.OwnerId = thisUser.Id;
			newOpty.StageName = 'Lead';
			newOpty.AccountId = testAccount.Id;
			newOpty.CloseDate = Date.today();            
			Database.insert(newOpty);
        	System.assert(newOpty.Id != null, 'Opportunity Created');
            
        	List<Opportunity> optyList = [select Id, GCM_Owner_Team_Name__c, OwnerId from Opportunity where OwnerId = :thisUser.Id];
        	System.assert(optyList.size() > 0, 'Opportunity Test Data Reassigned');
        	System.assert(optyList[0].GCM_Owner_Team_Name__c == 'Test_User', 'User Team Name Assigned');
            
            List<User> otherUser = [select Id from User order by CreatedDate desc limit 1];
            System.assert(otherUser.size() == 1, 'Other User Found');
            optyList[0].OwnerId = otherUser[0].Id;
            update optyList;
        }
        Test.stopTest();
    }
}