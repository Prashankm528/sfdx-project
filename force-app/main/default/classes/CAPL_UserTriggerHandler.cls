public with sharing class CAPL_UserTriggerHandler {

	public static Boolean isExecuting = false;

	public static void setPointsForProfile(List<User> usersList, Map<Id, User> oldUsersMap) {
		if (CAPL_UserTriggerHandler.isExecuting) {
			return;
		}
        
		try{

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

			if (networks.isEmpty()) {
				return;
			}

			List<NetworkMember> communityUsersList = [
				SELECT ReputationPoints, MemberId
				FROM NetworkMember
				WHERE MemberId IN :usersList
					AND NetworkId = :networks.get(0).Id
			];
            
            if (communityUsersList.isEmpty()) {
                return;
            }
            

			//Map<Id, User> oldUsersMap = new Map<Id, User>(oldUsersList);

			List<NetworkMember> communityUsersListToUpdate = new List<NetworkMember>();

			Map<Id, NetworkMember>  communityUsersMap = new Map<Id, NetworkMember>();

			for (NetworkMember member : communityUsersList) {
				communityUsersMap.put(member.MemberId, member);
			}

			List<CAPL_IsUserProfileFilled__c> usersProfileList = new List<CAPL_IsUserProfileFilled__c>();

			for (User u : usersList) {
				if (communityUsersMap.get(u.Id) != null) {
					CAPL_IsUserProfileFilled__c userProfile = new CAPL_IsUserProfileFilled__c();

					if (CAPL_IsUserProfileFilled__c.getValues(u.Id) != null) {
						userProfile = CAPL_IsUserProfileFilled__c.getValues(u.Id);
					} else {
						userProfile = new CAPL_IsUserProfileFilled__c(SetupOwnerId = u.Id);
					}


					NetworkMember member = communityUsersMap.get(u.Id);
					Boolean isUpdate = false;

					User oldUser = oldUsersMap.get(u.Id);

					if (u.CAPL_Location__c != oldUser.CAPL_Location__c && userProfile.Address__c == false) {
						//member.ReputationPoints += 10;
						isUpdate = true;

						userProfile.Address__c = true;
					}

					if (u.IsProfilePhotoActive == true  && userProfile.Photo__c == false) {
						member.ReputationPoints += 1000;
						isUpdate = true;

						userProfile.Photo__c = true;
					}

					if (u.CAPL_Birthdate__c != oldUser.CAPL_Birthdate__c && userProfile.Birthday__c == false) {
						member.ReputationPoints += 500;
						isUpdate = true;

						userProfile.Birthday__c = true;
					}
					if (u.CAPL_Job_Role__c != oldUser.CAPL_Job_Role__c && userProfile.JobRole__c == false) {
						member.ReputationPoints += 500;
						isUpdate = true;

						userProfile.JobRole__c = true;
					}

					if (isUpdate) {
						communityUsersListToUpdate.add(member);
					}

					usersProfileList.add(userProfile);
				}
			}

			try {
				upsert usersProfileList;
			} catch (DmlException ex) {
				ex.getMessage();
			}

			System.debug('communityUsersListToUpdate -> ' + communityUsersListToUpdate);

			try {
				update communityUsersListToUpdate;
			} catch (DmlException ex) {
				ex.getMessage();
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}

	}

	public static void setPointsForRegistration(List<User> usersList) {
		if (CAPL_UserTriggerHandler.isExecuting) {
			return;
		}

		try{

			List<User> users = [
				SELECT Id, Profile.Name
				FROM User
				WHERE Id IN :usersList
					AND  Id IN (
			    		SELECT AssigneeId
			    		FROM PermissionSetAssignment
			    		WHERE PermissionSet.Name = 'CAPL_CommunityPermission'
		    		)
			];
            
            if (users.isEmpty()) {
                return;
            }

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

			if (networks.isEmpty()) {
				return;
			}

			if (!users.isEmpty()) {
				List<NetworkMember> communityUserList = [
		            SELECT Id, ReputationPoints
		            FROM NetworkMember
		            WHERE MemberId IN :users
		            	AND NetworkId = :networks.get(0).Id
		        ];

		        for (NetworkMember member : communityUserList) {
		        	member.ReputationPoints += 1499;
		        	member.PreferencesDisableBookmarkEmail = true;
		        	member.PreferencesDisableDirectMessageEmail = true;
		        	member.PreferencesDisableEndorsementEmail = true;
		        	member.PreferencesDisableFollowersEmail = true;
		        	member.PreferencesDisableItemFlaggedEmail = true;
		        	member.PreferencesDisableLaterCommentEmail = true;
		        	member.PreferencesDisableLikeEmail = true;
		        	member.PreferencesDisableMentionsPostEmail = true;
		        	member.PreferencesDisableProfilePostEmail = true;
		        	member.PreferencesDisableSharePostEmail = true;
		        	member.PreferencesDisMentionsCommentEmail = true;
		        	member.PreferencesDisProfPostCommentEmail = true;
		        }

		        try {
	                update communityUserList;
	            } catch (DmlException ex) {
	                ex.getMessage();
	            }
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	}

	public static void addUsersToForumGroups(List<User> usersList) {
		if (CAPL_UserTriggerHandler.isExecuting) {
			return;
		}

		try {

			List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

			if (networks.isEmpty()) {
				return;
			}

			List<CollaborationGroup> existingGroups = [
				SELECT Id, Description, InformationBody
				FROM CollaborationGroup
				WHERE CollaborationType = 'Unlisted'
					AND NetworkId = :networks.get(0).Id
				LIMIT 10000
			];

			for (User u : usersList) {
				for (CollaborationGroup gr : existingGroups) {
					if (gr.InformationBody != null && gr.InformationBody.contains(u.LanguageLocaleKey)) {
						newMembers.add (
							new CollaborationGroupMember (
								CollaborationGroupId = gr.Id,
								MemberId = u.Id
							)
						);
					}
				}
			}

			try {
				insert newMembers;
			} catch (DmlException ex) {
				ex.getMessage();
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	}
}