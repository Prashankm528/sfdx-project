/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements deleteCustomerCardInfo Paydiant API method
 **/
public class REIDP_PADeleteCustomerCardInfo extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    }
    /* end of required */
    
    /* static methods */
    public static Boolean deleteCard(String cardUri, String customerUri, String issuingPartnerUri, String partnerUri) {
       REIDP_PADeleteCustomerCardInfo method = new REIDP_PADeleteCustomerCardInfo();
       method.args.issuingPartnerUri = issuingPartnerUri;
       method.args.customerUri = customerUri;
       method.args.partnerUri = partnerUri;
       method.args.cardUri = cardUri;

       Response res = method.send();
        
        
	   if(res.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS)
           return true;
       else
           return false;       
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PADeleteCustomerCardInfo() {
        super('customers/cards/delete/', 'POST');
        this.requestName = 'deleteCustomerCardInfoRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PADeleteCustomerCardInfo.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public String cardUri;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
    }
    
    /* other classes */
    
    /* end of other classes */
}