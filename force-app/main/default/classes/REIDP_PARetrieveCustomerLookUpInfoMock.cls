/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * retrieveCustomerLookUpInfo mock class
 **/
@isTest
global class REIDP_PARetrieveCustomerLookUpInfoMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        Request request;
        request = (Request) JSON.deserialize(req.getBody(), REIDP_PARetrieveCustomerLookUpInfoMock.Request.class);
        System.debug('mock got: ' + req.getBody());
        if(request.retrieveCustomerLookUpInfoRequest.email != null)
            if(request.retrieveCustomerLookUpInfoRequest.email == REIDP_PAIntegrationTest.wrongAccountId)
            	return emptySuccess();
        	else
                return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PARetrieveCustomerLookUpInfo.Request retrieveCustomerLookUpInfoRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerLookUpInfo.Response response = new REIDP_PARetrieveCustomerLookUpInfo.Response();
        List<REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo> clist = new List<REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo>();
        REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo c = new REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo();
        c.email = 'sometestemail';
        c.customerUri = 'test_customerUri';
    	c.issuingPartnerUri = 'test_issuingPartnerUri';
    	C.partnerUri = 'test_partnerUri';
        clist.add(c);
        response.customerLookUpInfo = clist;
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response));
        return res;
    }
    
    public static HTTPResponse emptySuccess() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerLookUpInfo.Response response = new REIDP_PARetrieveCustomerLookUpInfo.Response();
        List<REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo> clist = new List<REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo>();
        response.customerLookUpInfo = clist;
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response));
        return res;
    }
    
    public static HTTPResponse error() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        
        res.setBody('{"response":  ""}');
        return res;
    }
}