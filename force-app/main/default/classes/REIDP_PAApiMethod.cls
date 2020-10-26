/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Abstract Paydiant API method class
 * 
 * should be extended if implementing a Paydiant API method
 * 
 * ** NOTICE ** 
 * the child class should have an 
 * --  'args' instance field- contains the Response object
 * --  'buildArgsJSON' instance method- method that produces JSON from the args field;
 * This method can be copy pasted from other implementation if there is no desire for custom
 * functionality
 * 
 * -- DEFAULT CONSTRUCTOR- the default constructor should call the parent class constructor in
 * the following manner:
 *   super(String endpoint, String methodType) where:
 * - endpoint: it's a API endpoint e.g. '/customers/lookup' (notice there is no need to use base url)
 * - methodType: GET, POST,... one of those
 * 
 */

public abstract class REIDP_PAApiMethod {
    public static String baseApiUrl {
        get {
            if(REIDP_Constants.isSandbox)
                return 'callout:REIDP_PaydiantCertificationAPI/';      
            else
                return 'callout:REIDP_PaydiantProductionAPI/';
        }
        private set;
    }
    
    public static String baseApiUrlB2B {
        get {
            if(REIDP_Constants.isSandbox)
                return 'callout:REIDP_PaydiantCertificationB2BAPI/';
            else
                return 'callout:REIDP_PaydiantProductionB2BAPI/';
        }
        private set;
    }
    
    
    public String apiEndpoint;
    public Boolean isB2BApi;

    public String requestName;
    public String requestJSON;
    HttpRequest request;
    
    public HttpResponse rawResponse;
    
    public REIDP_PAApiMethod(String endpoint, String type, Boolean isB2BApi) {
        this.isB2BApi = isB2BApi;
        this.apiEndpoint = (isB2BApi ? baseApiUrlB2B : baseApiUrl) + endpoint;
        request = new HttpRequest();
        request.setHeader('Authorization', 'Basic ' +'{!$Credential.Password}');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(60000); //Increased timeout, as it sometimes failed with read timeouts in production
        request.setEndpoint(this.apiEndpoint);
        request.setMethod(type);
    }
   
    public REIDP_PAApiMethod(String endpoint, String type) {
        this(endpoint, type, false);
    }
    
    public virtual void build() {
		String argsJSON = this.buildArgsJSON();
        this.requestJSON = '{"' + this.requestName + '": ' + argsJSON + '}';
    }

    public virtual HttpResponse sendAndReturnRaw() {
        build();
        System.debug('REQUEST: ' + this.requestJSON);
        request.setBody(this.requestJSON);
        Http h = new Http();
        this.rawResponse = h.send(request);
        System.debug('response: ' + this.rawResponse.getBody());
        return this.rawResponse;
    }

    /* when implementing this method the child class
       should also have a arguments class field */
    public abstract String buildArgsJSON();
}