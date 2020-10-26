@isTest
global class REIDP_RevokeOAuthTokenMock implements HttpCalloutMock {
    
    public Set<String> tokens;
    
    global REIDP_RevokeOAuthTokenMock () {
        this.tokens = new Set<String>();
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/revoke', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', req.getHeader('Content-Type'));
        
        // Store request tokens
        this.tokens.add(req.getBody());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        return res;
    }
}