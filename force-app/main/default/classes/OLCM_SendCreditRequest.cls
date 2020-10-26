//To send credit request
global with sharing class OLCM_SendCreditRequest{
  @future (callout=true)
   public static void creditRequest(Id accountId) {
     //Construct HTTP request and response
     //Http request method,Endpoint and setBody
     HttpRequest req = new HttpRequest();
     req.setHeader('Content-Type','application/json');
     String endpoint = 'http://bp-ds-sappre-xapi-v1-dev.uk-e1.cloudhub.io/';
     req.setMethod('POST');
     req.setEndpoint(endpoint);
       req.setTimeout(60000);
     system.debug('accID' +accountId);
      String[] allFields = new String[]{};
     Map<String, Schema.SObjectField> fields = Schema.SObjectType.Account.fields.getMap();//map of field name and value
     for (String fieldName:fields.keySet()) {
        DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
        if (fieldDesc.isAccessible()) {
        allFields.add(fieldDesc.getName());
        }
    }
     //SOQL to construct JSON string in set body
     Account[] acc=Database.query('select ' + String.join(allFields, ', ') + ' from Account where id=:accountId ');//get value of all fields of this account which is accessible
                  
     system.debug('serialized JSON'+JSON.serialize(acc));
     String JsonString=JSON.serialize(acc);
     req.setBody(JsonString);  
     system.debug(JsonString);
     //Http response method 
     Http http = new Http();
     HTTPResponse res = http.send(req);
     System.debug(res.getBody());

   }
 }