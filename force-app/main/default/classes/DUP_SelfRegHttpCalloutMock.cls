/*****************************************************************************************
*       Date:        28JAN2020	
*       Author:      Arron Kukadia - IBM
*       Description: HttpCallout Mock for DUP_SelfRegistrationController
*****************************************************************************************/

@isTest
global class DUP_SelfRegHttpCalloutMock implements HttpCalloutMock  {
	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reqData" :{"firstname":"Tester","lastname":"Testing","email":"test@test.org"}}');                 
        response.setStatusCode(201);
        return response;         
    }
}