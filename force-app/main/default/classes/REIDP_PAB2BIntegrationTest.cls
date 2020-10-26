/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 2/2018
*
**/
@isTest
public class REIDP_PAB2BIntegrationTest {
	@isTest 
    static void getStoreAcceptanceLocationConfig_Success() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.assertNotEquals(null, REIDP_PAB2BApi.getStoreAcceptanceLocationConfig('testCode'));
        Test.stopTest();
    }
    
    @isTest 
    static void getStoreAcceptanceLocationConfig_Fail() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try{
            REIDP_PAB2BApi.getStoreAcceptanceLocationConfig(null);
            System.assert(false);
        }
        catch(Exception ex) {
			System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void updateMerchantLocation_Success() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.assert(REIDP_PAB2BApi.updateMerchantLocation(new REIDP_PAB2BApi.AcceptanceLocation()));
        Test.stopTest();
    }
    
    @isTest 
    static void updateMerchantLocation_Fail() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try{
            REIDP_PAB2BApi.updateMerchantLocation(null);
            System.assert(false);
        }
        catch(Exception ex) {
            System.assert(true);
        }
        Test.stopTest();
    }
}