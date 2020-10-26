/****************************************************************************************************
*  Date          : 02-JAN-2020
*  Author        : SoftPhone IT
*  Description   : ConnectorEntityController_Test.
*  Modifications : 
****************************************************************************************************/
@isTest
private class ConnectorEntityController_Test {

     static testMethod void myUnitTest() {
         //Insert Account
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact defCon = new contact();
         defCon.phone = '+521234567892';
         defCon.FirstName = 'Mx Fuels Dealer';
         defCon.lastName = 'Default';
         defCon.Email = 'abc@it.it';
         defCon.accountId = acc.Id;
         insert defCon;
         
         //Insert Task
         Task a = new Task();
         a.Subject='test';
         a.CallType = 'Inbound';
         
         Test.startTest();
         Task tsk1 = ConnectorEntityController.createTask(a, 'Email', 'abc@it.it');
         String sr = ConnectorEntityController.ERCOmniUtilsPath;
         ConnectorEntityController.GetResourceURL('namespace', 'resourceName');
         GCM_CTIController cticon = new GCM_CTIController();
         ConnectorEntityController cecp = new ConnectorEntityController(cticon);
         ConnectorEntityController cec = new ConnectorEntityController();
         Test.stopTest();
         
         //Assertion
         System.assert(tsk1.WhoId == defCon.Id, 'Contact recogition not successfull');
    }
}