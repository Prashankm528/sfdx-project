/****************************************************************************************************
 *  Date          : 27-JUL-2019
 *  Author        : Sunny Yap
 *  Description   : Helper class for EmailMessage handler.
 * Modifications  : 
 * 27-JUL-2019    : SYAP - Added exception handling.
 * 28-JUL-2019    : SYAP - Removed filter on mailbox reference in setLastMailTimestamp.
 * 03-SEP-2019    : SYAP - Enabled notification for follow up emails for cancelled or
 *                  closed cases.
 * 03-MAR-2020    : SYAP - PCI Compliance
 ****************************************************************************************************/

public with sharing class GCM_EmailMessage_Trigger_Helper {
/****************************************************************************************************
 * Common Function For Card Number Masking
 ****************************************************************************************************/ 
/*
    public static String maskCardData(String text) {
		String regex = '((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>50\\d{2}|5[6-8]\\d{2}|6\\d{3})( |-)\\d{4}( |-)\\d{4}( |-)\\d{4}( |-)\\d{3}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>4\\d{3}|5[1-5]\\d{2}|6011|622[1-9]|64[4-9]\\d|65\\d{2}|2[2-7]\\d{2}|62\\d{2}|54\\d{2}|55\\d{2}|50\\d{2}|5[6-8]\\d{2}|6\\d{3}|35[2-8]\\d{1}|636[1-9])( |-)\\d{4}( |-)\\d{4}( |-)\\d{4}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>34\\d{2}|37\\d{2}|50\\d{2}|5[6-8]\\d{2}|6\\d{3})( |-)\\d{6}( |-)\\d{5}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>62\\d{4})( |-)\\d{13}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>50\\d{2}|5[6-8]\\d{2}|6\\d{3})( |-)\\d{4}( |-)\\d{5}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>30[0-5]\\d{1}|36\\d{2}|38\\d{2}|39\\d{2}|309\\d{1})( |-)\\d{6}( |-)\\d{4}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))|((?>^|(?<=[\\s[:alpha:](),.:;?!"\'`&>]))(?>1\\d{3})( |-)\\d{5}( |-)\\d{6}(?>$|(?=[\\s[:alpha:](),.:;?!"\'`&<])))';
		String maskedText = text;
        if (!String.isBlank(text)) {
            // CPU Limit = 16K Characters
            if (text.length() <= 32768 / 2) {
				maskedText = text.replaceAll(regex, 'xxxx-xxxx-xxxx-xxxx');
				return maskedText;
        	}
	    }
        return text;
    }
*/
/****************************************************************************************************
 * Called By Before Insert Event
 * Overrides Sender Email
 ****************************************************************************************************/ 
    public static void setSenderEmail(List<EmailMessage> messages, Map<Id, EmailMessage> newMap) {
        try {
            // Logic Only Applies To GCM Users
			List<User> users = [select Name, Profile.Name, GCM_Sender_Email__c from User where Id = :UserInfo.getUserId()];
            String senderEmail = null;
            for (User thisUser : users) {
                if (!thisUser.Profile.Name.startsWith('GCM') && !Test.isRunningTest()) {
                    return;
                }
                senderEmail = thisUser.GCM_Sender_Email__c;
                if (senderEmail == null && !Test.isRunningTest()) return;
            }
            
            // Traverse Email Message
            Map<Id, String> caseMap = new Map<Id, String>();
            for (EmailMessage message : messages) {
                if (!message.Incoming) {
                    message.ValidatedFromAddress = senderEmail;
                }
            }
        }      
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_EmailMessage_Trigger_Helper', 'filterContent', newMap.keySet(), 'GCM_Application_Administrator');
        }
    }
    
/****************************************************************************************************
 * Called By Before Insert Event
 * Masks 16-Digit Card Numbers
 ****************************************************************************************************/ 
    public static void filterContent(List<EmailMessage> messages, Map<Id, EmailMessage> newMap) {
		/*
        try {
            // Get Valid Mailboxes
            List<GCM_Data_Map__mdt> dataMapList = [select Label from GCM_Data_Map__mdt where GCM_Type__c = 'Email_PCI' and GCM_Active__c = true];
            List<String> mailboxes = new List<String>();
            for (GCM_Data_Map__mdt dataMap : dataMapList) {
				mailboxes.add(dataMap.Label.toLowercase());
            }

			// Email Regex
			String regex = '(?:[a-z0-9!#$%&\'*+=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
            Pattern myPattern = Pattern.compile(regex);    

            // Get Cases
            Map<Id, String> caseMap = new Map<Id, String>();
            for (EmailMessage message : messages) {
	            // Extract Return-Path                
				String mailbox = null;
                if (message.Headers != null) {
                    String headers = message.Headers.toLowerCase();
                	Matcher myMatcher = myPattern.matcher(headers);
                    if (myMatcher.find()) mailbox = myMatcher.group();
                }

                if (message.Incoming && mailbox != null && mailboxes.contains(mailbox)) {
					message.Subject = GCM_EmailMessage_Trigger_Helper.maskCardData(message.Subject);
                    message.HtmlBody = GCM_EmailMessage_Trigger_Helper.maskCardData(message.HtmlBody);
                    message.TextBody = GCM_EmailMessage_Trigger_Helper.maskCardData(message.TextBody);
                }
            }
        }      
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_EmailMessage_Trigger_Helper', 'filterContent', newMap.keySet(), 'GCM_Application_Administrator');
        }
		*/
    }

/****************************************************************************************************
  Update E-Mail Timestamp In Case
 ****************************************************************************************************/ 
	public static void setLastMailTimestamp(List<EmailMessage> messages, Map<Id, EmailMessage> newMap) {
		try {
			// Get Cases
			Map<Id, String> caseMap = new Map<Id, String>();
			for (EmailMessage message : messages) {
				if (message.Incoming && !String.isBlank(message.ParentId)) {
					caseMap.put(message.ParentId, null);
				}
			}
      		if (caseMap.size() > 0) {
				// Update Cases
				List<Case> cases = [select Id, Subject, Description from Case where Id in :caseMap.keySet() and RecordType.DeveloperName like 'GCM%'];
				List<Case> updatedCases = new List<Case>();
				Database.DMLOptions dmo = new Database.DMLOptions();
				for (Case thisCase : cases) {
					Case updatedCase = new Case();
					updatedCase.Id = thisCase.Id;
					updatedCase.GCM_Incoming_Message_Date__c = Datetime.now();
					updatedCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();

					// Substitute Card Number
					// updatedCase.Subject = GCM_EmailMessage_Trigger_Helper.maskCardData(thisCase.Subject);
					// updatedCase.Description = GCM_EmailMessage_Trigger_Helper.maskCardData(thisCase.Description);
 
          			updatedCase.setOptions(dmo);
          			updatedCases.add(updatedCase);
        		}
        		if (updatedCases.size() > 0) Database.update(updatedCases);
      		}
		}
    	catch (Exception exceptionObject) {
			BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_EmailMessage_Trigger_Helper', 'setLastMailTimestamp', newMap.keySet(), 'GCM_Application_Administrator');
    	}
    }
}