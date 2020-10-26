/****************************************************************************************************
 *  Date          : 19-MAR-2019 
 *  Author        : Sunny Yap
 *  Description   : Validation to prevent a case from being closed when there are open
 *                  child tasks or activities.
 *  Modifications :
 *  19-MAR-2019   : SYAP Helper class.
 *  02-APR-2019   : SYAP Fixed issue where cancelled child cases are not
 *                  considered in the validation rules.
 *  11-APR-2019   : SYAP Bulkified the code.
 *  19-JUL-2019   : SYAP Optimised default account design.  Fixed due date defect.
 *  22-AUG-2019   : SYAP Validation for invalid Sub Area.
 *  19-SEP-2019   : SYAP Automation to set team name based on owner.
 *  08-NOV-2019   : SYAP Added logic to set Type Area field.
 *  10-JAN-2020   : SYAP Added logic to set due date based on received date (if set)
 *  30-JAN-2020   : SYAP Added calculation of due date based on case level business hours
 *                  if business hours not set in Entitlement Process.
 *  18-FEB-2020   : Roselin - Added logic to populate custom case number field.
 *  01-JUN-2020   : SYAP Added code to bypass validation for administrators.
 *  02-SEP-2020   : SYAP Bypass validation for child task and case if bypass timestamp is set.
 ****************************************************************************************************/

