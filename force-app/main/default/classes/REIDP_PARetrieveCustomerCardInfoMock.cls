/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
* retrieveCustomerCardInfo Api method mock class
**/
@isTest
global class REIDP_PARetrieveCustomerCardInfoMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            System.debug('activation got request: ' + request);
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PARetrieveCustomerCardInfoMock.Request.class);
            
        } catch (Exception e) {
            return error();
        }
        if(request.retrieveCustomerCardInfoRequest.customerUri != null
           && request.retrieveCustomerCardInfoRequest.issuingPartnerUri != null
           && request.retrieveCustomerCardInfoRequest.partnerUri  != null
           && request.retrieveCustomerCardInfoRequest.includeMetaData  != null
          )
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PARetrieveCustomerCardInfo.Request retrieveCustomerCardInfoRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerCardInfo.Response response = new REIDP_PARetrieveCustomerCardInfo.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        List<REIDP_PAApi.Card> l = new List<REIDP_PAApi.Card>();
        REIDP_PAApi.Card c = new REIDP_PAApi.Card();
        l.add(c);
		response.cards = l;
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