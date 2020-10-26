/****************************************************************************************************
*  Date          : 29-JAN-2020
*  Author        : Roselin Hephzibah
*  Description   : GCM_WDEEmailMessageController
*  Modifications : 29-JAN-2020 Roselin - Initial version.
****************************************************************************************************/   
public with sharing class GCM_WDEEmailMessageController {  
     private ApexPages.StandardController standardController;
     public static Task emailTaskRec{get{
         List<Id> idList = new List<Id>();
         try{
             Task t = [Select Id, GCM_Account__r.Name, Who.Name, softphone_it__IWS_Interaction_ID__c, WhatId, status, GCM_Interaction_Mark_Done__c, Type, CallType from Task Where GCM_Email_Message_Id__c =: apexpages.currentpage().getparameters().get('id') AND softphone_it__IWS_Interaction_ID__c != null and RecordType.Developername =: 'GCM_Task' LIMIT 1];
        	 idList.add(t.Id);
             return t;
         }catch(Exception e){	BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_LinkInteractionDetails', 'taskRec', idList, 'GCM_Business_Administrator');	} return null;
        
     }set;}

     
/****************************************************************************************************
  GCM_WDEEmailMessageController parameterized constructor.
 ****************************************************************************************************/
    public GCM_WDEEmailMessageController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        EmailMessage emsg = (EmailMessage)standardController.getRecord();
    }

/****************************************************************************************************
  Custom Method for Page load
 ****************************************************************************************************/    
    public void pageLoad() {  } 

}