public with sharing class GCM_Case_Trigger_Helper {
/****************************************************************************************************
 Set Entitlement Based On Account
 ****************************************************************************************************/
    public static void setCaseEntitlement(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> caseList) {
        try {
            // Triggered By Before Insert / Update Events
            List<Case> updatedCases = new List<Case>();
            Map<Id, Id> accountMap = new Map<Id, Id>(); // Account Id, Entitlement Id
        
            // Find In-Scope Cases
            for (Case thisCase : caseList) {
                if (!String.isBlank(thisCase.AccountId)) {
                    // Entitlement Blank
                    if (String.isBlank(thisCase.EntitlementId)) {
                        if (thisCase.Status != 'Closed' && thisCase.Status != 'Cancelled') {
                            updatedCases.add(thisCase);
                            accountMap.put(thisCase.AccountId, null);
                        }
                    }
                
                    // Account Changed
                    if (oldMap != null) {
                        if (oldMap.get(thisCase.Id).AccountId != thisCase.AccountId) {
                            updatedCases.add(thisCase);
                            accountMap.put(thisCase.AccountId, null);           
                        }
                    }
                }
            }
        
            if (accountMap.size() > 0) {
                // Find Entitlements
                List<Entitlement> entitlements = [
                    select
                        Id,
                        AccountId
                    from
                        Entitlement
                    where
                        Name like 'GCM%' and 
                        Status = 'Active' and 
                        AccountId in :accountMap.keySet()
                ];
            
                for (Entitlement thisEntitlement : entitlements) {
                    if (accountMap.containsKey(thisEntitlement.AccountId)) {
                        accountMap.put(thisEntitlement.AccountId, thisEntitlement.Id);
                    }
                }

                // Update Entitlements
                for (Case thisCase : updatedCases) {
                    thisCase.EntitlementId = accountMap.get(thisCase.AccountId);
                }      
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'setCaseEntitlement', newMap.keySet(), 'GCM_Application_Administrator');
        }
    }

/****************************************************************************************************
 Check If Current User = System Administrator
 ****************************************************************************************************/ 
    public static boolean isCurrentUserAdministrator() {
        List<Profile> profiles = [select Id from Profile where Name = 'System Administrator'];
        for (Profile thisProfile : profiles) {
            if (thisProfile.Id == UserInfo.getProfileId() && !Test.isRunningTest()) {
                return true;
            }
        }
        return false;
    }
    
/****************************************************************************************************
 Set Service Catalog + Due Date
 ****************************************************************************************************/ 
    public static void setServiceCatalog(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> caseList) {
        // Assigns Service Catalog Based On:
        // 1. Account Attributes (Sales Organisation, Business Unit)
        // 2. Case Attributes (Type, Area, Sub Area, Complaint)
        try {
            List<Case> updatedCases = new List<Case>();
            Map<Id, String> accountMap = new Map<Id, String>();
            Map<Id, String> userMap = new Map<Id, Id>();
        
            for (Case thisCase : caseList) {  
                if (
                    !String.isBlank(thisCase.AccountId) &&
                    !String.isBlank(thisCase.Type) &&
                    !String.isBlank(thisCase.Area__c) && 
                    !String.isBlank(thisCase.Sub_Area__c) && 
                    thisCase.Status != 'Closed' && 
                    thisCase.Status != 'Cancelled') {
                    Boolean setCatalog = true;
           
                    // New Record     
                    if (oldMap != null) {
                       
                       
                    setCatalog = 
                        oldMap.get(thisCase.Id).AccountId != newMap.get(thisCase.Id).AccountId || 
                        oldMap.get(thisCase.Id).Type != newMap.get(thisCase.Id).Type || 
                        oldMap.get(thisCase.Id).Area__c != newMap.get(thisCase.Id).Area__c || 
                        oldMap.get(thisCase.Id).Sub_Area__c != newMap.get(thisCase.Id).Sub_Area__c || 
                        oldMap.get(thisCase.Id).Complaint__c != newMap.get(thisCase.Id).Complaint__c ||
                        oldMap.get(thisCase.Id).OwnerId != newMap.get(thisCase.Id).OwnerId;
                    }
                                   
                    if (setCatalog) {
                        accountMap.put(thisCase.AccountId, null);
                        updatedCases.add(thisCase);
                    }

                    // Set User Map
                    userMap.put(thisCase.OwnerId, null);
                }
            }
        
            // Bypass If No Accounts Found
            if (accountMap.size() == 0) return;
        
            // Get User > Business Hours Map
            GCM_Entitlement_Engine.updateUserEntitlementMap(userMap);
            GCM_Entitlement_Engine.updateQueueEntitlementMap(userMap);
            
            // Get Account Map
            List<String> salesOrganisations = new List<String>();
            List<String> businessUnits = new List<String>();
            List<String> sels = new List<String>();
            List<Account> accounts = [
            select
                Id,
                Sales_Organisation__c,
                Business_Unit__c,
                Service_Experience_Level__c
            from
                Account
            where
                Id in :accountMap.keySet()
            ];
        
            for (Account thisAccount : accounts) {
                salesOrganisations.add(thisAccount.Sales_Organisation__c);
                businessUnits.add(thisAccount.Business_Unit__c);
                sels.add(thisAccount.Service_Experience_Level__c);
                String accountKey = thisAccount.Sales_Organisation__c + thisAccount.Business_Unit__c + thisAccount.Service_Experience_Level__c;
                accountMap.put(thisAccount.Id, accountKey); 
            }
        
            // Get Service Catalog Map
            Map<String, Id> catalogMap = new Map<String, Id>(); // Key, Catalog Id
            Map<String, Integer> catalogSLAMap = new Map<String, Integer>(); // Key, Service Level Priority
            Map<String, String> caseCategoryMap = new Map<String, String>();
            List<GCM_Service_Catalog__c> catalogs = [
            select
                Id,
                GCM_Sales_Organisation__c,
                GCM_Business_Unit__c,
                GCM_SEL__c,
                GCM_Type__c,
                GCM_Area__c,
                GCM_Sub_Area__c,
                GCM_Complaint__c,
                GCM_Duration__c
            from
                GCM_Service_Catalog__c
            where
                GCM_Sales_Organisation__c in :salesOrganisations and 
                GCM_Business_Unit__c in :businessUnits and 
                GCM_Related_Object__c = 'Case' and 
                GCM_Active__c = true
            ];
            system.debug('the scatalogs'+catalogs);

            for (GCM_Service_Catalog__c catalog : catalogs) {
                String key = '';
                key += catalog.GCM_Sales_Organisation__c;
                key += catalog.GCM_Business_Unit__c;
                key += catalog.GCM_SEL__c;
                key += catalog.GCM_Type__c;
                key += catalog.GCM_Area__c;
                key += catalog.GCM_Sub_Area__c;
                key += String.valueOf(catalog.GCM_Complaint__c);
                catalogMap.put(key, catalog.Id);
                catalogSLAMap.put(key, (Integer) catalog.GCM_Duration__c);
          
                // Save Valid Type, Area, Sub Area Combinations
                String caseCategoryKey = '';
                caseCategoryKey += catalog.GCM_Type__c;
                caseCategoryKey += catalog.GCM_Area__c;
                caseCategoryKey += catalog.GCM_Sub_Area__c;
                system.debug('the catalogs key'+caseCategoryMap);
                caseCategoryMap.put(caseCategoryKey, null); 
                system.debug('the catalogs'+caseCategoryMap);
            }
          
            // Update Cases
            Map<Id, Id> entitlementMap = new Map<Id, Id>(); // Entitlemment Id, Business Hours Id
            Map<Id, Integer> serviceLevelMap = new Map<Id, Integer>(); // Case Id, Service Level Priority
            for (Case thisCase : updatedCases) {
                if (thisCase.EntitlementId != null) {
                    entitlementMap.put(thisCase.EntitlementId, null);
                }
                String key = '';
                if (accountMap.containsKey(thisCase.AccountId)) {
                    key += accountMap.get(thisCase.AccountId);
                }
                key += thisCase.Type;
                key += thisCase.Area__c;
                key += thisCase.Sub_Area__c;
                key += String.valueOf(thisCase.Complaint__c);
                if (catalogMap.containsKey(key)) {
                    system.debug('check1');
                    thisCase.GCM_Service_Catalog__c = catalogMap.get(key);
                    if (catalogSLAMap.containsKey(key)) {
                        system.debug('check2');
                        system.debug('catalogSLAMap check1'+catalogSLAMap.get(key));
                        
                        if (catalogSLAMap.get(key) != null) serviceLevelMap.put(thisCase.Id, catalogSLAMap.get(key));
                    }
                }
            }
        
            // Update Entitlement > Business Hours Map
            GCM_Entitlement_Engine.updateEntitlementMap(entitlementMap);

            // Update Due Date
            for (Case thisCase : updatedCases) {
                Boolean dueDateSet = false;
                system.debug('the entitlements'+thisCase.EntitlementId);
                if (thisCase.EntitlementId != null) {
                    system.debug('the entitlements'+thisCase.EntitlementId);
                    if (entitlementMap.containsKey(thisCase.EntitlementId)) {
                         system.debug('the entitlements inside first');
                        if (serviceLevelMap.containsKey(thisCase.Id)) {
                             system.debug('the entitlements inside check');
                            if (entitlementMap.get(thisCase.EntitlementId) != null) {
                                system.debug('the entitlements inside check 3');
                                Datetime startDate = thisCase.CreatedDate == null ? Datetime.now() : thisCase.CreatedDate;

                                // Override Start Date If Received Date Set
                                if (thisCase.GCM_Received_Date__c != null) startDate = thisCase.GCM_Received_Date__c;

                                // Override Business Hours If Set On Owner
                                Id businessHoursId = entitlementMap.get(thisCase.EntitlementId);
                                system.debug('the business hours check first'+businessHoursId);
                                Id userBusinessHoursId = null;
                                if (userMap.containsKey(thisCase.OwnerId)) {
                                    userBusinessHoursId = userMap.get(thisCase.OwnerId); 
                                    system.debug('the business hours check second'+businessHoursId);
                                }
                                if (userBusinessHoursId != null) businessHoursId = userBusinessHoursId;
                                system.debug('the business hours id'+businessHoursId);
                            
                                Datetime dueDate = BusinessHours.addGmt(businessHoursId, startDate, (Long) serviceLevelMap.get(thisCase.Id) * 60 * 1000L);
                                thisCase.Due__c = dueDate;
                                dueDateSet = true;
                            
                                // Update Case Business Hours
                                if (thisCase.BusinessHoursId == null || thisCase.BusinessHoursId != businessHoursId) {
                                    thisCase.BusinessHoursId = businessHoursId;
                                }
                            }
                        }
                    }
                }

                // Clear Due Date If Not Set
                if (!dueDateSet) {
                    thisCase.Due__c = null;
                    Boolean skip = false;
                    if (oldMap == null) {
                        skip = thisCase.GCM_ByPassValidation_Timestamp__c != null;
                    }
                    else {
                        skip = oldMap.get(thisCase.Id).GCM_ByPassValidation_Timestamp__c != thisCase.GCM_ByPassValidation_Timestamp__c;
                    }

                    if (!skip && !GCM_Case_Trigger_Helper.isCurrentUserAdministrator()) {
                        String caseCategoryKey = '';
                        caseCategoryKey += thisCase.Type;
                        caseCategoryKey += thisCase.Area__c;
                        caseCategoryKey += thisCase.Sub_Area__c;
                        system.debug('Find the Map'+caseCategoryMap);
                        system.debug('find the key'+caseCategoryKey);
                        
                        if (!caseCategoryMap.containsKey(caseCategoryKey)) {
                            thisCase.addError('Type, Area and Sub-Area combination does not have a Service Level Agreement associated. Please check the LOV job aid.');
                        }
                    }
                }
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'setServiceCatalog', newMap.keySet(), 'GCM_Application_Administrator');     
        }
    }
 
/****************************************************************************************************
 Set Case Milhttps://bpcustomer--gcmdev.cs86.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#estone Completed Date
 ****************************************************************************************************/ 
    public static void setMilestoneCompletedDate(List<Case> caseList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        // Complete Milestone When Case = Closed / Cancelled
        try {
            List<Id> caseIds = new List<Id>();
        
            for (Case thisCase : caseList) {
                if (oldMap != null) {
                    // Checking Case Status Previous Value / New Value 
                    if ((oldMap.get(thisCase.Id).Status != thisCase.Status) && 
                    (thisCase.Status == 'Closed' || thisCase.Status == 'Cancelled')) {
                        caseIds.add(thisCase.Id);
                    }
                    else {
                        if (thisCase.Status == 'Closed' || thisCase.Status == 'Cancelled') {
                            caseIds.add(thisCase.Id);
                        }    
                    }  
                }
            }
        
            // Bypass If No Cases In Scope
            if (caseIds.size() == 0) return;
        
            List<CaseMilestone> milestones = [select Id from CaseMilestone where CaseId in :caseIds];
            List<CaseMilestone> updatedMilestones = new List<CaseMilestone>();
            for (CaseMilestone milestone : milestones) {
                CaseMilestone updatedMilestone = new CaseMilestone();
                updatedMilestone.Id = milestone.Id;
                updatedMilestone.CompletionDate = Datetime.now();
                updatedMilestones.add(updatedMilestone);
            }
            if (updatedMilestones.size() > 0) update updatedMilestones;
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'setMilestoneCompletedDate', newMap.keySet(), 'GCM_Application_Administrator');          
        }
    }

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
 Get Default Account Mapping
 Required If Case.AccountId = NULL
 ****************************************************************************************************/
