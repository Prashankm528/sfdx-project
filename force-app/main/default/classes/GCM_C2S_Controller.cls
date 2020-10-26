/****************************************************************************************************
 *  Date          : 5-JUL-2019
 *  Author        : Sunny Yap
 *  Description   : Cost to serve server side controller.
 *  Modifications : 5-JUL-2019 SYAP - Initial
 *                  27-JUL-2019 SYAP - Added exception handling.
 *					10-OCT-2019 AJAY KONATHALA - Added a Method to fetch the case Id from the case duration record.
 ****************************************************************************************************/

public with sharing class GCM_C2S_Controller {

/****************************************************************************************************
   Returns true If ALL Conditions Below Met:
   1. Object Type = Case
   2. Case Status = Closed OR Cancelled
   Check Object Type
 ****************************************************************************************************/
  public static boolean isCaseOpen(Id caseId) {
    try {
      if (caseId.getSObjectType().getDescribe().getName() == 'Case') {
        List<Case> cases = [select ownerId,Status from Case where Id = :caseId];
        for (Case thisCase : cases) {
          return thisCase.Status != 'Closed' && thisCase.Status != 'Cancelled';
        }
      }
       
      return false;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'isCaseOpen', new List<Id>{caseId}, 'GCM_Application_Administrator');
      return false;
    }
  }

/****************************************************************************************************
   Only Called By Lightning Component doInit Event
 ****************************************************************************************************/
  @AuraEnabled  
  public static void clearTimer() {
    try {
       
      // Stop All Timers
      List<GCM_Case_Duration__c> trackersOld = [select Id, CreatedDate, GCM_End_Time__c from GCM_Case_Duration__c where OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null]; 
      List<GCM_Case_Duration__c> trackersExpired = new List<GCM_Case_Duration__c>();
      for (GCM_Case_Duration__c trackerOld : trackersOld) {
        GCM_Case_Duration__c trackerExpired = new GCM_Case_Duration__c();
        trackerExpired.Id = trackerOld.Id;
      
        // Business Requirement: Set Orphaned Records End Time = Created Timestamp
        trackerExpired.GCM_End_Time__c = trackerOld.CreatedDate;
        trackersExpired.add(trackerExpired);
      }
      if (trackersExpired.size() > 0) update trackersExpired;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'clearTimer', (List<Id>) null, 'GCM_Application_Administrator');
    }
  }
  
/****************************************************************************************************
   Clean Up Open Timers When New Cases Are Abandoned 
 ****************************************************************************************************/
  @AuraEnabled  
  public static void NewCaseclearTimer() {
    try {
      // Stop All Timers
      List<GCM_Case_Duration__c> trackersOld = [select Id, CreatedDate, GCM_End_Time__c from GCM_Case_Duration__c where OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null and GCM_Case__c = null]; 
      List<GCM_Case_Duration__c> trackersExpired = new List<GCM_Case_Duration__c>();
      for (GCM_Case_Duration__c trackerOld : trackersOld) {
        GCM_Case_Duration__c trackerExpired = new GCM_Case_Duration__c();
        trackerExpired.Id = trackerOld.Id;
      
        // Business Requirement: Set Orphaned Records End Time = Created Timestamp
        trackerExpired.GCM_End_Time__c = trackerOld.CreatedDate;
        trackersExpired.add(trackerExpired);
      }
      if (trackersExpired.size() > 0) update trackersExpired;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'NewCaseclearTimer', (List<Id>) null, 'GCM_Application_Administrator');   
    }
  }

