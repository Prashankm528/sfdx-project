@IsTest
private with sharing class CAJBP_PDF_DataStrategyTest {

    @TestSetup
    static void init() {
        CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
        jbp.CAJBP_Description__c = '<img></img>';
        jbp.CAJBP_Vision_Statement__c = '<img></img>';
        update jbp;

        CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);

        insert CAJBP_TestFactory.createJbpSwot(jbp.Id, 'Strength').values()[0];
        insert CAJBP_TestFactory.createJbpSwot(jbp.Id, 'Weakness').values()[0];
        insert CAJBP_TestFactory.createJbpSwot(jbp.Id, 'Opportunity').values()[0];
        insert CAJBP_TestFactory.createJbpSwot(jbp.Id, 'Threat').values()[0];

        CAJBP_JBP_Activity__c activity1 = CAJBP_TestFactory.createJbpActivity(objective.Id);

        CAJBP_JBP_Activity__c activity2 = CAJBP_TestFactory.createJbpActivity(objective.Id);
        activity2.CAJBP_End_Date__c = Date.today().addYears(2);
        update activity2;

        CAJBP_Ways_of_Working_Target__c workingTarget = CAJBP_TestFactory.createWaysOfWorkingTarget(jbp.Id);
        insert workingTarget;

        CAJBP_Distributor_Joint_Activity_Fund__c jaf = CAJBP_TestFactory.createJaf(jbp.Id);
        insert jaf;
    }

    @IsTest
    static void itShouldContainAccountLocaleErrorMessage() {
        CAJBP_Joint_Business_Plan__c jbp = [SELECT Id FROM CAJBP_Joint_Business_Plan__c LIMIT 1];
        jbp.CAJBP_Account_Locale__c = null;
        update jbp;

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(jbp);
            CAJBP_PDF_SummaryExecutor controller = new CAJBP_PDF_SummaryExecutor(stdController);

            System.assertEquals(1, controller.messages.size());
    }

    @IsTest
    static void itShouldCreateDataStrategyPlan() {
        CAJBP_Joint_Business_Plan__c jbp = [SELECT Id FROM CAJBP_Joint_Business_Plan__c LIMIT 1];

        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(jbp);
            CAJBP_PDF_SummaryExecutor controller = new CAJBP_PDF_SummaryExecutor(stdController);
            System.assertEquals(0, controller.messages.size());

            CAJBP_PDF_DataStrategy.InputSummary inputData = CAJBP_PDF_SummaryExecutor.getPayload(jbp.Id);
            System.assertEquals(2, inputData.objectives[0].JBP_Activities__r.size());
            System.assertEquals(1, inputData.swotStrengths.size());
            System.assertEquals(1, inputData.swotWeaknesses.size());
            System.assertEquals(1, inputData.swotOpportunities.size());
            System.assertEquals(1, inputData.swotThreats.size());
            System.assertNotEquals(null, inputData.jaf);

            ID cacheId = CAJBP_PDF_SummaryExecutor.generateCache(jbp.Id, JSON.serialize(inputData));
            System.assertNotEquals(null, cacheId);

            delete [SELECT Id FROM CAJBP_Distributor_Joint_Activity_Fund__c WHERE CAJBP_Joint_Business_Plan__c = :JBP.Id];

            jbp.CAJBP_Account_Locale__c = 'fr_FR';
            update jbp;

            inputData = CAJBP_PDF_SummaryExecutor.getPayload(jbp.Id);

            cacheId = CAJBP_PDF_SummaryExecutor.generateCache(jbp.Id, JSON.serialize(inputData));
            System.assertNotEquals(null, cacheId);

            System.currentPageReference().getParameters().put('cacheId', cacheId);
            CAJBP_PDF_SummaryViewer pdfViewer = new CAJBP_PDF_SummaryViewer(stdController);
            System.assertNotEquals(null, pdfViewer.payload);
    }

    @IsTest
    static void itShouldCreateOutputSummary() {
        Test.startTest();
           CAJBP_PDF_DataStrategy.OutputSummary summary = new CAJBP_PDF_DataStrategy.OutputSummary();
            summary.assets = new CAJBP_PDF_DataStrategy.AssetLibrary();
            summary.assets.pageHeaderImageName = UserInfo.getUserId();
            System.assertNotEquals(null, summary.assets);

            summary.generatedDate = Date.today().format();
            summary.generatedBy = UserInfo.getName();
            summary.jbp = new CAJBP_PDF_DataStrategy.JointBusinessPlan();
            summary.objectives = new List<CAJBP_PDF_DataStrategy.Objective>();
            summary.activityYear = new Map<String, List<CAJBP_PDF_DataStrategy.ActivityYear>>();
            summary.swotStrengths = new List<CAJBP_PDF_DataStrategy.SWOT>();
            summary.swotWeaknesses = new List<CAJBP_PDF_DataStrategy.SWOT>();
            summary.swotOpportunities = new List<CAJBP_PDF_DataStrategy.SWOT>();
            summary.swotThreats = new List<CAJBP_PDF_DataStrategy.SWOT>();
            summary.scorecard = new CAJBP_PDF_DataStrategy.Scorecard();
            summary.singleRebatePPL = new List<CAJBP_PDF_DataStrategy.Rebate>();
            summary.singleRebatePercentage = new List<CAJBP_PDF_DataStrategy.Rebate>();
            summary.multiRebatePPL = new List<CAJBP_PDF_DataStrategy.Rebate>();
            summary.multiRebatePercentage = new List<CAJBP_PDF_DataStrategy.Rebate>();
            summary.singleRebateVolumePercentage = new List<CAJBP_PDF_DataStrategy.Rebate>();
            summary.multiRebateVolumePercentage = new List<CAJBP_PDF_DataStrategy.Rebate>();

            summary.mixAnnualPPL = new List<CAJBP_PDF_DataStrategy.ProductMixTarget>();
            summary.mixAnnualPercentage = new List<CAJBP_PDF_DataStrategy.ProductMixTarget>();
            summary.mixQuarterlyPPL = new List<CAJBP_PDF_DataStrategy.ProductMixTarget>();
            summary.mixQuarterlyPercentage = new List<CAJBP_PDF_DataStrategy.ProductMixTarget>();
            summary.waysOfWorkingTargets = new List<CAJBP_PDF_DataStrategy.WaysOfWorkingTarget>();
            summary.jaf = new CAJBP_PDF_DataStrategy.JointActivityFund();

            System.assertNotEquals(null, summary.jbp);
            System.assertNotEquals(null, summary.jaf);

            CAJBP_PDF_DataStrategy.JointBusinessPlan jbp = new CAJBP_PDF_DataStrategy.JointBusinessPlan();
            jbp.record = new CAJBP_Joint_Business_Plan__c();
            jbp.id = UserInfo.getUserId();
            jbp.name = 'test';
            jbp.state = 'test';
            jbp.accountStatus = 'test';
            jbp.year = '2019';
            jbp.startDate = '01/01/2020';
            jbp.endDate = '01/01/2020';
            jbp.termStartDate = '01/01/2020';
            jbp.termEndDate = '01/01/2020';
            jbp.vision = 'test';
            jbp.description = 'test';
            jbp.accountName = 'test';
            jbp.ownerName = 'test';
            jbp.recordType = 'test';
            jbp.currencyIsoCode = 'GBP';
            jbp.locale = 'en_GB';
            jbp.sellInPreviousVolume = '1000';
            jbp.sellInPreviousTurnover = '1000';
            jbp.sellOutPreviousVolume = '1000';
            jbp.sellOutPreviousTurnover = '1000';
            System.assertNotEquals(null, jbp);

            CAJBP_PDF_DataStrategy.SWOT swot = new CAJBP_PDF_DataStrategy.SWOT();
            swot.id = UserInfo.getUserId();
            swot.title = 'test';
            swot.description = 'test';
            System.assertNotEquals(null, swot);

            CAJBP_PDF_DataStrategy.Objective objective = new CAJBP_PDF_DataStrategy.Objective();
            objective.id = UserInfo.getUserId();
            objective.title = 'test';
            objective.totalActivities = '0';
            objective.completedActivities = '0';
            objective.estimatedCost = '0';
            objective.estimatedValue = '0';
            objective.estimatedVolume = '0';
            objective.actualCost = '0';
            objective.actualValue = '0';
            objective.actualVolume = '0';
            objective.currencyIsoCode = 'GBP';
            objective.activities = new List<CAJBP_PDF_DataStrategy.Activity>();
            System.assertNotEquals(null, objective);

            CAJBP_PDF_DataStrategy.Activity activity = new CAJBP_PDF_DataStrategy.Activity();
            activity.record = new CAJBP_JBP_Activity__c();
            activity.id = UserInfo.getUserId();
            activity.objectiveId = UserInfo.getUserId();
            activity.title = 'test';
            activity.status = 'test';
            activity.paidBy = 'test';
            activity.estimatedValue = '1000';
            activity.estimatedVolume = '1000';
            activity.estimatedCost = '1000';
            activity.actualValue = '1000';
            activity.actualVolume = '1000';
            activity.actualCost = '1000';
            activity.startDate = '1000';
            activity.endDate = '1000';
            activity.currencyIsoCode = 'GBP';
            System.assertNotEquals(null, activity);

            CAJBP_PDF_DataStrategy.Scorecard scorecard = new CAJBP_PDF_DataStrategy.Scorecard();
            scorecard.id = UserInfo.getUserId();
            scorecard.sellInVolumePlan = '1000';
            scorecard.sellInActualVolume = '1000';
            scorecard.sellInActualTurnover = '1000';
            scorecard.sellInMatVolume = '1000';
            scorecard.sellInMatTurnover = '1000';
            scorecard.sellOutActualVolume = '1000';
            scorecard.sellOutActualTurnover = '1000';
            scorecard.sellOutMatVolume = '1000';
            scorecard.sellOutMatTurnover = '1000';
            scorecard.currencyIsoCode = 'GBP';
            System.assertNotEquals(null, scorecard);

            CAJBP_PDF_DataStrategy.Rebate rebate = new CAJBP_PDF_DataStrategy.Rebate();
            rebate.id = UserInfo.getUserId();
            rebate.name = 'test';
            rebate.targetVolume = '1000';
            rebate.targetPPL = '1000';
            rebate.targetTurnover = '1000';
            rebate.targetPercentage = '1000';
            rebate.targetRebate = '1000';
            rebate.thresholdVolume = '1000';
            rebate.thresholdPPL = '1000';
            rebate.thresholdTurnover = '1000';
            rebate.thresholdPercentage = '1000';
            rebate.thresholdRebate = '1000';
            rebate.stretchVolume = '1000';
            rebate.stretchPPL = '1000';
            rebate.stretchTurnover = '1000';
            rebate.stretchPercentage = '1000';
            rebate.stretchRebate = '1000';
            rebate.currencyIsoCode = 'GBP';
            System.assertNotEquals(null, rebate);

            CAJBP_PDF_DataStrategy.ProductMixTarget mixTarget = new CAJBP_PDF_DataStrategy.ProductMixTarget();
            mixTarget.id = UserInfo.getUserId();
            mixTarget.product = 'test';
            mixTarget.recordTypeName = 'test';
            mixTarget.currencyIsoCode = 'GBP';
            mixTarget.annualVolumeTarget = '1000';
            mixTarget.annualPPL = '1000';
            mixTarget.annualVolumeTargetPercentage = '1000';
            mixTarget.annualPercentage = '1000';
            mixTarget.actualYtdVolume = '1000';
            mixTarget.q1Volume = '1000';
            mixTarget.q2Volume = '1000';
            mixTarget.q3Volume = '1000';
            mixTarget.q4Volume = '1000';
            mixTarget.q1PPL = '1000';
            mixTarget.q2PPL = '1000';
            mixTarget.q3PPL = '1000';
            mixTarget.q4PPL = '1000';
            mixTarget.q1Percentage = '1000';
            mixTarget.q2Percentage = '1000';
            mixTarget.q3Percentage = '1000';
            mixTarget.q4Percentage = '1000';
            mixTarget.q1ActualYtdVolume = '1000';
            mixTarget.q2ActualYtdVolume = '1000';
            mixTarget.q3ActualYtdVolume = '1000';
            mixTarget.q4ActualYtdVolume = '1000';
            System.assertNotEquals(null, mixTarget);

            CAJBP_PDF_DataStrategy.WaysOfWorkingTarget workingTarget = new CAJBP_PDF_DataStrategy.WaysOfWorkingTarget();
            workingTarget.record = new CAJBP_Ways_of_Working_Target__c();
            workingTarget.id = UserInfo.getUserId();
            workingTarget.title = 'test';
            workingTarget.status = 'test';
            workingTarget.dueDate = '01/01/2020';
            workingTarget.rebatePercentage = '10000';
            System.assertNotEquals(null, workingTarget);

            CAJBP_PDF_DataStrategy.JointActivityFund fund = new CAJBP_PDF_DataStrategy.JointActivityFund();
            fund.id = UserInfo.getUserId();
            fund.name = 'test';
            fund.castrolContribution = '1000';
            fund.partnerContribution = '1000';
            fund.totalFund = '2000';
            fund.estimatedSpend = '1000';
            fund.actualSpend = '1000';
            fund.estimatedRemaining = '1000';
            fund.actualRemaining = '1000';
            fund.currencyIsoCode = '1000';
            System.assertNotEquals(null, fund);
    }
}