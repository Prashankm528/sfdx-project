/************************************************************************************************************
* Description : Apex trigger for the Document Request object. This trigger will create the document store 
                records when the status is changed to Confirm details and record type of the list of values
                records is equal to risk status field.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2019-SEP-05   1.0                 Payal Ahuja        Initial version 
*
*************************************************************************************************************/

trigger DUP_DocumentRequestTrigger on DUP_Document_Request__c(before insert, before update, after update) 
{
    BPG_Trigger_Handler_Utilities.handleEvent('DUP_Document_Request__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
}