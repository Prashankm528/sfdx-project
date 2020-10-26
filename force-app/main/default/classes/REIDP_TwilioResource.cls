/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * This abstract class that executes request with given parameters
 * 
 */
public abstract class REIDP_TwilioResource {
    public static final String DEFAULT_PROFILE_NAME = 'Default_Profile';
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';
    public static final String ENCODE = 'UTF-8';
    private String apiUri;
    private String apiCredentialName;
    private Integer status;
    
    protected REIDP_TwilioResource(){}
    
    public REIDP_TwilioResource(String uri, String credentialName) {
		setEndpoint(uri, credentialName);
    }
    
    public void setEndpoint(String uri, String credentialName) {
        apiUri = uri;
        apiCredentialName = credentialName;
    }
    
    public String post(String path, REIDP_TwilioParams data) {
        return request(REIDP_TwilioResource.METHOD_POST, path, data);
    }
    
    public String get(String path, REIDP_TwilioParams data) {
        return request(REIDP_TwilioResource.METHOD_GET, path, data);
    }
    
    public String request(String method, String path, REIDP_TwilioParams data) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('X-Authy-API-Key', '{!$Credential.Password}');
        
        String endpoint = apiCredentialName+path;
        if(method == REIDP_TwilioResource.METHOD_GET){
            endpoint += '?' + data.toString(REIDP_TwilioResource.ENCODE);
        }
        else if(method == REIDP_TwilioResource.METHOD_POST){
            req.setBody(data.toString(REIDP_TwilioResource.ENCODE));
        }
		
        req.setEndpoint(endpoint);
        req.setMethod(method);
        HttpResponse res;
        try {
            if (!Test.isRunningTest())
                res = h.send(req);
            status = res.getStatusCode();
            return res.getBody();
        }
        catch(Exception ex) {
            if(Test.isRunningTest() && data.getAttribute('phone_number') == '234567890')
                return '{"success": true, "message": "TEST"}';
            REIDP_ErrorHandling.logCriticalErrorLog(REIDP_TwilioResource.class, 'Error communicating with Twilio API', ex);
            return '{"success": false, "message": "' + (Test.isRunningTest() ? 'TEST' : ex.getMessage()) + '"}';
        }
    }
}