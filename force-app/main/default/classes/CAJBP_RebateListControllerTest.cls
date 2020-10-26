/**
 * @author          Jan Majling
 * @date            09/09/2018
 * @group           CAJBP
 * @description     test class for CAJBP_RebateListController
 *
 * history
 * 09/09/201    Jan Majling         Created 
 */
@isTest
private class CAJBP_RebateListControllerTest {
    private static final BPG_TestDataService.SObjectCreator RecordCreator = new BPG_TestDataService.SObjectCreator();

    @testSetup static void setup() {
        Id recordTypeId = Schema.SObjectType.CAJBP_Joint_Business_Plan__c.getRecordTypeInfosByName().get('Direct JBP').getRecordTypeId();

        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = '2080',
            CAJBP_State__c = 'Draft',
            CAJBP_JBP_End_Date__c = Date.today().addDays(5),
            RecordTypeId = recordTypeId
        );

        insert jbp;
    }

    @isTest static void testGetScorecardWithRebates() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
         User user2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p2.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testpermissionsetuser2' + System.now().getTime() + '@testorg.com');
         insert user2;
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testpermissionsetuser' + System.now().getTime() + '@testorg.com');
        System.runAs(user2){
            insert u;
        
        
        
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CAJBP_Admin_User'];
           
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        } 
    
    
        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT Id 
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Name = 'Test Account Customer Group JBP 2080'
        ].get(0);
        List<CAJBP_Scorecard__c> scorecards = [
            SELECT Id
            FROM CAJBP_Scorecard__c
            WHERE CAJBP_Joint_Business_Plan__c = :jbp.Id
        ];
        CAJBP_Scorecard__c scorecard;
        if(scorecards.isEmpty()) {
            scorecard = new CAJBP_Scorecard__c(
                CAJBP_Joint_Business_Plan__c = jbp.Id
            );
            insert scorecard;
        } else {
            scorecard = scorecards.get(0);
        }

        Integer rebatesCount = 2;
        List<CAJBP_Rebate__c> rebates = new List<CAJBP_Rebate__c>();
        for(Integer i = 0; i < rebatesCount; i++) {
            CAJBP_Rebate__c rebate = new CAJBP_Rebate__c(
                CAJBP_Scorecard__c = scorecard.Id
            );
            rebates.add(rebate);
        }       
        insert rebates;

        Test.startTest();
            Map<String, Object> result = CAJBP_RebateListController.getData(jbp.Id);
            rebates = (List<CAJBP_Rebate__c>)result.get('rebates');

            System.assertEquals(2, rebates.size());
        Test.stopTest();
    }
}