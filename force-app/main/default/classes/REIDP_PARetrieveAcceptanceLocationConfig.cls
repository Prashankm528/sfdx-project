/**
 * @author Nazim Aliyev
 * @company bluewolf, an ibm company
 * @date 2/2018
 *
 * Class implements retrieveAcceptanceLocationConfig Paydiant API method
 **/
public class REIDP_PARetrieveAcceptanceLocationConfig extends REIDP_PAApiMethod {
    /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        this.args.setB2BMessageHeader();
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static Response getAcceptanceLocationConfig(String storeCode, String merchantCode, String parentCode) {
        REIDP_PARetrieveAcceptanceLocationConfig method = new REIDP_PARetrieveAcceptanceLocationConfig();
        
        method.args.storeCode = storeCode;
        method.args.merchantCode = merchantCode;
        method.args.parentCode = parentCode;
        Response res = method.send();

        return res;
    }
    /* end of static methods */
    
    /* constructors */
    public REIDP_PARetrieveAcceptanceLocationConfig() {
        super('onboarding/config/merchants/stores/search', 'POST', true);
        this.requestName = 'retrieveAcceptanceLocationConfigRequest';
    }
    /* end of constructors */
    
    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();

        //Fix for reserved keyword Currency
        jsonString = jsonString.replace('"currency":', '"currency_SF_RESERVED_FIX":');
        //End Fix

        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveAcceptanceLocationConfig.Response.class);
        return this.response;
    }
    /* end of instance methods */
    
    /* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String storeCode;
        public String merchantCode;
        public String parentCode;
    }
    
    /* response */
    
    public class Response extends REIDP_PAApiResponse  {
        public AcceptanceLocationConfiguration acceptanceLocationConfiguration;
    }
    
    /* other classes */
    public class AcceptanceLocationConfiguration {
        public REIDP_PAB2BApi.AcceptanceLocation acceptanceLocation;
    }
    
    /* end of other classes */
    
}