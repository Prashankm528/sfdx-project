/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements updateCustomerActivation Paydiant API method
 **/
public class REIDP_PAUpdateCustomerActivation extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    }
    
    /* overriding because 'activate' is a reserved keyword but
     * is required by the Paydiant API as such */
    public override void build() {
        String argsJSON = this.buildArgsJSON();
        argsJSON = argsJSON.replace('activateddd', 'activate');
        System.debug('final json: ' + argsJSON);
        this.requestJSON = '{"' + this.requestName + '": ' + argsJSON + '}';
    }
    /* end of required */
    
    /* static methods */
    public static Boolean setWalletState(String customerUri, String issuingPartnerUri, String partnerUri, Boolean state) {
       
       System.debug('setting state to ' + state); 
       REIDP_PAUpdateCustomerActivation method = new REIDP_PAUpdateCustomerActivation();
       method.args.issuingPartnerUri = issuingPartnerUri;
       method.args.customerUri = customerUri;
       method.args.partnerUri = partnerUri;
       method.args.activateddd = state;
       
       Response res = method.send();
       
       if(res.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS)
           return true;
       else
           return false;
       
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PAUpdateCustomerActivation() {
        super('customers/activation/', 'PUT');
        this.requestName = 'updateCustomerActivationRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PAUpdateCustomerActivation.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public Boolean activateddd;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
    }
}