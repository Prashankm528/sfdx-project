/****************************************************************************************************
 *  Date          : 14-SEP-2019 
 *  Author        : Sunny Yap
 *  Description   : Non-voice routing rules engine.
 *  Modifications : 14-SEP-2019 SYAP - Initial.
 *                  21-NOV-2019 SYAP - Added assignment by sender e-mail capability.
 ****************************************************************************************************/

public with sharing class GCM_Routing_Engine {

/****************************************************************************************************
 Find Account ID By REGEX
 ****************************************************************************************************/ 
    public static String getSubstring(String textPatternIn, Integer textLengthIn, String searchTextIn) {
        // Helper Method - Returns Text After Regex Pattern Against Input Text
        String returnedText = '';
        
        String expression = '.{0}\\b'+textPatternIn +'\\b.{0}';
        Pattern textPattern = Pattern.compile(expression);
        
        
        Matcher textMatcher = textPattern.matcher(searchTextIn);
        
        
        if (textMatcher.find()) {
            system.debug('textMatcher');
            Integer startPosition = textMatcher.start();
            Integer endPosition = startPosition + textLengthIn;
            
            
            returnedText = searchTextIn.substring(startPosition, endPosition).trim();
            
        }
        else {
            returnedText = '';
        }
        return returnedText;
    }
    
/****************************************************************************************************
 Routing Strategy Core Logic Here
 Only Works On Cases Assigned To GCM_MB* Queues (Landing Queues)
 ****************************************************************************************************/ 
    public static void applyRoutingRules (Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> caseList) {
      // Assign Cases Based On Recipient Mailboxes
      try {
        Map<Id, String> ownerMap = new Map<Id, String>();
        // Get Distinct Case OwnerId
        for (Case thisCase : caseList) {
          if (thisCase.OwnerId != null) {
            ownerMap.put(thisCase.OwnerId, null);
          }
        }
        
        // Get Case Owner Queue Names
        List<Group> queues = [select DeveloperName from Group where Type = 'Queue' and Id in :ownerMap.keySet()];
        for (Group queue : queues) {
          ownerMap.put(queue.Id, queue.DeveloperName);
        }
        
        // 1. Get In Scope Cases
        // 2. Initialise Routing Rules Grouping By Landing Queue
        // 3. Get Contact Map
        Map<String, List<GCM_Routing_Strategy__c>> ruleMap = new Map<String, List<GCM_Routing_Strategy__c>>();
        Map<Id, Id> contactMap = new Map<Id, Id>();
        List<Case> caseSubSet = new List<Case>();
        List<String> landingQueue = new List<String>();
        for (Case thisCase : caseList) {
          if (ownerMap.containsKey(thisCase.OwnerId)) {
            String ownerQueue = ownerMap.get(thisCase.OwnerId);
            if (ownerQueue != null) {
              if (ownerQueue.startsWith('GCM_MB')) {
                caseSubSet.add(thisCase);
                landingQueue.add(ownerQueue);
                ruleMap.put(ownerQueue, null);
              } 
            }
          }
          // Contact Recognised
          if (thisCase.ContactId != null) {
            contactMap.put(thisCase.ContactId, null);
          }
        }
        
        // Exit If No Cases In Scope
        if (caseSubSet.size() == 0) return;

        // Retrieve Rules
        List<GCM_Routing_Strategy__c> rules = [
          select
            GCM_Landing_Queue__c,
            GCM_Mailbox__c,
            GCM_Sender__c,
            GCM_Account_Length__c,
            GCM_Account_Match__c,
            GCM_Keyword_Long__c,
            GCM_Case_Type__c,
            GCM_Case_Area__c,
            GCM_Case_Sub_Area__c,
            GCM_Queue__c,
            GCM_Default_Account__c,
            GCM_Portfolio_1__c,
            GCM_Portfolio_2__c,
            GCM_Portfolio_3__c,
            GCM_Portfolio_4__c,
            GCM_Contact_Id__c
          from
            GCM_Routing_Strategy__c
          where
            GCM_Landing_Queue__c in :landingQueue and 
            GCM_Active__c = true
          order by
            GCM_Landing_Queue__c asc,
            GCM_Order__c desc
        ];
        
        // Group Rules By Landing Queue (Mailbox)
        // Initialise Assignment Queue Map
        // Initialise Default Account Map
        Map<String, Id> queueMap = new Map<String, Id>();
        Map<String, Id> defaultAccountMap = new Map<String, Id>();
        Map<String, Id> defaultContactMap = new Map<String, Id>();
        for (GCM_Routing_Strategy__c rule : rules) {
          List<GCM_Routing_Strategy__c> ruleList;
          if (ruleMap.containsKey(rule.GCM_Landing_Queue__c)) {
            ruleList = ruleMap.get(rule.GCM_Landing_Queue__c);
            if (ruleList == null) {
              ruleList = new List<GCM_Routing_Strategy__c>();
              ruleMap.put(rule.GCM_Landing_Queue__c, ruleList);
            }
            ruleList.add(rule);           
          }
          
          // Save Distinct Assignment Queue Name
          if (rule.GCM_Queue__c != null) {
            queueMap.put(rule.GCM_Queue__c, null);
          }
          
          // Save Distinct Default Account ERP ID
          if (rule.GCM_Default_Account__c != null) {
            defaultAccountMap.put(rule.GCM_Default_Account__c, null);
            defaultContactMap.put(rule.GCM_Default_Account__c, rule.GCM_Contact_Id__c);
          }
        }
        
        // Get Assignment Queue Name > Id Map
        List<Group> assignees = [
          select
            Id,
            DeveloperName
          from
            Group
          where
            DeveloperName in :queueMap.keySet() and 
            Type = 'Queue'
        ];
        for (Group assignee : assignees) {
          queueMap.put(assignee.DeveloperName, assignee.Id);
        }
        
        // Get Default Account ERP ID > Id Map
        List<Account> defaultAccounts = [
          select
            Id,
            Account_ERP_ID__c
          from
            Account
          where
            Account_ERP_ID__c in :defaultAccountMap.keySet()
        ];
        for (Account defaultAccount : defaultAccounts) {
          defaultAccountMap.put(defaultAccount.Account_ERP_ID__c, defaultAccount.Id);
        }          
        
        // Traverse Cases
        Map <Id, String> caseAccountMap = new Map<Id, String>(); // Case Id > Account Number
        Map <Id, String> caseAccountDefaultMap = new Map<Id, String>(); // Case Id > Account Number (Default)
        Map <String, Id> accountMap = new Map<String, Id>(); // Account Number > Account Id
        for (Case thisCase : caseSubSet) {
          if (ownerMap.containsKey(thisCase.OwnerId)) {
            String ownerQueue = ownerMap.get(thisCase.OwnerId);
            if (ruleMap.containsKey(ownerQueue)) {
              List<GCM_Routing_Strategy__c> ruleList = ruleMap.get(ownerQueue);
                               
              if (ruleList != null) {
                for (GCM_Routing_Strategy__c rule : ruleList) {
                  // Save Mailbox In Case
                  thisCase.GCM_Mailbox_Reference__c = rule.GCM_Mailbox__c;
                  
                  // Save Landing Queue - Always The Same Across Environments
                  thisCase.GCM_Landing_Queue__c = rule.GCM_Landing_Queue__c;
                  
                  // Concatenate Case Body + Subject
                  String bodySubject = thisCase.Subject + ' ' + thisCase.Description;
                  
                  // Match Account By Pattern
                  if (rule.GCM_Account_Match__c != null && rule.GCM_Account_Length__c != null) {
                    String accountNumber = '';
                    accountNumber = GCM_Case_Trigger_Helper.getSubstring(rule.GCM_Account_Match__c, (Integer) rule.GCM_Account_Length__c, bodySubject);
                       
                    if (!String.isBlank(accountNumber)) {
                      accountNumber = accountNumber.trim();
                      caseAccountMap.put(thisCase.Id, accountNumber);
                      accountMap.put(accountNumber, null);
                    }
                  }

                  // Always Possibility
                  // "accountNumber" Not Matching Any Record
                  // Save Default Account Map For All Cases
                  if (defaultAccountMap.containsKey(rule.GCM_Default_Account__c)) {
                    caseAccountDefaultMap.put(thisCase.Id, rule.GCM_Default_Account__c);
                    accountMap.put(rule.GCM_Default_Account__c, null);   
                  } 
                }
              }
            }
          }
        }

        // Get Contact Id > Account Id Map
        List<Contact> contacts = [select Id, AccountId from Contact where Id in :contactMap.keySet()];
        for (Contact thisContact : contacts) {
          contactMap.put(thisContact.Id, thisContact.AccountId);
        }
        
        // Get Accounts
        // Get Account ERP ID > Account Id Map
        // Get Account Id > Account Map (Portfolio)
        Map <Id, Account> portfolioMap = new Map<Id, Account>();
        List<Account> accounts = [
          select
            Id,
            Account_ERP_ID__c,
            Business_Unit__c,
            Sales_Organisation__c,
            GCM_Portfolio_1__c,
            GCM_Portfolio_2__c,
            GCM_Portfolio_3__c,
            GCM_Portfolio_4__c            
          from
            Account
          where
            Account_ERP_ID__c in :accountMap.keySet() or
            Id in :contactMap.values()
        ];
        for (Account thisAccount : accounts) {
          accountMap.put(thisAccount.Account_ERP_ID__c, thisAccount.Id);
          portfolioMap.put(thisAccount.Id, thisAccount);
        }
        
        // Update Case Account
        for (Case thisCase : caseSubSet) {
          if (caseAccountMap.containsKey(thisCase.Id)) {
            String accountNumber = caseAccountMap.get(thisCase.Id);
            if (accountMap.containsKey(accountNumber)) {
              if (thisCase.AccountId == null) {
                thisCase.AccountId = accountMap.get(accountNumber);
              }
            }                
          }
            
          // If Account ID Still Not Set - Assign Default Account
          if (thisCase.AccountId == null && thisCase.ContactId == null) {
            if (caseAccountDefaultMap.containsKey(thisCase.Id)) {
              String accountNumber = caseAccountDefaultMap.get(thisCase.Id);
              if (accountMap.containsKey(accountNumber)) {
                Id accountId = accountMap.get(accountNumber);
                  if (defaultContactMap.containsKey(accountNumber)) {
          thisCase.ContactId = defaultContactMap.get(accountNumber);
                  }
                if (thisCase.AccountId == null) thisCase.AccountId = accountId;
              }
            }
          }
          
          // Assign Account If Contact Recognised
          if (thisCase.ContactId != null) {
            if (contactMap.containsKey(thisCase.ContactId)) {
              thisCase.AccountId = contactMap.get(thisCase.ContactId);
            }
          }
        }
                
        // Assign Cases
        for (Case thisCase : caseSubSet) {
          Account thisAccount = null;
          if (thisCase.AccountId != null) {
            if (portfolioMap.containsKey(thisCase.AccountId)) {
              thisAccount = portfolioMap.get(thisCase.AccountId);
            }
          }
          
          if (thisAccount != null && ownerMap.containsKey(thisCase.OwnerId)) {
            String ownerQueue = ownerMap.get(thisCase.OwnerId);
            if (ownerQueue != null && ruleMap.containsKey(ownerQueue)) {
              List<GCM_Routing_Strategy__c> ruleList = ruleMap.get(ownerQueue);
              if (ruleList != null) {
                for (GCM_Routing_Strategy__c rule : ruleList) {
                  // Concatenate Case Body + Subject
                  String bodySubject = thisCase.Subject + ' ' + thisCase.Description;

                  // Find Keyword
                  Boolean matchPortfolio = false;
                  
                  if (rule.GCM_Keyword_Long__c != null) {
                    String keyMatch = GCM_Routing_Engine.getSubstring(rule.GCM_Keyword_Long__c.toLowerCase(), 1, bodySubject.toLowerCase());
                    if (keyMatch != '') {
                      matchPortfolio = true;
                    }
                  }

                  // Match Sender E-Mail
                  if (rule.GCM_Sender__c != null) {
                    String keyMatch = GCM_Routing_Engine.getSubstring(rule.GCM_Sender__c.toLowerCase(), 1, thisCase.SuppliedEmail.toLowerCase());
                    if (keyMatch == '') {
                      matchPortfolio = false;
                    }
                  }
                    
                  if (!String.isBlank(rule.GCM_Portfolio_1__c)) {
                    if (String.isBlank(thisAccount.GCM_Portfolio_1__c) || thisAccount.GCM_Portfolio_1__c != rule.GCM_Portfolio_1__c) matchPortfolio = false;
                  }
                  if (!String.isBlank(rule.GCM_Portfolio_2__c)) {
                    if (String.isBlank(thisAccount.GCM_Portfolio_2__c) || thisAccount.GCM_Portfolio_2__c != rule.GCM_Portfolio_2__c) matchPortfolio = false;
                  }
                  if (!String.isBlank(rule.GCM_Portfolio_3__c)) {
                    if (String.isBlank(thisAccount.GCM_Portfolio_3__c) || thisAccount.GCM_Portfolio_3__c != rule.GCM_Portfolio_3__c) matchPortfolio = false;
                  }
                  if (!String.isBlank(rule.GCM_Portfolio_4__c)) {
                    if (String.isBlank(thisAccount.GCM_Portfolio_4__c) || thisAccount.GCM_Portfolio_4__c != rule.GCM_Portfolio_4__c) matchPortfolio = false;
                  }

                  if (matchPortfolio && !String.isBlank(rule.GCM_Queue__c) && queueMap.containsKey(rule.GCM_Queue__c)) {
                    if (queueMap.get(rule.GCM_Queue__c) != null) thisCase.OwnerId = queueMap.get(rule.GCM_Queue__c);
                    if (!String.isBlank(rule.GCM_Case_Type__c)) thisCase.Type = rule.GCM_Case_Type__c;
                    if (!String.isBlank(rule.GCM_Case_Area__c)) thisCase.Area__c = rule.GCM_Case_Area__c;
                    if (!String.isBlank(rule.GCM_Case_Sub_Area__c)) thisCase.Sub_Area__c = rule.GCM_Case_Sub_Area__c;
                    thisCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
                  }
                }
              }
            }
          }
        }            
      }  
      catch (Exception exceptionObject) {
        BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Routing_Engine', 'applyRoutingRules', new List<Id>(), 'GCM_Application_Administrator');               
      } 
    }
}