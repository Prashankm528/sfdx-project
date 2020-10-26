/*
* @author Jewelslyn Shama P
* @company Tata Consultancy Services
* @date 
* 
*/
public with sharing  class OLCM_AccountTriggerHandlerQueueable implements Queueable, Database.AllowsCallouts {
public list<Account> accList;
public Set<Id> accIds=new set<Id>();

public OLCM_AccountTriggerHandlerQueueable(List<Account> accs){
this.accList = accs ;  
}
public void execute(QueueableContext context){
for(Account acc :accList){

if(acc.OLCM_Credit_Request_Check__c == true || (acc.Marked_For_Deletion__c == false&&OLCM_constant.chksend==false&&acc.OLCM_Siebel_Check__c ==true ))
{
accIds.add(acc.Id);

OLCM_constant.chksend =true;
}

}

if(accIds != null){   

for(id i:accIds){ 
       
       
List<OLCM_Http_Request__c> reqdat = OLCM_Http_Request__c.getall().values();
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Mule_Test_Credit_Request_API/api/creditAssesmentReq/'+i);
req.setMethod('GET');
req.setHeader('Client_id',reqdat[0].OLCM_Client_Id__c);

system.debug('Client_id'+reqdat[0].OLCM_Client_Id__c);
   
    req.setHeader('Client_secret',reqdat[0].OLCM_Client_Secret__c);  
   
Http http = new Http();
     if(i!=null){
HTTPResponse res = http.send(req);

 }          
}     
}
}
}