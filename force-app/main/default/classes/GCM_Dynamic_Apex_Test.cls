/******************************************************************************************
 *  Date          : 11-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Dynamic_Apex
 * Modifications  : 11-MAR-2020 SYAP - Initial
 ******************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Dynamic_Apex_Test
{
/******************************************************************************************
  Test Dynamic Apex Run
 ******************************************************************************************/
	@isTest
    static void testRun() {        
        // Insert Data
        GCM_Automation__c positive = new GCM_Automation__c();
        positive.Name = 'Test Positive';
        String code = '';
        code += 'Task newTask = new Task();';
        code += 'newTask.Subject = \'Test Dynamic Apex\';';
        code += 'insert newTask;';
		positive.GCM_Code__c = code;
        insert positive;
        System.assert(positive.Id != null, 'Record Created');

        GCM_Automation__c negative = new GCM_Automation__c();
        negative.Name = 'Test Negative';
		negative.GCM_Code__c = 'Syntax Error';
        insert negative;
        System.assert(negative.Id != null, 'Record Created');
        
        List<User> users = [select Id from User where Id = :UserInfo.getUserId()];
        if (users.size() > 0) {
			System.runAs(users[0]) {
                // Test Positive Scenario
		        Test.startTest();
				GCM_Dynamic_Apex_Future.run('Test Positive', positive.Id);

                // Test Negative Scenario
				GCM_Dynamic_Apex_Future.run('Test Negative', negative.Id);
		        Test.stopTest();
            }
		}
        
	}
}