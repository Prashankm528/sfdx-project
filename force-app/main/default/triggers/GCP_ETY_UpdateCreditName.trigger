/*****************************************************************************************
*   Date:         18/10/2019
*   Author:       Subin M Nair
*   Description:  Trigger to pass the Credit Entity record to GCP_ETY_UpdateCreditNameHandler class
*   Test Class :  GCP_ETY_UpdateCreditNameHandlerTest
****************************************************************************************/
trigger GCP_ETY_UpdateCreditName on GCP_ETY_Credit_Entity__c (after insert, after update) {

if(Trigger.isafter && (Trigger.isInsert || Trigger.IsUpdate) && GCP_ETY_UpdateCreditNameHandler.avoidRecursion())
 {
    GCP_ETY_UpdateCreditNameHandler.updateName(trigger.new);
 }
}