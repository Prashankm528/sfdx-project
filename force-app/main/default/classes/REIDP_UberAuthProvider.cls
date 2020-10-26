global with sharing class REIDP_UberAuthProvider extends Auth.AuthProviderPluginClass {

   
    public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;


    private String authUrl;    // application redirection to the Instgram website for authentication and authorizations
    private String accessTokenUrl; // uri to get the new access token from Uber  using the GET verb
    private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in Uber
    private String userAPIVersionUrl; // version of the user api url to access data from Uber
    private String url;
    private String scope;
    private String grantType;
    @TestVisible  Map<String, Object> responseMap;
    @TestVisible public Auth.AuthProviderTokenResponse response;
    
   global String getCustomMetadataType() {
        return 'REIDP_Custom_Auth_Config__mdt'; // this comes from auth provider configuration so not needed
    }
    
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
    String url;
        authUrl = authProviderConfiguration.get('Auth_URL__c');
        key = authProviderConfiguration.get('Client_ID__c');
        redirectUrl = authProviderConfiguration.get('Redirect_URL__c');
        scope= authProviderConfiguration.get('Scopes__c');
        url = authUrl + '?client_id='+ key +'&response_type=code'+ '&state=' + stateToPropagate+'&scope='+ scope+'&redirect_uri='+redirectUrl;
     
        return new PageReference(url);
    }
    
       global override Auth.OAuthRefreshResult refresh(Map<string,string> authProviderConfiguration, String refreshToken) {
           Auth.OAuthRefreshResult result;
            try{
            String token;

            String sfdcState;
            key = authProviderConfiguration.get('Client_ID__c'); 
            secret =authProviderConfiguration.get('Client_Secret__c'); 
            accessTokenUrl =authProviderConfiguration.get('Access_Token_URL__c'); 
            redirectURL =authProviderConfiguration.get('Redirect_URL__c');
            HttpRequest req = new HttpRequest(); 
            url = accessTokenUrl;
            grantType='refresh_token';
            String body= '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"client_secret\"\r\n\r\n'+secret+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"client_id\"\r\n\r\n'+key+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"grant_type\"\r\n\r\n'+grantType+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"refresh_token\"\r\n\r\n'+refreshToken+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--';
            req.setbody(body);       
            
            req.setHeader('Content-Length',String.valueOf(body.length()));
            req.setHeader('Content-Type','application/json');
            req.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            
            req.setHeader('Host',' login.uber.com');
            req.setMethod('POST'); 
            req.setEndpoint(url);
           
            Http http = new Http(); 
            
            HTTPResponse res = http.send(req); 
            String responseBody = res.getBody(); 
            system.debug('@@@refresh@@@@+'+responseBody );
                 Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                     ///       throw new myexception (responseBody );
           String accessToken= (String)responseMap.get('access_token');
            refreshToken = (String)responseMap.get('refresh_token');
           System.debug('response map from second '+responseMap);
                  ///  throw new myexception (String.valueof(responseMap));
            result = new Auth.OAuthRefreshResult(accessToken, refreshToken);

            // throw new myexception (responseMap);
           // result = new Auth.OAuthRefreshResult('', '');
            }catch(exception e){
               throw new myexception (e.getMessage());
            }
          return result ;
       }
      public class myexception extends exception{
          
      }
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        String token;
        String refreshToken;
        String sfdcState;
       key = authProviderConfiguration.get('Client_ID__c'); 
        secret =authProviderConfiguration.get('Client_Secret__c'); 
        accessTokenUrl =authProviderConfiguration.get('Access_Token_URL__c'); 
        redirectURL =authProviderConfiguration.get('Redirect_URL__c');
    
        Map<String,String> queryParams = state.queryParameters; 
        String code = queryParams.get('code'); 
        sfdcState = queryParams.get('state'); 
        HttpRequest req = new HttpRequest(); 
        url = accessTokenUrl;
        grantType='authorization_code';
        String body= '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"client_secret\"\r\n\r\n'+secret+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"client_id\"\r\n\r\n'+key+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"grant_type\"\r\n\r\n'+grantType+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"redirect_uri\"\r\n\r\n'+redirectURL+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"code\"\r\n\r\n'+ code+'\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        req.setbody(body);       
        
        req.setHeader('Content-Length',String.valueOf(body.length()));
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
        
        req.setHeader('Host',' login.uber.com');
        req.setMethod('POST'); 
        req.setEndpoint(url);
       
        Http http = new Http(); 
        HTTPResponse res = http.send(req); 
        String responseBody = res.getBody(); 
        if(!Test.isRunningTest()){
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        token = (String)responseMap.get('access_token');
            refreshToken = (String)responseMap.get('refresh_token');
            System.debug('response map from second '+responseMap);
        }
        return new Auth.AuthProviderTokenResponse('REIDP_UberAuthProvider', token, refreshToken, sfdcState);
  }
    
    
    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        //Here the developer is responsible for constructing an Auth.UserData object
        String token = response.oauthToken;
        
        userAPIUrl = authProviderConfiguration.get('User_Endpoint__c');
                system.debug('@@@@@@@@@response in userinfo@@@'+response);
        //  Uber requires access token in the query string
        
        responseMap = callUserapi(token,userAPIUrl);
        String driverid = (String)responseMap.get('driver_id');
        Blob requestBlob = Blob.valueOf(driverid);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        system.debug('@@@@@@@@@responseMap@@@'+responseMap);
        String hashDriverID = EncodingUtil.convertToHex(hash);
        String id = hashDriverID;
        String username = (String)responseMap.get('email');
        String profilePicture = (String)responseMap.get('picture');
        String website = (String)responseMap.get('website');
        String bio = (String)responseMap.get('bio');
        String firstname = (String)responseMap.get('first_name'); 
        String lastname = (String)responseMap.get('last_name'); 
        String fullname = firstname+lastname;
        String email = (String)responseMap.get('email');
        Map<String,String> provMap = new Map<String,String>();
        provMap.put('profilePicture', profilePicture);
        provMap.put('bio', bio);
        provMap.put('sfdc_networkid',Network.getNetworkId());
        return new Auth.UserData(id, firstname, lastname, fullName, email, null, username,null, 'REIDP_UberAuthProvider', null, provMap);
    }
    
    global static Map<String, Object> callUserapi(String token, String userAPIUrl){
        Map<String, Object> resMap = new Map<String,Object>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(userAPIUrl + '?access_token=' + token);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('!!!!!!!!!response data'+ token);
        
        resMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        return resMap;
        
    }
    
}