/****************************************************************************************************
  Called By Lightning Component onTabFocused, onTabUpdated Events
  Starts Timer
 ****************************************************************************************************/
  @AuraEnabled
  public static void startTimer(Id caseId) {
    try {
      if (isCaseOpen(caseId)) {
        // Stop Other Timers
        List<GCM_Case_Duration__c> trackersOld = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where GCM_Case__c != :caseId and OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null]; 
        List<GCM_Case_Duration__c> trackersExpired = new List<GCM_Case_Duration__c>();
        for (GCM_Case_Duration__c trackerOld : trackersOld) {
          GCM_Case_Duration__c trackerExpired = new GCM_Case_Duration__c();
          trackerExpired.Id = trackerOld.Id;
          trackerExpired.GCM_End_Time__c = Datetime.now();
          trackersExpired.add(trackerExpired);
        }
        if (trackersExpired.size() > 0) update trackersExpired;
    
        // Find Currently Tracked Case
        List<GCM_Case_Duration__c> trackers = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where GCM_Case__c = :caseId and GCM_End_Time__c = null];
        if (trackers.size() == 0) {
          GCM_Case_Duration__c tracker = new GCM_Case_Duration__c();
          tracker.GCM_Case__c = caseId;
          tracker.OwnerId = UserInfo.getUserId();
          insert tracker;
        }
      }
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'startTimer', new List<Id>{caseId}, 'GCM_Application_Administrator');
    }
  }

/****************************************************************************************************
  Called From Lightning Component tabClosed Event
  Stop Timer For Specific Cases
 ****************************************************************************************************/
  @AuraEnabled
  public static void stopTimerByCase(Id caseId) {
    try {
      if (isCaseOpen(caseId)) {
        List<GCM_Case_Duration__c> trackersNew = new List<GCM_Case_Duration__c>();
        List<GCM_Case_Duration__c> trackers = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where GCM_Case__c = :caseId and OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null];
        for (GCM_Case_Duration__c tracker : trackers) {
          GCM_Case_Duration__c trackerNew = new GCM_Case_Duration__c();
          trackerNew.Id = tracker.Id;
          trackerNew.GCM_End_Time__c = Datetime.now();
          trackersNew.add(trackerNew);
        }
        if (trackersNew.size() > 0) update trackersNew;
      }
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'stopTimerByCase', new List<Id>{caseId}, 'GCM_Application_Administrator');
    }
  }

/****************************************************************************************************
  Called From Case Trigger Handler
  Clock Stops When Cases Closed / Cancelled (Bulkified)
 ****************************************************************************************************/
  public static void stopTimerBulk(List<Case> cases, Map<Id, Case> oldMap) {
    try {   
      // Retrieve Case Ids
      List<Id> caseIds = new List<Id>();
      List<Id> reOpencaseIds = new List<Id>();
      List<GCM_Case_Duration__c> lstReopenCase = new List<GCM_Case_Duration__c>();
      for (Case thisCase : cases) {        
        if (thisCase.Status != oldMap.get(thisCase.Id).Status) {
          // Status = Closed OR Cancelled
          if (thisCase.Status == 'Closed' || thisCase.Status == 'Cancelled') {
            caseIds.add(thisCase.Id);
          }
        }

        // Start Timers For Reopened Cases
        if ((thisCase.Status != 'Closed' &&  thisCase.Status != 'Cancelled') &&  (oldMap.get(thisCase.Id).Status == 'Closed' || oldMap.get(thisCase.Id).Status == 'Cancelled' ) ) {
          GCM_Case_Duration__c tracker = new GCM_Case_Duration__c();
          tracker.GCM_Case__c = thisCase.Id;
          tracker.OwnerId = UserInfo.getUserId();
          lstReopenCase.add(tracker);
        }
      
        // Reassign Owner AND Owner NOT EQUAL Current User
        if (thisCase.OwnerId != oldMap.get(thisCase.Id).OwnerId) {
          if (thisCase.OwnerId != UserInfo.getUserId()) {
            caseIds.add(thisCase.Id);
          }
        }
      }
      
      // Insert Reopened Cases Timers
      if (lstReopenCase.size() > 0) insert lstReopenCase;
    
      // Find + Close Open Timers
      List<GCM_Case_Duration__c> trackersNew = new List<GCM_Case_Duration__c>();
      List<GCM_Case_Duration__c> trackers = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where GCM_Case__c in :caseIds and OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null];
      for (GCM_Case_Duration__c tracker : trackers) {
        GCM_Case_Duration__c trackerNew = new GCM_Case_Duration__c();
        trackerNew.Id = tracker.Id;
        trackerNew.GCM_End_Time__c = Datetime.now();
        trackersNew.add(trackerNew);
      }
      if (trackersNew.size() > 0) update trackersNew;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'stopTimerBulk', oldMap.keySet(), 'GCM_Application_Administrator');
    }
  }

