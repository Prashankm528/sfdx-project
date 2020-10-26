/*****************************************************************************************
*	Date:		    29-Aug-2019
*   Author:         Matt - SFO 
*   Description:    Account trigger handler 
*   Modifications:  06APR2020 Rahma Belghouti - Add unit tests for setChannelManager()
****************************************************************************************/
@isTest
private class SFO_AccountTriggerHandlerTest {
    
    @isTest
    public static void isShouldPopulateSearchableTestField() {
        // Given
        Account acc = SFO_TestDataService.createCustomerAccount();
        acc.Type = 'ZMBP'; //Bill-To Party
        // When
        SFO_AccountTriggerHandler handler = new SFO_AccountTriggerHandler(new List<Account>{acc});
        handler.setAccountTypeSearch();
        // Then
        System.assertEquals('Bill-To Party', acc.Search_type__c, 'Search Type Not Changed');
    }
    
    /*
    * Checks if Channel Manager is assigned correctly 
    * and is matching Channel Manager NTID
    */
    @isTest
    public static void itShouldSetChannelManager(){
        User testCastrolUser1 = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser1.Ntid__c = 'testNTID';
        
        User testCastrolUser2 = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser2.Ntid__c = 'testNTID2';
        
        insert new List<User>{testCastrolUser1, testCastrolUser2};
        Account testAccount1, testAccount2;
        System.runAs(testCastrolUser1){
            testAccount1 = SFO_TestDataService.createCustomerAccount();
            testAccount1.CASFO_Channel_Manager_NTID__c = 'testNTID';
            
            testAccount2 = SFO_TestDataService.createCustomerAccount();
            testAccount2.CASFO_Channel_Manager_NTID__c = 'testNTID2';
            
            insert new List<Account>{testAccount1, testAccount2};
         }
        List<Account> accountsInserted = [SELECT Id, CASFO_Channel_Manager__c 
                                          FROM Account 
                                          WHERE Id =: testAccount1.Id OR Id =: testAccount2.Id
                                          Order by CASFO_Channel_Manager_NTID__c ];
        
        System.assertEquals(testCastrolUser1.Id, accountsInserted[0].CASFO_Channel_Manager__c);
        System.assertEquals(testCastrolUser2.Id, accountsInserted[1].CASFO_Channel_Manager__c);
    }
}