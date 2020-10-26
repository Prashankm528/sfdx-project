/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrievsMFAQuestions Paydiant API method
 **/
public class REIDP_PARetrieveMFAQuestions extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static List<REIDP_PAApi.Question> getSecurityQuestions(String customerUri, String issuingPartnerUri, String partnerUri) {
        REIDP_PARetrieveMFAQuestions method = new REIDP_PARetrieveMFAQuestions();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
        
        Response res = method.send();

        return res.questionDetails;
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveMFAQuestions() {
        super('partners/security/mfa/search/', 'POST');
        this.requestName = 'retrieveMFAQuestionsRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveMFAQuestions.Response.class);
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
    }
    
    /* other classes */
    /* end of other classes */
}