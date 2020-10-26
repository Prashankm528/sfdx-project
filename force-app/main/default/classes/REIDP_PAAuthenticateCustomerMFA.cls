/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implementing authenticateCustomerMFA Paydiant API method
 **/
public class REIDP_PAAuthenticateCustomerMFA extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static Boolean authenticateSecurityQuestions(String customerUri, String issuingPartnerUri, String partnerUri, 
                                                                     List<REIDP_PAApi.QuestionAnswer> questionsAnswers) {
        REIDP_PAAuthenticateCustomerMFA method = new REIDP_PAAuthenticateCustomerMFA();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
        method.args.questionAnswers = questionsAnswers;
        Response res = method.send();
        
    	if(res.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS)
           return true;
       else
           return false;      
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PAAuthenticateCustomerMFA() {
        super('customers/security/authenticate/mfa', 'POST');
        this.requestName = 'authenticateCustomerMFARequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        System.debug('auth response json: ' + this.requestJSON);
        System.debug('auth response json: ' + jsonString);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString,  REIDP_PAAuthenticateCustomerMFA.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public List<REIDP_PAApi.QuestionAnswer> questionAnswers;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
    }
    
    /* other classes */
    /* end of other classes */
}