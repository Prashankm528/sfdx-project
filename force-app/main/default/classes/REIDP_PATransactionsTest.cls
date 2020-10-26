/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
public class REIDP_PATransactionsTest  {
	static String customerUri = 'test_customerUri';
    static String issuingPartnerUri = 'test_issuingPartnerUri';
    static String partnerUri = 'test_partnerUri';
    
    @isTest static void constructorTest() {
        REIDP_PARetrieveCustomerTransactions method = new REIDP_PARetrieveCustomerTransactions();
        System.assertNotEquals(null, method);
    }
    
    @isTest static void getTransactionsSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PACustomerTransactionsMock());
        System.assert(REIDP_PARetrieveCustomerTransactions.getCustomerTransactions(customerUri, issuingPartnerUri, partnerUri, 1, null) != null);
    }
    
    @isTest static void getTransactionsBadArgsTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PACustomerTransactionsMock());
        try {
        REIDP_PARetrieveCustomerTransactions.getCustomerTransactions(null, issuingPartnerUri, partnerUri, 1, null);
		System.assert(false);
        } catch (JSONException e) {
            System.assert(true);
        }
    }
}