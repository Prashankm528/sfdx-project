/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
global class REIDP_PADeleteCustomerMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        try {
            Request request = (Request) JSON.deserializeStrict(req.getBody(), REIDP_PADeleteCustomerMock.Request.class);
            if(request.deleteCustomerRequest.customerUri != null
               && request.deleteCustomerRequest.issuingPartnerUri != null
               && request.deleteCustomerRequest.partnerUri  != null)
                return success();
            else
                return error();
            
            
        } catch (Exception e) {
            return error();
        }
    }
    
    public class Request {
        public REIDP_PADeleteCustomer.Request deleteCustomerRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PADeleteCustomer.Response response = new REIDP_PADeleteCustomer.Response();
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
        
        REIDP_PADeleteCustomer.Response response = new REIDP_PADeleteCustomer.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.INVALID_DATA;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response) + '}');
        return res;
    }
}