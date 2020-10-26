/************************************************************************************************************
*Description : Wrapper for a-synch method.In wrapper needed to be Invocable Method.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-FEB-28   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

public with sharing class clsOptOutNewRecordWrapper {
	
	@InvocableMethod
    public static void invokeOptOut(list<string> contactId) {
    	
     CALCF_OptOutHelper.newRecordCreated(contactId[0]);
   }
    
}