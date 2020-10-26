/*****************************************************************************************
*   Date:         11/07/2020
*   Author:      Pooja Deokar
*   Description:  Test class for monthly and quaterly scheduele class
****************************************************************************************/
@isTest
public with sharing class PCRM_CloneOpportunityHierarchyTest {
	//test method to cover PCRM_CloneOpportunityHierarchyMonthly class
   	static testMethod void testPCRM_CloneOpportunityHierarchyMonthly(){
        Test.startTest();
        PCRM_CloneOpportunityHierarchyMonthly sh1 = new PCRM_CloneOpportunityHierarchyMonthly();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test PCRM_CloneOpportunityHierarchyMonthly', sch, sh1); 
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOpportunityHierarchyMonthly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

        Test.stopTest(); 
    }
    //test method to cover PCRM_CloneOpportunityHierarchyQuarterly class
   	static testMethod void testPCRM_CloneOpportunityHierarchyQuarterly(){
        Test.startTest();
        PCRM_CloneOpportunityHierarchyQuarterly sh1 = new PCRM_CloneOpportunityHierarchyQuarterly();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test PCRM_CloneOpportunityHierarchyQuarterly', sch, sh1); 
     	List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOpportunityHierarchyQuarterly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

        Test.stopTest(); 
    }
 
}