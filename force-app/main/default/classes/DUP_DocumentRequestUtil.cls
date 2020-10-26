/*****************************************************************************************
*       Date:        11OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: utility class for operations on Document Request
*****************************************************************************************/

public with sharing class DUP_DocumentRequestUtil {
    private final static String STANDARD_EMAIL_FOR_SUPPORT_BP = 'BP Accounts Team';

    /**
	* @description:	it creates DUP_Document_Store__c records using DUP_List_Of_Values__c as guidance
	* @param: oldMap from DUP_Document_Request__c Trigger, newList from DUP_Document_Request__c Trigger
	* @return: void
	*/
    public static void createDocumentStores(List<DUP_Document_Request__c> docRequestList){        
        
        List<DUP_Document_Store__c> docStoreRecords = new List<DUP_Document_Store__c>();

        Map<String,String> picklistVal = new Map<String,String>();
        picklistVal.put('High','DUP_High_Risk');
        picklistVal.put('Low','DUP_Low_Risk');
        picklistVal.put('Medium','DUP_Medium_Risk');

        List<DUP_List_Of_Values__c> lovRecordsLst = [SELECT Name,
                            RecordtypeId,
                            RecordType.DeveloperName,
                            DUP_Type__c,
                            DUP_Quantity__c,
                            DUP_Options__c, 
                            DUP_Document_Template__c,
                            DUP_Description__c,
                            DUP_Group_Title__c                         
                        FROM DUP_List_Of_Values__c
                        ORDER BY Name ASC
                        LIMIT 200];
        for(DUP_Document_Request__c docReq : docRequestList ){
            for(DUP_List_Of_Values__c listOfValue : lovRecordsLst){
                if(picklistVal.get(docReq.DUP_Risk_Status__c) == listOfValue.RecordType.DeveloperName){
                    for(Integer i = 0; i < listOfValue.DUP_Quantity__c; i++){
                        DUP_Document_Store__c docStore = new DUP_Document_Store__c();
                        docStore.DUP_Document_Request__c = docReq.Id;
                        docStore.DUP_Document_Name__c = listOfValue.DUP_Type__c;
                        docStore.DUP_Options__c = listOfValue.DUP_Options__c;
                        docStore.DUP_Document_Template__c = listOfValue.DUP_Document_Template__c;
                        docStore.DUP_Requested__c = (listOfValue.DUP_Options__c == 'Mandatory');
                        docStore.DUP_Description__c = listOfValue.DUP_Description__c;
                        docStore.DUP_Group_Title__c = listOfValue.DUP_Group_Title__c;
                        docStoreRecords.add(docStore);    
                    }                     
                }                
            }
        }        
        
        if(!docStoreRecords.isEmpty()){
            try {
                insert docStoreRecords;
            } catch (DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }

    /**
	* @description:	sends an email to the counterparty/user relative to the requested document stores
	* @param:List of DUP_Document_Request__c, Id of an optional template
	* @return: void
	*/
    public static void sendEmailToCounterParty(List<DUP_Document_Request__c> docRequestList, Id emailtemplateId, List<DUP_Document_Store__c> docStoreRecords, boolean toSend){
        // Set of the email in the document requests (User + Counterparty)
        Set<String> allEmails = new Set<String>();
        //Map document request Id with a set of Emails relative to the document request
        Map<Id, Set<String>> documentRequestIdRelatedEmailMap = new Map<Id, Set<String>>();
        
        for(DUP_Document_Request__c newDocRequest : docRequestList){
            //Set of the email (User + Counterparty) in a single document request
            Set<String> emailOfASingleDocumentRequest = new Set<String>();
            	
            for(DUP_Document_Store__c newDocStore : docStoreRecords){
                allEmails.add(newDocStore.DUP_Counterparty_Contact_Name__r.DUP_Email__c);
                if(newDocStore.DUP_Document_Request__c == newDocRequest.id) {
                    emailOfASingleDocumentRequest.add(newDocStore.DUP_Counterparty_Contact_Name__r.DUP_Email__c);
                }            
            }

            documentRequestIdRelatedEmailMap.put(newDocRequest.id,emailOfASingleDocumentRequest);
        }   
        
        List<User> allUsersConnectedToDocStore = [SELECT Email FROM User 
            WHERE Email IN :allEmails
                AND isActive = true];
        //Map to relate an email to a user
        Map<String, Id> emailUserMap = new Map<String, Id>();
        for(User u : allUsersConnectedToDocStore){
            emailUserMap.put(u.email, u.id);
        }
        
        //Set of Email not related to a user (Counterparty Email - New Reg)
        Set<String> emailListWithoutUser = allEmails.clone();
        for (String email : allEmails) {
            if(emailUserMap.get(email) != null) {
                emailListWithoutUser.remove(email);
            }
        }

        Savepoint sp = Database.setSavepoint();
        //Map to manage the fake contacts in related to email.
        //No new method because we are using Database.setSavepoint() / rollback
        Map<String,Id> contactEmailIdMap = new Map<String, Id>();
         
        if(!emailListWithoutUser.isEmpty()){
            Account a = [SELECT Id FROM Account WHERE Name = 'ContactAccount' AND RecordType.Name = 'DUP Misc' LIMIT 1];
            List<Contact> createdcontacts = new List<Contact>();

            Integer i = 0;
            for(String email : emailListWithoutUser) {
                Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
                Contact newContact = new Contact (
                FirstName = 'FirstName' +i,
                LastName = 'CounterpartyWithoutEmail'+i,
                AccountId = a.Id,
                Email = email,
                RecordTypeId = contactRecordTypeId
                );
                createdcontacts.add(newContact);
                i++;
            }
        
            try {
                upsert createdContacts;
            } catch (Exception e){
                System.debug('THESE Contact HAVE BEEN CREATED BEFORE: ' + e);
            }    
            
           for (Contact lm : createdContacts) {
                contactEmailIdMap.put(lm.Email, lm.Id);
            }
        }
        //END create fakecontacts

        List<Messaging.SingleEmailMessage> messagesToBeSentList = new List<Messaging.SingleEmailMessage>();

        //Template block
        Id templateRequestId = emailtemplateId;
        Id templateWithRegistrationId;
        List<EmailTemplate> emailTemplates = [
            SELECT DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName = 'DUP_Request_VF_Template' 
                OR DeveloperName = 'DUP_Registration_VF_Template' 
                OR DeveloperName = 'DUP_Registration_Review_VF_Template' 
                OR DeveloperName = 'DUP_Reminder_Contact_VF_Template'];
		
        //Code Added/Modified by Ankit on 27/02/2020
        //get the develoer name of the Email Template
        String emailTemplateName = '';
        if(emailtemplateId != null){
            emailTemplateName = [SELECT DeveloperName FROM EmailTemplate WHERE ID =: emailtemplateId Limit 1].DeveloperName;
        }
        //Org Wide Email Address block
        OrgWideEmailAddress owe = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName =: STANDARD_EMAIL_FOR_SUPPORT_BP LIMIT 1];        

        for(EmailTemplate et : emailTemplates){
            if(emailTemplateName == 'DUP_Request_VF_Template'){
                if(et.DeveloperName == 'DUP_Registration_VF_Template'){
                    templateWithRegistrationId = et.id;
                }
            }
            else if(emailTemplateName == 'DUP_Review_VF_Template'){
                if(et.DeveloperName == 'DUP_Registration_Review_VF_Template'){
                    templateWithRegistrationId = et.id;
                }
            }
            else if(emailTemplateName == 'DUP_Reminder_VF_Template'){
                //the case where we are sending reminder email to new user who have not even registered yet
                if(et.DeveloperName == 'DUP_Reminder_Contact_VF_Template'){
                    templateWithRegistrationId = et.id;
                }
            }else{
                //Setting default value
                if(et.DeveloperName == 'DUP_Registration_VF_Template'){
                    templateWithRegistrationId = et.id;
                }
            }
        }
        //Code Ends here
        
 		//Attachment
 		 List<EmailTemplate> emailTemp = [
            SELECT DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName = 'DUP_AddInfo_VF_Template'];
       
		/*List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentID =:templateWithRegistrationId 
                                  or ParentID =:emailTemp[0].Id];
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    	for (Attachment file: files) {
      	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      	efa.setFileName(file.Name);
      	efa.setBody(file.Body);
      	efa.setContentType(file.ContentType);
      	attachments.add(efa);
    	}
		*/
        Set<Id> docReqSet = new Set<Id>();
        for(DUP_Document_Request__c docReqSetVar : docRequestList){
            docReqSet.add(docReqSetVar.Id);
        }
        List<DUP_Document_Request__c> docReqEntityList = [SELECT Id,DUP_Email_Templates__c, 
                                                          DUP_BP_Entity_Details__r.DUP_Return_Email__c,DUP_BP_Entity_Details__r.DUP_Review_Email__c 
                                                          FROM DUP_Document_Request__c 
                                                          WHERE Id IN :docReqSet];
        Map<Id, String> docReqEntityMap = New  Map<Id, String>();
        for(DUP_Document_Request__c docEntReq : docReqEntityList){
			if(('Review Template').equalsIgnoreCase(docEntReq.DUP_Email_Templates__c) || 
				  ('Additional Info Review Request Template').equalsIgnoreCase(docEntReq.DUP_Email_Templates__c)){
                   docReqEntityMap.put(docEntReq.Id, docEntReq.DUP_BP_Entity_Details__r.DUP_Review_Email__c); 
			}else{
				docReqEntityMap.put(docEntReq.Id, docEntReq.DUP_BP_Entity_Details__r.DUP_Return_Email__c);
			}
        }

        List<DUP_Document_Request__c> requestorEmail = [SELECT DUP_Requestor_Emails__c 
                                                        FROM DUP_Document_Request__c 
                                                        WHERE Id IN :docReqSet];
        Map<Id, List<String>> requestorEmailMap = New  Map<Id, List<String>>();
        Boolean isEmailNull = false;
        for(DUP_Document_Request__c reqEmail : requestorEmail){
            if(reqEmail.DUP_Requestor_Emails__c != null && reqEmail.DUP_Requestor_Emails__c != ''){
                List<String> requestorEmails = reqEmail.DUP_Requestor_Emails__c.split(',');
                requestorEmailMap.put(reqEmail.Id, requestorEmails);
            } else {
                isEmailNull = true;
            }
        }
        
        for(DUP_Document_Request__c docReqIteration : docRequestList){
            Set<String> emailsRelatedToTheDocumentRequest = new Set<String>();
            if(documentRequestIdRelatedEmailMap.containsKey(docReqIteration.Id)){
                emailsRelatedToTheDocumentRequest = documentRequestIdRelatedEmailMap.get(docReqIteration.Id);
            }            
            for(String email : emailsRelatedToTheDocumentRequest){
                List<String> toAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                Id userId = emailUserMap.get(email);
                if(userId != null){
                    toAddresses.add(email);
                    ccAddresses.add(docReqEntityMap.get(docReqIteration.Id));
                    if(!isEmailNull){
                        ccAddresses.addAll(requestorEmailMap.get(docReqIteration.Id));
                    }
                    
                    //Id targetObjId, EmailTemplate emailTemplate, Id objectToPopulateId, String senderDisplayName, List<String> ccAddresses
                    messagesToBeSentList.add(DUP_MessagingServices.createEmailMessage(userId, templateRequestId, docReqIteration.Id, owe.Id, toAddresses, ccAddresses));    
                } else {
                    Id contactId = contactEmailIdMap.get(email);
                    toAddresses.add(email);
                    ccAddresses.add(docReqEntityMap.get(docReqIteration.Id));
                    if(!isEmailNull){
                        ccAddresses.addAll(requestorEmailMap.get(docReqIteration.Id));
                    }
                    messagesToBeSentList.add(DUP_MessagingServices.createEmailMessage(contactId, templateWithRegistrationId, docReqIteration.Id, owe.Id, toAddresses, ccAddresses));
                }
            }
        }
        if(!messagesToBeSentList.isEmpty()){
            //Generating Emails - No new method because we are using Database.rollback(sp)
            //if(toSend)
            DUP_MessagingServices.sendEmails(messagesToBeSentList);
            Database.rollback(sp);
            
            //Creating the actual list of emails to be sent
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : messagesToBeSentList) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setCCAddresses(email.getCcAddresses());
                emailToSend.setOrgWideEmailAddressId(owe.Id);
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                DUP_PathUpdateController.emailBody = email.getHTMLBody();
                emailToSend.setSubject(email.getSubject());
                emailToSend.setReplyTo('donotreply@bp.com');
                //emailToSend.setSenderDisplayName(owe.DisplayName);
                emailToSend.setSaveAsActivity(true);
                emailToSend.setWhatId(email.getWhatId());
               /* if(attachments != Null){
                  emailToSend.setFileAttachments(attachments);
                  }
				*/  
                lstMsgsToSend.add(emailToSend);
            }
            if(toSend)
            DUP_MessagingServices.sendEmails(lstMsgsToSend);  
        }
        Integer invocations = Limits.getEmailInvocations();
    }

    /**
	* @description:	sends an email to the counterparty/user relative to the requested document stores
	* @param:List of DUP_Document_Request__c, Id of an optional template
	* @return: void
	*/
    public static void sendReminderEmailToCounterParty(Set<Id> docRequestIdSet, Id firstremindertemplateId, List<DUP_Document_Store__c> docStoreRecords){ 
        //Id secondremindertemplateId,Id thirdremindertemplateId,ID fourthremindertemplateId,
        Date firstReminderDate = System.today().addDays(-7);
        Date secondReminderDate = System.today().addDays(-14);
        Date thirdReminderDate = System.today().addDays(-21);
        Date fourthReminderDate = System.today().addDays(-28);
        if(Test.isRunningTest()){
		firstReminderDate = System.today();
        }

		List<DUP_Document_Request__c> docRequests = [SELECT Id,DUP_Email_Templates__c,DUP_Remaining_Days__c,createdDate,DUP_Requestor_Emails__c,
                                                          DUP_BP_Entity_Details__r.DUP_Return_Email__c,DUP_BP_Entity_Details__r.DUP_Review_Email__c 
                                                          FROM DUP_Document_Request__c 
                                                          WHERE Id IN :docRequestIdSet  
                    									  AND (DAY_ONLY(CreatedDate) =: firstReminderDate 
                        								 OR DAY_ONLY(CreatedDate) =: secondReminderDate
                         							     OR DAY_ONLY(CreatedDate) =: thirdReminderDate 
                                                         OR DAY_ONLY(CreatedDate) =: fourthReminderDate)];
		
          Map<Id, String> docReqEntityMap = New  Map<Id, String>();
        Map<Id, DUP_Document_Request__c> docReqMap = New  Map<Id, DUP_Document_Request__c>();
        
        for(DUP_Document_Request__c docEntReq : docRequests){
            if(('Review Template').equalsIgnoreCase(docEntReq.DUP_Email_Templates__c) || 
				  ('Additional Info Review Request Template').equalsIgnoreCase(docEntReq.DUP_Email_Templates__c)){
                   docReqEntityMap.put(docEntReq.Id, docEntReq.DUP_BP_Entity_Details__r.DUP_Review_Email__c); 
			}else{
				docReqEntityMap.put(docEntReq.Id, docEntReq.DUP_BP_Entity_Details__r.DUP_Return_Email__c);
			}
            docReqMap.put(docEntReq.Id, docEntReq);
        }
		
        // Set of the email in the document requests (User + Counterparty)
        Set<String> allEmails = new Set<String>();
        //Map document request Id with a set of Emails relative to the document request
            for(DUP_Document_Store__c newDocStore : docStoreRecords){
                allEmails.add(newDocStore.DUP_Counterparty_Contact_Name__r.DUP_Email__c);
            }

		List<Contact> allUsersConnectedToDocStore = [SELECT Id,Email, CreatedDate FROM Contact 
                WHERE Email IN :allEmails];
        
        //Map to relate an email to a contact
        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        for(Contact c : allUsersConnectedToDocStore){
            emailContactMap.put(c.email, c);
        }  
		List<Messaging.SingleEmailMessage> messagesToBeSentList = new List<Messaging.SingleEmailMessage>();

        //Org Wide Email Address block
        OrgWideEmailAddress owe = [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName =: STANDARD_EMAIL_FOR_SUPPORT_BP LIMIT 1]; 
		for(Id docReqId : docReqMap.keySet()){
			DateTime reqCreatedDate = (docReqMap.get(docReqId)).createdDate;
            String reqCCEmail = (docReqMap.get(docReqId)).DUP_Requestor_Emails__c;
			//Set of the email (User + Counterparty) in a single document request
            Set<String> emailOfASingleDocumentRequest = new Set<String>();
            
            for(DUP_Document_Store__c newDocStore : docStoreRecords){
                allEmails.add(newDocStore.DUP_Counterparty_Contact_Name__r.DUP_Email__c);
                if((String.valueOf(newDocStore.DUP_Document_Request__c)).substring(0,17) == (String.valueOf(docReqId)).substring(0,17)) {
                    emailOfASingleDocumentRequest.add(newDocStore.DUP_Counterparty_Contact_Name__r.DUP_Email__c);
                }
            }			

            for(String email : emailOfASingleDocumentRequest){
                List<String> toAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                ccAddresses.add(docReqEntityMap.get(docReqId));
                if(reqCCEmail!=null){
                    List<String> tempreqEmails = reqCCEmail.split(',');
                    ccAddresses.addAll(tempreqEmails); 
                }
                Contact contactTarget = emailContactMap.get(email);
                if(contactTarget != null){
                    Messaging.SingleEmailMessage message;
                    if(Date.valueOf(firstReminderDate) == Date.newinstance((reqCreatedDate).year(), (reqCreatedDate).month(), (reqCreatedDate).day()) || 
                      Date.valueOf(secondReminderDate) == Date.newinstance((reqCreatedDate).year(), (reqCreatedDate).month(), (reqCreatedDate).day()) || 
                      Date.valueOf(thirdReminderDate) == Date.newinstance((reqCreatedDate).year(), (reqCreatedDate).month(), (reqCreatedDate).day()) ||
                      Date.valueOf(fourthReminderDate) == Date.newinstance((reqCreatedDate).year(), (reqCreatedDate).month(), (reqCreatedDate).day())){
                        message = DUP_MessagingServices.createEmailMessage(contactTarget.Id, firstremindertemplateId, docReqId, owe.Id, toAddresses, ccAddresses);
                        message.setSaveAsActivity(true);
                        messagesToBeSentList.add(message);                     
                   }                 
                }
            }
        }
		
        if(!messagesToBeSentList.isEmpty()){
            DUP_MessagingServices.sendEmails(messagesToBeSentList);
        }
        Integer invocations = Limits.getEmailInvocations();
    }   

/**
	* @description:	sends an email to developers when an exception occurs
	* @param:error message to send
	* @return: void
	*/
    public static void sendEmailOnException(String emailMessage){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String temp = System.Label.DUP_ErrorRecipients;
		message.toAddresses = temp.split(',');
		message.subject = 'DUP Application : Exception Occured';
        message.plainTextBody = emailMessage;
		DUP_MessagingServices.sendEmail(message) ;       
    }        
}