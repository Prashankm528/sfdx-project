/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
public class REIDP_PADeleteCustomerTest { 
    static String customerUri = 'test_customerUri';
    static String issuingPartnerUri = 'test_issuingPartnerUri';
    static String partnerUri = 'test_partnerUri';
    
    @isTest static void constructorTest() {
        REIDP_PADeleteCustomer method = new REIDP_PADeleteCustomer();
        System.assertNotEquals(null, method);
    }
    
    @isTest static void deleteCustomerSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PADeleteCustomerMock());
        System.assert(REIDP_PADeleteCustomer.deleteCustomer(customerUri, issuingPartnerUri, partnerUri));
    }
    
    @isTest static void deleteCustomerFailTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PADeleteCustomerMock());
        System.assert(!REIDP_PADeleteCustomer.deleteCustomer(null, issuingPartnerUri, partnerUri));
    }
}