/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
global class REIDP_PARetrieveCustomerMFAQuestionsMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        try {
            Request request = (Request) JSON.deserialize(req.getBody(), REIDP_PARetrieveCustomerMFAQuestionsMock.Request.class);
            if(request.retrieveCustomerMFAQuestionsRequest.customerUri != null
               && request.retrieveCustomerMFAQuestionsRequest.issuingPartnerUri != null
               && request.retrieveCustomerMFAQuestionsRequest.partnerUri  != null)
                return success();
            else
                return error();
            
            
        } catch (Exception e) {
            return error();
        }
    }
    
    public class Request {
        public REIDP_PARetrieveCustomerMFAQuestions.Request retrieveCustomerMFAQuestionsRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveCustomerMFAQuestions.Response response = new REIDP_PARetrieveCustomerMFAQuestions.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        response.questionDetails = new List<REIDP_PAApi.Question>();
        REIDP_PAApi.Question q = new REIDP_PAApi.Question();
        q.question = 'tests questions';
        q.mandatory = true;
        response.questionDetails.add(q);
        response.numberOfQuestionsToAnswer = 3;
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