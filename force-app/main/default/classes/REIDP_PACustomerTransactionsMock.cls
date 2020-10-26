/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Mock transactions reply
 **/
@isTest
global class REIDP_PACustomerTransactionsMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        //try {
            System.debug('req body: ' + req.getBody());
            Request request = (Request) JSON.deserialize(req.getBody(), REIDP_PACustomerTransactionsMock.Request.class);
            System.debug('got request: ' + request);
            if(request.retrieveCustomerTransactionsHistoryRequest.customerUri != null
               && request.retrieveCustomerTransactionsHistoryRequest.issuingPartnerUri != null
               && request.retrieveCustomerTransactionsHistoryRequest.partnerUri  != null)
                return success();
            else
                return error();
            
            
        //} catch (Exception e) {
         //   return error();
        //}
    }
    
    public class Request {
        public REIDP_PARetrieveCustomerTransactions.Request retrieveCustomerTransactionsHistoryRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerTransactions.Response response = new REIDP_PARetrieveCustomerTransactions.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        response.customerTransactions  = new List<REIDP_PAApi.CustomerTransaction>();
        REIDP_PAApi.CustomerTransaction q = new REIDP_PAApi.CustomerTransaction();
        q.terminalId = 'test terminal Id';
        response.customerTransactions.add(q);
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