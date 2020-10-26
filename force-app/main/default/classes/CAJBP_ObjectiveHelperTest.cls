/**
 * @author Jan Majling
 * @date 23/08/2018
 * @group			CAJBP
 * @description     testing class for CAJBP_ObjectiveHelper
 * 
 * history
 * 23/08/2018	Jan Majling			Created 
 */
@isTest
private class CAJBP_ObjectiveHelperTest {
    @testSetup static void setup() {
        CAJBP_TestFactory.createUsers(1, 0);
        CAJBP_TestFactory.createJointBusinessPlan();
    }

    @isTest static void testShareObjectivesWithTeamMember() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c WHERE Name = 'Test Account Customer Group JBP 2080'].Id;
        CAJBP_JBP_Team_Member__c teamMember = CAJBP_TestFactory.createJBPTeamMember(userId, jbpId, 'Read Only', 'Others');
        List<CAJBP_Objective__c> objectives = new List<CAJBP_Objective__c>();
        Integer objectivesCount = 1;

        for(Integer i = 0; i < objectivesCount; i++ ) {
            CAJBP_Objective__c objective = new CAJBP_Objective__c(Name='Test Objective', CAJBP_Description__c = 'Test Decription',
                CAJBP_Joint_Business_Plan__c = jbpId
            );
            objectives.add(objective);
        }

        Test.startTest();
        insert objectives;
        Test.stopTest();

        Set<Id> objectiveIds = new Set<Id>();
        for(CAJBP_Objective__c objective : objectives) {
            objectiveIds.add(objective.Id);
        }
        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId IN :objectiveIds AND UserOrGroupId = :userId
        ];

        System.assertEquals(objectivesCount, objectiveShares.size());
    }

    @isTest static void testShareObjectivesWithoutJbp() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;

        CAJBP_Objective__c objective = new CAJBP_Objective__c(Name='Test Objective', CAJBP_Description__c = 'Test Decription');

        Test.startTest();
        insert objective;
        Test.stopTest();

        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId = :objective.Id AND UserOrGroupId = :userId
        ];

        System.assertEquals(0, objectiveShares.size());
    }

    @isTest static void testShareObjectivesWithNoTeamMember() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c WHERE Name = 'Test Account Customer Group JBP 2080'].Id;

        CAJBP_Objective__c objective = new CAJBP_Objective__c(
            //Name = 'Increase Sales By 5%',
            CAJBP_Joint_Business_Plan__c = jbpId,Name='Test Objective', CAJBP_Description__c = 'Test Decription'
        );

        Test.startTest();
        insert objective;
        Test.stopTest();

        List<CAJBP_Objective__Share> objectiveShares = [
            SELECT Id
            FROM CAJBP_Objective__Share
            WHERE ParentId = :objective.Id AND UserOrGroupId = :userId
        ];

        System.assertEquals(0, objectiveShares.size());
    }

    @isTest
    static void validateObjectiveCannotBeDeleteIfJBPInvalidState() {
        Id userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 1].Id;

        Contact contact = [select id, firstname, lastname from contact limit 1];

        CAJBP_Joint_Business_Plan__c plan  = [SELECT Id FROM CAJBP_Joint_Business_Plan__c WHERE Name = 'Test Account Customer Group JBP 2080'];
        plan.CAJBP_State__c = 'In Progress';
        plan.CAJBP_JBP_Start_Date__c=Date.today();
        plan.CAJBP_JBP_End_Date__c=Date.Today();
        plan.CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id;
        plan.CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today();
        plan.CAJBP_JBP_Agreed_Sign_Off__c=True;
        plan.CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id;
        plan.CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today();
        plan.CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True;
        update plan;

        CAJBP_Objective__c objective = new CAJBP_Objective__c(
            //Name = 'Increase Sales By 5%',
            CAJBP_Joint_Business_Plan__c = plan.Id,Name='Test Objective', CAJBP_Description__c = 'Test Decription'
        );

        insert objective;

        Test.startTest();
            try {
                delete objective;
                List<CAJBP_Objective__c> objectiveCount = [select id from CAJBP_Objective__c];
                System.assertEquals(0,objectiveCount.size(), 'Expecting validation you cannot delete object if JBP invalid state.');
            } catch(System.DmlException ex) 
            {
                System.debug(ex.getMessage());
            }
        Test.stopTest();
    }
}