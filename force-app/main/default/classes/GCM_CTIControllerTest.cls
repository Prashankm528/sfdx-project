/****************************************************************************************************
*  Date          : 24-DEC-2019
*  Author        : Roselin Hephzibah
*  Description   : GCM_CTIControllerTest.
*  Modifications : 24-DEC-2019 Roselin - Initial Version.
				   07-MAY-2020 Roselin - Enhanced to cover Non voice CTI Methods.
****************************************************************************************************/
@isTest(isParallel = true)
private class GCM_CTIControllerTest {

    public static List<RecordType> recordTypeList = [Select id,name,DeveloperName,SobjectType from RecordType where SobjectType =: 'Task' and Developername =: 'GCM_Task'];           

/****************************************************************************************************
  Testmethod to cover GCM_CTIController - Voice.
 ****************************************************************************************************/
     static testMethod void ctiControllerVoiceTest() {
         
         //Create Task Instances
         Task tas = new Task();
         tas.Subject='test';
         tas.Status ='In Progress';
         tas.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.Status ='In Progress';
         tas1.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas2 = new Task();
         tas2.Subject='test';
         tas2.Status ='In Progress';
         tas2.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas2.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas3 = new Task();
         tas3.Subject='test';
         tas3.Status ='In Progress';
         tas3.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas3.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas4 = new Task();
         tas4.Subject='test';
         tas4.Status ='In Progress';
         tas4.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas4.RecordTypeId = recordTypeList.get(0).Id;
            }

