/***ESASharedController Test Class***/
/*Description : This Apex Test class is for ESA_SharedAccountList Apex Class.
 *Project     : ESA B2B Fuels
 *Copyright   : Tata Consultancy Services Ltd
 *Last Modified Date : 4/10/19
*/

@isTest
public with sharing class ESA_SharedAccountControllerTestClass {

    /***ESASharedController Test Class***/
/*Description : This Apex Test class is for ESA_SharedAccountList Apex Class.
 *Project     : ESA B2B Fuels
 *Copyright   : Tata Consultancy Services Ltd
 *Last Modified Date : 4/10/19
*/
    public static testMethod void TestFunction(){         
        List<Account> result = new List<Account>();
        List<Account> testAccounts = new List<Account>();
        ESA_Test_Setup testsetup = new ESA_Test_Setup();
        testAccounts = testsetup.createAccount1();     
        insert testAccounts;
        Test.StartTest();
            if(testAccounts.size()>0){
                for(Account acc: testAccounts)
                {         
                   result = ESA_SharedAccountController.getAccountNames(acc.Id);            
                } 
            }                   
       Test.stopTest();
            system.assertEquals(2,result.size());  
    }
}