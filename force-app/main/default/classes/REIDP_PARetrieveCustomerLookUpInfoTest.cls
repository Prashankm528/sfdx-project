/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
* retrieveCustomerInfo Api method mock class
**/
@isTest
public class REIDP_PARetrieveCustomerLookUpInfoTest {
    static String customerUri = 'test_customerUri';
    static String issuingPartnerUri = 'test_issuingPartnerUri';
    static String partnerUri = 'test_partnerUri';
    static String email = 'test@test.com';
    
    @isTest static void constructorTest() {
        REIDP_PARetrieveCustomerLookUpInfo method = new REIDP_PARetrieveCustomerLookUpInfo();
        System.assertNotEquals(null, method);
    }
    
    @isTest static void getUserSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PARetrieveCustomerLookUpInfoMock());
        System.assert(REIDP_PARetrieveCustomerLookUpInfo.retrieveUser(email) != null);
    }
    
    @isTest static void getWrongUserTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PARetrieveCustomerLookUpInfoMock());
        try {
            System.assert(REIDP_PARetrieveCustomerLookUpInfo.retrieveUser('wrong-account-id') != null);
            System.assert(false);
        } catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException e) {
            System.assert(true);
        }
    }
    
    @isTest static void getTransactionsBadArgsTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PARetrieveCustomerLookUpInfoMock());
        try {
            REIDP_PARetrieveCustomerLookUpInfo.retrieveUser(null);
            System.assert(false);
        } catch (JSONException e) {
            System.assert(true);
        }
    }
}