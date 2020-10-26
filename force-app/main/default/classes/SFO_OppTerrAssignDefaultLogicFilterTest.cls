/*****************************************************************************************
*   Date:           12-Mar-2020
*   Author:         Matt - SFO 
*   Description:    Test the Territory assignment   
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2020-Mar-12   1.0                Matt                Initial version
*
* 2020-Apr-08   2.0                Jit Patel           fix the failing test   
****************************************************************************************/

@isTest(SeeAllData = false)
private class SFO_OppTerrAssignDefaultLogicFilterTest 
{
    @isTest
    private static void OppTerrAssignDefaultLogicFilterTest() 
    {
        
        //Given User is assigned 2 territories with different priority
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);  
        insert testCastrolUser;

        UserTerritory2Association uta = new UserTerritory2Association(
            UserId = testCastrolUser.Id,
            Territory2Id = [SELECT Id, Territory2Type.Priority FROM Territory2 WHERE Territory2Type.MasterLabel = 'Segment' LIMIT 1].Id
        );

        UserTerritory2Association uta2 = new UserTerritory2Association(
            UserId = testCastrolUser.Id,
            Territory2Id = [SELECT Id, Territory2Type.Priority FROM Territory2 WHERE Territory2Type.MasterLabel = 'Regional' LIMIT 1].Id
        );

        insert new List<UserTerritory2Association>{uta, uta2};
        System.assert([SELECT Id, Territory2.Territory2Type.Priority FROM UserTerritory2Association WHERE Id = :uta.Id].Territory2.Territory2Type.Priority > 
        [SELECT Id, Territory2.Territory2Type.Priority FROM UserTerritory2Association WHERE Id = :uta2.Id].Territory2.Territory2Type.Priority);

        Account castrolAcc = SFO_TestDataService.createCustomerAccount();

        System.runAs(testCastrolUser)
        {
            insert castrolAcc;
        }  

        Opportunity castrolOpp =  SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id); 

        System.runAs(testCastrolUser)
        {
            insert castrolOpp;
        }        
        
        // When Opp assignement is ran
        Test.startTest();

        BPG_OppTerrAssignDefaultLogicFilter handler = new BPG_OppTerrAssignDefaultLogicFilter();
        Map<Id,Id> opp2territoryMap = handler.getOpportunityTerritory2Assignments(new List<Id>{castrolOpp.Id});
        Test.stopTest();
        // Then Opp has owner territory assigned
        System.assertEquals(
            [SELECT Id, Territory2Id 
             FROM UserTerritory2Association 
             WHERE UserId = :testCastrolUser.Id 
             ORDER BY Territory2.Territory2Type.Priority DESC LIMIT 1].Territory2Id, 
            opp2territoryMap.get(castrolOpp.Id),
            'Territory not Assigned');
        System.assertEquals(
            [SELECT Id, Territory2Id 
                FROM UserTerritory2Association 
                WHERE Id = :uta.Id].Territory2Id, 
            opp2territoryMap.get(castrolOpp.Id),
            'Territory not Assigned');
        
    } 

    @isTest
    private static void OppTerrAssignDefaultLogicFilterSamePriorityTest() 
    {
        
        //Given User is assigned 2 territories with same priority
        User testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);  
        insert testCastrolUser;

        List<UserTerritory2Association> utaList = new List<UserTerritory2Association>();
        for(Territory2 terr : [SELECT Id FROM Territory2 WHERE Territory2Type.MasterLabel = 'Segment' LIMIT 2]){
            utaList.add(new UserTerritory2Association(
                UserId = testCastrolUser.Id,
                Territory2Id = terr.Id));
        }
        insert utaList;

        Account castrolAcc = SFO_TestDataService.createCustomerAccount();

        System.runAs(testCastrolUser)
        {
            insert castrolAcc;
        }         

        Opportunity castrolOpp =  SFO_TestDataService.createCastrolOpportunity(castrolAcc.Id); 

        System.runAs(testCastrolUser)
        {
            insert castrolOpp;
        }   

        // When Opp assignement is ran
        Test.startTest();

        BPG_OppTerrAssignDefaultLogicFilter handler = new BPG_OppTerrAssignDefaultLogicFilter();
        Map<Id,Id> opp2territoryMap = handler.getOpportunityTerritory2Assignments(new List<Id>{castrolOpp.Id});
        Test.stopTest();
        System.assertNotEquals(null, castrolOpp.Id, 'opportunity not inserted');
    } 

}