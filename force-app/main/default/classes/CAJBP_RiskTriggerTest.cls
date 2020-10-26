@IsTest
private with sharing class CAJBP_RiskTriggerTest {
    private static final String TARGET_USERNAME = 'testpermissionsetuser_jbp@testorg.bp.com.customer';

    @TestSetup
    static void initData() {
        Map<String, Object> bundle = CAJBP_TestFactory.createSingleUserPermission(TARGET_USERNAME);

        System.runAs((User)bundle.get('user')) {
            CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
            jbp.CAJBP_State__c = 'Draft';
            update jbp;

            CAJBP_Risk__c risk = CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', 0.0, -100.00, Date.today());
            insert risk;
        }
    }

    @IsTest
    static void itShouldDeleteIfJbpNotInProgress() {
        User u = [SELECT Id FROM User WHERE Username = :TARGET_USERNAME];

        System.runAs(u) {
            System.assertEquals(1, [SELECT Id FROM CAJBP_Risk__c LIMIT 2].size());

            Test.startTest();
                delete [SELECT Id FROM CAJBP_Risk__c LIMIT 2];
            Test.stopTest();

            System.assertEquals(0, [SELECT Id FROM CAJBP_Risk__c LIMIT 1].size());
        }
    }

    @IsTest
    static void itShouldNotDeleteIfJbpInProgress() {
        User u = [SELECT Id FROM User WHERE Username = :TARGET_USERNAME];

        System.runAs(u) {
            System.assertEquals(1, [SELECT Id FROM CAJBP_Risk__c LIMIT 2].size());

            CAJBP_Joint_Business_Plan__c jbp = [SELECT Id FROM CAJBP_Joint_Business_Plan__c LIMIT 1];
            jbp.CAJBP_State__c = 'In Progress';
            jbp.CAJBP_JBP_Start_Date__c = Date.today();
            jbp.CAJBP_JBP_End_Date__c = Date.today().addMonths(6);
            jbp.CAJBP_JBP_Agreed_Sign_Off__c = true;
            jbp.CAJBP_Date_of_JBP_Agreed_Sign_Off__c = Date.today();
            jbp.CAJBP_JBP_Agreed_Customer_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
            update jbp;

            Test.startTest();
                try {
                    delete [SELECT Id FROM CAJBP_Risk__c LIMIT 2];
                    System.assert(false, 'Expected dml exception for jbp locked record.');
                } catch(System.DmlException ex) {
                    System.assert(ex.getMessage().containsIgnoreCase('You cannot delete this record unless the Joint Business Plan is in Draft'));
                }
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM CAJBP_Risk__c LIMIT 1].size());
        }
    }

    @isTest
    static void itShouldUpdateRiskCurrency()
    {
        CAJBP_Risk__c risk = [SELECT Id, currencyIsoCode, CAJBP_Value__c FROM CAJBP_Risk__c LIMIT 1];
        system.assertEquals('EUR', risk.CurrencyIsoCode,'Risk currency is not updated correctly');
        system.assertEquals(-100.00, risk.CAJBP_Value__c,'Value is not updated correctly');
    }
}