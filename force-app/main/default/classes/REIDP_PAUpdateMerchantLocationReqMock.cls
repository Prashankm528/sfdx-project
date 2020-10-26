/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 2/2018
*
**/
@isTest
global class REIDP_PAUpdateMerchantLocationReqMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PAUpdateMerchantLocationReqMock.Request.class);
            System.debug('got request: ' + request);
        } catch (Exception e) {
            return error();
        }
        if(request.updateMerchantLocationRequest.acceptanceLocation != null
           && request.updateMerchantLocationRequest.merchantCode != null
           && request.updateMerchantLocationRequest.messageHeader != null)
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PAUpdateMerchantLocationRequest.Request updateMerchantLocationRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PAUpdateMerchantLocationRequest.Response response = new REIDP_PAUpdateMerchantLocationRequest.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        System.debug('pure response: ' + JSON.serialize(response));
        res.setBody('{"response": ' +  JSON.serialize(response) + '}');
        return res;
    }
    
    public static HTTPResponse error() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        REIDP_PAUpdateMerchantLocationRequest.Response response = new REIDP_PAUpdateMerchantLocationRequest.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.FAILED;
        response.status = status;
        res.setBody('{"response": ' +  JSON.serialize(response) + '}');
        return res;
    }   
}