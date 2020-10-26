/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
public class REIDP_PARetrieveMFAQuestionsTest {
	static String customerUri = 'test_customerUri';
    static String issuingPartnerUri = 'test_issuingPartnerUri';
    static String partnerUri = 'test_partnerUri';
    
    @isTest static void constructorTest() {
        REIDP_PARetrieveMFAQuestions method = new REIDP_PARetrieveMFAQuestions();
        System.assertNotEquals(null, method);
    }
    
    @isTest static void getSecurityQuestionsSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PARetrieveMFAQuestionsMock());
        System.assert(REIDP_PARetrieveMFAQuestions.getSecurityQuestions(customerUri, issuingPartnerUri, partnerUri) != null);
    }
    
    @isTest static void getSecurityQuestionsBadArgsTest() {
        Test.setMock(HttpCalloutMock.class, new REIDP_PARetrieveMFAQuestionsMock());
        try {
        REIDP_PADeleteCustomer.deleteCustomer(null, issuingPartnerUri, partnerUri);
		System.assert(false);
        } catch (JSONException e) {
            System.assert(true);
        }
    }
}