/*
    public static Map<String, String> getDefaultAccount() {
      // Get Metadata
      List<GCM_Case_Default_Account__mdt> defaultAccounts = [
        select
          GCM_Sales_Organisation__c,
          GCM_Business_Unit__c,
          GCM_Default_Account_ID__c 
        from
          GCM_Case_Default_Account__mdt
        where
          GCM_Active__c = true
      ];
      
      // Maps <Sales Organisation>_<Business Unit> Into Account ERP ID
      Map<String, String> defaultMap = new Map<String, String>();
      for (GCM_Case_Default_Account__mdt defaultAccount : defaultAccounts) {
        String key = defaultAccount.GCM_Sales_Organisation__c + '_' + defaultAccount.GCM_Business_Unit__c;
        defaultMap.put(key, defaultAccount.GCM_Default_Account_ID__c);
      }
    
      return defaultMap;
    }
*/

/****************************************************************************************************
 Basic Routing Strategy
 ****************************************************************************************************/ 
    public static void applyRoutingRules (Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> caseList) {
      // Assign Cases Based On Recipient Mailboxes
      try {        
        // Get Mailboxes
        Map<String, List<GCM_Routing_Rule__mdt>> ruleMap = new Map<String, List<GCM_Routing_Rule__mdt>>();
        List<Case> cases = new List<Case>();
        system.debug('the cases are-->'+cases);
        for (Case thisCase : caseList) {
            system.debug('the cases are-->'+thisCase.CaseNumber);
            system.debug('the cases are-->'+thisCase.GCM_Mailbox_Reference__c);
          if (String.isBlank(oldMap.get(thisCase.Id).GCM_Mailbox_Reference__c) || 
              oldMap.get(thisCase.Id).GCM_Mailbox_Reference__c != newMap.get(thisCase.Id).GCM_Mailbox_Reference__c) {
            List<GCM_Routing_Rule__mdt> ruleList;
            if (!ruleMap.containsKey(thisCase.GCM_Mailbox_Reference__c)) {
              ruleMap.put(thisCase.GCM_Mailbox_Reference__c, null);
            }
            
            // Cases For Processing
            cases.add(thisCase);
          }
        }
        
        if (cases.size() == 0) return;

        // Get Default Account Map
        // Map<String, String> defaultMap = getDefaultAccount();
        Map<String, String> defaultMap = new Map<String, String>();
            
        // Get Rule Parameters
        Map<String, Id> queueMap = new Map<String, Id>(); // Queue, Queue Id
        List<GCM_Routing_Rule__mdt> rules = [
          select
            MasterLabel,
            GCM_Account_Length__c,
            GCM_Account_Match__c,
            GCM_Keyword_Match__c,
            GCM_Case_Type__c,
            GCM_Case_Area__c,
            GCM_Case_Sub_Area__c,
            GCM_Business_Unit__c,
            GCM_Sales_Organisation__c,
            GCM_Queue__c,
            GCM_Default_Account__c
          from
            GCM_Routing_Rule__mdt
          where
            MasterLabel in :ruleMap.keySet() and 
            GCM_Active__c = true
          order by
            MasterLabel asc,
            GCM_Order__c desc
        ];
        for (GCM_Routing_Rule__mdt rule : rules) {
          List<GCM_Routing_Rule__mdt> ruleList;
          if (ruleMap.containsKey(rule.MasterLabel)) {
            ruleList = ruleMap.get(rule.MasterLabel);
            if (ruleList == null) {
              ruleList = new List<GCM_Routing_Rule__mdt>();
              ruleMap.put(rule.MasterLabel, ruleList);
            }
            ruleList.add(rule);           
          }
          if (rule.GCM_Queue__c != null) {
            queueMap.put(rule.GCM_Queue__c, null);
          }
          // Default Account Map
          defaultMap.put(rule.MasterLabel, rule.GCM_Default_Account__c);
        }
        
        // Get Queue
        List<Group> queues = [
          select
            Id,
            DeveloperName
          from
            Group
          where
            DeveloperName in :queueMap.keySet() and 
            Type = 'Queue'
        ];
        for (Group queue : queues) {
          queueMap.put(queue.DeveloperName, queue.Id);
        }
        
        // Traverse Cases
        Map <Id, String> caseAccountMap = new Map<Id, String>(); // Case Id, Account Number
        Map <Id, String> caseAccountDefaultMap = new Map<Id, String>(); // Case Id, Account Number (Default)
        Map <String, Id> accountMap = new Map<String, Id>(); // Account Number, Account Id
        for (Case thisCase : cases) {
          if (ruleMap.containsKey(thisCase.GCM_Mailbox_Reference__c)) {
            List<GCM_Routing_Rule__mdt> ruleList = ruleMap.get(thisCase.GCM_Mailbox_Reference__c);
                               
            if (ruleList != null) {
              for (GCM_Routing_Rule__mdt rule : ruleList) {
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
                // String key = rule.GCM_Sales_Organisation__c + '_' + rule.GCM_Business_Unit__c;
                if (defaultMap.containsKey(thisCase.GCM_Mailbox_Reference__c)) {
                  // caseAccountDefaultMap.put(thisCase.Id, defaultMap.get(key));
                  caseAccountDefaultMap.put(thisCase.Id, defaultMap.get(thisCase.GCM_Mailbox_Reference__c));
                  accountMap.put(defaultMap.get(thisCase.GCM_Mailbox_Reference__c), null);   
                }
                    
                // Find Keyword
                if (rule.GCM_Keyword_Match__c != null) {
                  String keyMatch = GCM_Case_Trigger_Helper.getSubstring(rule.GCM_Keyword_Match__c, 1, bodySubject.toLowerCase());
                  if (keyMatch != '') {
                    if (!String.isBlank(rule.GCM_Case_Type__c)) thisCase.Type = rule.GCM_Case_Type__c;
                    if (!String.isBlank(rule.GCM_Case_Area__c)) thisCase.Area__c = rule.GCM_Case_Area__c;
                    if (!String.isBlank(rule.GCM_Case_Area__c)) thisCase.Sub_Area__c = rule.GCM_Case_Sub_Area__c;
                    if (!String.isBlank(rule.GCM_Queue__c) && queueMap.containsKey(rule.GCM_Queue__c)) {
                      if (queueMap.get(rule.GCM_Queue__c) != null) thisCase.OwnerId = queueMap.get(rule.GCM_Queue__c);
                    }
                  }
                }
              }
            }
          }
        }
            
        // Get Accounts        
        List<Account> accounts = [select Id, Account_ERP_ID__c,Business_Unit__c,Sales_Organisation__c from Account where Account_ERP_ID__c = :accountMap.keySet()];
        for (Account thisAccount : accounts) {
          accountMap.put(thisAccount.Account_ERP_ID__c, thisAccount.Id);
        }
        
        // Update Case Account
        for (Case thisCase : cases) {
          if (caseAccountMap.containsKey(thisCase.Id)) {
            String accountNumber = caseAccountMap.get(thisCase.Id);
            if (accountMap.containsKey(accountNumber)) {
              if (thisCase.AccountId == null) {
                thisCase.AccountId = accountMap.get(accountNumber);
              }
            }                
          }
            
          // If Account ID Still Not Set - Assign Default Account
          if (thisCase.AccountId == null) {
            if (caseAccountDefaultMap.containsKey(thisCase.Id)) {
              String accountNumber = caseAccountDefaultMap.get(thisCase.Id);
              if (accountMap.containsKey(accountNumber)) {
                thisCase.AccountId = accountMap.get(accountNumber);
              }
            }
          }
        }
      }  
      catch (Exception exceptionObject) {
        BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'applyRoutingRules', newMap.keySet(), 'GCM_Application_Administrator');               
      } 
    }
    
