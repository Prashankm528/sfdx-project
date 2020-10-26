public with sharing class CAPL_TermsAndConditions {

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