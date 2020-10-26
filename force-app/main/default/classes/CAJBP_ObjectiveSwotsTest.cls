@IsTest
private with sharing class CAJBP_ObjectiveSwotsTest {
    static final BPG_TestDataService.SObjectCreator RecordService = new BPG_TestDataService.SObjectCreator();
    static final Account JbpAccount = CAJBP_TestFactory.createCustomerMock();
    static final CAJBP_Joint_Business_Plan__c JbpPlan = CAJBP_TestFactory.createJointBusinessPlanMock(JbpAccount);
    static final CAJBP_Objective__c JbpObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
    static CAJBP_SWOT__c TargetSwot = CAJBP_TestFactory.createSwotMock(JbpPlan, 'Strength');
    static CAJBP_Objective_SWOT__c TargetObjectiveSwot = null;
    static List<SObject> TargetRecords = null;

    class MockDmlProvider extends CAJBP_ObjectiveSwots.DmlProvider {
        Boolean isError = false;

        MockDmlProvider() {}
        MockDmlProvider(Boolean isError) { this.isError = isError; }

        public override void insertRecords(List<SObject> records) {
            if (isError) {
                throw new NullPointerException();
            }

            try {
                super.insertRecords(records);
            } catch(System.Exception ex) {
                System.debug(ex);
            }

            for (SObject record :records) {
                record.put('Id', RecordService.generateId(record.getSObjectType()));
            }

            TargetRecords = new List<SObject>(records);
        }

        public override void upsertRecords(List<SObject> records) {
            if (isError) {
                throw new NullPointerException();
            }

            try {
                super.upsertRecords(records);
            } catch(System.Exception ex) {
                System.debug(ex);
            }

            for (SObject record :records) {
                if (record.get('Id') != null) {
                    record.put('Id', RecordService.generateId(record.getSObjectType()));
                }
            }

            TargetRecords = new List<SObject>(records);
        }

        public override void deleteRecords(List<SObject> records) {
            if (isError) {
                throw new NullPointerException();
            }

            try {
                super.deleteRecords(records);
            } catch(System.Exception ex) {
                System.debug(ex);
            }

            TargetRecords = new List<SObject>();
        }
    }

    public class MockDAOProvider extends CAJBP_ObjectiveSwots.DAOProvider {
        Boolean isError = false;

        MockDAOProvider() {}
        MockDAOProvider(Boolean isError) { this.isError = isError; }

        public override List<CAJBP_SWOT__c> getJbpSwots(ID jbpId) {
            if (isError) {
                throw new NullPointerException();
            }

            super.getJbpSwots(jbpId);
            List<CAJBP_SWOT__c> swots = new List<CAJBP_SWOT__c>();

            for (Integer i = 0; i < 10; i++) {
                String type = 'Strength';

                switch on i {
                    when 0 {
                        type = 'Strength';
                    }
                    when 1 {
                        type = 'Opportunity';
                    }
                    when 2 {
                        type = 'Weakness';
                    }
                    when 3 {
                        type = 'Threat';
                    }
                }

                swots.add(CAJBP_TestFactory.createSwotMock(JbpPlan, type));
            }

            return swots;
        }

        public override List<CAJBP_Objective_SWOT__c> getObjectiveSwots(ID objectiveId) {
            if (isError) {
                throw new NullPointerException();
            }

            super.getObjectiveSwots(objectiveId);
            List<CAJBP_Objective_SWOT__c> swots = new List<CAJBP_Objective_SWOT__c>();

            for (Integer i = 0; i < 10; i++) {
                swots.add(CAJBP_TestFactory.createObjectiveSwotMock(TargetSwot, JbpObjective));
            }

            if (TargetObjectiveSwot != null) {
                swots.add(TargetObjectiveSwot);
            }

            return swots;
        }
    }

    @IsTest
    static void standardUserShouldBeAbleToCreateAndReadObjectiveSwots() {
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
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isCreateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isUpdateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isDeletable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isAccessible());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective__c.isCreateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_SWOT__c.isCreateable());

                //Check field permissions.
                System.assertEquals(true, CAJBP_Objective_SWOT__c.CAJBP_Objective__c.getDescribe().isAccessible());
                System.assertEquals(true, CAJBP_Objective_SWOT__c.CAJBP_SWOT__c.getDescribe().isAccessible());
            }
        Test.stopTest();
    }

    @IsTest
    static void adminUserShouldBeAbleToCreateAndReadObjectiveSwots() {
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
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isCreateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isUpdateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isDeletable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective_SWOT__c.isAccessible());
                System.assertEquals(true, Schema.SObjectType.CAJBP_Objective__c.isCreateable());
                System.assertEquals(true, Schema.SObjectType.CAJBP_SWOT__c.isCreateable());

                //Check field permissions.
                System.assertEquals(true, CAJBP_Objective_SWOT__c.CAJBP_Objective__c.getDescribe().isAccessible());
                System.assertEquals(true, CAJBP_Objective_SWOT__c.CAJBP_SWOT__c.getDescribe().isAccessible());
            }
        Test.stopTest();
    }

    @IsTest
    static void itShouldReturnSwots() {
        CAJBP_ObjectiveSwots.DMLService = new MockDmlProvider();
        CAJBP_ObjectiveSwots.DAOService = new MockDAOProvider();

        Test.startTest();
            List<CAJBP_ObjectiveSwots.Option> options = CAJBP_ObjectiveSwots.getSwotOptions(JbpPlan.Id, JbpObjective.Id);
            System.assertEquals(10, options.size());
    }

    @IsTest
    static void itShouldCreateObjectiveAndSwots() {
        CAJBP_ObjectiveSwots.DMLService = new MockDmlProvider();
        CAJBP_ObjectiveSwots.DAOService = new MockDAOProvider();

        CAJBP_Objective__c newObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
        newObjective.Id = null;

        Test.startTest();
            CAJBP_ObjectiveSwots.saveObjective(JSON.serialize(newObjective), new List<ID>{
                RecordService.generateId(Schema.CAJBP_SWOT__c.SObjectType)
            });

            System.assertNotEquals(null, newObjective);
            System.assertEquals(1, TargetRecords.size());

            try {
                CAJBP_ObjectiveSwots.saveObjective(JbpObjective.Id, new List<ID>{
                    RecordService.generateId(Schema.CAJBP_SWOT__c.SObjectType)
                });

                System.assert(false, 'Expecting AuraHandledException but did not.');
            } catch(System.AuraHandledException ex) {
                System.assertNotEquals(null, ex);
            }
    }

    @IsTest
    static void itShouldInsertObjectiveSwots() {
        CAJBP_ObjectiveSwots.DMLService = new MockDmlProvider();
        CAJBP_ObjectiveSwots.DAOService = new MockDAOProvider();

        CAJBP_Objective__c newObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
        CAJBP_SWOT__c newSwot = CAJBP_TestFactory.createSwotMock(JbpPlan, 'Opportunity');
        TargetObjectiveSwot = CAJBP_TestFactory.createObjectiveSwotMock(newSwot, newObjective);

        Test.startTest();
            CAJBP_ObjectiveSwots.saveSwots(newObjective.Id, new List<ID>{
                newSwot.Id
            });

            CAJBP_ObjectiveSwots.saveSwots(newObjective.Id, new List<ID>{
                RecordService.generateId(Schema.CAJBP_SWOT__c.SObjectType)
            });

            System.assertEquals(1, TargetRecords.size());

            CAJBP_ObjectiveSwots.DAOService = new MockDAOProvider(true);

            try {
                CAJBP_ObjectiveSwots.saveSwots(newObjective.Id, new List<ID>{
                    RecordService.generateId(Schema.CAJBP_SWOT__c.SObjectType)
                });

                System.assert(false, 'Expecting AuraHandledException but did not.');
            } catch(System.AuraHandledException ex) {
                System.assertNotEquals(null, ex);
            }
    }
}