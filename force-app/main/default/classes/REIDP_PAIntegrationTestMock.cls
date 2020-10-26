/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
global class REIDP_PAIntegrationTestMock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
    
    public void setup() {
		System.debug('setting mock objects');
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/lookup/', new REIDP_PARetrieveCustomerLookUpInfoMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/lookup/uri/', new REIDP_PARetrieveCustomerByUriMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/activation/', new REIDP_PAUpdateCustomerActivationMock());
		setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/cards/search/', new REIDP_PARetrieveCustomerCardInfoMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/cards/delete/', new REIDP_PADeleteCustomerCardInfoMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/delete/', new REIDP_PADeleteCustomerMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/security/mfa/search/', new REIDP_PARetrieveCustomerMFAQuestionsMock());
		setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'partners/security/mfa/search/', new REIDP_PARetrieveMFAQuestionsMock());
		setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/transactions/search', new REIDP_PACustomerTransactionsMock());
		setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/security/mfa/', new REIDP_PAUpdateCustomerMFAQuestionsMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrl + 'customers/security/authenticate/mfa', new REIDP_PAAuthenticateCustomerMFAMock());
        
        //B2B API Mocks
        setResponseMock(REIDP_PAApiMethod.baseApiUrlB2B + 'onboarding/merchants/stores', new REIDP_PAUpdateMerchantLocationReqMock());
        setResponseMock(REIDP_PAApiMethod.baseApiUrlB2B + 'onboarding/config/merchants/stores/search', new REIDP_PARetrieveAcceptanceLocationMock());
    }
	
    public void setResponseMock(String endpoint, HttpCalloutMock mock) {
        requests.put(endpoint, mock);
    }
    
	global HTTPResponse respond(HTTPRequest req) {
       HttpCalloutMock m = requests.get(req.getEndpoint());   
        if(m != null) 
            return m.respond(req);
        
        return null;
	}

	
    public class TestException extends Exception {}
}