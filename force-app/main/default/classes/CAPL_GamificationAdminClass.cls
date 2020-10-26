public with sharing class CAPL_GamificationAdminClass {

	public List<CommunityUser> communityUserList {get; set;}
	private Network community {get; set;}

	public CAPL_GamificationAdminClass() {
		fetchCommunityUsers();
	}

	public class CommunityUser {
		public Decimal reputationPoints {get; set;}
		public User communityUser {get; set;}

		public CommunityUser(Decimal points, User u) {
			reputationPoints = points;
			communityUser = u;
		}
	}

	/*
	* used to fetch CAPL community users info
	*/

	public void fetchCommunityUsers() {
		communityUserList = new List<CommunityUser>();

		community = [
			SELECT id, Name 
			FROM Network 
			WHERE Name LIKE 'CAPL%'
			LIMIT 1
		];

		List<NetworkMember> communityUsersList = new List<NetworkMember>();

	    if (community != null) {
	    	communityUsersList = [
		        SELECT ReputationPoints, MemberId 
		        FROM NetworkMember
		        WHERE NetworkId = :community.Id
		        LIMIT 50000
		    ];

	    } else {
	    	communityUsersList = [
		        SELECT ReputationPoints, MemberId 
		        FROM NetworkMember
		        LIMIT 50000
		    ];
	    }

	    Map<Id, Decimal> usersMap = new Map<Id, Decimal>();

	    for (NetworkMember member : communityUsersList) {
	    	usersMap.put(member.MemberId, member.ReputationPoints);
	    }

	    List<User> usersList = [
	    	SELECT Name, LastLoginDate, Email 
	    	FROM User
	    	WHERE Id IN 
    		(
	    		SELECT AssigneeId
	    		FROM PermissionSetAssignment
	    		WHERE PermissionSet.Name = 'CAPL_CommunityPermission' 
    		)
    		LIMIT 50000
	    ];

	    for (User u : usersList) {
	    	if (usersMap.get(u.Id) != null) {
	    		communityUserList.add(new CommunityUser(usersMap.get(u.Id), u));
	    	}
 	    }
	}

	/*
	* used to add reputation points to selected CAPL community user
	*/

	public void addReputationPoints() {
		String userId = ApexPages.currentPage().getParameters().get('userId');
		String points = ApexPages.currentPage().getParameters().get('points');

		List<NetworkMember> userToUpdate = [
			SELECT Id, ReputationPoints
			FROM NetworkMember
			WHERE MemberId = :userId
				AND NetworkId = :community.Id
			LIMIT 50000
		];

		if (!userToUpdate.isEmpty()) {
			for (NetworkMember item : userToUpdate) {
				item.ReputationPoints = Decimal.valueOf(points);
			}

			try {
				update userToUpdate;
			} catch (DmlException ex) {
				ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
				ApexPages.addMessage(erorMessage);
			}
		}

		fetchCommunityUsers();
	}

	/*
	* used to save CAPL community users info in .csv file
	*/

	public PageReference downloadUsers() {
		return Page.CAPL_SaveCommunityUsersAsCSV;
	}
}