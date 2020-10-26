/****************************************************************************************************
*  Date          : 29-JAN-2020
*  Author        : Roselin Hephzibah
*  Description   : GCM_LinkInteractionDetailsTest.
*  Modifications : 29-JAN-2020 Roselin - Initial Version.
				   11-FEB-2020 Roselin - Added method to cover GCM_WDEEmailMessageController
				   16-MAR-2020 Roselin - Enhanced to increase code coverage.
****************************************************************************************************/
@isTest(isParallel=true)
public class GCM_LinkInteractionDetailsTest {
    
/****************************************************************************************************
  Testmethod to cover GCM_LinkInteractionDetails.
 ****************************************************************************************************/
     static testMethod void linkInteractionDetailTest() {
         List<RecordType> recordTypeList = [Select id,name,DeveloperName,SobjectType from RecordType where SobjectType =: 'Task' and Developername =: 'GCM_Task'];           
         
         //Insert Account
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c;
         
         //Insert EmailMessage
         EmailMessage emailMsg = new EmailMessage();
         emailMsg.Subject = 'subject';
         emailMsg.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
         emailMsg.TextBody = 'messageText';
         emailMsg.FromAddress = 'roselin.hephzibah@bp.com';
         emailMsg.ToAddress = 'rhephzi1@in.ibm.com';
         emailMsg.status = '1';
         emailMsg.Incoming = true;
         String str = '2019-12-06T11:04:10+00:00';
         emailMsg.messagedate = (DateTime)Json.deserialize('"'+str+'"', DateTime.class);
         emailMsg.GCM_Has_Attachment__c = true;
         insert emailMsg;
         
         //Insert Task
         Task tas = new Task();
         tas.Subject='test';
         tas.GCM_Email_Message_Id__c = emailMsg.Id;
         tas.Status ='In Progress';
         tas.CallType = 'Inbound';
         tas.WhatId = c.Id;
         tas.softphone_it__IWS_Media_Name__c = 'email';
         tas.Type = 'Fax-Inbound';
         tas.GCM_Interaction_Mark_Done__c = false;
         tas.OwnerId = UserInfo.getUserId();
         tas.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas;
         
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.Status ='In Progress';
         tas1.CallType = 'Outbound';
         tas1.WhoId = con.Id;
         tas1.WhatId = c.Id;
         tas1.softphone_it__IWS_Interaction_ID__c = '1234567892';
         tas1.softphone_it__IWS_Media_Name__c = 'email';
         tas1.Type = 'Email-Outbound';
         tas.GCM_Email_Message_Id__c = emailMsg.Id;
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas1;
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(tas);
         GCM_LinkInteractionDetails lidp = new GCM_LinkInteractionDetails(controller);
         GCM_LinkInteractionDetails.parentInteractionId = '1234567890';
         GCM_LinkInteractionDetails.interactionId = '1234567891';
        
         boolean disb = GCM_LinkInteractionDetails.disableButton;
         PageReference myVfPage = Page.GCM_AssociateTaskwithInteraction;
         Test.setCurrentPage(myVfPage);
         //Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', tas.Id);
         Task t1 = GCM_LinkInteractionDetails.taskRec;
         List <SelectOption> tempOptions = lidp.interactionDisplayList;
         
         Test.startTest();
         //Call controller methods
         lidp.pageLoad();
         lidp.associateCaseToTask();
         Test.stopTest();
         
         ApexPages.StandardController controller1 = new ApexPages.StandardController(tas1);
         GCM_LinkInteractionDetails lidp1 = new GCM_LinkInteractionDetails(controller1);
         ApexPages.currentPage().getParameters().put('id', tas1.Id);
         List <SelectOption> tempOptions1 = lidp1.interactionDisplayList;
         
         
         //Assert Statements
         System.assert(tas1.WhoId == con.Id);
     }
    
/****************************************************************************************************
  Testmethod to cover GCM_WDEEmailMessageController.
 ****************************************************************************************************/
     static testMethod void wdeEmailMessageControllerTest() {
         List<RecordType> recordTypeList = [Select id,name,DeveloperName,SobjectType from RecordType where SobjectType =: 'Task' and Developername =: 'GCM_Task'];           
         
         //Insert Account
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c;
         
         //Insert Email Message
         EmailMessage emailMsg = new EmailMessage();
         emailMsg.Subject = 'subject';
         emailMsg.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
         emailMsg.TextBody = 'messageText';
         emailMsg.ToAddress = 'rhephzi1@in.ibm.com';
         emailMsg.status = '1';
         String str = '2019-12-06T11:04:10+00:00';
         emailMsg.messagedate = (DateTime)Json.deserialize('"'+str+'"', DateTime.class);
         insert emailMsg;
         
         //Insert Task
         Task tas = new Task();
         tas.Subject='test';
         tas.Status ='In Progress';
         tas.CallType = 'Inbound';
         tas.WhatId = c.Id;
         tas.softphone_it__IWS_Media_Name__c = 'email';
         tas.Type = 'Fax-Inbound';
         tas.GCM_Interaction_Mark_Done__c = false;
         tas.OwnerId = UserInfo.getUserId();
         tas.softphone_it__IWS_Interaction_ID__c = '1234567892';
         tas.GCM_Email_Message_Id__c = emailMsg.Id;
         if(!recordTypeList.isEmpty()){
                tas.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas;
         
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(emailMsg);
         GCM_WDEEmailMessageController wemcp = new GCM_WDEEmailMessageController(controller);
         PageReference myVfPage = Page.GCM_WDEEmailResponsefromSalesforce;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', emailMsg.Id);
         Task tas1 = GCM_WDEEmailMessageController.emailTaskRec;
         
         Test.startTest();
         //Call controller methods
         wemcp.pageLoad();
         Test.stopTest();
         
         //Assert Statements
         System.assert(tas.GCM_Email_Message_Id__c == emailMsg.Id, 'Email message does not exist on task!');
     }
}