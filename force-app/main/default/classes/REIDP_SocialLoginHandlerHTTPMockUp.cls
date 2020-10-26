@isTest
global class REIDP_SocialLoginHandlerHTTPMockUp implements HttpCalloutMock{
    //    Implement this interface method  
    global HTTPResponse respond(HTTPRequest request) {
        

        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        Auth.UserData data = createUser('test@example.com','TestName','TestLastName');
        response.setBody('{"reqData" : {"firstname":"' + data.firstname + '","lastname":"' + data.lastname + '","email":"' + data.email  + '","socialUser":' + true + '}}');
        response.setStatusCode(200);
        return response; 
    }
    
    private static Auth.UserData createUser(String email, String lastName, String firstName) {
        Map<String, String> attributeMap = new Map<String,String>();
        String identifier = lastName + System.currentTimeMillis();
        String locale = 'en_US';
        attributeMap.put('sfdc_networkid', '00000001');
        return new Auth.UserData( identifier,
                                 firstName,
                                 lastName,
                                 '', // fullname
                                 email,
                                 '', // link
                                 '', // userName
                                 locale,
                                 '', // provider
                                 '', // siteLoginUrl
                                 attributeMap);       
    }
}