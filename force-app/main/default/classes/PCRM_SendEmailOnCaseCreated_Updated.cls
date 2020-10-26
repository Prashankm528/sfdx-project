/*****************************************************************************************
*   Date:      10/05/2020
*   Author:    Mansi Dhoke (TCS)  
*   Description: Email will be sent when case is created or updated
*   Changes: 0.1


****************************************************************************************/

public with sharing class  PCRM_SendEmailOnCaseCreated_Updated
{
    @InvocableMethod(label='PCRM SendAcknowledgement')
    public static void SetupCase(List<CaseRequest> CaseRequests) 
    {
        for(CaseRequest request: CaseRequests)
        {
            SendEmails(request);
        }
    }
    
    //this method is used to fetch all emails address and send notification via email 
    public static void SendEmails(CaseRequest ParamRequest)
    {
        try
        {
            List<Id> ListOfReportedByAccountIds = NEW List<Id>();
            List<Id> ListOfReportedBy_ResposibleByAccountIds = NEW List<Id>();
            
            //list for sending notification to users while case creation
            List<Id> ListOfUserId = NEW List<Id>();
            
            //list for sending notification to users while case closure
            List<Id> ListOfUserIdForClosure = NEW List<Id>();
            
            //list for sending notification to queue members
            List<Id> grMemberId = NEW List<Id>();
            
            //list of email addresses
            List<String> ListOfEmailAddress = NEW List<String>();
            
            //Creating map of Case Id and Case Instance
            Map<ID, CASE> MapOfCaseId_CaseInstance = NEW Map<ID,Case>([SELECT ID, PCRM_Reported_By__c, PCRM_Responsible_Party__c,
                                                                       PCRM_Sales_Manager__c, PCRM_Investigator__c, OwnerId FROM CASE WHERE ID = :ParamRequest.CaseId]);
            
            //Creating List of ReportedBy Account Ids AND List of Reported by,Responsible by Account Ids
            for (Id CaseId : MapOfCaseId_CaseInstance.keySet())
            {
                //Creating ReportedBY Acccount Ids List only
                ListOfReportedByAccountIds.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Reported_By__c);
                
                //Combine list of ReportedBY Acccount Ids,Responsible Party Acccount Ids
                ListOfReportedBy_ResposibleByAccountIds.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Reported_By__c);
                ListOfReportedBy_ResposibleByAccountIds.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Responsible_Party__c);
                
                
                //combining list of userId for case creation
                ListOfUserId.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Sales_Manager__c);
                
                ListOfUserId.add(MapOfCaseId_CaseInstance.get(CaseId).OwnerId);
                
                //combining list of userId for case closure
                ListOfUserIdForClosure.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Sales_Manager__c);
                ListOfUserIdForClosure.add(MapOfCaseId_CaseInstance.get(CaseId).PCRM_Investigator__c);
                ListOfUserIdForClosure.add(MapOfCaseId_CaseInstance.get(CaseId).OwnerId);
                
            }
            
            //List Of Contacts whom acknowledgment should sent
            List<Contact> ListOfContacts = NEW List<Contact>();
            
            // Email template Id
            String templateId = '';
            
             
				//Condition for case updation
				if(ParamRequest.Action == 'Update')
				{
					
					templateId = [SELECT Id,Body FROM EmailTemplate where developerName = 'PCRM_Notify_Good_Spot_Updated'].Id;
					
					for (Contact varContact : [select Id,email,lastname FROM Contact 
											   WHERE AccountId IN : ListOfReportedBy_ResposibleByAccountIds AND email <> null AND PCRM_Status__c =: 'Active' 
                                               AND PCRM_Allow_Notification__c = TRUE ])
					{
						if(String.isNotBlank(varContact.Email))
							ListOfEmailAddress.add(varContact.Email);
					}
				}
				
				//Condition for case updation
				if(ParamRequest.Action == 'Close')
				{
					templateId = [SELECT Id,Body FROM EmailTemplate where developerName = 'PCRM_Notify_Good_Spot_Closed'].Id;
					
					//ListOfContacts = [select Id,email,lastname FROM Contact WHERE AccountId IN : ListOfReportedBy_ResposibleByAccountIds AND email <> null ];
					
					
					for (Contact varContact : [select Id,email,lastname FROM Contact 
											   WHERE AccountId IN : ListOfReportedBy_ResposibleByAccountIds AND email <> null AND PCRM_Status__c =: 'Active'
                                              AND PCRM_Allow_Notification__c = TRUE])
					{
						if(String.isNotBlank(varContact.Email)){
							ListOfEmailAddress.add(varContact.Email);}
					}
					
					for (User varUserClose : [select Id,email FROM User WHERE Id IN : ListOfUserIdForClosure AND email <> null ])
					{
						 if(String.isNotBlank(varUserClose.Email)){
							 ListOfEmailAddress.add(varUserClose.Email);}
					}
					
					for (User varGrMemberUser : [SELECT Id,Email FROM User WHERE Id IN (
						SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'PCRM_HSSE_Manager_group_EU')])
					{
						if(String.isNotBlank(varGrMemberUser.Email)){
							ListOfEmailAddress.add(varGrMemberUser.Email);}
					}
                
				}
				
                
            
            
            //condition for case creation
            else if(ParamRequest.Action == 'Create')
            {
                templateId = [SELECT Id,Body FROM EmailTemplate where developerName = 'PCRM_Notify_Good_Spot_Created'].Id;
                
                //ListOfContacts = [select Id,email,lastname FROM Contact WHERE AccountId IN : ListOfReportedBy_ResposibleByAccountIds AND email <> null ];
                
                for (Contact varContact : [select Id,email,lastname FROM Contact 
                                           WHERE AccountId IN : ListOfReportedBy_ResposibleByAccountIds AND email <> null AND PCRM_Status__c =: 'Active'
                                          AND PCRM_Allow_Notification__c = TRUE])
                {
                    if(String.isNotBlank(varContact.Email)){
                        ListOfEmailAddress.add(varContact.Email);}
                }
                
                for (User varUser : [select Id,email FROM User WHERE Id IN : ListOfUserId AND email <> null ])
                {
                    if(String.isNotBlank(varUser.Email)){
                         ListOfEmailAddress.add(varUser.Email);}
                }
                
                for (User varGrMemberUser : [SELECT Id,Email FROM User WHERE Id IN (
                    SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'PCRM_HSSE_Manager_group_EU')])
                {
                   if(String.isNotBlank(varGrMemberUser.Email)){
                        ListOfEmailAddress.add(varGrMemberUser.Email);}
                }
                
            }
            
            List<Id> ListOfContactId = NEW List<Id>();
            
            for (Contact varContact : ListOfContacts)
            {
                ListOfContactId.add(varContact.Id);
            }
            
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null,ParamRequest.CaseId);
            email.setToAddresses(ListOfEmailAddress);
            
            Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage> {email};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            
            system.debug('Case Result : '+results);
            
            if (results[0].success) 
            {
                System.debug(' PB TEST 1 The email was sent successfully.');
            }
            else 
            {
                System.debug(' PB TEST 1 The email failed to send: '+ results[0].errors[0].message);
            }
            
        }
        catch(Exception e)
        {
            system.debug('Excption while sending emails when Good spot is created or updated: '+e);
        }        
    }
    //Class is used to store caseid and is updated or not  
    public with sharing class CaseRequest
    {
        @InvocableVariable(label='Case Id' required=true)
        public Id CaseId;       
        @InvocableVariable(label='Action' required=true)
        public String Action;
     
    }
}