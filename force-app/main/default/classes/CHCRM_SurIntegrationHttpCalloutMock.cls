/*****************************************************************************************
*       Date:        2020-08-14 
*       Author:      Xc
*       Description: HttpCallout Mock for CHCRM Surrounding Integration
*****************************************************************************************/
@isTest
public with sharing class CHCRM_SurIntegrationHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().endsWith('token')) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599","expires_on": "1597386027","not_before": "1597382127","resource": "111","access_token": "testtoken"}');
            res.setStatusCode(200);
            return res;
        } else if (req.getEndpoint().endsWith('hqMAssmntObj/upsert')) {
            return getResponese();
        } else if (req.getEndpoint().endsWith('contacter/upsert')) {
            return getResponese();
        } else if (req.getEndpoint().endsWith('wspYS/upsert')) {
            return getResponese();
        } else if (req.getEndpoint().endsWith('wspYSRef/upsert')) {
            return getResponese();
        }  else if (req.getEndpoint().endsWith('event/upsert')) {
            return getResponese();
        } else if (req.getEndpoint().endsWith('event/delete')) {
            return getResponese();
        } else if (req.getEndpoint().endsWith('hqMAssmnt/upsert')) {
            return getResponese();
        }else {
            return getResponese();
        }
    }
    public HTTPResponse getResponese(){
        HTTPResponse res = new HTTPResponse();
        res.setBody('{"code":"success","msg":"success","data":"success"}');
        res.setStatusCode(200);
        return res;
    }
}