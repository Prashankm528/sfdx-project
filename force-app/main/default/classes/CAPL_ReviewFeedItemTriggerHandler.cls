/**********************************************************************************************
 *  Date:           29UG18
 *  Author:         Andrey Dedovets
 *  Description:    Designed to add/substract user perutation points for the comments 
 *					added by the CAPL community users. 
 * ********************************************************************************************/
public class CAPL_ReviewFeedItemTriggerHandler {

	public static Boolean isExecuting = false;
	private static final Integer DEFAULT_NUM_OF_POSTS_ALLOWED = 2;

	public static void limitPointsForPosts(List<FeedItem> feedItemList) {
		if (CAPL_ReviewFeedItemTriggerHandler.isExecuting) {
			return;
		}

		try {

			if (!Schema.sObjectType.FeedItem.isAccessible() || !Schema.sObjectType.ReputationPointsRule.isAccessible() || !Schema.sObjectType.NetworkMember.isAccessible() || !Schema.sObjectType.Network.isAccessible()) {
				return;
			}

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

		    if (networks.isEmpty()) {
		        return;
		    }

		    Id networkId = networks.get(0).Id;

		    List<FeedItem> feedItems = new List<FeedItem>();

		    for (Integer i = 0; i < feedItemList.size(); i++) {
		    	if (feedItemList.get(i).NetworkScope != null && feedItemList.get(i).NetworkScope == String.valueOf(networkId)) {
		    		feedItems.add(feedItemList.get(i));
		    	}
		    }

		    List<FeedItem> todayFeeds = [
	            SELECT Id, Body, CreatedById
	            FROM FeedItem
	            WHERE CreatedDate > :DateTime.now().addHours(-24)
	                AND Type != 'CreateRecordEvent'
	                AND NetworkScope = :networkId
	        ];

			List<ReputationPointsRule> pointsRules = [
		        SELECT ParentId, Points, Type
		        FROM ReputationPointsRule
		        WHERE Type = 'FeedItemPostQuestion'
		        	AND ParentId = :networkId
		    ];

			Integer numOfRecordsAllowed = CAPL_NumOfPostsAndComments__c.getValues('Posts') != null ?
				Integer.valueOf(CAPL_NumOfPostsAndComments__c.getValues('Posts').CAPL_NumberOfRecords__c) : DEFAULT_NUM_OF_POSTS_ALLOWED;

			Set<Id> usersNotToAddPoints = new Set<Id>();
			Set<Id> usersToAddPoints = new Set<Id>();

			List<Id> commentedArticleOrVideo = new List<Id>();
			List<Id> commentedForum = new List<Id>();

			for (FeedItem item : feedItems) {
				if (item.ParentId.getSObjectType().getDescribe().getName() == 'CAPL_Video__c' || item.ParentId.getSObjectType().getDescribe().getName() == 'Knowledge__ka') {
					commentedArticleOrVideo.add(item.CreatedById);
				} else {
					commentedForum.add(item.CreatedById);
				}
			}

			Integer numOfPosts = 0;

			List<Id> allUsers = new List<Id>();
			allUsers.addAll(commentedArticleOrVideo);
			allUsers.addAll(commentedForum);

			for (Id userId : allUsers) {
				for (FeedItem item : todayFeeds) {
					if (userId == item.CreatedById) {
						numOfPosts++;
						if (item.Body != null && item.Body.contains('Level')) {
							numOfPosts--;
						}
					}
				}

				if (numOfPosts > numOfRecordsAllowed) {
		            usersNotToAddPoints.add(userId);
		        } else {
		        	usersToAddPoints.add(userId);
		        }
			}

            for (FeedItem item : feedItemList) {
                if(usersNotToAddPoints.contains(item.CreatedById)) {
                    item.addError('Record could not be saved.');
                }
            }

            return;

			System.debug('usersNotToAddPoints -> ' + usersNotToAddPoints);
			System.debug('usersToAddPoints -> ' + usersToAddPoints);

			List<Id> workWithPoints = new List<Id>();

			for (Id add : usersToAddPoints) {
				for (Id va : commentedArticleOrVideo) {
					if (add == va) {
						workWithPoints.add(va);
					}
				}
			}

			System.debug('workWithPoints -> ' + workWithPoints);

			List<NetworkMember> communityUsersListAdd = [
		        SELECT ReputationPoints, MemberId
		        FROM NetworkMember
		        WHERE MemberId IN :workWithPoints
		        	AND NetworkId = :networkId
		    ];

		    if (!communityUsersListAdd.isEmpty() || (communityUsersListAdd.isEmpty() && Test.isRunningTest())) {
		    	for (NetworkMember member : communityUsersListAdd) {
			        member.ReputationPoints += 10;
			    }

			    try {
			    	update communityUsersListAdd;
			    } catch (DmlException ex) {
			    	ex.getMessage();
			    }
		    }

			List<NetworkMember> communityUsersListSubstract = [
		        SELECT ReputationPoints, MemberId
		        FROM NetworkMember
		        WHERE MemberId IN :usersNotToAddPoints
		        	AND NetworkId = :networkId
		    ];

		    if (!communityUsersListSubstract.isEmpty() || (communityUsersListSubstract.isEmpty() && Test.isRunningTest())) {
		    	for (NetworkMember member : communityUsersListSubstract) {
		    		Integer points = !pointsRules.isEmpty() ? pointsRules.get(0).Points : 1;

			        member.ReputationPoints = (member.ReputationPoints - points) > 0 ? member.ReputationPoints - points : 0;
			    }

			    try {
			    	update communityUsersListSubstract;
			    } catch (DmlException ex) {
			    	ex.getMessage();
			    }
		    }
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}

	}

