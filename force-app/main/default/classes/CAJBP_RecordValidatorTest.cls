@IsTest
private class CAJBP_RecordValidatorTest {
    /*
    * Mock test data, which is not committed to the database and persisted in memory.
    */
    private static Account customer = CAJBP_TestFactory.createCustomerMock();
    private static CAJBP_Joint_Business_Plan__c plan = CAJBP_TestFactory.createJointBusinessPlanMock(customer);
    private static CAJBP_Objective__c objective = CAJBP_TestFactory.createObjectiveMock(plan);
    private static CAJBP_Valid_Delete_State__mdt validDeleteState = CAJBP_TestFactory.createJBPDeleteStateMock();
    private static Boolean NoMockData = false;

    private static void resetData() {
        customer = CAJBP_TestFactory.createCustomerMock();
        plan = CAJBP_TestFactory.createJointBusinessPlanMock(customer);
        objective = CAJBP_TestFactory.createObjectiveMock(plan);
        validDeleteState = CAJBP_TestFactory.createJBPDeleteStateMock();
    }

    private static void assignDraftState() {
        resetData();

        plan.CAJBP_State__c = 'Draft';
        validDeleteState.DeveloperName = 'Draft';
        validDeleteState.Label = 'Draft';
    }

    /*
    * Create mock DAO provider to return test data.
    */
    private class MockDAOProvider extends CAJBP_RecordValidator.DAOProvider {
        public override Map<Id, CAJBP_Joint_Business_Plan__c> getJointBusinessPlansInDeleteState(Set<Id> jbpIds, Set<String> validDeleteStates) {
            Map<Id, CAJBP_Joint_Business_Plan__c> jbps = new Map<Id, CAJBP_Joint_Business_Plan__c>();
            super.getJointBusinessPlansInDeleteState(jbpIds, validDeleteStates);

            if (!NoMockData && validDeleteStates.contains(plan.CAJBP_State__c)) {
                jbps = new Map<Id, CAJBP_Joint_Business_Plan__c>{plan.Id => plan};
            }

            return jbps;
        }

        public override List<CAJBP_Valid_Delete_State__mdt> getValidDeleteStateRecords() {
            List<CAJBP_Valid_Delete_State__mdt> states = new List<CAJBP_Valid_Delete_State__mdt>();
            super.getValidDeleteStateRecords();

            if (!NoMockData) {
                states = new List<CAJBP_Valid_Delete_State__mdt>{validDeleteState};
            }

            return states;
        }
    }

    /*
    * This error provider throws an exception rather than adding an error to the sObject, which we cannot
    * verify unless committed to the database.
    */
    private class MockErrorProvider extends CAJBP_RecordValidator.RecordErrorProvider {
        public override void addError(SObject record, String message) {
            super.addError(record, message);
            throw new ErrorException(message);
        }
    }

    /*
    * Verify unexpected params and default behaviour.
    */
    @IsTest
    static void itShouldEscapeOnInvalidParams() {
        resetData();

        Test.startTest();
            try {
                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(new Map<String, Object>());
                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(null, null);

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    null
                );

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>()
                );

                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(
                    new Map<String, Object>{
                        'DAOProvider' => new CAJBP_RecordValidator.DAOProvider()
                    }
                );

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );

                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(
                    new Map<String, Object>{
                        'ErrorProvider' => new CAJBP_RecordValidator.RecordErrorProvider()
                    }
                );

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );

                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(new Map<String, Object>{
                    'DAOProvider' => new CAJBP_RecordValidator.DAOProvider(),
                    'ErrorProvider' => new CAJBP_RecordValidator.RecordErrorProvider()
                });

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );

                NoMockData = true;
                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(new Map<String, Object>{
                    'DAOProvider' => new MockDAOProvider(),
                    'ErrorProvider' => new MockErrorProvider()
                });

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );
                NoMockData = false;

                CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(new Map<String, Object>{
                    'DAOProvider' => new CAJBP_RecordValidator.DAOProvider(),
                    'ErrorProvider' => new CAJBP_RecordValidator.RecordErrorProvider()
                });

                objective.CAJBP_Joint_Business_Plan__c = null;

                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );
            } catch(System.Exception ex) {
                System.assert(false, 'invalid params did not escape gracefully.');
            }
        Test.stopTest();
    }


    @IsTest
    static void itShouldDeleteObjectiveIfJBPInDeleteState() {
        //JBP is set to valid delete state, so the objective can be deleted.
        assignDraftState();

        //Dependency inject mock providers for data and error handler.
        CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(
            new Map<String, Object>{
                'DAOProvider' => new MockDAOProvider(),
                'ErrorProvider' => new MockErrorProvider()
            }
        );

        Test.startTest();
            try {
                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );
            } catch(System.Exception ex) {
                System.assert(false, 'objective JBP should be in a valid delete state: ' + ex.getMessage());
            }
        Test.stopTest();
    }

    @IsTest
    static void itShouldNotDeleteObjectiveIfJBPInNotDeleteState() {
        assignDraftState();
        //JBP is set to an invalid delete state, so the objective cannot be deleted.
        plan.CAJBP_State__c = 'In Progress';

        //Dependency inject mock providers for data and error handler.
        CAJBP_RecordValidator.instance = new CAJBP_RecordValidator(
            new Map<String, Object>{
                'DAOProvider' => new MockDAOProvider(),
                'ErrorProvider' => new MockErrorProvider()
            }
        );

        Test.startTest();
            try {
                CAJBP_RecordValidator.validateDeleteWithJointBusinessPlanState(
                    Schema.CAJBP_Objective__c.fields.CAJBP_Joint_Business_Plan__c,
                    new List<CAJBP_Objective__c>{objective}
                );

                System.assert(false, 'objective JBP should NOT be in a valid delete state');

            } catch(CAJBP_RecordValidatorTest.ErrorException ex) {

                //Validate if expected message is the not valid delete state message.
                System.assertEquals(CAJBP_RecordValidator.instance.getDeleteErrorMessage(
                    ((CAJBP_RecordValidator.DAOProvider)CAJBP_RecordValidator.instance.providers.get('DAOProvider')).getValidDeleteStates()),
                    ex.getMessage()
                );

                System.assert(true);
            }
        Test.stopTest();
    }

    @IsTest
    static void itShouldGenerateUniqueValueForIgnoreValidation() {
        List<String> currentValues = new List<String>();

        Test.startTest();
            for (Integer i = 0; i < 200; i ++) {
                CAJBP_Joint_Business_Plan__c plan = new CAJBP_Joint_Business_Plan__c();
                CAJBP_RecordValidator.ignoreValidation(plan);

                System.assertEquals(true, String.isNotBlank(plan.CAJBP_Ignore_Validation__c));
                currentValues.add(plan.CAJBP_Ignore_Validation__c);
            }
        Test.stopTest();

        System.assertNotEquals(true, currentValues.isEmpty());
        System.assertEquals(currentValues.size(), (new Set<String>(currentValues)).size(), 'Values are not unique.');
    }

    public class ErrorException extends Exception {}
}