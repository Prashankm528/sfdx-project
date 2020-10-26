public with sharing class CAPL_ForumGuidelineClass {

	@AuraEnabled
	public static Boolean agreeWithGuideline(Boolean isAgree) {
		User communityUser = [
            SELECT CAPL_IsForumGuidelineChecked__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        communityUser.CAPL_IsForumGuidelineChecked__c = isAgree;

        try {
        	update communityUser;
        	return true;
        } catch (DmlException ex) {
        	return false;
        }
	}

	@AuraEnabled
	public static String fetchUserLanguage() {
		User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];

		if (u != null) {
			return u.LanguageLocaleKey;
		} else {
			return 'en_US';
		}

	}
}