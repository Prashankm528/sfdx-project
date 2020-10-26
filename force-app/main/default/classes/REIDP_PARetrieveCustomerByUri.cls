/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrieveCustomerByUri Paydiant API method
 **/
public class REIDP_PARetrieveCustomerByUri extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    }
    /* end of required */
    
    /* static methods */
    public static String getModifiedTime(String customerUri, String issuingPartnerUri, String partnerUri) {
        REIDP_PARetrieveCustomerByUri method = new REIDP_PARetrieveCustomerByUri();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
        
        return method.send().modifiedTime;
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveCustomerByUri() {
        super('customers/lookup/uri/', 'POST');
        this.requestName = 'retrieveCustomerByUriRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveCustomerByUri.Response.class);
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
        public String modifiedTime;
    }
}