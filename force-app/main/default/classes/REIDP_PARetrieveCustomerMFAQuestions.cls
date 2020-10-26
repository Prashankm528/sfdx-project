/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrieveCustomerMFAQuestions Paydiant API method
 **/
public class REIDP_PARetrieveCustomerMFAQuestions extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static REIDP_PAApi.QuestionsWrap getSecurityQuestions(String customerUri, String issuingPartnerUri, String partnerUri) {
        REIDP_PARetrieveCustomerMFAQuestions method = new REIDP_PARetrieveCustomerMFAQuestions();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
        
        Response res = method.send();
        REIDP_PAApi.QuestionsWrap qw = new  REIDP_PAApi.QuestionsWrap();
        qw.questions = res.questionDetails;
        qw.numberOfQuestionsToAnswer = res.numberOfQuestionsToAnswer;
        return  qw;
    }
    
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveCustomerMFAQuestions() {
        super('customers/security/mfa/search/', 'POST');
        this.requestName = 'retrieveCustomerMFAQuestionsRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        System.debug('as raw JSON: ' + jsonString);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveCustomerMFAQuestions.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
        public List<REIDP_PAApi.Question> questionDetails;
        public Integer numberOfQuestionsToAnswer;
    }
    
    /* other classes */
    /* end of other classes */
}