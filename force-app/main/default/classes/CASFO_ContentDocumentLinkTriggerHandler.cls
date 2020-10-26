/*****************************************************************************************
*	Date:		    03-Aug-2020
*   Author:         Jit Patel - SFO 
*   Description:    SFO ContentDocumentLink trigger handler 
****************************************************************************************/
public with sharing class CASFO_ContentDocumentLinkTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    /*
    * process ContentDocumentLink records after insert  
    */     
    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CASFO_FillNoteTitle fillNoteTitle = new CASFO_FillNoteTitle((Map<Id, ContentDocumentLink>) newMap);
        fillNoteTitle.fillNoteTitle();        
    }
}