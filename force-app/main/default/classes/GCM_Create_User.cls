/****************************************************************************************************
 * Date          : 14-AUG-2020
 * Author        : Sunny Yap
 * Description   : GCM_Create_User - Automate creation of users in sandboxes.
 * Modifications : 14-AUG-2020 SYAP - Initial
 ****************************************************************************************************/
@RestResource(urlMapping='/gcm_create_user/*')
global with sharing class GCM_Create_User {
    @HttpPost
/****************************************************************************************************
 * Create Or Update User
 ****************************************************************************************************/
    global static String createUser(String json) {
        try {
        	Organization thisOrganization = [select IsSandbox from Organization limit 1];
        	if (thisOrganization.IsSandbox || Test.isRunningTest()) {
            	List<Object> requests = (List<Object>) System.JSON.deserializeUntyped(json);

            	Map<String, Id> userMap = new Map<String, Id>();
            	Map<String, Map<String, Object>> userNodeMap = new Map<String, Map<String, Object>>();
            	Map<String, Id> profileMap = new Map<String, Id>();
            	Map<String, Id> roleMap = new Map<String, Id>();
            	Map<String, Id> callCenterMap = new Map<String, Id>();
            	Map<String, Id> groupMap = new Map<String, Id>();
            	Map<String, Id> queueMap = new Map<String, Id>();
            	Map<String, Id> permissionMap = new Map<String, Id>();
            	for (Object request : requests) {
                	Map<String, Object> node = (Map<String, Object>) request;
                	for (String key : node.keySet()) {
                    	if (node.get(key) instanceof String) {
                        	if (key == 'Username') {
                            	userMap.put((String) node.get('Username'), null);
                            	userNodeMap.put((String) node.get('Username'), node);
                        	}
                        	else
                        	if (key == 'Profile') {
	                            profileMap.put((String) node.get('Profile'), null);
    	                    }
        	                else
            	            if (key == 'Role') {
                	            roleMap.put((String) node.get('Role'), null);
                    	    }
	                        else
    	                    if (key == 'CallCenter') {
        	                    callCenterMap.put((String) node.get('CallCenter'), null);
            	            }
                	    }
	                    else {
    	                    if (key == 'Group') {
        	                    List<Object> subNodes = (List<Object>) node.get(key);
            	                for (Object subNode : subNodes) {
                	                Map<String, Object> subNodeMap = (Map<String, Object>) subNode;
	                                groupMap.put((String) subNodeMap.get('DeveloperName'), null);
    	                        }
        	                }
            	            else
                	        if (key == 'Queue') {
                    	        List<Object> subNodes = (List<Object>) node.get(key);
                        	    for (Object subNode : subNodes) {
	                                Map<String, Object> subNodeMap = (Map<String, Object>) subNode;
    	                            queueMap.put((String) subNodeMap.get('DeveloperName'), null);
        	                    }
            	            }
                	        else
                    	    if (key == 'PermissionSet') {
                        	    List<Object> subNodes = (List<Object>) node.get(key);
	                            for (Object subNode : subNodes) {
    	                            Map<String, Object> subNodeMap = (Map<String, Object>) subNode;
        	                        permissionMap.put((String) subNodeMap.get('DeveloperName'), null);
            	                }
                	        }
                    	}
	                }
    	        }
    
        	    // Get Profile Map
	            List<Profile> profiles = [select Id, Name from Profile where Name in :profileMap.keySet()];
    	        for (Profile thisProfile : profiles) {
        	        profileMap.put(thisProfile.Name, thisProfile.Id);
            	}

	            // Get User Role Map
    	        List<UserRole> roles = [select Id, DeveloperName from UserRole where DeveloperName in :roleMap.keySet()];
        	    for (UserRole thisRole : roles) {
            	    roleMap.put(thisRole.DeveloperName, thisRole.Id);
            	}

	            // Get Call Center Map
    	        List<CallCenter> callCenters = [select Id, Name from CallCenter where Name in :callCenterMap.keySet()];
				for (CallCenter thisCallCenter : callCenters) {
                	callCenterMap.put(thisCallCenter.Name, thisCallCenter.Id);
	            }

    	        // Get Group Map
	            List<Group> groups = [select Id, DeveloperName, Type from Group where DeveloperName in :groupMap.keySet() and Type = 'Regular'];
    	        for (Group thisGroup : groups) {
        	        groupMap.put(thisGroup.DeveloperName, thisGroup.Id);
            	}

	            // Get Queue Map
    	        List<Group> queues = [select Id, DeveloperName, Type from Group where DeveloperName in :queueMap.keySet() and Type = 'Queue'];
        	    for (Group queue : queues) {
            	    queueMap.put(queue.DeveloperName, queue.Id);
            	}

	            // Get Permission Set Map
    	        List<PermissionSet> permissions = [select Id, Name from PermissionSet where Name in :permissionMap.keySet()];
        	    for (PermissionSet permission : permissions) {
            	    permissionMap.put(permission.Name, permission.Id);
            	}

	            // Update Existing User Records
    	        List<User> users = [
        	        select
            	        Id,
                	    Username,
                    	Alias,
	                    Email,
    	                SenderEmail,
        	            FirstName,
            	        LastName,
                	    TimeZoneSidKey,
                    	NTID__c,
                    	Sales_Organisation__c,
                    	Business_Unit__c,
                    	GCM_User_Team__c,
                    	GCM_Business_Hours__c,
                    	ProfileId,
                    	UserRoleId,
                    	UserPermissionsInteractionUser,
                    	UserPermissionsKnowledgeUser,
                    	UserPermissionsLiveAgentUser,
                    	UserPermissionsSupportUser,
                    	CallCenterId
                	from
	                    User
    	            where
        	            Username in :userMap.keySet()
            	];

	            for (User thisUser : users) {
    	            // Save User Id
        	        // New Users In The Map Will Not Have Ids Assigned - Handle In Next Code Block
            	    userMap.put(thisUser.Username, thisUser.Id);
        
                	Map<String, Object> node = (Map<String, Object>) userNodeMap.get(thisUser.Username);

	                thisUser.Alias = (String) node.get('Alias');
    	            thisUser.Email = (String) node.get('Email');
        	        thisUser.SenderEmail = (String) node.get('SenderEmail');
            	    thisUser.FirstName = (String) node.get('FirstName');
                	thisUser.LastName = (String) node.get('LastName');
	                thisUser.TimeZoneSidKey = (String) node.get('TimeZoneSidKey');
    	            thisUser.NTID__c = (String) node.get('NTID__c');
        	        thisUser.Sales_Organisation__c = (String) node.get('Sales_Organisation__c');
            	    thisUser.Business_Unit__c = (String) node.get('Business_Unit__c');
                	thisUser.GCM_User_Team__c = (String) node.get('GCM_User_Team__c');
                	thisUser.GCM_Business_Hours__c = (String) node.get('GCM_Business_Hours__c');
	                thisUser.ProfileId = (Id) profileMap.get((String) node.get('Profile'));
    	            thisUser.UserRoleId = (Id) roleMap.get((String) node.get('Role'));
        	        thisUser.UserPermissionsInteractionUser = true;
            	    thisUser.UserPermissionsKnowledgeUser = true;
                	thisUser.UserPermissionsLiveAgentUser = true;
	                thisUser.UserPermissionsSupportUser = true;
    	            if (callCenterMap.containsKey((String) node.get('CallCenter'))) {
        	            thisUser.CallCenterId = (Id) callCenterMap.get((String) node.get('CallCenter'));
            	    }
            	}
            	if (!Test.isRunningTest()) update users;

            	// Create New Users
	            List<User> newUsers = new List<User>();
    	        for (String key : userMap.keySet()) {
        	        Map<String, Object> node = (Map<String, Object>) userNodeMap.get(key);
            	    if (userMap.get(key) == null) {
	                    User newUser = new User();
    	                newUser.Username = key;
        	            newUser.Alias = (String) node.get('Alias');
            	        newUser.Email = (String) node.get('Email');
                	    newUser.SenderEmail = (String) node.get('SenderEmail');
                    	newUser.FirstName = (String) node.get('FirstName');
	                    newUser.LastName = (String) node.get('LastName');
    	                newUser.TimeZoneSidKey = (String) node.get('TimeZoneSidKey');
        	            newUser.NTID__c = (String) node.get('NTID__c');
            	        newUser.Sales_Organisation__c = (String) node.get('Sales_Organisation__c');
                	    newUser.Business_Unit__c = (String) node.get('Business_Unit__c');
                    	newUser.GCM_User_Team__c = (String) node.get('GCM_User_Team__c');
	                    newUser.GCM_Business_Hours__c = (String) node.get('GCM_Business_Hours__c');
    	                newUser.ProfileId = (Id) profileMap.get((String) node.get('Profile'));
        	            newUser.UserRoleId = (Id) roleMap.get((String) node.get('Role'));
            	        newUser.LocaleSidKey = 'en_GB';
                	    newUser.EmailEncodingKey = 'ISO-8859-1';
                    	newUser.LanguageLocaleKey = 'en_US';
	                    newUser.UserPermissionsInteractionUser = true;
    	                newUser.UserPermissionsKnowledgeUser = true;
        	            newUser.UserPermissionsLiveAgentUser = true;
            	        newUser.UserPermissionsSupportUser = true;
                	    if (callCenterMap.containsKey((String) node.get('CallCenter'))) {
                    	    newUser.CallCenterId = (Id) callCenterMap.get((String) node.get('CallCenter'));
	                    }
    	                newUsers.add(newUser);
        	        }
            	}
	            if (!Test.isRunningTest()) insert newUsers;

	            // Update User Map
    	        List<User> allUsers = [select Id, Username from User where Username in :userMap.keySet()];
        	    for (User thisUser : allUsers) {
            	    userMap.put(thisUser.Username, thisUser.Id);
            	}

	            // Delete Child Records
    	        List<GroupMember> oldMembers = [select Id from GroupMember where UserOrGroupId in :userMap.values()];
        	    delete oldMembers;
	            List<PermissionSetAssignment> oldAssignees = [select Id from PermissionSetAssignment where AssigneeId in :userMap.values()];
    	        Database.delete(oldAssignees, false);

	            List<GroupMember> newMembers = new List<GroupMember>();
    	        List<PermissionSetAssignment> newAssignees = new List<PermissionSetAssignment>();
        	    List<CollaborationGroupMember> newChatMembers = new List<CollaborationGroupMember>();
            	for (String key : userNodeMap.keySet()) {
                	Map<String, Object> node = (Map<String, Object>) userNodeMap.get(key);
                	if (userMap.get(key) != null) {
	                    // Add Groups
    	                List<Object> groupNodes = (List<Object>) node.get('Group');
        	            for (Object groupNode : groupNodes) {
            	            Map<String, Object> subNode = (Map<String, Object>) groupNode;
                	        GroupMember newMember = new GroupMember();
                    	    newMember.GroupId = groupMap.get((String) subNode.get('DeveloperName'));
                        	newMember.UserOrGroupId = (Id) userMap.get(key);
	                        newMembers.add(newMember);
    	                }

        	            // Add Queues
            	        List<Object> queueNodes = (List<Object>) node.get('Queue');
                	    for (Object queueNode : queueNodes) {
                    	    Map<String, Object> subNode = (Map<String, Object>) queueNode;
                        	GroupMember newMember = new GroupMember();
	                        newMember.GroupId = queueMap.get((String) subNode.get('DeveloperName'));
    	                    newMember.UserOrGroupId = (Id) userMap.get(key);
        	                newMembers.add(newMember);
            	        }

	                    // Add Permission Set
    	                List<Object> permissionNodes = (List<Object>) node.get('PermissionSet');
        	            for (Object permissionNode : permissionNodes) {
            	            Map<String, Object> subNode = (Map<String, Object>) permissionNode;
                	        PermissionSetAssignment newAssignee = new PermissionSetAssignment();
                    	    newAssignee.PermissionSetId = permissionMap.get((String) subNode.get('DeveloperName'));
                        	newAssignee.AssigneeId = (Id) userMap.get(key);
	                        newAssignees.add(newAssignee);
    	                }
        	        }
	            }
    	        if (!Test.isRunningTest()) {
        	    	insert newMembers;
            		insert newAssignees;
	            }
            
    	        GCM_Create_User.addChatterGroup(json);
        	}
            return '';
        }
        catch (Exception exceptionObject) {
            return exceptionObject.getMessage();
        }
    }
    
    @future
/****************************************************************************************************
 * Add Chatter Group Member, Use Future Method, Avoid Mixed DML Error
 ****************************************************************************************************/
    public static void addChatterGroup(String json) {
        Organization thisOrganization = [select IsSandbox from Organization limit 1];
        if (thisOrganization.IsSandbox || Test.isRunningTest()) {
            List<Object> requests = (List<Object>) System.JSON.deserializeUntyped(json);

            Map<String, Id> userMap = new Map<String, Id>();
            Map<String, Map<String, Object>> userNodeMap = new Map<String, Map<String, Object>>();
            Map<String, Id> profileMap = new Map<String, Id>();
            Map<String, Id> roleMap = new Map<String, Id>();
            Map<String, Id> callCenterMap = new Map<String, Id>();
            Map<String, Id> groupMap = new Map<String, Id>();
            Map<String, Id> queueMap = new Map<String, Id>();
            Map<String, Id> permissionMap = new Map<String, Id>();
            Map<String, Id> chatGroupMap = new Map<String, Id>();   
            for (Object request : requests) {
                Map<String, Object> node = (Map<String, Object>) request;
                userMap.put((String) node.get('Username'), null);
                userNodeMap.put((String) node.get('Username'), node);
                List<Object> subNodes = (List<Object>) node.get('CollaborationGroup');
                for (Object subNode : subNodes) {
                    Map<String, Object> subNodeMap = (Map<String, Object>) subNode;
                    chatGroupMap.put((String) subNodeMap.get('Name'), null);
                }
            }

            // Get Collaboration Group
            List<CollaborationGroup> chatGroups = [select Id, Name from CollaborationGroup where Name in :chatGroupMap.keySet()];
            for (CollaborationGroup chatGroup : chatGroups) {
                chatGroupMap.put(chatGroup.Name, chatGroup.Id);
            }

            // Update Existing User Records
            List<User> users = [
                select
                    Id,
                    Username
                from
                    User
                where
                    Username in :userMap.keySet()
            ];
            for (User thisUser : users) {
                // Save User Id
                // New Users In The Map Will Not Have Ids Assigned - Handle In Next Code Block
                userMap.put(thisUser.Username, thisUser.Id);
            }

            // Delete Child Records
            List<CollaborationGroupMember> oldChatMembers = [select Id from CollaborationGroupMember where MemberId in :userMap.values()];
            delete oldChatMembers;

            List<CollaborationGroupMember> newChatMembers = new List<CollaborationGroupMember>();
            for (String key : userNodeMap.keySet()) {
                Map<String, Object> node = (Map<String, Object>) userNodeMap.get(key);
                if (userMap.get(key) != null) {
                    // Add Chat Members
                    List<Object> chatNodes = (List<Object>) node.get('CollaborationGroup');
                    for (Object chatNode : chatNodes) {
                        Map<String, Object> subNode = (Map<String, Object>) chatNode;
                        CollaborationGroupMember newChatMember = new CollaborationGroupMember();
                        newChatMember.CollaborationGroupId = chatGroupMap.get((String) subNode.get('Name'));
                        newChatMember.MemberId = (Id) userMap.get(key);
                        newChatMembers.add(newChatMember);
                    }
                }
            }
            if (!Test.isRunningTest()) insert newChatMembers;
        }
    }
}