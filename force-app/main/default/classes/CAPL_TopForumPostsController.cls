public without sharing class CAPL_TopForumPostsController {

    static final String CAPL_PERMISSION_NAME = 'CAPL_CommunityPermission';

    public class FeedWrapper implements Comparable {
		@AuraEnabled 
		public String userPhotoURL {get; set;}
		@AuraEnabled 
		public FeedItem post {get; set;}

		public FeedWrapper(String photo, FeedItem obj) {
			userPhotoURL = photo;
			post = obj;
		}

        public Integer compareTo(Object compareTo) {
            FeedWrapper compareToEmp = (FeedWrapper)compareTo;
            if (post.CommentCount < compareToEmp.post.CommentCount) return 1;
            if (post.CommentCount > compareToEmp.post.CommentCount) return -1;
            return 0;        
        }
	}

	/*
	* used to fetch 5 top commented posts
	*/

	@AuraEnabled
    public static List<FeedWrapper> fetchForumPosts() {
        List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        if (networks.isEmpty()) {
            return null;
        }

    	Set<Id> usersIds = new Set<Id>();

        List<FeedItem> knowledgePosts = [
            SELECT ID, Title, Type, Body, ParentId, CreatedBy.Name, CreatedBy.Id, CreatedDate, LikeCount, CommentCount, NetworkScope
            FROM FeedItem 
            WHERE Type != 'CreateRecordEvent'
                AND Type != 'TrackedChange'
                AND CreatedById IN (
                    SELECT AssigneeId 
                    FROM PermissionSetAssignment 
                    WHERE PermissionSet.Name = :CAPL_PERMISSION_NAME
                )
            ORDER BY CommentCount DESC 
            LIMIT 10
        ];

        List<FeedItem> posts = [
            SELECT ID, Title, Type, Body, CreatedBy.Name, CreatedBy.Id, CreatedDate, LikeCount, CommentCount, NetworkScope
            FROM FeedItem 
            WHERE Type != 'CreateRecordEvent'
                AND Type != 'TrackedChange'
                AND NetworkScope = :networks.get(0).Id
            ORDER BY CommentCount DESC 
            LIMIT 10
        ];

        Set<FeedItem> filteredPosts = new Set<FeedItem>();

        filteredPosts.addAll(knowledgePosts);
        filteredPosts.addAll(posts);

    	for (FeedItem item : filteredPosts) {
    		usersIds.add(item.CreatedBy.Id);
    	}

    	List<User> usersList = [
    		SELECT SmallPhotoUrl 
    		FROM User 
    		WHERE Id IN :usersIds
    	];

    	List<FeedWrapper> wrapperList = new List<FeedWrapper>();

    	for (FeedItem item : filteredPosts) {
    		for (User u : usersList) {
    			if (item.CreatedBy.Id == u.Id && wrapperList.size() < 5) {
                    if (item.Type == 'TextPost' && item.Body != null && item.Body.contains('Level')) {
                        continue;
                    } else {
                        wrapperList.add(new FeedWrapper(u.SmallPhotoUrl, item));
                    }
    			}
    		}
    	}

        wrapperList.sort();

    	System.debug(wrapperList);

    	return wrapperList;
    }
}