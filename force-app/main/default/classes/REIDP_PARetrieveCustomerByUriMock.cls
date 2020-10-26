/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * retrieveCustomerByUri mock class
 **/
@isTest
global class REIDP_PARetrieveCustomerByUriMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
		System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PARetrieveCustomerByUriMock.Request.class);
            System.debug('got request: ' + request);

        } catch (Exception e) {
            return error();
        }
        if(request.retrieveCustomerByUriRequest.customerUri != null
           && request.retrieveCustomerByUriRequest.issuingPartnerUri != null
           && request.retrieveCustomerByUriRequest.partnerUri  != null)
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PARetrieveCustomerByUri.Request retrieveCustomerByUriRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerByUri.Response response = new REIDP_PARetrieveCustomerByUri.Response();
        response.modifiedTime = '1508812435';
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        System.debug('pure response: ' + JSON.serialize(response));
        res.setBody('{"response": ' + JSON.serialize(response) + '}');
        return res;
    }
    
    public static HTTPResponse error() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        
        res.setBody('{"response":  }');
        return res;
    }
}