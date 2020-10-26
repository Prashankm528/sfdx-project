/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 2/2018
*
**/
@isTest
public class REIDP_PAStoreSearchControllerTest {
    @isTest 
    static void getStoreAcceptanceLocationConfig_Success() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        REIDP_PAStoreSearchController.StoreConfig conf = REIDP_PAStoreSearchController.getStoreAcceptanceLocationConfig('testCode');
        System.assertNotEquals(null, conf);
        System.assertEquals(false, conf.mobileEnabled);
        System.assertEquals(null, conf.goLiveDate);
        Test.stopTest();
    }
    
    @isTest 
    static void getStoreAcceptanceLocationConfig_Fail() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try{
            REIDP_PAStoreSearchController.getStoreAcceptanceLocationConfig(null);
            System.assert(false);
        }
        catch(Exception ex) {
			System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void setMobileEnabled_Success() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.assert(REIDP_PAStoreSearchController.setMobileEnabled('testCode', true));
        Test.stopTest();
    }
    
    @isTest 
    static void setMobileEnabled_Fail() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try{
            REIDP_PAStoreSearchController.setMobileEnabled(null, true);
            System.assert(false);
        }
        catch(Exception ex) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest 
    static void updateStoreAcceptanceLocationConfig_Success() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        REIDP_PAB2BApi.AcceptanceLocation aLocation = new REIDP_PAB2BApi.AcceptanceLocation();
        aLocation.storeCode = 'testCode';
        Test.startTest();
        System.assert(REIDP_PAStoreSearchController.updateStoreAcceptanceLocationConfig(JSON.serialize(aLocation), 
                                                                                        true, 
                                                                                        '1/1/2018'));
        Test.stopTest();
    }
    
    @isTest 
    static void updateStoreAcceptanceLocationConfig_Fail() {
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        ((REIDP_PAIntegrationTestMock) mock).setup();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try{
            REIDP_PAStoreSearchController.updateStoreAcceptanceLocationConfig(null, true, null);
            System.assert(false);
        }
        catch(Exception ex) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
}