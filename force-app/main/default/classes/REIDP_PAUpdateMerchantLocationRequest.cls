/**
 * @author Nazim Aliyev
 * @company bluewolf, an ibm company
 * @date 2/2018
 *
 * Class implements updateMerchantLocationRequest Paydiant API method
 **/
public class REIDP_PAUpdateMerchantLocationRequest extends REIDP_PAApiMethod{
    /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        this.args.setB2BMessageHeader();
        return JSON.serializePretty(this.args, true).replace('"currency_SF_RESERVED_FIX"', '"currency"');
    } 
    /* end of required */
    
    /* static methods */
    public static Response updateMerchantLocation(String merchantCode, REIDP_PAB2BApi.AcceptanceLocation acceptanceLocation) {
        REIDP_PAUpdateMerchantLocationRequest method = new REIDP_PAUpdateMerchantLocationRequest();
        
        method.args.merchantCode = merchantCode;
        method.args.acceptanceLocation = acceptanceLocation;
        Response res = method.send();
        
		return res;
    }
    /* end of static methods */
    
    /* constructors */
    public REIDP_PAUpdateMerchantLocationRequest() {
        super('onboarding/merchants/stores', 'PUT', true);
        this.requestName = 'updateMerchantLocationRequest';
    }
    /* end of constructors */
    
    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        System.debug(jsonString);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PAUpdateMerchantLocationRequest.Response.class);
        return this.response;
    }
    /* end of instance methods */
    
    /* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String merchantCode;
        public REIDP_PAB2BApi.AcceptanceLocation acceptanceLocation;
    }
    
    /* response */
    
    public class Response extends REIDP_PAApiResponse  {}
}