/**
 * @author          Jan Majling
 * @date            20/09/2018
 * @group           CAJBP
 * @description     test class for CAJBP_JbpBridgeChartController
 *
 * history
 * 20/09/2018   Jan Majling         Created 
 */
@isTest
private class CAJBP_JbpBridgeChartControllerTest {
    @testSetup static void setup() {
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();

        List<CAJBP_Risk__c> risks = new List<CAJBP_Risk__c>();

        risks.add(CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -1000, -2000, Date.today()));
        risks.add(CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -2000, -8000, Date.today().addDays(100)));
        risks.add(CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -4000, -15000, Date.today().addDays(-100)));

        insert risks;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CAJBP_Standard_User'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;

        Database.insert(psa, false);
    }

    @IsTest
    static void testUserHasNoFieldAccess() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User user1 = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
             EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US', ProfileId = p2.Id,
             TimeZoneSidKey = 'America/Los_Angeles',
             UserName = 'testpermissionsetuser2' + System.now().getTime() + '@bp.customer.jbp.test');

        insert user1;


        CAJBP_JbpBridgeChartController.ChartData chartData;

        Test.startTest();
            System.runAs(user1) {
                CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
                ID recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByDeveloperName().get('CAJBP_Direct_Joint_Business_Plan').getRecordTypeId();
                jbp.RecordTypeId = recordTypeId;
                jbp.CAJBP_SellIn_Previous_Annual_Volume__c = 2000;
                update jbp;

                jbp = [
                    SELECT Id, CAJBP_Account__c, CAJBP_Account__r.Name,
                        (SELECT Id FROM CAJBP_Scorecards__r)
                    FROM CAJBP_Joint_Business_Plan__c
                    WHERE Name = 'Test Account Customer Group JBP 2080'
                ].get(0);

                CAJBP_Scorecard__c scorecard = jbp.CAJBP_Scorecards__r.get(0);
                scorecard.CAJBP_Sell_In_Volume_Plan__c = 2200;
                update scorecard;

                ID objectiveId = CAJBP_TestFactory.createObjective(jbp.Id).Id;
                CAJBP_TestFactory.createJbpActivity(objectiveId);

                try {
                    chartData = CAJBP_JbpBridgeChartController.getChartData(jbp.Id);
                    System.assert(false, 'Expecting no risk field access and throwing aura exception');
                } catch(System.AuraHandledException ex) {
                    System.assert(true);
                }
            }
        Test.stopTest();
     }

    @isTest static void testGetChartDataIndirectJbp() {
         Profile p2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
         User user2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
              LocaleSidKey='en_US', ProfileId = p2.Id,
              TimeZoneSidKey='America/Los_Angeles',
              UserName='testpermissionsetuser2' + System.now().getTime() + '@bp.customer.jbp.test'
         );

         insert user2;
        
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
              LocaleSidKey='en_US', ProfileId = p.Id,
              TimeZoneSidKey='America/Los_Angeles',
              UserName='testpermissionsetuser' + System.now().getTime() + '@bp.customer.jbp.test'
         );

        System.runAs(user2){
            insert u;

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CAJBP_Admin_User'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT Id, CAJBP_Account__c, CAJBP_Account__r.Name,
                (SELECT Id FROM CAJBP_Scorecards__r)
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Name = 'Test Account Customer Group JBP 2080'
        ].get(0);

        System.assertNotEquals(null, jbp.CAJBP_Account__c);
        System.assertEquals('Test Account', jbp.CAJBP_Account__r.Name);

        Id recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByDeveloperName().get('CAJBP_Indirect_Joint_Business_Plan').getRecordTypeId();
        jbp.RecordTypeId = recordTypeId;
        jbp.CAJBP_SellIn_Previous_Annual_Volume__c = 2000;

        Test.startTest();
            update jbp;
        
            Id objectiveId = CAJBP_TestFactory.createObjective(jbp.Id).Id;
            CAJBP_JbpBridgeChartController.ChartData chartData;

            System.runAs(u) {
                CAJBP_TestFactory.createJbpActivity(objectiveId);
                chartData = CAJBP_JbpBridgeChartController.getChartData(jbp.Id);
            }
        Test.stopTest();

        System.assertEquals(2079, chartData.previousYear, 'Chart Data previous year does not match');
        System.assertEquals(2080, chartData.currentYear, 'Chart Data current year does not match');
        System.assertEquals(2000, chartData.previousYearVolume, 'Chart Data previous year volume does not match');
        System.assertEquals(0, chartData.targetValueVolume, 'Chart Data target value volume does not match');
    }

    @isTest
    static void testGetChartDataDirectJbp() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User user2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p2.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testpermissionsetuser2' + System.now().getTime() + '@bp.customer.jbp.test'
        );

        insert user2;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testpermissionsetuser' + System.now().getTime() + '@bp.customer.jbp.test'
        );

        System.runAs(user2){
            insert u;

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CAJBP_Admin_User'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT Id, CAJBP_Account__c, CAJBP_Account__r.Name,
                (SELECT Id FROM CAJBP_Scorecards__r)
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Name = 'Test Account Customer Group JBP 2080'
        ].get(0);

        System.assertNotEquals(null, jbp.CAJBP_Account__c);
        System.assertEquals('Test Account', jbp.CAJBP_Account__r.Name);

        Id recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByDeveloperName().get('CAJBP_Direct_Joint_Business_Plan').getRecordTypeId();
        jbp.RecordTypeId = recordTypeId;
        jbp.CAJBP_SellIn_Previous_Annual_Volume__c = 2000;
        update jbp;

        CAJBP_Scorecard__c scorecard = jbp.CAJBP_Scorecards__r.get(0);
        scorecard.CAJBP_Sell_In_Volume_Plan__c = 2200;
        update scorecard;

        Id objectiveId = CAJBP_TestFactory.createObjective(jbp.Id).Id;
        CAJBP_TestFactory.createJbpActivity(objectiveId);
        CAJBP_JbpBridgeChartController.ChartData chartData;

        Test.startTest();
            System.runAs(u) {
                chartData = CAJBP_JbpBridgeChartController.getChartData(jbp.Id);
            }
        Test.stopTest();

        System.assertEquals(2079, chartData.previousYear, 'Chart Data previous year does not match');
        System.assertEquals(2080, chartData.currentYear, 'Chart Data current year does not match');
        System.assertEquals(2000, chartData.previousYearVolume, 'Chart Data previous year volume does not match');
        System.assertEquals(2200, chartData.targetValueVolume, 'Chart Data target value volume does not match');
        //System.assertEquals('Test Account', chartData.accountName, 'Chart Data account name does not match');
        //System.assertEquals(4, chartData.activities.size(), 'Chart Data should contain exactly 4 activities');
    }
}