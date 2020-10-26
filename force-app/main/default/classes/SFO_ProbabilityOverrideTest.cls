@IsTest(SeeAllData=false)
private class SFO_ProbabilityOverrideTest {
    private static final String OPP_NAME = 'Test Castrol Opp';

    @TestSetup
    private static void initData() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(
                SFO_TestDataService.CastrolSalesUserProfile.Id,
                SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id
            );

            testCastrolUser.Username += '.SFO_ProbabilityOverrideTest';
            insert testCastrolUser;

            List<Product2> castrolProducts = SFO_TestDataService.createCastrolTestProducts(1);
            insert castrolProducts;

            System.runAs(testCastrolUser) {
                Account castrolAcc = SFO_TestDataService.createCustomerAccount();
                insert castrolAcc;

                Contact testContact = SFO_TestDataService.createContact(castrolAcc.Id);
                insert testContact;

                Opportunity castrolOpp = SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id);
                castrolOpp.Name = OPP_NAME;
                castrolOpp.StageName = 'Lead';
                insert castrolOpp;

                CASFO_Opportunity_Contact__c role = SFO_TestDataService.createOpportunityContactRole(castrolOpp.Id, testContact.Id);
                insert role;

                Revenue__c oppRevenue = SFO_TestDataService.createOpportunityRevenue(
                    castrolOpp.Id,
                    castrolProducts.get(0).Id
                );

                insert oppRevenue;
            }
        }
    }

    @IsTest
    private static void itShouldOverrideProbabilityAndStayStaticAcrossStages() {
        User salesCastrolUser = [SELECT Id FROM User WHERE Username LIKE '%SFO_ProbabilityOverrideTest%' LIMIT 1];
        System.assertnotEquals(null, salesCastrolUser);

        Opportunity castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE NAME = :OPP_NAME];
        System.assertnotEquals(null, castrolOpp);

        Map<String, Decimal> stageProbabilityMap = new Map<String, Decimal>();

        for (OpportunityStage oppStage :[SELECT MasterLabel, DefaultProbability
                                            FROM OpportunityStage]) {

            stageProbabilityMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
        }

        System.assertEquals(stageProbabilityMap.get(castrolOpp.StageName), castrolOpp.Probability);
        System.assertnotEquals(11, castrolOpp.Probability);

        Test.startTest();
            System.runAs(salesCastrolUser) {
                //Override probability.
                castrolOpp.CASFO_Probability_Override__c = 11;
                update castrolOpp;

                //Probability value should be overridden.
                castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE Id = :castrolOpp.Id];
                System.assertEquals(11, castrolOpp.Probability);

                //Change stage and check that probability is still overridden value.
                castrolOpp.StageName = 'Opportunity';
                update castrolOpp;

                castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE Id = :castrolOpp.Id];
                System.assertEquals(11, castrolOpp.Probability);

                //Change stage and check that probability is still overridden value.
                castrolOpp.StageName = 'Proposal';
                update castrolOpp;

                castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE Id = :castrolOpp.Id];
                System.assertEquals(11, castrolOpp.Probability);
            }
        Test.stopTest();
    }

    @IsTest
    private static void itShouldResetProbabilityWhenOverridden() {
        User salesCastrolUser = [SELECT Id FROM User WHERE Username LIKE '%SFO_ProbabilityOverrideTest%' LIMIT 1];
        System.assertnotEquals(null, salesCastrolUser);

        Opportunity castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE NAME = :OPP_NAME];
        System.assertnotEquals(null, castrolOpp);

        Map<String, Decimal> stageProbabilityMap = new Map<String, Decimal>();

        for (OpportunityStage oppStage :[SELECT MasterLabel, DefaultProbability
                                            FROM OpportunityStage]) {

            stageProbabilityMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
        }

        System.assertEquals(stageProbabilityMap.get(castrolOpp.StageName), castrolOpp.Probability);
        System.assertnotEquals(11, castrolOpp.Probability);

        Test.startTest();
            System.runAs(salesCastrolUser) {
                //Override probability.
                castrolOpp.CASFO_Probability_Override__c = 11;
                update castrolOpp;

                //Probability value should be overridden.
                castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE Id = :castrolOpp.Id];
                System.assertEquals(11, castrolOpp.Probability);

                //Reset override.
                castrolOpp.CASFO_Probability_Override__c = null;
                update castrolOpp;

                castrolOpp = [SELECT Id, Probability, StageName FROM Opportunity WHERE Id = :castrolOpp.Id];

                System.assertNotEquals(11, castrolOpp.Probability);
                System.assertEquals(stageProbabilityMap.get(castrolOpp.StageName), castrolOpp.Probability);
            }
        Test.stopTest();
    }
}