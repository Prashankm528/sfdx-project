/************************************************************************************************************
* Description : Trigger will update survey time according to timezone of contact. 
*Survey must be send at 3pm of local time for each contact.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-11   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
trigger CALCF_SurveyTakerTrigger on SurveyTaker__c (before insert) {
	
	// isBefore logic.
	if(trigger.isBefore){
		// isInsert logic. 
		if(trigger.isInsert){
			
			Set<Id> contactIdSet = new Set<Id>();
			for(SurveyTaker__c st : trigger.new){
    			contactIdSet.add(st.Contact__c);
			}
			
			// Query for timezones.  
			Map<Id, Contact> ContactTimezoneMap = new Map<Id, Contact>([SELECT TimeZone__c FROM Contact WHERE Id IN :contactIdSet]); 
    	
        	// Handler will update SurveyTime for each SurveyTaker__c according to its contact timezone. 
        	CALCF_SurveyTakerUpdateTimeHandler.updateSurveyTimeAccordingToContact(trigger.new, ContactTimezoneMap);

		}		
	}   
}