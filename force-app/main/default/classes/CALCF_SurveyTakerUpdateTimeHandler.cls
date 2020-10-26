/************************************************************************************************************
* Description : Handler which will calculate survey time according to Contact timezone.
* Survey time needs to be 3pm of local time for each contact. 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JAN-11   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

public class CALCF_SurveyTakerUpdateTimeHandler {
	
	// Property to set DateTime.Now in way that it could be tested.	    
	@testVisible
   	private static DateTime NOW {
        get {
            if (NOW == null) {
            	datetime current = system.now();
                NOW = DateTime.newInstanceGmt(current.dateGMT(), current.timeGmt());
            }

            return NOW;
        }   
        private set;
    }
	
	 public static void updateSurveyTimeAccordingToContact(list<SurveyTaker__c> newSurveys, Map<Id, Contact> contactTimezoneMap){
	 	
	 	if(newSurveys == null || contactTimezoneMap == null){
	 			return;
	 	}
	 		
	 	for(SurveyTaker__c survey : newSurveys){
	 		
	 		Contact surveyContact = contactTimezoneMap.get(survey.Contact__c);
	 		
	 		if(surveyContact == null){
	 			continue;
	 		}
	 		
	 		if(surveyContact.TimeZone__c != null){	 			
	
	 			String timeZone = String.valueOf(surveyContact.TimeZone__c);
	 			 		
	 			if(!String.isEmpty(timeZone)){
	 				// Update Survey time according to contact timezone
	 				survey.Survey_Time__c = DetermineSurveyTime(timeZone);
	 			}	
	 		}
	 	}
	 }
	 
	 /************************************************************************************************************
	 * This parser will return string containing number of hours which needs to be added to GMT with sign + or -
	 *************************************************************************************************************/
	 private static String GetHoursFromTimezone(String timezone){

		String timeShift;	
		if(timezone.startsWith('(GMT)')){
				
			// If the time zone is GMT return 0 hour and 0 minutes as a time shift
			return '+00.00';
			}
			else{

			// Parse timezone to find what time shift needs to be add 
			timeShift = timezone.remove('(GMT').left(6);
			timeShift = timeShift.replace(':', '.');
			return timeShift;	
			}
	 }
	 
	 /************************************************************************************************************
	 * Method will determine at what time (in GMT) survey needs to be send, so all surveys will be sent at 3pm of local time.
	 *************************************************************************************************************/
	 private static DateTime DetermineSurveyTime(String timezone){
	 	
	 	String timeZoneDifference = GetHoursFromTimezone(timeZone);
	 	Datetime todaysDateTime = NOW;
	 	// 3pm at GMT
	 	Datetime surveyDateTime = Datetime.newInstanceGmt(todaysDateTime.yearGmt(),todaysDateTime.monthGmt(),todaysDateTime.dayGmt(),15,0,0);
	 		
	 	if(timeZoneDifference != null && timeZoneDifference.length() == 6){
	 		
	 		// How many hours the difference contains ?
	 		Integer hoursDifference = Integer.valueOf(timeZoneDifference.substring(1,3));
	 		// How many minutes the difference contains ?
	 		Integer minutesDiffrence = Integer.valueOf(timeZoneDifference.substring(4,6));
	 		
	 		// Branch for case that we need add to GMT.
	 		if(timeZoneDifference.left(1) == '-'){
	 			surveyDateTime = surveyDateTime.addHours(hoursDifference);
	 			surveyDateTime = surveyDateTime.addMinutes(minutesDiffrence);
	 		}
	 			else{
	 				// Branch for case that we need to lower GMT.	 				
	 				if(timeZoneDifference.left(1) == '+'){
	 					surveyDateTime = surveyDateTime.addHours(-hoursDifference);
	 					surveyDateTime = surveyDateTime.addMinutes(-minutesDiffrence);
	 				}
	 			}
	 	}
	 	
	 	// If survey needs to be sent today.
	 	if(surveyDateTime < todaysDateTime){
	 		return Datetime.newInstanceGmt(surveyDateTime.yearGmt(),surveyDateTime.monthGmt(),surveyDateTime.addDays(1).dayGmt(), surveyDateTime.hourGmt(), surveyDateTime.minuteGmt(),0);
	 	}
	 	// If survey needs to be sent tomorrow.
	 	else{
	 		return Datetime.newInstanceGmt(surveyDateTime.yearGmt(),surveyDateTime.monthGmt(),surveyDateTime.dayGmt(), surveyDateTime.hourGmt(), surveyDateTime.minuteGmt(),0);
	 	}	 	
	 }    		 	
}