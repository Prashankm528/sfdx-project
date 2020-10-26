/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 4/2019
*
*/
@isTest
public class REIDP_PostCopyObfuscateTest {
    @isTest
    static void testMySandboxPrep() {
        Test.startTest();
        
        Test.testSandboxPostCopyScript(
            new REIDP_PostCopyObfuscate(), UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        
        Test.stopTest();
        System.assertNotEquals(0, [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                                           FROM AsyncApexJob].size());
    }
}