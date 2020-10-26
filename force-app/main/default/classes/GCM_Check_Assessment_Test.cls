/****************************************************************************************************
 *  Date          : 22-JAN-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Check_Assessment
 * Modifications  : 22-JAN-2020 SYAP - Initial
 * 					15-MAY-2020 SYAP - Added Trail Attribute
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Check_Assessment_Test 
{
/****************************************************************************************************
 * Create Metadata / Test Results
 ****************************************************************************************************/   
    @isTest static void validateResults() {
		// Create Achievement
        GCM_Achievement__c achievement = new GCM_Achievement__c();
        achievement.Name = 'GCM_Test';
        achievement.GCM_Message__c = 'Success';
        achievement.GCM_Email__c = 'test@bp.com';
        achievement.GCM_Trail__c = 'Trail';
        insert achievement;
        System.assert(achievement.Id != null, 'Achievement Created');
        
        // Create Child Goals
        GCM_Goal__c goal = new GCM_Goal__c();
        goal.Name = 'GCM_Goal';
        goal.GCM_SOQL__c = 'select Id from Task where CreatedById = \'{!UserId}\' and Subject = \'GCM_Check_Assessment_Test\'';
        goal.GCM_Message__c = 'Task Not Created';
        goal.GCM_Achievement__c = achievement.Id;
        insert goal;
        System.assert(goal.Id != null, 'Goal Created');

		PageReference reference = Page.GCM_Check_Assessment;
		Test.setCurrentPage(reference);
		ApexPages.currentPage().getParameters().put('code', 'GCM_Test');
        GCM_Check_Assessment assessment = new GCM_Check_Assessment();
        assessment.checkResults();
        
        Task newTask = new Task();
        newTask.Subject = 'GCM_Check_Assessment_Test';
        insert newTask;
        assessment.checkResults();
		System.assert(assessment.message == 'Success', 'Assessment Passed');
    }
}