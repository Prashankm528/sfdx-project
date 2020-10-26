public with sharing class CAPL_EmailNotificationsClass {

	@AuraEnabled
    public static String fetchUserId() {
    	return UserInfo.getUserId();
    }

	@AuraEnabled
	public static NetworkMember fetchEmailNotifications() {
		NetworkMember member = [
            SELECT PreferencesDisableAllFeedsEmail, PreferencesDisableBookmarkEmail,
            PreferencesDisableChangeCommentEmail, PreferencesDisableDirectMessageEmail,
            PreferencesDisableEndorsementEmail, PreferencesDisableFollowersEmail,
            PreferencesDisableItemFlaggedEmail, PreferencesDisableLaterCommentEmail,
            PreferencesDisableLikeEmail, PreferencesDisableMentionsPostEmail,
            PreferencesDisableProfilePostEmail,PreferencesDisableSharePostEmail,
            PreferencesDisMentionsCommentEmail, PreferencesDisProfPostCommentEmail,
            ReputationPoints 
            FROM NetworkMember 
            WHERE MemberId = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.debug('member -> ' + member);

        return member;
	}

	@AuraEnabled
	public static void updateEmailNotifications(NetworkMember member) {
		try {
			update member;
		} catch (DmlException ex) {
			ex.getMessage();
		}
	}
}