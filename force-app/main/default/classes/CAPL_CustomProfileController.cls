/**********************************************************************************************
 *  Date:           29UG18
 *  Author:         Andrey Dedovets
 *  Description:    Designed to retrieve User settings like Profile Photo, ChatterActivity, 
 *					Reputation. Also User can change Photo and its data.
 * ********************************************************************************************/
public with sharing class CAPL_CustomProfileController {
	
	@auraEnabled
	public static String fetchUserProfilePhoto(String userId) {
		List<User> usersList = [
			SELECT SmallPhotoUrl, FullPhotoUrl 
            FROM User 
            WHERE id = :userId
        ];

        if (!usersList.isEmpty()) {
        	return usersList.get(0).FullPhotoUrl;
        } else {
        	return '';
        }
	}

	@auraEnabled
	public static void uploadUserPhoto(String imageBody, String imageName, String imageFormat) {

		Blob convertedImage = EncodingUtil.base64Decode(imageBody);

		if(!Test.isRunningTest()){
			ConnectApi.BinaryInput photo = new ConnectApi.BinaryInput(convertedImage, imageFormat, imageName);

			ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), UserInfo.getUserId(), photo);
		}

		Set<CAPL_IsUserProfileFilled__c> usersProfileList = new Set<CAPL_IsUserProfileFilled__c>();

		List<NetworkMember> communityUsers = [
			SELECT ReputationPoints, MemberId
			FROM NetworkMember
			WHERE MemberId = :UserInfo.getUserId()
				AND NetworkId = :Network.getNetworkId()
		];

		if (!communityUsers.isEmpty() || (communityUsers.isEmpty() && Test.isRunningTest())) {

			NetworkMember member = !communityUsers.isEmpty() ? communityUsers.get(0) : new NetworkMember();
			CAPL_IsUserProfileFilled__c userProfile;

			if (CAPL_IsUserProfileFilled__c.getValues(member.MemberId) != null) {
				userProfile = CAPL_IsUserProfileFilled__c.getValues(member.MemberId);
			} else {
				userProfile = new CAPL_IsUserProfileFilled__c(SetupOwnerId = member.MemberId);
			}

			if (userProfile.Photo__c == false) {
				if (!Test.isRunningTest()) {
					member.ReputationPoints += 1000;
				}
				userProfile.Photo__c = true;
			}

			usersProfileList.add(userProfile);
		}

		Database.update(communityUsers, false);

		List<CAPL_IsUserProfileFilled__c> usersCustomSetting = new List<CAPL_IsUserProfileFilled__c>(usersProfileList);

		try {
			upsert usersCustomSetting;
		} catch (DmlException ex) {
			ex.getMessage();
		}
	}

	@auraEnabled
	public static String fetchUserId() {
		return UserInfo.getUserId();
	}

	@auraEnabled
	public static ChatterActivity fetchUserChatterActivity(String userId) {

		List<ChatterActivity> usersList = [
			SELECT CommentCount, CommentReceivedCount, InfluenceRawRank,
				LikeReceivedCount, PostCount
            FROM ChatterActivity 
            WHERE NetworkId = :Network.getNetworkId()
            	AND ParentId = :userId
        ];

        if (!usersList.isEmpty()) {
        	return usersList.get(0);
        } else {
        	return new ChatterActivity();
        }
	}

	@auraEnabled
	public static ConnectApi.Reputation fetchUserReputation(String userId) {
		ConnectApi.Reputation userReputation;

		if(!Test.isRunningTest()){
			userReputation = ConnectApi.ChatterUsers.getReputation(Network.getNetworkId(), userId);
		}

		return userReputation;
	}

	@auraEnabled
	public static User fetchUserInfo(String userId) {
		List<User> usersList = [
			SELECT Name, AboutMe, MobilePhone, Phone, Email,
				CAPL_Job_Role__c, CAPL_Location__c, CAPL_Birthdate__c, CAPL_OEM_Brand__c
            FROM User 
            WHERE id = :userId
        ];

        if (!usersList.isEmpty()) {
        	return usersList.get(0);
        } else {
        	return null;
        }
	}

	@auraEnabled
	public static Integer fetchUserFollowers(String userId) {

        List<EntitySubscription> followers = [
        	SELECT id
            FROM EntitySubscription
            WHERE Parentid = :userId
            LIMIT 1000
        ];
 
        return followers.size();
	}

	@auraEnabled
	public static void saveUserChanges(User userObject) {
		update userObject;
	}

	@auraEnabled
	public static List<String> fetchOEMBrandValues() {
		List<String> result = new List<String>();        
        List<Schema.PicklistEntry> statusValues = User.CAPL_OEM_Brand__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry o : statusValues) {                                        
            result.add(o.getValue());
        } 

        return result;
	}
}