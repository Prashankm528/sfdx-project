@isTest
global class CDM_Dofa_HttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(request.getEndpoint().containsIgnoreCase(Label.CDM_Dofa_Api_Url))
            response.setBody('{  "listDelegates": {    "Delegates": {      "FirstName": "Tronje",      "LastName": "Schneider-Pungs",      "EmployeeNumber": "",      "NTLoginForDelegate": "BP1\\SCTN0Q",      "GPID": "HH99IT59",      "EmailAddressForDelegate": "tronje.schneider-pungs@de.bp.com",      "Country": "Germany",      "Currency": "EUR",      "SegmentName": "Downstream",      "Delegations": [        {          "Organisation": "Downstream",          "DelegatorName": "Rigas, Thanasis",          "NTLoginForDelegator": "BP1\\RIGASA",          "GPIDForDelegator": "DQ49GN02",          "AuthorisationType": "IN",          "AuthorisationName": "Requisition",          "USDAmount": "50000",          "ApprovalAmount": "41500",          "AuthorityAmount": [            {              "SAPCompanyCode": "",              "SAPUSDAmount": "",              "SAPApprovalAmount": ""            }          ],          "UnlimitedAmount": "",          "Currency": "EUR",          "LastChangedDate": "10112014",          "SupportingNotes": ""        }      ]    }  }}');
         if(request.getEndpoint().containsIgnoreCase(Label.CDM_Currency_Api))
            response.setBody('{"rates":{"CAD":1.4679,"HKD":8.6525,"ISK":136.3,"PHP":56.235,"DKK":7.4727,"HUF":334.29,"CZK":25.513,"AUD":1.6287,"RON":4.7741,"SEK":10.6265,"IDR":15575.19,"INR":79.271,"BRL":4.6313,"RUB":70.4361,"HRK":7.4365,"JPY":120.03,"THB":33.39,"CHF":1.0994,"SGD":1.5072,"PLN":4.2977,"BGN":1.9558,"TRY":6.3119,"CNY":7.7834,"NOK":10.1083,"NZD":1.7236,"ZAR":16.2718,"USD":1.1058,"MXN":21.4472,"ILS":3.8332,"GBP":0.8598,"KRW":1303.07,"MYR":4.6123},"base":"EUR","date":"2019-11-22"}');    
        response.setStatusCode(200);
        return response; 
    }
}