         Task tas8 = new Task();
         tas8.Subject='test';
         tas8.Status ='In Progress';
         tas8.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas8.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas9 = new Task();
         tas9.Subject='test';
         tas9.Status ='In Progress';
         tas9.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas9.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas12 = new Task();
         tas12.Subject='test';
         tas12.Status ='In Progress';
         tas12.CallType = 'Outbound';
         if(!recordTypeList.isEmpty()){
                tas12.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas6 = new Task();
         tas6.Subject='test';
         tas6.Status ='In Progress';
         tas6.CallType = 'Inbound';
         tas6.softphone_it__IWS_Media_Name__c = 'email';
         tas6.Type = 'Email-Inbound';
         tas6.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas6.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas6;
         
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
         
         //Insert Tasks
         Task tas7 = new Task();
         tas7.Subject='test';
         tas7.Status ='In Progress';
         tas7.CallType = 'Outbound';
         tas7.WhatId = c.Id;
         tas7.GCM_Email_Message_Id__c = emailMsg.Id;
         tas7.softphone_it__IWS_Interaction_ID__c = '1234567891';
         if(!recordTypeList.isEmpty()){
                tas7.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas7;
         
         Task tas10 = new Task();
         tas10.Subject='test';
         tas10.Status ='In Progress';
         tas10.CallType = 'Outbound';
         tas10.softphone_it__IWS_Interaction_ID__c = '1234567890';
         tas10.GCM_Interaction_Mark_Done__c = true;
         if(!recordTypeList.isEmpty()){
                tas10.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas10;
         
         Task tas11 = new Task();
         tas11.Subject='test';
         tas11.Status ='In Progress';
         tas11.CallType = 'Inbound';
         tas11.WhatId = c.Id;
         tas11.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas11.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas11;
         
         //Insert Account
         Account defAcc = new Account();
         defAcc.name = 'MX Fuels Dealer Default';
         defAcc.Account_ERP_ID__c ='MX020104DEFAULT';
         defAcc.Sales_Organisation__c = 'MX02';
         defAcc.Type = 'Business';
         insert defAcc;
         
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
         
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Case instances
         Case c2 = new Case();
         c2.Type = 'Test';
         c2.Area__c = 'Test';
         c2.Sub_Area__c = 'Test';
         c2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         //Update Task
         tas11.WhoId = con.Id;
         update tas11;
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(c);
         GCM_CTIController cecp = new GCM_CTIController(controller);
         GCM_CTIController cec = new GCM_CTIController();
         List <SelectOption> tempOptions = cecp.interactionDisplayList;
         GCM_CTIController.interactionId = '1234567891';
         GCM_CTIController.parentInteractionId = '1234567890';
         String disb = GCM_CTIController.disableButton;
         
         PageReference myVfPage = Page.GCM_AssociateCasewithInteraction;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('myParam', c.Id);
          
         Test.startTest();
         //Call controller methods
         Task tsk1 = GCM_CTIController.createTaskforOutboundCall(tas1, '+517777777777', con.Id);
         Task tsk2 = GCM_CTIController.createTaskforOutboundCall(tas2, '+521234567892', null);         
         Task tsk3 = GCM_CTIController.createTaskforInboundCall(tas3, '+528888888888', String.valueof(acc.Id), String.valueof(con.Id), 'Single', defAcc.Id, defCon.Id);         
         Task tsk4 = GCM_CTIController.createTaskforInboundCall(tas4, '+528888888888', String.valueof(defAcc.Id), String.valueof(con.Id), 'ContactMultiAccount', defAcc.Id, defCon.Id); 
         Task tsk10 = GCM_CTIController.createTaskforInboundCall(tas8, '+528888888888', String.valueof(acc.Id), '', 'AccountMultiContact', defAcc.Id, defCon.Id);
         Task tsk11 = GCM_CTIController.createTaskforInboundCall(tas9, '+528888888888', null, null, 'MultiContact', defAcc.Id, defCon.Id);
         Task tsk6 = GCM_CTIController.updateTaskDetail(String.valueof(tas6.Id),'EndDate','Call-Inbound'); 
         Task tsk7 = GCM_CTIController.getTaskDetails(tas6.Id);
         Task tsk8 = GCM_CTIController.updateTaskOwner(string.valueof(tas6.Id));
         Task tsk9 = GCM_CTIController.updateTaskDetail(String.valueof(tas6.Id),'MarkDone','Call-Outbound');
         Task tsk12 = GCM_CTIController.getTaskDetails(c.Id);
         Task tsk13 = GCM_CTIController.getTaskDetails(tas11.Id);
         Task tsk14 = GCM_CTIController.createTaskforOutboundCall(tas12, '+517777777777', c.Id);
         
         GCM_CTIController.getCaseDetails(c.Id);
         cecp.associateExistingCasetoTask();
         ApexPages.currentPage().getParameters().put('id', c.Id);
         cecp.associateExistingCaseDetailstoTask();
         cecp.pageLoad();
         GCM_CTIController.getCaseRecordTypeId('','Fuels - Dealer');
         GCM_CTIController.getCaseRecordTypeId('','');
         GCM_CTIController.checkCurrentUser('herkej');
         GCM_CTIController.checkInteractionCase();
         Task tsk15 = GCM_CTIController.createTaskforInboundEmail(tas3, acc.Id, con.Id, 'NoMatch', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', null, 'Email', null, 'false','','' );
         Task tsk16 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id, 'NoMatch', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', null,'OutboundNew', 'roselin.hephzibah@bp.com', 'false','' );
         Task tsk17 = GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(tas3, acc.Id, con.Id, 'NoMatch', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', c2.CaseNumber, 'false','','' );
         Test.stopTest();
         
         //Assert Statements
         System.assert(tsk1.Id != null, 'Task creation not successfull. Click to call from Salesforce');
         System.assert(tsk2.WhoId == defCon.Id, 'Single match Contact recogition not successfull for Outbound Call');
         System.assert(tsk3.WhatId == acc.Id, 'Single match recogition not successfull for Inbound Call');
         System.assert(tsk4.WhoId == con.Id, 'ContactMultiAccount recogition not successfull for Inbound call');
         System.assert(tsk6.GCM_Call_End_Date__c != null, 'Call End date update not successfull');
         System.assert(tsk7.Id != null, 'Task record does not exist');
         System.assert(tsk9.GCM_Interaction_Mark_Done__c, 'Call End date update not successfull');
         System.assert(tsk10.WhatId == acc.Id, 'AccountMultiContact recogition not successfull');
         System.assert(tsk11.WhoId == defCon.Id, 'Multi match recogition not successfull');
         System.assert(tsk12 ==  null, 'Task record does not exist');
     }
    
/****************************************************************************************************
  Testmethod to cover GCM_CTIController - Non Voice.
 ****************************************************************************************************/
     static testMethod void ctiControllerNonVoiceTest() {
              
         //Insert Account
         Account defAcc = new Account();
         defAcc.name = 'MX Fuels Dealer Default';
         defAcc.Account_ERP_ID__c ='MX020104DEFAULT';
         defAcc.Sales_Organisation__c = 'MX02';
         defAcc.Type = 'Business';
         insert defAcc;
         
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.CSD_DistChannelDivCode__c = '0104';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact defCon = new contact();
         defCon.phone = '+521234567892';
         defCon.FirstName = 'Mx Fuels Dealer';
         defCon.lastName = 'Default';
         defCon.Email = 'abc@it.it';
         defCon.accountId = defAcc.Id;
         insert defCon;
         
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Create Task Instances
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.CallType = 'Inbound';
         tas1.softphone_it__IWS_Interaction_ID__c = '12345';
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }

         Task tas2 = new Task();
         tas2.Subject='test';
         tas2.CallType = 'Inbound';
         tas2.softphone_it__IWS_Interaction_ID__c = '12346';
         if(!recordTypeList.isEmpty()){
                tas2.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas3 = new Task();
         tas3.Subject='test';
         tas3.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas3.RecordTypeId = recordTypeList.get(0).Id;
            }
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.AccountId = defAcc.Id;
         c.ContactId = defCon.Id;
         c.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c;
         
         //Create Case Instance
         Case c1 = new Case();
         c1.Type = 'Test';
         c1.Area__c = 'Test';
         c1.Sub_Area__c = 'Test';
         c1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         Case c2 = new Case();
         c2.Type = 'Test';
         c2.Area__c = 'Test';
         c2.Sub_Area__c = 'Test';
         c2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         //Insert Task
         Task tas11 = new Task();
         tas11.Subject='test';
         tas11.Status ='In Progress';
         tas11.CallType = 'Inbound';
         tas11.WhatId = c.Id;
         tas11.Type = 'Fax-Inbound';
         tas11.WhoId = con.Id;
         tas11.softphone_it__IWS_Media_Name__c = 'email';
         tas11.GCM_Account__c = acc.Id;
         tas11.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas11.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas11;
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(c);
         GCM_CTIController cecp = new GCM_CTIController(controller);
         GCM_CTIController.interactionId = '1234567892';
         PageReference myVfPage = Page.GCM_AssociateCasewithInteraction;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', c.Id);
         
         Test.startTest();
         //Call controller methods
         cecp.associateExistingCaseDetailstoTask();
         Task tsk1 = GCM_CTIController.createTaskforInboundEmail(tas1, acc.Id, con.Id, 'Single', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c1, 'Email', null, 'true','','' );
         Task tsk2 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id, 'Single', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', null,'OutboundNew', 'roselin.hephzibah@bp.com', 'false','' );
         Task tsk3 = GCM_CTIController.updateTaskDetail(String.valueof(tas11.Id),'EmailReleased','Email-Inbound');
         Task tsk4 = GCM_CTIController.updateTaskOwner(string.valueof(tas11.Id));
         Task tsk5 = GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(tas3, acc.Id, con.Id, 'Single', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', c2.CaseNumber, 'false','','' );
         Test.stopTest();
         
         //Assert Statements
         System.assert(tsk1.Id != null, 'Task creation not successfull. Single match Inbound email');
     }
 
/****************************************************************************************************
  Testmethod to cover GCM_CTIController - Non Voice Part 1.
 ****************************************************************************************************/
     static testMethod void ctiControllerNonVoiceTest1() {
              
         //Insert Account
         Account defAcc = new Account();
         defAcc.name = 'MX Fuels Dealer Default';
         defAcc.Account_ERP_ID__c ='MX020104DEFAULT';
         defAcc.Sales_Organisation__c = 'MX02';
         defAcc.Type = 'Business';
         insert defAcc;
         
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.CSD_DistChannelDivCode__c = '0104';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact defCon = new contact();
         defCon.phone = '+521234567892';
         defCon.FirstName = 'Mx Fuels Dealer';
         defCon.lastName = 'Default';
         defCon.Email = 'abc@it.it';
         defCon.accountId = defAcc.Id;
         insert defCon;
         
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Create Task Instances
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.CallType = 'Inbound';
         tas1.softphone_it__IWS_Interaction_ID__c = '12345';
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }

         Task tas2 = new Task();
         tas2.Subject='test';
         tas2.CallType = 'Inbound';
         tas2.softphone_it__IWS_Interaction_ID__c = '12346';
         if(!recordTypeList.isEmpty()){
                tas2.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas3 = new Task();
         tas3.Subject='test';
         tas3.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas3.RecordTypeId = recordTypeList.get(0).Id;
            }
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.AccountId = acc.Id;
         c.ContactId = defCon.Id;
         c.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c;
         c.Status = 'Closed';
         c.GCM_ByPassValidation_Timestamp__c = DateTime.now();
         update c;
         
         //Create Case Instance
         Case c1 = new Case();
         c1.Type = 'Test';
         c1.Area__c = 'Test';
         c1.Sub_Area__c = 'Test';
         c1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         insert c1;
         
         Case c2 = new Case();
         c2.Type = 'Test';
         c2.Area__c = 'Test';
         c2.Sub_Area__c = 'Test';
         c2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         //Insert Task
         Task tas11 = new Task();
         tas11.Subject='test';
         tas11.Status ='In Progress';
         tas11.CallType = 'Inbound';
         tas11.WhatId = c.Id;
         tas11.Type = 'Email-Inbound';
         tas11.WhoId = con.Id;
         tas11.GCM_Account__c = acc.Id;
         tas11.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas11.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas11;

         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(c);
         GCM_CTIController cecp = new GCM_CTIController(controller);
         GCM_CTIController.interactionId = '1234567892';
         PageReference myVfPage = Page.GCM_AssociateCasewithInteraction;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', c.Id);
         
         Test.startTest();
         List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c from Case Where Id =: c1.Id];
         //Call controller methods
         cecp.associateExistingCaseDetailstoTask();
         if(!caseList.isEmpty()){
         	Task tsk1 = GCM_CTIController.createTaskforInboundEmail(tas1, acc.Id, con.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', null , 'Email', caseList.get(0).CaseNumber, 'true','','GCM_Fuels_Dealer' );
         	Task tsk2 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', null, 'Email', caseList.get(0).CaseNumber,'OutboundNew', 'roselin.hephzibah@bp.com', 'false','' );        
             system.debug('caselist*******'+caseList);
            Task tsk3 = GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(tas3, acc.Id, con.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', caseList.get(0).CaseNumber, 'false','','' );
         }
         Test.stopTest();
         
         //Assert Statements
         List<Task> tasList = [Select Id from Task];
         System.assert(tasList.size() > 0, 'Task creation not successfull. Multicontact task creation - Inbound email');
     }
    
/****************************************************************************************************
  Testmethod to cover GCM_CTIController - Non Voice Part 2.
 ****************************************************************************************************/
     static testMethod void ctiControllerNonVoiceTest2() {
              
         //Insert Account
         Account defAcc = new Account();
         defAcc.name = 'MX Fuels Dealer Default';
         defAcc.Account_ERP_ID__c ='MX020104DEFAULT';
         defAcc.Sales_Organisation__c = 'MX02';
         defAcc.Type = 'Business';
         insert defAcc;
         
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.CSD_DistChannelDivCode__c = '0104';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact defCon = new contact();
         defCon.phone = '+521234567892';
         defCon.FirstName = 'Mx Fuels Dealer';
         defCon.lastName = 'Default';
         defCon.Email = 'abc@it.it';
         defCon.accountId = defAcc.Id;
         insert defCon;
         
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Create Task Instances
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.CallType = 'Inbound';
         tas1.softphone_it__IWS_Interaction_ID__c = '12345';
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }

         Task tas2 = new Task();
         tas2.Subject='test';
         tas2.CallType = 'Inbound';
         tas2.softphone_it__IWS_Interaction_ID__c = '12346';
         if(!recordTypeList.isEmpty()){
                tas2.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas3 = new Task();
         tas3.Subject='test';
         tas3.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas3.RecordTypeId = recordTypeList.get(0).Id;
            }
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.AccountId = defAcc.Id;
         c.ContactId = con.Id;
         c.GCM_Parent_Interaction_Id__c = '1234567893';
         insert c;
         
          Case c3 = new Case();
         c3.Subject = 'Test';
         c3.AccountId = defAcc.Id;
         c3.ContactId = con.Id;
         c3.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c3;
         c3.Status = 'In Progress';
         c3.GCM_ByPassValidation_Timestamp__c = DateTime.now();
         update c3;
         
         //Create Case Instance
         Case c1 = new Case();
         c1.Type = 'Test';
         c1.Area__c = 'Test';
         c1.Sub_Area__c = 'Test';
         c1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         Case c2 = new Case();
         c2.Type = 'Test';
         c2.Area__c = 'Test';
         c2.Sub_Area__c = 'Test';
         c2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         //Insert Task
         Task tas11 = new Task();
         tas11.Subject='test';
         tas11.Status ='In Progress';
         tas11.CallType = 'Inbound';
         tas11.WhatId = c3.Id;
         tas11.Type = 'Email-Inbound';
         tas11.WhoId = con.Id;
         tas11.GCM_Account__c = acc.Id;
         tas11.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas11.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas11;
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(c);
         GCM_CTIController cecp = new GCM_CTIController(controller);
         GCM_CTIController.interactionId = '1234567892';
         PageReference myVfPage = Page.GCM_AssociateCasewithInteraction;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', c.Id);
         
         Test.startTest();
         List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c from Case Where Id =: c.Id];
         system.debug('caseList*****'+caseList);
         //Call controller methods
         cecp.associateExistingCaseDetailstoTask();
         GCM_CTIController.checkInteractionCase();
         GCM_CTIController.getRecordTypeId('GCM_Fuels_Dealer', 'Case');
         Task tsk1 = GCM_CTIController.createTaskforInboundEmail(tas1, acc.Id, con.Id, 'ContactMultiAccount', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c1, 'Email', null, 'false','','GCM_Fuels_Dealer' );
         Task tsk2 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id, 'ContactMultiAccount', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', null,'OutboundNew', 'roselin.hephzibah@bp.com', 'true','' );
         if(!caseList.isEmpty()){
            Task tsk3 = GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(tas3, acc.Id, con.Id, 'ContactMultiAccount', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', caseList.get(0).CaseNumber, 'true','','' );
         }
         Task tsk4 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id+'|'+defCon.Id, 'ContactMultiAccount', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', null,'OutboundNew', 'roselin.hephzibah@bp.com', 'true','' );
         
         Test.stopTest();
         
         //Assert Statements
         System.assert(tsk1.Id != null, 'Task creation not successfull. ContactMultiAccount task creation - Inbound Email');
     }

/****************************************************************************************************
  Testmethod to cover GCM_CTIController - Non Voice Part 3.
 ****************************************************************************************************/
     static testMethod void ctiControllerNonVoiceTest3() {
              
         //Insert Account
         Account defAcc = new Account();
         defAcc.name = 'MX Fuels Dealer Default';
         defAcc.Account_ERP_ID__c ='MX020104DEFAULT';
         defAcc.Sales_Organisation__c = 'MX02';
         defAcc.Type = 'Business';
         insert defAcc;
         
         Account acc = new Account();
         acc.name = 'Test Acc';
         acc.Sales_Organisation__c = 'MX02';
         acc.CSD_DistChannelDivCode__c = '0104';
         acc.Type = 'Business';
         insert acc;
         
         //Insert Contact
         contact defCon = new contact();
         defCon.phone = '+521234567892';
         defCon.FirstName = 'Mx Fuels Dealer';
         defCon.lastName = 'Default';
         defCon.Email = 'abc@it.it';
         defCon.accountId = defAcc.Id;
         insert defCon;
         
         contact con = new contact();
         con.phone = '+517777777777';
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.Email = 'abcd@it.it';
         con.accountId = acc.Id;
         insert con;
         
         //Create Task Instances
         Task tas1 = new Task();
         tas1.Subject='test';
         tas1.CallType = 'Inbound';
         tas1.softphone_it__IWS_Interaction_ID__c = '12345';
         if(!recordTypeList.isEmpty()){
                tas1.RecordTypeId = recordTypeList.get(0).Id;
            }

         Task tas2 = new Task();
         tas2.Subject='test';
         tas2.CallType = 'Inbound';
         tas2.softphone_it__IWS_Interaction_ID__c = '12346';
         if(!recordTypeList.isEmpty()){
                tas2.RecordTypeId = recordTypeList.get(0).Id;
            }
         
         Task tas3 = new Task();
         tas3.Subject='test';
         tas3.CallType = 'Inbound';
         if(!recordTypeList.isEmpty()){
                tas3.RecordTypeId = recordTypeList.get(0).Id;
            }
         //Insert Case
         Case c = new Case();
         c.Subject = 'Test';
         c.AccountId = defAcc.Id;
         c.ContactId = con.Id;
         c.GCM_Parent_Interaction_Id__c = '1234567893';
         c.Status = 'Closed';
         insert c;
         
         Case c3 = new Case();
         c3.Subject = 'Test';
         c3.AccountId = defAcc.Id;
         c3.ContactId = con.Id;
         c3.GCM_Parent_Interaction_Id__c = '1234567892';
         insert c3;
         c3.Status = 'In Progress';
         c3.GCM_ByPassValidation_Timestamp__c = DateTime.now();
         update c3;
         
         //Create Case Instance
         Case c1 = new Case();
         c1.Type = 'Test';
         c1.Area__c = 'Test';
         c1.Sub_Area__c = 'Test';
         c1.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         Case c2 = new Case();
         c2.Type = 'Test';
         c2.Area__c = 'Test';
         c2.Sub_Area__c = 'Test';
         c2.GCM_ByPassValidation_Timestamp__c = Datetime.now();
         
         //Insert Task
         Task tas11 = new Task();
         tas11.Subject='test';
         tas11.Status ='In Progress';
         tas11.CallType = 'Inbound';
         tas11.WhatId = c.Id;
         tas11.Type = 'Email-Inbound';
         tas11.WhoId = con.Id;
         tas11.GCM_Account__c = acc.Id;
         tas11.softphone_it__IWS_Interaction_ID__c = '1234567892';
         if(!recordTypeList.isEmpty()){
                tas11.RecordTypeId = recordTypeList.get(0).Id;
            }
         insert tas11;
         
         //Initialization
         ApexPages.StandardController controller = new ApexPages.StandardController(c);
         GCM_CTIController cecp = new GCM_CTIController(controller);
         GCM_CTIController.interactionId = '1234567892';
         PageReference myVfPage = Page.GCM_AssociateCasewithInteraction;
         Test.setCurrentPage(myVfPage);
         // Put Id into the current page Parameters
         ApexPages.currentPage().getParameters().put('id', c.Id);
         
         Test.startTest();
         List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c from Case Where Id =: c.Id];
         system.debug('caseList*****'+caseList);
         //Call controller methods
         cecp.associateExistingCaseDetailstoTask();
         GCM_CTIController.checkInteractionCase();
         GCM_CTIController.getRecordTypeId('GCM_Fuels_Dealer', 'Case');
         Task tsk1 = GCM_CTIController.createTaskforInboundEmail(tas1, acc.Id, con.Id+'|'+defCon.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c1, 'Email', null, 'false','','' );
         Task tsk2 = GCM_CTIController.createTaskforOutboundEmail(tas2, acc.Id, con.Id+'|'+defCon.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', null,'OutboundNew', 'roselin.hephzibah@bp.com', 'true','' );
         if(!caseList.isEmpty()){
            Task tsk3 = GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(tas3, acc.Id, con.Id+'|'+defCon.Id, 'MultiContact', defAcc.Id, defCon.Id, '2020-03-16T19:34:23+08:00','Subject','Test email','Y', c2, 'Email', caseList.get(0).CaseNumber, 'true','','' );
         }
         Test.stopTest();
         
         //Assert Statements
         System.assert(tsk1.Id != null, 'Task creation not successfull. ContactMultiAccount task creation - Inbound Email');
     }
}