/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
global class REIDP_PAAuthenticateCustomerMFAMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        try {
            Request request = (Request) JSON.deserializeStrict(req.getBody(), REIDP_PAAuthenticateCustomerMFAMock.Request.class);
            if(request.authenticateCustomerMFARequest.customerUri != null
               && request.authenticateCustomerMFARequest.issuingPartnerUri != null
               && request.authenticateCustomerMFARequest.questionAnswers != null
               && request.authenticateCustomerMFARequest.partnerUri  != null)
                return success();
            else
                return error();
            
            
        } catch (Exception e) {
            return error();
        }
    }
    
    public class Request {
        public REIDP_PAAuthenticateCustomerMFA.Request authenticateCustomerMFARequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PAAuthenticateCustomerMFA.Response response = new REIDP_PAAuthenticateCustomerMFA.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response) + '}');
        return res;
    }
    
    public static HTTPResponse error() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        
        REIDP_PAAuthenticateCustomerMFA.Response response = new REIDP_PAAuthenticateCustomerMFA.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.INVALID_DATA;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response) + '}');
        return res;
    }
}