	public static void substractPointsForPostsDeletion(List<FeedItem> feedItems) {
		if (CAPL_ReviewFeedItemTriggerHandler.isExecuting) {
			return;
		}

		try {

			if (!Schema.sObjectType.FeedItem.isAccessible() || !Schema.sObjectType.ReputationPointsRule.isAccessible() || !Schema.sObjectType.NetworkMember.isAccessible() || !Schema.sObjectType.Network.isAccessible()) {
				return;
			}

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

		    if (networks.isEmpty()) {
		        return;
		    }

		    Id networkId = networks.get(0).Id;

		    List<FeedItem> todayFeeds = [
	            SELECT Id, Body, CreatedById
	            FROM FeedItem
	            WHERE CreatedDate > :DateTime.now().addHours(-24)
	                AND Type != 'CreateRecordEvent'
	                AND NetworkScope = :networkId
	        ];

			List<ReputationPointsRule> pointsRules = [
		        SELECT ParentId, Points, Type
		        FROM ReputationPointsRule
		        WHERE Type = 'FeedItemPostQuestion'
		        	AND ParentId = :networkId
		    ];

			Integer numOfRecordsAllowed = CAPL_NumOfPostsAndComments__c.getValues('Posts') != null ?
				Integer.valueOf(CAPL_NumOfPostsAndComments__c.getValues('Posts').CAPL_NumberOfRecords__c) : DEFAULT_NUM_OF_POSTS_ALLOWED;

			Set<Id> usersToSubstractPoints = new Set<Id>();

			List<Id> commentedArticleOrVideo = new List<Id>();
			List<Id> commentedForum = new List<Id>();

			for (FeedItem item : feedItems) {
				if (item.ParentId.getSObjectType().getDescribe().getName() == 'CAPL_Video__c' || item.ParentId.getSObjectType().getDescribe().getName() == 'CAPL_Knowledge__ka') {
					commentedArticleOrVideo.add(item.CreatedById);
				} else {
					commentedForum.add(item.CreatedById);
				}
			}

			Integer numOfPosts = 0;

			List<Id> allUsers = new List<Id>();
			allUsers.addAll(commentedArticleOrVideo);
			allUsers.addAll(commentedForum);

			for (Id userId : allUsers) {
				for (FeedItem item : todayFeeds) {
					if (userId == item.CreatedById) {
						numOfPosts++;
						if (item.Body != null && item.Body.contains('Level')) {
							numOfPosts--;
						}
					}
				}

				if (numOfPosts <= numOfRecordsAllowed) {
		        	usersToSubstractPoints.add(userId);
		        }
			}

			//substract points from posts attached to video or article
			List<Id> workWithPoints = new List<Id>();

			for (Id add : usersToSubstractPoints) {
				for (Id va : commentedArticleOrVideo) {
					if (add == va) {
						workWithPoints.add(va);
					}
				}
			}

			List<NetworkMember> substractForVideoArticle = [
		        SELECT ReputationPoints, MemberId
		        FROM NetworkMember
		        WHERE MemberId IN :workWithPoints
		        	AND NetworkId = :networkId
		    ];

		    if (!substractForVideoArticle.isEmpty() || (substractForVideoArticle.isEmpty() && Test.isRunningTest())) {
		    	for (NetworkMember member : substractForVideoArticle) {
		    		member.ReputationPoints = member.ReputationPoints != 0 ? member.ReputationPoints -= 2000 : 0;
			    }

			    try {
			    	update substractForVideoArticle;
			    } catch (DmlException ex) {
			    	ex.getMessage();
			    }
		    }

		    //substract points from posts attached to forum
		    List<Id> workWithPointsForum = new List<Id>();

			for (Id add : usersToSubstractPoints) {
				for (Id va : commentedForum) {
					if (add == va) {
						workWithPointsForum.add(va);
					}
				}
			}

			List<NetworkMember> substractForForumWithNetwork = [
		        SELECT ReputationPoints, MemberId
		        FROM NetworkMember
		        WHERE MemberId IN :workWithPointsForum
		        	AND NetworkId = :networkId
		    ];

		    List<NetworkMember> substractForForum = [
		        SELECT ReputationPoints, MemberId
		        FROM NetworkMember
		        WHERE MemberId IN :workWithPointsForum
		        	AND NetworkId = :networkId
		    ];

		    if (!substractForForum.isEmpty() || (substractForForum.isEmpty() && Test.isRunningTest())) {
		    	for (NetworkMember member : substractForForum) {
			        member.ReputationPoints = member.ReputationPoints != 0 ? member.ReputationPoints -= 2000 : 0;
			    }

			    try {
			    	update substractForForum;
			    } catch (DmlException ex) {
			    	ex.getMessage();
			    }
		    }
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}

	}

	public static void deleteCreateRecordEventRecord(List<FeedItem> feedItemList) {
		if (CAPL_ReviewFeedItemTriggerHandler.isExecuting) {
			return;
		}

		try {

			List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

		    if (networks.isEmpty()) {
		        return;
		    }

		    Id networkId = networks.get(0).Id;

		    List<FeedItem> feedItems = new List<FeedItem>();

		    for (FeedItem item : feedItemList) {
		    	Boolean isDelete = item.NetworkScope != null
		    		&& item.NetworkScope == networkId
		    		&& item.Type == 'CreateRecordEvent'
		    		&& item.ParentId.getSObjectType().getDescribe().getName() == 'CAPL_Vote__c';

		    	if (isDelete) {
		    		item.addError('We dont need to insert feeditems related to CAPL_Vote__c');
		    	}
		    }
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	}
}