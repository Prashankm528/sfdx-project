/************************************************************************************************************
* Description : 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-Nov-28   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
trigger CALCF_SurveyQuestionResponse on SurveyQuestionResponse__c (before update) {

	// isBefore logic.
	if(trigger.isBefore){
		// isUpdate logic. 
		if(trigger.isUpdate){

			CALCF_SurveyQuestionResponseHandler.updateHideableResponse(trigger.new);
		}		
	}

}