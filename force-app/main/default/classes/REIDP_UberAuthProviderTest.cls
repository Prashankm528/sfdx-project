/**
 * @author Neha* 
 * @company Bluewolf, an IBM Company
 * @date 6/2017    
 *
*
 * A test class for Uber Auth Provider
 */
@IsTest 
    public class REIDP_UberAuthProviderTest { 


    
        private static final String OAUTH_TOKEN = 'testToken'; 

        private static final String STATE = 'mocktestState'; 
        private static final String REFRESH_TOKEN = 'refreshToken'; 
        private static final String LOGIN_ID = 'testLoginId'; 
        private static final String USERNAME = 'testUsername'; 
        private static final String FIRST_NAME = 'testFirstName'; 
        private static final String LAST_NAME = 'testLastName'; 
        private static final String EMAIL_ADDRESS = 'testEmailAddress'; 
        private static final String LOCALE_NAME = 'phone_number'; 
        private static final String promo_code = 'promo_code'; 
        private static final String rating = 'rating'; 
        private static final String activation_status = 'activation_status'; 
        private static final String driver_id = 'driver_id'; 
        private static final String email = 'email'; 
        private static final String phone_number = 'testLocalName'; 
        private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
        private static final String PROVIDER = 'Uber'; 
        private static final String REDIRECT_URL = 'https://idpdev-bpcustomer.cs109.force.com/BP/services/authcallback/Uber_Test'; 
        private static final String KEY = 'testKey'; 
        private static final String SECRET = 'testSecret'; 
        private static final String STATE_TO_PROPOGATE = 'testState'; 
        private static final String ACCESS_TOKEN_URL = 'https://login.uber.com/oauth/v2/token'; 
        private static final String API_USER_VERSION_URL = 'http://www.dummyhost.com/user/20/1'; 
        private static final String AUTH_URL = 'https://login.uber.com/oauth/v2/authorize'; 
        private static final String API_USER_URL = 'www.uberCls.com/user/api'; 
        private static final String grantType='authorization_code';
        private static  Auth.AuthProviderTokenResponse actualAuthProvResponse;
    
    // In the real world scenario, the key and value would be read 
    // from the (custom fields in) custom metadata type record. 
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put('Key__c', KEY); 
        authProviderConfiguration.put('Auth_Url__c', AUTH_URL); 
        authProviderConfiguration.put('clientSecret__c', SECRET); 
        authProviderConfiguration.put('Access_Token_URL__c', ACCESS_TOKEN_URL); 
        authProviderConfiguration.put('API_User_Url__c',API_USER_URL); 
        authProviderConfiguration.put('API_User_Version_Url__c', API_USER_VERSION_URL); 
        authProviderConfiguration.put('Redirect_Url__c',REDIRECT_URL); 
        return authProviderConfiguration; 
    
    } 
    
    static testMethod void testInitiateMethod() 
    { 
        String stateToPropogate = 'mocktestState'; 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        REIDP_UberAuthProvider uberCls = new REIDP_UberAuthProvider(); 
        uberCls.redirectUrl = authProviderConfiguration.get('Redirect_Url__c'); 
        PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Auth_Url__c') + '?client_id='+ 
                                    authProviderConfiguration.get('Key__c') +'&scope=USER,EXPRPT,LIST&redirect_uri='+ 
                                    authProviderConfiguration.get('Redirect_Url__c') + '&state=' + 
                                    STATE_TO_PROPOGATE); 
        PageReference actualUrl = uberCls.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assert(expectedUrl.getUrl()!=null, 'URL is null');
        
    } 
    
    static testMethod void testHandleCallback() 
    { 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        REIDP_UberAuthProvider concurCls = new REIDP_UberAuthProvider(); 
        concurCls.redirectUrl = authProviderConfiguration.get('Redirect_Url_c'); 
    
        Test.setMock(HttpCalloutMock.class, new uberMockHttpResponseGenerator()); 
        
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',authProviderConfiguration.get('State_c')); 
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
         actualAuthProvResponse =  concurCls.handleCallback(authProviderConfiguration, cbState); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('Uber', OAUTH_TOKEN, REFRESH_TOKEN, null); 
    
        System.assert(expectedAuthProvResponse.oauthToken!=null, 'Oauth token  is null');

    } 
     
    static testMethod void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        REIDP_UberAuthProvider concurCls = new REIDP_UberAuthProvider(); 
    
        Test.setMock(HttpCalloutMock.class, new UberMockHttpResponseGenerator()); 
    
        //Auth.AuthProviderTokenResponse
        concurCls.response = new Auth.AuthProviderTokenResponse( PROVIDER, OAUTH_TOKEN ,'sampleOauthSecret', STATE); 
        Auth.UserData actualUserData = concurCls.getUserInfo(authProviderConfiguration, concurCls.response) ; 
   
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2'); 
    
        Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID,FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, 
                                        null, LOCALE_NAME, null, PROVIDER, null, provMap);
        System.assert(LOGIN_ID!=null,'Driver ID returned');
    
       
    } 
    
    
    // Implement a mock http response generator for Concur. 
    public class UberMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String namespace = API_USER_VERSION_URL; 
            String prefix = 'mockPrefix'; 
    
            Dom.Document doc = new Dom.Document(); 
            Dom.XmlNode xmlNode = doc.createRootElement( 'mockRootNodeName', namespace, prefix); 
            xmlNode.addChildElement('+17635552061', namespace, prefix).addTextNode(phone_number); 
            xmlNode.addChildElement('FirstName', namespace, prefix).addTextNode(first_name); 
            xmlNode.addChildElement('LastName', namespace, prefix).addTextNode(last_name); 
            xmlNode.addChildElement('EmailAddress', namespace, prefix).addTextNode(promo_code); 
            xmlNode.addChildElement('LocaleName', namespace, prefix) .addTextNode(rating); 
            xmlNode.addChildElement('Token', null, null).addTextNode(activation_status);
             xmlNode.addChildElement('8NpYoNAXy-iwMqAFa84p49_96fQi5Ry72FcYuEDADIbaLzVkAjWcLpbfGVieq_0tSkubuF', null, null).addTextNode(driver_id);
             xmlNode.addChildElement('Token', null, null).addTextNode(email);
            System.debug(doc.toXmlString()); 
            // Create a fake response 
            string fulljson ='{\"phone_number\":\"+17635552061\",\"picture\":\"APKAJSDH2OZQQSA64LQQ\",\"first_name\":\"Friso\",\"last_name\":\"Kok\",\"promo_code\":\"frisok93vui\",\"rating\":5,\"activation_status\":\"active\",\"driver_id\":\"8NpYoNAX\",\"email\":\"friso.kok+test+blue@uber.com\"}';
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/xml'); 
            res.setBody(fulljson); 
            res.setStatusCode(200); 
            return res; 
        } 
    
    } 
}