/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
* retrieveCustomerByUri mock class
**/
@isTest
global class REIDP_PAUpdateCustomerActivationMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('PUT', req.getMethod());
        System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            System.debug('activation got request: ' + request);
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PAUpdateCustomerActivationMock.Request.class);
            
        } catch (Exception e) {
            return error();
        }
        if(request.updateCustomerActivationRequest.customerUri != null
           && request.updateCustomerActivationRequest.issuingPartnerUri != null
           && request.updateCustomerActivationRequest.partnerUri  != null
          )
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PAUpdateCustomerActivation.Request updateCustomerActivationRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PAUpdateCustomerActivation.Response response = new REIDP_PAUpdateCustomerActivation.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        System.debug('pure response: ' + JSON.serialize(response));
        res.setBody('{"response": ' + JSON.serialize(response));
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