/****************************************************************************************************
 Case Child Record Status Validation
 Do Not Allow Case Closure If There Are Open Child Records
 ****************************************************************************************************/
    public static void validateChildRecords(Map<Id, Case> oMap, Map<Id, Case> nMap, List<Case> caseList) {
		// Exit For New Records
		if (oMap == null) return;
        
        // Bypass Check For Administrators
		if (GCM_Case_Trigger_Helper.isCurrentUserAdministrator()) return;

        // Get In Scope 
        List<Id> caseIdList = new List<Id>();
        for (Case thisCase : caseList) {
            if (!(oMap.get(thisCase.Id).GCM_ByPassValidation_Timestamp__c != thisCase.GCM_ByPassValidation_Timestamp__c)) {
                caseIdList.add(thisCase.Id);
            }    
        }
        
        // Validation Rule
        // Cases With Open Child Tasks Cannot Be Closed
        List <Task> tasks = [Select WhatId, Id From Task WHERE WhatId in :caseIdList AND Status <> 'Completed'];
        List <Case> cases = [Select ParentId, Id From Case WHERE ParentId in :caseIdList AND Status <> 'Closed' AND Status <> 'Cancelled'];
        
        Map<String, String> errorMessages = new Map<String, String>();
        
        // Traverse Open Child Tasks
        for (Task thisTask : tasks) {
            String errorMessage = 'Close Child Tasks before closing or cancelling the case.';
            if (errorMessages.containsKey(thisTask.WhatId)) {
                errorMessages.put(thisTask.WhatId, errorMessages.get(thisTask.WhatId) + '<br/>' + errorMessage);
            }
            else {
                errorMessages.put(thisTask.WhatId, errorMessage);
            }
        }
        
         
        // Traverse Open Child Cases
        for (Case thisCase : cases) {
            String errorMessage = 'Close Child Cases before closing or cancelling the case.';
            if (errorMessages.containsKey(thisCase.ParentId)) {
                errorMessages.put(thisCase.ParentId, errorMessages.get(thisCase.ParentId) + '<br/>' + errorMessage);
            }
            else {
                errorMessages.put(thisCase.ParentId, errorMessage);
            }
        }
        
        // Create SObject Map
        Map <String, Case> caseMap = new Map<String, Case>();
        for (Case thisCase : caseList) {
            caseMap.put(thisCase.Id, thisCase);
        }
        
        // Display Error Messages        
        for (String caseId : errorMessages.keySet()) {
            if (caseMap.get(CaseId).Status == 'Closed' || caseMap.get(CaseId).Status == 'Cancelled') {
                caseMap.get(caseId).addError(errorMessages.get(caseId));
            }
        }
    }
    
