/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
global class REIDP_PAUpdateCustomerMFAQuestionsMock  implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('PUT', req.getMethod());
        try {
            Request request = (Request) JSON.deserializeStrict(req.getBody(), REIDP_PAUpdateCustomerMFAQuestionsMock.Request.class);
            if(request.updateCustomerMFAQuestionsRequest.customerUri != null
               && request.updateCustomerMFAQuestionsRequest.issuingPartnerUri != null
               && request.updateCustomerMFAQuestionsRequest.questionsAnswers  != null
               && request.updateCustomerMFAQuestionsRequest.partnerUri  != null)
                return success();
            else
                return error();
            
            
        } catch (Exception e) {
            return error();
        }
    }
    
    public class Request {
        public REIDP_PAUpdateCustomerMFAQuestions.Request updateCustomerMFAQuestionsRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PAUpdateCustomerMFAQuestions.Response response = new REIDP_PAUpdateCustomerMFAQuestions.Response();
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
        
        REIDP_PADeleteCustomer.Response response = new REIDP_PADeleteCustomer.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.INVALID_DATA;
        response.status = status;
        res.setBody('{"response": ' + JSON.serialize(response) + '}');
        return res;
    }
}