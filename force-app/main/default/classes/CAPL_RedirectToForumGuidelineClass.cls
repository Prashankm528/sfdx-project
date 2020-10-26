public with sharing class CAPL_RedirectToForumGuidelineClass {
	
	@AuraEnabled
	public static Boolean redirectToForumGuideline() {
		User communityUser = [
            SELECT CAPL_IsForumGuidelineChecked__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (communityUser.CAPL_IsForumGuidelineChecked__c == true) {
            return false;
        } else {
            return true;
        }
	}


}