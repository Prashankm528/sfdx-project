/**
* @Author:       Sushant Sethi
* @Date  :       08 June 2020
* @Description : This class handles trigger activities related to BPCM Case object
**/
public inherited sharing class BPCM_CaseService{

    private static String ACTIVE = 'Active';
    private static String PHONECALL = 'Phone Call';
    private static String BPCM = 'BPCM_';
    private static AssignmentRule[] csAssRules = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
    
/*  Method Name: processCaseService(list<case> castCaseRecs)
    Method Desription:  This method will handle the logic for BPCM Cases
                        This method will accept list<case> to be processed and will set the fields on BPCM Cases with business defined rules
*/
    public static void processCaseService(List<Case> castCaseRecs){
            list<case> caseToProcess = new list<case>();
            caseToProcess = casesToProcess(castCaseRecs);
             map<string,BPCM_Automation_Setup__c> keyAutoSetupMap = new map<string,BPCM_Automation_Setup__c>();
             //Iterate over the Automation Setup object to capture 'Active' records sorted by Process Order field in Ascending order 
             for(BPCM_Automation_Setup__c autoSet : [SELECT BPCM_Keywords__c,BPCM_Process_Order__c,BPCM_Status__c,
                                                        BPCM_Case_Record_Type__c,BPCM_Business_Unit__c,BPCM_Case_Priority__c,
                                                        BPCM_Case_Further_Subcategory__c,BPCM_Case_Category__c,BPCM_Case_Subcategory__c FROM 
                                                        BPCM_Automation_Setup__c WHERE  BPCM_Status__c = :ACTIVE 
                                                        ORDER BY 
                                                        BPCM_Process_Order__c ASC
                                                        limit :Limits.getLimitQueryRows()]){
                                                        //Check if the same set of Keywords exist already, if yes then do not add to map
                                                        if((autoSet.BPCM_Keywords__c!=null) && !keyAutoSetupMap.containsKey(autoSet.BPCM_Keywords__c)){
                                                            keyAutoSetupMap.put(autoSet.BPCM_Keywords__c,autoSet);
                                                        }
                                                        }
             
             
             //Iterate over the Incoming Cases
             if(caseToProcess.size()>0){
                for(case c: caseToProcess){
                    
                    boolean processOrderFound=false; //Boolean to stop processing the loop multiple times if an entry is found first
                    string searchKeyword= c.Description + c.subject;
                    searchKeyword = searchKeyword.replaceAll('[^a-zA-Z0-9\\s+]', ''); // Syntax to remove all special characters from string, only for comparison
                    
                    for(string autoSetKey : keyAutoSetupMap.keyset()){
                        List<string> autoSetupKey = autoSetKey.split(',');
                        if(!processOrderFound){
                        for(string autoKey : autoSetupKey){
                            if(searchKeyword != null && searchKeyword.containsIgnoreCase(autoKey)){
                                c.BPCM_Run_Case_Assignment_Rules__c = true;
                                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(keyAutoSetupMap.get(autoSetKey).BPCM_Case_Record_Type__c).getRecordTypeId();
                                //All fields to be set on Case should contain a valid value
                                if(keyAutoSetupMap.get(autoSetKey).BPCM_Case_Category__c!=null){
                                    c.BPCM_Category__c = keyAutoSetupMap.get(autoSetKey).BPCM_Case_Category__c;
                                }
                                if(keyAutoSetupMap.get(autoSetKey).BPCM_Case_Subcategory__c !=null){
                                c.BPCM_Subcategory__c = keyAutoSetupMap.get(autoSetKey).BPCM_Case_Subcategory__c;
                                }
                                if(keyAutoSetupMap.get(autoSetKey).BPCM_Case_Further_Subcategory__c!=null){
                                c.BPCM_Further_Subcategory__c = keyAutoSetupMap.get(autoSetKey).BPCM_Case_Further_Subcategory__c;
                                }
                                if(keyAutoSetupMap.get(autoSetKey).BPCM_Case_Priority__c!=null){
                                c.Priority = keyAutoSetupMap.get(autoSetKey).BPCM_Case_Priority__c;
                                }
                                //Entry found, stop processing the loop further
                                processOrderFound = true;
                                }
                        }
                        }
                    }
                    }
                }
             
             }
             
    /*  Method Name: casesToProcess(list<case> castCaseRecs)
    Method Desription:  This method will handle the logic for BPCM Cases
                        This method will accept list<case> to be processed and will return the cases to be handled for Origin!=Phone Call and Record Type starting with 'BPCM_ '
*/
    public static list<case> casesToProcess(List<Case> castCaseRecs){
        List<Case> caseScopeForProcessing = new List<Case>();
         for(case c:castCaseRecs){
             //Fetch record type of incoming case
             string caseRecName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getDeveloperName();
             //Selection criteria of Case: Origin should not be Phone Call and Record Type should start with BPCM
             if(c.Origin != PHONECALL && caseRecName.startsWith(BPCM)){
                 caseScopeForProcessing.add(c);
             }
         }
         return caseScopeForProcessing;
    }
    
 /*  Method Name: runBeforeInsert(list<case> newRecords)
    Method Desription:  This method will handle the logic for BPCM Cases
                        This method will accept list<case> to be Update the field before insert when the Case Owner is a Queue, 
                        set the queue name to BPCM_Team__c. 
 */
    public static void runBeforeInsert(List<Case> newRecords)
    {
        map<Id, Group> mapAllQueue = new map<Id, Group>();
        String userBUInfo = [SELECT BPCM_Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId()].BPCM_Business_Unit__c;
        List<Group> getAllQueue = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName like 'BPCM_%'];
        for(Group Obj : getAllQueue){
          mapAllQueue.put(Obj.Id, Obj);
        }
        for(case c:newRecords){
            String csRecTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            if(String.isNotBlank(csRecTypeName) && csRecTypeName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){
              if (mapAllQueue.containsKey(c.OwnerId)){
                  c.BPCM_Team__c = mapAllQueue.get(c.OwnerId).Name; 
              }
                
                //get business unit from the default queue name set in email-to-case
                if(c.Origin == BPCM_GlobalConstants.CASE_ORIGIN_EMAIL){
                    if(!mapAllQueue.isEmpty() && mapAllQueue.containsKey(c.OwnerId)){
                        List<String> queueNameList = mapAllQueue.get(c.OwnerId).DeveloperName.split('_');
                        c.BPCM_Business_Unit__c = queueNameList[1];
                    }
                }
                
                //get business unit from user information and set Status to In Progress
                if(c.Origin == BPCM_GlobalConstants.CASE_ORIGIN_PHONE_CALL){
                    c.BPCM_Business_Unit__c = userBUInfo;
                    c.Status = BPCM_GlobalConstants.CASE_STATUS_IN_PROGRESS;
                }

                //set status to Closed if not changed and set BPCM_Customer_Consent_to_Close__c to true.
                if(c.BPCM_Customer_Consent_to_Close__c && c.Status != BPCM_GlobalConstants.CASE_STATUS_CLOSED){
                    c.Status = BPCM_GlobalConstants.CASE_STATUS_CLOSED;
                }
            }
        }
    }
    
 /*  Method Name: runBeforeUpdate(list<case> newRecords, Map<Id, Case> oldMap)
    Method Desription:  This method will handle the logic for BPCM Cases
                        This method will accept list<case> to be Update the field before update when the Case Owner is a Queue, 
                        set the queue name to BPCM_Team__c. 
 */
    public void runBeforeUpdate(List<Case> newRecords, Map<Id, Case> oldMap){

        map<Id, String> mapAllQueue = new map<Id, String>();
        List<Group> getAllQueue = [select Id, name from Group where Type = 'Queue' and DeveloperName like 'BPCM_%'];
        List<String> csFieldsList = BPCM_SettingsService.getCaseFieldsToCheckUpdate(BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);

        for(Group Obj : getAllQueue){
          mapAllQueue.put(Obj.Id, Obj.name);
        }
        for(Case c : newRecords){
            Case oldCs = oldMap.get(c.Id);
            String csRecTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            if(String.isNotBlank(csRecTypeName) && csRecTypeName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){
                
                //set BPCM Team based on the assigned Queue
                if(c.OwnerId != oldCs.OwnerId){
                    if (mapAllQueue.containsKey(c.OwnerId)){
                        c.BPCM_Team__c = mapAllQueue.get(c.OwnerId);
                    }

                    //set case status to 'Assigned' when it's assigned by the Supervisor
                    if(String.valueOf(oldCs.OwnerId).startsWith('00G') 
                      && String.valueOf(c.OwnerId).startsWith('005')){
                        c.Status = BPCM_GlobalConstants.CASE_STATUS_ASSIGNED;
                    }
                }
                
                //set status to 'In Progress' if any changes is made on the Case. Fields check controlled by metadata type.
                if(c.Status == BPCM_GlobalConstants.CASE_STATUS_NEW && String.valueOf(c.OwnerId).startsWith('005')){
                    for(String fieldAPIName : csFieldsList){
                        if(c.get(fieldAPIName.trim()) != oldCs.get(fieldAPIName.trim())){
                            c.Status = BPCM_GlobalConstants.CASE_STATUS_IN_PROGRESS;
                            break;
                        }
                    }
                }

                //set status to Closed if not changed and set BPCM_Customer_Consent_to_Close__c to true.
                if(c.BPCM_Customer_Consent_to_Close__c && c.Status != BPCM_GlobalConstants.CASE_STATUS_CLOSED
                && c.BPCM_Customer_Consent_to_Close__c != oldCs.BPCM_Customer_Consent_to_Close__c){
                    c.Status = BPCM_GlobalConstants.CASE_STATUS_CLOSED;
                }
            }
        }
    }
    
    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all cases that must run the assignment rules
     * 2. Identify new Cases origin Phone Call and then log inbound call automatically
     * @author Gabriela Matos | 22/06/2020
     * @param: List of new Case records
     * @return void
     * */
    public void runAfterInsert(List<Case> newRecords){
        
        List<Case> upCaseList = new List<Case>();
        List<Case> csToLogInbCallList = new List<Case>();

        for(Case cs : newRecords){
            String csRecTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getDeveloperName();
            if(String.isNotBlank(csRecTypeName) 
               && csRecTypeName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){

               if(cs.BPCM_Run_Case_Assignment_Rules__c){
                   //It must be a new case instance as DML cannot operate in Trigger.new/Trigger.old
                   upCaseList.add(new Case(Id = cs.Id));
               }

               if(cs.Origin == BPCM_GlobalConstants.CASE_ORIGIN_PHONE_CALL){
                    csToLogInbCallList.add(cs);
               }
            }
        }
        
        //run assignment rules
        if(!upCaseList.isEmpty()){
            runAssignmentRules(upCaseList);
        }

        //log inbound calls
        if(!csToLogInbCallList.isEmpty()){
            BPCM_TaskService.logInboundCall(csToLogInbCallList);
        }
    }
    
    /** 
     * @description: method to run after update and centralise all logics
     * 1. Get all fields on Case that should be tracked, in case of any has changed count to Case Touch History
     * 2. Identify if the case has been trasnfered, then count to Case Touch History
     * @author Gabriela Matos | 19/06/2020
     * @param: Map of new Case records
     * @return void
     * */
    public void runAfterUpdate(Map<Id, Case> oldMap, List<Case> newRecords){
        
        Map<Id, List<String>> csListMap = new Map<Id, List<String>>();
        List<String> csFieldsList = BPCM_SettingsService.getCaseFieldsToCheckUpdate(BPCM_GlobalConstants.SET_CASE_FIELDS_CHECK_UP);
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        
        for(Case cs : newRecords){
            Case oldCs = oldMap.get(cs.Id);
            String csRecTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getDeveloperName();
            
            if(String.isNotBlank(csRecTypeName) 
               && csRecTypeName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)
               && userProfile == BPCM_GlobalConstants.BPCM_BASE_PROFILE){
                   
                   if(cs.OwnerId != oldCs.OwnerId){
                       //count when case is transfered (interaction)   
                       csListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(csListMap, cs.Id, BPCM_GlobalConstants.CHT_TRANSFERS_FIELD_APINAME);
                   } else { 
                       //check tracked fields if case has been updated to count into the interactions. first change find it will be considered
                       for(String fieldAPIName : csFieldsList){
                           if(cs.get(fieldAPIName.trim()) != oldCs.get(fieldAPIName.trim())){
                               csListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(csListMap, cs.Id, BPCM_GlobalConstants.CHT_CASE_UPDATE_FIELD_APINAME);
                               break;
                           }
                       }
                   }
               }
        }
        
        if(!csListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(csListMap);
        }
    }
    
    /** 
     * @description: method to set DML to run Case assignment rules for the Cases in context
     * @author Gabriela Matos | 22/06/2020
     * @param: List of Case to run assignment rules
     * @return void
     * */
    public static void runAssignmentRules(List<Case> upCaseList){
        
        List<Case> upRunAssRulesList = new List<Case>();
        for(Case cs : upCaseList){
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(csAssRules[0].Id != null)
                dmlOpts.assignmentRuleHeader.assignmentRuleId = csAssRules[0].Id;
            else dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            //Setting the DMLOption on Case instance
            cs.setOptions(dmlOpts);
            upRunAssRulesList.add(cs);
        }
        
        if(!upRunAssRulesList.isEmpty()){
            update upRunAssRulesList;
        }
    }

 }