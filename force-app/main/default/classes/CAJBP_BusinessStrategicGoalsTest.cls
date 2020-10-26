/**
* Unit tests for Business Strategic Goals.
*/
@IsTest
private class CAJBP_BusinessStrategicGoalsTest {

    class DAOMock extends CAJBP_BusinessStrategicGoals.DAO {
        public override List<CAJBP_Business_Strategic_Goal__c> getJbpGoals(String jbpId,String year, String clt, Integer rows) {

            super.getJbpGoals(jbpId, year, clt, rows);
            List<CAJBP_Business_Strategic_Goal__c> goals = new List<CAJBP_Business_Strategic_Goal__c>();

            if (year == '2025' && clt == 'Europe') {
                for (Integer i = 0; i < rows; i++) {
                    goals.add(CAJBP_TestFactory.createBusinessGoal('Indirect Joint Business Plan','test', '2025', 'Europe'));
                }
            }

            return goals;
        }
    }

    @IsTest
    static void itShouldReturnGoals() {
        CAJBP_BusinessStrategicGoals.DataService = new DAOMock();
        Id jbpId = [SELECT id FROM CAJBP_JOINT_BUSINESS_PLAN__C LIMIT 1].Id;
        Test.startTest();
            System.assertEquals(false, CAJBP_BusinessStrategicGoals.getJbpGoals(jbpId,'2025', 'Europe', 10).isEmpty());
            System.assertEquals(false, CAJBP_BusinessStrategicGoals.getJbpCustomGoals(jbpId,'2025', 'Europe',10).isEmpty());
        Test.stopTest();
    }

    @IsTest
    static void itShouldNotReturnGoals() {
        CAJBP_BusinessStrategicGoals.DataService = new DAOMock();
        Id jbpId = [SELECT id FROM CAJBP_JOINT_BUSINESS_PLAN__C LIMIT 1].Id;
        Test.startTest();
            System.assertEquals(true, CAJBP_BusinessStrategicGoals.getJbpGoals(jbpId,'2015', 'Europe', 10).isEmpty());
            System.assertEquals(true, CAJBP_BusinessStrategicGoals.getJbpCustomGoals(jbpId,'2015', 'Europe', 10).isEmpty());
            System.assertEquals(true, CAJBP_BusinessStrategicGoals.getJbpGoals(null,null, null, null).isEmpty());
            System.assertEquals(true, CAJBP_BusinessStrategicGoals.getJbpCustomGoals(null,null, null, null).isEmpty());
        Test.stopTest();
    }

    @IsTest
    static void standardJbpUserShouldNotBeAbleToCreateBusinessGoalAndHaveReadOnlyFieldAccess() {
        User testUser = CAJBP_TestFactory.createUsers(1, 1)[0];
        CAJBP_TestFactory.createPermissionSetAssignment(testUser.Id, CAJBP_TestFactory.STANDARD_USER_PERMISSION_SET);

        //Verify the permission set was assigned.
        System.assertEquals(1, [
            SELECT Id FROM PermissionSetAssignment
                WHERE PermissionSet.Label = :CAJBP_TestFactory.STANDARD_USER_PERMISSION_SET
                    AND AssigneeId = :testUser.Id
        ].size());

        Test.startTest();
            System.runAs(testUser) {
                //Check object permissions.
                System.assertEquals(false, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isCreateable());
                System.assertEquals(false, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isUpdateable());
                System.assertEquals(false, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isDeletable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isAccessible());

                //Check field permissions.
                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Description__c.getDescribe().isAccessible());
                System.assertEquals(false, CAJBP_Business_Strategic_Goal__c.CAJBP_Description__c.getDescribe().isUpdateable());

                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Year__c.getDescribe().isAccessible());
                System.assertEquals(false, CAJBP_Business_Strategic_Goal__c.CAJBP_Year__c.getDescribe().isUpdateable());

                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_CLT__c.getDescribe().isAccessible());
                System.assertEquals(false, CAJBP_Business_Strategic_Goal__c.CAJBP_CLT__c.getDescribe().isUpdateable());
            }
        Test.stopTest();
    }

    @IsTest
    static void adminJbpUserShouldBeAbleToCreateBusinessGoalAndHaveEditFieldAccess() {
        User testUser = CAJBP_TestFactory.createUsers(1, 1)[0];
        CAJBP_TestFactory.createPermissionSetAssignment(testUser.Id, CAJBP_TestFactory.ADMIN_USER_PERMISSION_SET);

        //Verify the permission set was assigned.
        System.assertEquals(1, [
            SELECT Id FROM PermissionSetAssignment
                WHERE PermissionSet.Label = :CAJBP_TestFactory.ADMIN_USER_PERMISSION_SET
                    AND AssigneeId = :testUser.Id
        ].size());

        Test.startTest();
            System.runAs(testUser) {
                //Check object permissions.
                System.assertEquals(true, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isCreateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isUpdateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isDeletable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Business_Strategic_Goal__c.isAccessible());

                //Check field permissions.
                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Description__c.getDescribe().isAccessible());
                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Description__c.getDescribe().isUpdateable());

                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Year__c.getDescribe().isAccessible());
                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_Year__c.getDescribe().isUpdateable());

                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_CLT__c.getDescribe().isAccessible());
                System.assertEquals(true, CAJBP_Business_Strategic_Goal__c.CAJBP_CLT__c.getDescribe().isUpdateable());
            }
        Test.stopTest();
    }
    @TestSetup
    static void createTestData(){
        string recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByName().get('Indirect Joint Business Plan').getRecordTypeId();
        CAJBP_JOINT_Business_plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan('2025', 'Draft','Europe',recordTypeId);
    }
}