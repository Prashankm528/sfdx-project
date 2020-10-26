/************************************************************************************************************
* Description : 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-Nov-28   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

public class CALCF_SurveyQuestionResponseHandler{

	public static void updateHideableResponse(list<SurveyQuestionResponse__c> responses){

		if(responses == null){
			return;
		}

		for(SurveyQuestionResponse__c response : responses){

			if(response.lcf_Hide_Response__c == true){
				response.lcf_Hideable_Response__c = '';
			}

			if(response.lcf_Hide_Response__c == false){
				response.lcf_Hideable_Response__c = response.Response__c;
			}
		}
	}
}