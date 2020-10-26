/****************************************************************************************************
*  Date          : 16-MAR-2020
*  Author        : Roselin Hephzibah
*  Description   : GCM_GSYS_DuplicateEmailHandlerTest.
*  Modifications : 16-MAR-2020 Roselin - Initial Version.
****************************************************************************************************/
@isTest(isParallel=true)
public class GCM_GSYS_DuplicateEmailHandlerTest {
    
/****************************************************************************************************
  Testmethod to cover deleteDuplicateEmail method.
 ****************************************************************************************************/
     static testMethod void deleteDuplicateEmailTest() {

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
         
         //Insert BPG Error Log record
         BPG_Error_Log__c bpgel = new BPG_Error_Log__c();
         bpgel.BPG_Method__c = 'DeleteEmailDuplicatesGenesys';
         bpgel.BPG_Object_Name__c = 'GCM_CTIController';
         bpgel.BPG_User__c = UserInfo.getUserId();
         bpgel.BPG_Record_ID__c = emailMsg.Id;
         bpgel.BPG_Error_Message__c = '';
         insert bpgel;
         
         //Initialization
         GCM_CTIController cticon = new GCM_CTIController();
         GCM_GSYS_DuplicateEmailHandler deh = new GCM_GSYS_DuplicateEmailHandler(cticon);
         
         Test.startTest();
         //Call controller methods
		 GCM_GSYS_DuplicateEmailHandler.deleteDuplicateEmails();
         Test.stopTest();
         
         //Assert Statements
         System.assert(bpgel.BPG_Error_Message__c != null, 'Duplicate email message not deleted successfully');
     }
    
/****************************************************************************************************
  Testmethod to cover cloneAttachment method.
 ****************************************************************************************************/
     static testMethod void cloneAttachmentTest() {

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
         
         EmailMessage emailMsg1 = new EmailMessage();
         emailMsg1.Subject = 'subject';
         emailMsg1.Headers = '"Header_Date":"Wed, 8 Jan 2020 09:27:25 +0000"';
         emailMsg1.TextBody = 'messageText';
         emailMsg1.FromAddress = 'roselin.hephzibah@bp.com';
         emailMsg1.ToAddress = 'rhephzi1@in.ibm.com';
         emailMsg1.status = '1';
         emailMsg1.Incoming = true;
         String str1 = '2019-12-06T11:04:10+00:00';
         emailMsg1.messagedate = (DateTime)Json.deserialize('"'+str+'"', DateTime.class);
         emailMsg1.GCM_Has_Attachment__c = true;
         insert emailMsg1;
         
         //Insert BPG Error Log record
         BPG_Error_Log__c bpgel = new BPG_Error_Log__c();
         bpgel.BPG_Method__c = 'DeleteEmailDuplicatesGenesys';
         bpgel.BPG_Object_Name__c = 'GCM_CTIController';
         bpgel.BPG_User__c = UserInfo.getUserId();
         bpgel.BPG_Record_ID__c = emailMsg.Id;
         insert bpgel;
         
         //Insert Attachment
         Blob b = Blob.valueOf('Test Data');
    	 Attachment attachment = new Attachment();
    	 attachment.ParentId = emailMsg.Id;
    	 attachment.Name = 'Test Attachment for Parent';
    	 attachment.Body = b;
    	 insert attachment;
         
         //Flow Inputs
         List<GCM_GSYS_DuplicateEmailHandler.FlowInputs> fiList = new List<GCM_GSYS_DuplicateEmailHandler.FlowInputs>();
         GCM_GSYS_DuplicateEmailHandler.FlowInputs fi = new GCM_GSYS_DuplicateEmailHandler.FlowInputs();
         fi.originalEmailMsg = emailMsg;
         fi.newEmailMsgId = emailMsg1.Id;
         fiList.add(fi);
         
         Test.startTest();
         //Call controller methods
		 GCM_GSYS_DuplicateEmailHandler.cloneAttachment(fiList);
         Test.stopTest();
         
         //Assert Statements
         List<attachment> attachList = [Select Id from Attachment Where ParentId =: emailMsg1.Id];
		 System.assert(attachList.size() > 0, 'Attachment not Cloned Successfully');
     }
}