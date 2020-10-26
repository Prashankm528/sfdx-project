/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 09/2017
 * 
 * Class to manage OAuth Tokens
 */
public class REIDP_OAuthHelper {
    
    @future(callout=true)
    public static void revokeTokensForUser(String userId){
        
        List<String> tokens = new List<String>();
        
        if(!Test.isRunningTest()) {
            for (OauthToken token : [SELECT DeleteToken FROM OauthToken WHERE UserId =:userId]) {
                tokens.add(token.DeleteToken);
            }
        }
        sendRevokeRequest(tokens);
    }
    
    @future(callout=true)
    public static void revokeToken(String authToken) {
        List<String> tokens = new List<String>();
        tokens.add(authToken);
        sendRevokeRequest(tokens);
    }
        
    @future(callout=true)
    public static void revokeTokens(List<String> authTokens) {
        sendRevokeRequest(authTokens);
    }
    
    public static List<HttpResponse> sendRevokeRequest(List<String> authTokens) {
        
        List<HttpResponse> responses = new List<HttpResponse>();
        
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setTimeout(20000); //Increased timeout, as it sometimes failed with read timeouts in production
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/revoke');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            for (String token : authTokens) {
                req.setBody('token=' + EncodingUtil.urlEncode(token, 'UTF-8'));
                HttpResponse resp = http.send(req);
                responses.add(resp);
                System.debug('Revoke OAuth Tokens on Password Lockout HttpRequest reqest ' + req);
                System.debug('Revoke OAuth Tokens on Password Lockout HttpRequest response ' + resp + resp.getBody());
            }
        } catch (Exception e) {
            REIDP_ErrorHandling.logWarningErrorLog(REIDP_OAuthHelper.class, 'Error while trying to revoke OAuth tokens', e);
        }
        return responses;
    }
    
}