@isTest
private class GCP_EmailMessageHandlerTest {

 static testMethod void unitTest1(){
 GCP_EmailMessageHandler TestGCPInboundEmail = New GCP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(null,null);
        }
 }