/****************************************************************************************************
 Set Team Name - References GCM_Data_Map__mdt Custom Metadata
 ****************************************************************************************************/ 
    public static void setTeamName(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> caseList) {
        // Get In-Scope Cases
        try {
            List<Case> caseSubSet = new List<Case>();
            List<Id> ownerList = new List<Id>();
            for (Case thisCase : caseList) {
                if (oldMap == null) {
                    caseSubSet.add(thisCase);
                    ownerList.add(thisCase.OwnerId);
                }
                else {
                    if (oldMap.get(thisCase.Id).OwnerId != thisCase.OwnerId) {
                        caseSubSet.add(thisCase);
                        ownerList.add(thisCase.OwnerId);
                    }
                }
            }
        
            if (caseSubSet.size() == 0) return;
        
            // Get User Map
            Map<Id, String> userMap = new Map<Id, String>();
            List<User> users = [select Id, GCM_Team_Name__c from User where Id in :ownerList];
            for (User thisUser : users) {
                userMap.put(thisUser.Id, thisUser.GCM_Team_Name__c);
            }
        
            // Get Queue Map
            Map<Id, String> queueMap = new Map<Id, String>();
            List<Group> queues = [select Id, DeveloperName from Group where Type = 'Queue' and Id in :ownerList];
            for (Group queue : queues) {
                queueMap.put(queue.Id, queue.DeveloperName);
            }
        
            // Get Data Map
            Map<String, String> valueMap = new Map<String, String>();
            List<GCM_Data_Map__mdt> dataMaps = [
                select
                    GCM_Source__c,
                    GCM_Target__c
                from
                    GCM_Data_Map__mdt
                where
                    GCM_Active__c = true and 
                    GCM_Source__c in :queueMap.values() and
                    GCM_Type__c = 'Queue_Team'
            ];
            for (GCM_Data_Map__mdt dataMap : dataMaps) {
                valueMap.put(dataMap.GCM_Source__c, dataMap.GCM_Target__c);
            }
        
            // Translate Values
            for (Case thisCase : caseSubSet) {
                if (queueMap.containsKey(thisCase.OwnerId)) {
                    String queueName = queueMap.get(thisCase.OwnerId);
                    if (valueMap.containsKey(queueName)) {
                        thisCase.GCM_Owner_Team_Name__c = valueMap.get(queueName);
                    }
                    else {
                        thisCase.GCM_Owner_Team_Name__c = null;
                    }            
                }
                else if (userMap.containsKey(thisCase.OwnerId)) {
                    thisCase.GCM_Owner_Team_Name__c = userMap.get(thisCase.OwnerId);
                }
                else {
                    thisCase.GCM_Owner_Team_Name__c = null;
                }
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'setTeamName', newMap.keySet(), 'GCM_Application_Administrator');               
        }
    }

/****************************************************************************************************
 Set Case Number in custome field. Format - BP-XXXXXXXX
 ****************************************************************************************************/ 
/*
    public static void setCaseNumber(Map<Id,Case> newCaseMap) {
        List<Case> updateCaseList = new List<Case>();
        List<Case> caseList = [Select Id, CaseNumber, GCM_Case_Number__c FROM Case WHERE Id IN: newCaseMap.keySet()];
        try {
            for(Case cas : caseList){
                if(String.ISBLANK(cas.GCM_Case_number__c)){
                    cas.GCM_Case_Number__c = 'BP-'+cas.CaseNumber;
                    updateCaseList.add(cas);
                }
            }
            if(!updateCaseList.isEmpty()){
                update updateCaseList;
            }
        }
        catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Case_Trigger_Helper', 'setCaseNumber', newCaseMap.keySet(), 'GCM_Application_Administrator');               
        }
    }
*/
}