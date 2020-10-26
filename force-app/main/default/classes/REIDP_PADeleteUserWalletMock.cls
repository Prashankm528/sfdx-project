/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
* deleteCustomerCardInfo Api method mock class
**/
@isTest
global class REIDP_PADeleteUserWalletMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            System.debug('activation got request: ' + request);
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PADeleteCustomerCardInfoMock.Request.class);
            
        } catch (Exception e) {
            return error();
        }
        if(request.deleteCustomerCardInfoRequest.customerUri != null
           && request.deleteCustomerCardInfoRequest.issuingPartnerUri != null
           && request.deleteCustomerCardInfoRequest.partnerUri  != null
           && request.deleteCustomerCardInfoRequest.cardUri  != null
          )
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PADeleteCustomerCardInfo.Request deleteCustomerCardInfoRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PADeleteCustomerCardInfo.Response response = new REIDP_PADeleteCustomerCardInfo.Response();
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