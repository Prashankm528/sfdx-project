/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements updateCustomerMFAQuestions Paydiant API method
 **/
public class REIDP_PAUpdateCustomerMFAQuestions  extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static Boolean updateSecurityQuestions(String customerUri, String issuingPartnerUri, String partnerUri, 
                                                                     List<REIDP_PAApi.QuestionAnswer> qas) 
    {
        REIDP_PAUpdateCustomerMFAQuestions method = new REIDP_PAUpdateCustomerMFAQuestions();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
        method.args.questionsAnswers = qas;

        Response res = method.send();
        //System.debug(method.sendAndReturnRaw().getBody());
        if(res.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS)
            return true;
        else
            return false;   
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PAUpdateCustomerMFAQuestions() {
        super('customers/security/mfa/', 'PUT');
        this.requestName = 'updateCustomerMFAQuestionsRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
		System.debug('JSON REQUEST: ' + this.requestJSON);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString,  REIDP_PAUpdateCustomerMFAQuestions.Response.class);
        return this.response;
    }
    
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public List<REIDP_PAApi.QuestionAnswer> questionsAnswers{get;set;}
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
    }
    
    /* other classes */
    /* end of other classes */
}