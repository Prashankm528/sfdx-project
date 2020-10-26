/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 2/2018
*
**/
@isTest
global class REIDP_PARetrieveAcceptanceLocationMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('Responding from URI mock on request: ' + req.getBody());
        Request request;
        try {
            request = (Request) JSON.deserialize(req.getBody(), REIDP_PARetrieveAcceptanceLocationMock.Request.class);
            System.debug('got request: ' + request);
        } catch (Exception e) {
            return error();
        }
        if(request.retrieveAcceptanceLocationConfigRequest.storeCode != null
           && request.retrieveAcceptanceLocationConfigRequest.merchantCode != null
           && request.retrieveAcceptanceLocationConfigRequest.parentCode  != null
           && request.retrieveAcceptanceLocationConfigRequest.messageHeader != null)
            return success();
        else
            return error();
    }
    
    public class Request {
        public REIDP_PARetrieveAcceptanceLocationConfig.Request retrieveAcceptanceLocationConfigRequest;
    }
    
    public static HTTPResponse success() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        REIDP_PARetrieveAcceptanceLocationConfig.Response response = new REIDP_PARetrieveAcceptanceLocationConfig.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.SUCCESS;
        response.status = status;
        response.acceptanceLocationConfiguration = new REIDP_PARetrieveAcceptanceLocationConfig.AcceptanceLocationConfiguration();
        response.acceptanceLocationConfiguration.acceptanceLocation = new REIDP_PAB2BApi.AcceptanceLocation(); 
        response.acceptanceLocationConfiguration.acceptanceLocation.storeCode = 'testCode';
        response.acceptanceLocationConfiguration.acceptanceLocation.additionalInformation = new List<REIDP_PAApi.KeyVal>();
        REIDP_PAApi.KeyVal keyVal = new REIDP_PAApi.KeyVal();
        keyVal.key = 'SL_CUSTOM_ATTRIBUTES_1';
        keyVal.value = 'MobileEnabled=FALSE,Restaurant=FALSE,BPDiesel=TRUE,Shop=TRUE,RepairService=FALSE,CentsPerGallonDiscount=TRUE,BPDriverRewards=TRUE,ATM=TRUE,CarWash=TRUE,BPVisa=TRUE,WiFi=FALSE,Bathroom=TRUE,AllTime=FALSE,MonOP=05:00 AM,MonCLS=11:00 PM,TueOP=05:00 AM,TueCL=11:00 PM';
        response.acceptanceLocationConfiguration.acceptanceLocation.additionalInformation.add(keyVal);
        System.debug('pure response: ' + JSON.serialize(response));
        res.setBody('{"response": ' +  JSON.serialize(response) + '}');
        return res;
    }
    
    public static HTTPResponse error() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        REIDP_PARetrieveAcceptanceLocationConfig.Response response = new REIDP_PARetrieveAcceptanceLocationConfig.Response();
        REIDP_PAApiResponse.Status status = new REIDP_PAApiResponse.Status();
        status.statusCode = REIDP_PAApiResponse.StatusCode.FAILED;
        response.status = status;
        res.setBody('{"response": ' +  JSON.serialize(response) + '}');
        return res;
    }
}