/****************************************************************************************************
  Housekeeping
  Delete Timers Not Associated With Cases
 ****************************************************************************************************/
  public static void deleteOrphanNewCaseTimer() {
    try {
      List<GCM_Case_Duration__c> trackersOld = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null and GCM_Case__c = null]; 
      if (trackersOld.size() > 0) update trackersOld;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'deleteOrphanNewCaseTimer', (List<Id>) null, 'GCM_Application_Administrator');   
    }
  }

/****************************************************************************************************
  Starts Timer - Handles Scenario For New Cases - Case Id Not Available Yet
 ****************************************************************************************************/
  @AuraEnabled  
  public static void startNewCaseTimer() {
    try {
      // Stop Other Timers
      List<GCM_Case_Duration__c> trackersOld = [select Id, GCM_End_Time__c from GCM_Case_Duration__c where OwnerId = :UserInfo.getUserId() and GCM_End_Time__c = null]; 
      List<GCM_Case_Duration__c> trackersExpired = new List<GCM_Case_Duration__c>();
      for (GCM_Case_Duration__c trackerOld : trackersOld) {
        GCM_Case_Duration__c trackerExpired = new GCM_Case_Duration__c();
        trackerExpired.Id = trackerOld.Id;
        trackerExpired.GCM_End_Time__c = Datetime.now();
        trackersExpired.add(trackerExpired);
      }
      if (trackersExpired.size() > 0) update trackersExpired;

      GCM_Case_Duration__c tracker = new GCM_Case_Duration__c();
      tracker.OwnerId = UserInfo.getUserId();
      insert tracker;
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'startNewCaseTimer', (List<Id>) null, 'GCM_Application_Administrator');       
    }
  }

/****************************************************************************************************
  Stops Timer - New Case Record Scenario Only  
 ****************************************************************************************************/
  public static void stopNewCaseTimer(List<Case> cases) {
    try {    
      // Retrieve Case Ids
      List<Id> ownerIds = new List<Id>();
      Map<Id, Id> caseMap = new Map<Id, Id>();
      for (Case thisCase : cases) {
        if (thisCase.OwnerId != null && thisCase.Id != null){
          ownerIds.add(thisCase.OwnerId);
          caseMap.put(thisCase.OwnerId, thisCase.Id);
        }
      }
         
      // Find + Close Open Timers
      List<GCM_Case_Duration__c> trackersNew = new List<GCM_Case_Duration__c>();
      List<GCM_Case_Duration__c> trackers = [select Id, OwnerId, GCM_End_Time__c from GCM_Case_Duration__c where OwnerId in :ownerIds and GCM_End_Time__c = null];
      for (GCM_Case_Duration__c tracker : trackers) {
        GCM_Case_Duration__c trackerNew = new GCM_Case_Duration__c();
        trackerNew.Id = tracker.Id;
        if (caseMap.containsKey(tracker.OwnerId)) {
          trackerNew.GCM_Case__c = caseMap.get(tracker.OwnerId);
          trackerNew.GCM_End_Time__c = Datetime.now();
          trackersNew.add(trackerNew);
        }
      }
      if (trackersNew.size() > 0) update trackersNew;
    }
    catch (Exception exceptionObject) {   
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_C2S_Controller', 'stopNewCaseTimer', (List<Id>) null, 'GCM_Application_Administrator');       
    } 
  }
  
  /****************************************************************************************************
  Getting the case Id of the Case Duration Record for the current user where the end time is null
 ****************************************************************************************************/
	@AuraEnabled
    public static Id getCaseId(string UserId){
		
		list<GCM_Case_Duration__c> caseIds = new list <GCM_Case_Duration__c>([select GCM_Case__c,OwnerId,GCM_End_Time__c from GCM_Case_Duration__c where OwnerId=:UserId and GCM_End_Time__c=null limit 1]);
		system.debug(caseIds);
       
        Id CaseId;
        if(!caseIds.isempty()){
        for(GCM_Case_Duration__c GCD:caseIds){
            system.debug(GCD);
            CaseId=GCD.GCM_Case__c;            
        }
        }
        stopTimerByCase(CaseId);
        return CaseId;
        
		
	} 
        
}