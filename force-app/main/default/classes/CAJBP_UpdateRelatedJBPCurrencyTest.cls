/**
 * @author 			Abhinit Kohar
 * @date 			30/01/2020
 * @group			CAJBP
 * @description     test class for CAJBP_UpdateRelatedJBPCurrency
 *
 * history
 * 30/01/2020	Abhinit Kohar			Created
 * 01/06/2020   Venkatesh Muniyasamy    Updated for Scorecard validation
 */

@IsTest
private class CAJBP_UpdateRelatedJBPCurrencyTest {
    static Date startDate = Date.today();
    static final String CURRENCY_ISO_CODE = 'CAD';
    static final String CURRENCY_ISO_CODE_AUD = 'AUD';
    static string rebateRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Rebate__c' and isactive=true limit 1].Id;
    static string swotType = CAJBP_SWOT__c.Type__c.getDescribe().getPicklistValues()[0].getValue();
    static string productMixTargetRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;

    @isTest
    static void checkRelatedRecordsCurrencyAfterUpdate1(){
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
        CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);
        CAJBP_JBP_Activity__c activity = CAJBP_TestFactory.createJbpActivity(objective.Id);

        CAJBP_Risk__c risk = CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -100.00, -200.00, startDate);
        insert risk;

        List<CAJBP_SWOT__c> swot = new List<CAJBP_SWOT__c>();
        swot.add(new CAJBP_SWOT__c (CAJBP_Joint_Business_Plan__c=jbp.Id,Name='Swot Record',Type__c = swotType));
        insert swot;

        List<CAJBP_Distributor_Joint_Activity_Fund__c> jafs = new List<CAJBP_Distributor_Joint_Activity_Fund__c>();
        jafs.add(new CAJBP_Distributor_Joint_Activity_Fund__c (CAJBP_Joint_Business_Plan__c=jbp.Id, CAJBP_Castrol_Contribution_Amount__c=100, CAJBP_Partner_Contribution_Amount__c=100));
        insert jafs;

        List<CAJBP_Ways_of_Working_Target__c> waysOfWorkingTargets = new List<CAJBP_Ways_of_Working_Target__c>();
        waysOfWorkingTargets.add(new CAJBP_Ways_of_Working_Target__c(Name = 'TestWays of Working', CAJBP_Joint_Business_Plan__c = jbp.ID, CAJBP_Description__c = 'Test Description', CAJBP_Due_Date__c = startDate));
        insert waysOfWorkingTargets;

        List<CAJBP_Objective_SWOT__c> objectiveSwots = new List<CAJBP_Objective_SWOT__c>();
        objectiveSwots.add(new CAJBP_Objective_SWOT__c(CAJBP_Objective__c = objective.ID, CAJBP_SWOT__c = swot[0].ID));
        insert objectiveSwots;

        CAJBP_Joint_Business_Plan__c jbp1 = createJBP();
        CAJBP_Objective__c objective1 = CAJBP_TestFactory.createObjective(jbp1.Id);
        CAJBP_JBP_Activity__c activity1 = CAJBP_TestFactory.createJbpActivity(objective1.Id);

        Map<Id, String> jbpIdCurrencyMap = new Map<Id, String>();
        jbpIdCurrencyMap.put(jbp.Id, CURRENCY_ISO_CODE);
        jbpIdCurrencyMap.put(jbp1.Id, CURRENCY_ISO_CODE_AUD);

        Test.startTest();
        System.enqueueJob(new CAJBP_UpdateRelatedJBPCurrency(jbpIdCurrencyMap));
        Test.stopTest();

        CAJBP_Objective__c obj = [select id, CurrencyIsoCode from CAJBP_Objective__c where id = :objective.Id];
        system.assertEquals(CURRENCY_ISO_CODE, obj.CurrencyIsoCode);

        CAJBP_JBP_Activity__c act = [select id, CurrencyIsoCode from CAJBP_JBP_Activity__c where id = :activity.Id];
        system.assertEquals(CURRENCY_ISO_CODE, act.CurrencyIsoCode);

        CAJBP_Objective__c obj1 = [select id, CurrencyIsoCode from CAJBP_Objective__c where id = :objective1.Id];
        system.assertEquals(CURRENCY_ISO_CODE_AUD, obj1.CurrencyIsoCode);

        CAJBP_JBP_Activity__c act1 = [select id, CurrencyIsoCode from CAJBP_JBP_Activity__c where id = :activity1.Id];
        system.assertEquals(CURRENCY_ISO_CODE_AUD, act1.CurrencyIsoCode);

        CAJBP_Risk__c ris = [select id, CurrencyIsoCode, CAJBP_Volume__c from CAJBP_Risk__c where id = :risk.Id];
        system.assertEquals(CURRENCY_ISO_CODE, ris.CurrencyIsoCode);
        system.assertEquals(-100.00, ris.CAJBP_Volume__c);

        CAJBP_SWOT__c swo = [select id, CurrencyIsoCode from CAJBP_SWOT__c where id = :swot[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, swo.CurrencyIsoCode);

        CAJBP_Distributor_Joint_Activity_Fund__c jaf = [select id, CurrencyIsoCode, CAJBP_Castrol_Contribution_Amount__c from CAJBP_Distributor_Joint_Activity_Fund__c where id = :jafs[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, jaf.CurrencyIsoCode);
        system.assertEquals(100.00, jaf.CAJBP_Castrol_Contribution_Amount__c);

        CAJBP_Ways_of_Working_Target__c waysOfWorkingTarget = [select id, CurrencyIsoCode from CAJBP_Ways_of_Working_Target__c where id = :waysOfWorkingTargets[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, waysOfWorkingTarget.CurrencyIsoCode);

        CAJBP_Objective_SWOT__c objectiveSwot = [select id, CurrencyIsoCode from CAJBP_Objective_SWOT__c where id = :objectiveSwots[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, objectiveSwot.CurrencyIsoCode);
    }

    static void checkRelatedRecordsCurrencyAfterUpdate2(){
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
        CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);
        CAJBP_JBP_Activity__c activity = CAJBP_TestFactory.createJbpActivity(objective.Id);

        CAJBP_Scorecard__c scoreCard = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c Limit 1];

        List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
        rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=scoreCard.Id,RecordTypeId=rebateRecordType));
        insert rebate;

        Product2 product = new Product2(Name='Generator',CASFO_Product_Sales_Organisation__c='UK01' );
        insert product;

        List<CAJBP_Product_Mix_Target__c> productMixTargets = new List<CAJBP_Product_Mix_Target__c>();
        productMixTargets.add(new CAJBP_Product_Mix_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,
                CAJBP_Product_Mix_Target_Name__c = 'EDGE', CAJBP_Price_Per_Litre_Rebate__c=100.00, 
                CAJBP_Volume_Target__c=10000, recordtypeid = productMixTargetRecordType,
                CAJBP_Scorecard__c = scoreCard.Id));
        insert productMixTargets;

        CAJBP_Scorecard__c score = [select id, CurrencyIsoCode from CAJBP_Scorecard__c where id = :scoreCard.Id];
        system.assertEquals(CURRENCY_ISO_CODE, score.CurrencyIsoCode);

        CAJBP_Rebate__c reb = [select id, CurrencyIsoCode from CAJBP_Rebate__c where id = :rebate[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, reb.CurrencyIsoCode);

        CAJBP_Product_Mix_Target__c productMixTarget = [select id, CurrencyIsoCode, CAJBP_Price_Per_Litre_Rebate__c from CAJBP_Product_Mix_Target__c where id = :productMixTargets[0].Id];
        system.assertEquals(CURRENCY_ISO_CODE, productMixTarget.CurrencyIsoCode);
        system.assertEquals(100.00, productMixTarget.CAJBP_Price_Per_Litre_Rebate__c);
    }

    @isTest
    static void checkWhenJbpIdCurrencyMapEmpty(){
        Test.startTest();
        System.enqueueJob(new CAJBP_UpdateRelatedJBPCurrency(new Map<Id, String>()));
        Test.stopTest();
    }

        //Create and return JBP record
    static CAJBP_Joint_Business_Plan__c createJBP(){
        Id recordTypeCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account account = new Account(
                Name = 'Test Account1',
                RecordTypeId = recordTypeCustomerId,
                Type = 'ZMHI'
        );
        insert account;
        Contact contact = new Contact(FirstName = 'Test1', LastName = 'Last1', accountId = account.Id);
        insert contact;

        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                                    CAJBP_Account__c = account.Id, 
                                    CAJBP_Year__c = '2090', CAJBP_State__c = 'Draft',
                                    CAJBP_JBP_End_Date__c=Date.today().addDays(5)
                                    );
        insert jbp;
        return jbp;
    }
}