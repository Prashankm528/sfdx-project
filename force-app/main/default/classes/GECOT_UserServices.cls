public without sharing class GECOT_UserServices {

	public static void assignTerritory(List<User> newRecords){

		Set<Id> roleIds = new Set<Id>();
		for(User u : newRecords){
			if(!u.IsPortalEnabled){ // only for internal users
					roleIds.add(u.UserRoleId);
			}
		}
		
	  if(!roleIds.isEmpty()){
			GroupWrappers groupInfos = new GroupWrappers(roleIds); // not supported for external users
			List<UserTerritory2Association> territoryAssToInsert = new List<UserTerritory2Association>();

			for(User u : newRecords){
				Id roleId = u.UserRoleId;
				if(groupInfos.hasTerritoryNameRoleByRoleId(roleId)){
					territoryAssToInsert.add(
						new UserTerritory2Association(
									Territory2 = new Territory2( Name = groupInfos.getTerritoryNameRoleByRoleId(roleId)), 
									UserId = u.Id));
				}
			}
			if(!territoryAssToInsert.isEmpty()){
				Database.insert(territoryAssToInsert, true);
			}
		}
	}


	private class GroupWrappers {
		
		Map<Id, GroupMemberInfo> groupMemberInfoById = new Map<Id, GroupMemberInfo>();
		Map<Id, GroupMemberInfo> groupMemberInfoByRoleId = new Map<Id, GroupMemberInfo>();

		public Map<String, String> role2TerritoryMap = new Map<String, String>();

		public GroupWrappers(Set<Id> roleIds){
			
			for(GECOT_Territory_Mapping__mdt mapping : 
					[SELECT Id, MasterLabel, DeveloperName, Territory_Developer_Name__c 
					 FROM GECOT_Territory_Mapping__mdt])
			{
		        role2TerritoryMap.put(
		        	mapping.MasterLabel, 
		        	mapping.Territory_Developer_Name__c.replace('_',' '));
	   		}

			for(Group g : 
		    	[SELECT RelatedId, Id, DeveloperName, Type 
	             FROM Group 
	             WHERE Id IN
	              (SELECT UserOrGroupId 
	                FROM GroupMember 
	                WHERE Group.Name IN :role2TerritoryMap.keySet())
	              AND RelatedId IN :roleIds])
			{
	    		this.addGroupMemberInfo(g);
	    	}

	    	for(GroupMember gm : 
		    	[SELECT GroupId, Group.Name, UserOrGroupId
	               FROM GroupMember
	               WHERE Group.Name IN :role2TerritoryMap.keySet()
	                AND UserOrGroupId IN
	                 (SELECT Id
	                  FROM Group
	                  WHERE RelatedId IN :roleIds)])
	    	{
	    		GroupMemberInfo newInfo = this.addGroupMemberInfo(gm);
	    		groupMemberInfoByRoleId.put(newInfo.RoleId, newInfo);
	    	}
		}

		private GroupMemberInfo addGroupMemberInfo(SObject obj){
			GroupMemberInfo newInfo;
			if(obj.getSObjectType() == Schema.GroupMember.SObjectType){
				newInfo = new GroupMemberInfo((GroupMember) obj);
			}else if(obj.getSObjectType() == Schema.Group.SObjectType){
				newInfo = new GroupMemberInfo((Group) obj);
			}
			if(!groupMemberInfoById.containsKey(newInfo.Id)){
	    		groupMemberInfoById.put(newInfo.Id, newInfo);
	    	}else{
	    		groupMemberInfoById.get(newInfo.Id).setBy(obj);
	    	}
	    	return groupMemberInfoById.get(newInfo.Id);
		}

		public String getTerritoryNameRoleByRoleId(Id roleId){
			return role2TerritoryMap.get(groupMemberInfoByRoleId.get(roleId).GroupName);
		}

		public Boolean hasTerritoryNameRoleByRoleId(Id roleId){
			return groupMemberInfoByRoleId.containsKey(roleId) && role2TerritoryMap.containsKey(groupMemberInfoByRoleId.get(roleId).GroupName);
		}

	}

	private class GroupMemberInfo {
		
		public Id Id { 
			get { 
				Id myId;
				if(gm != null){
					myId = gm.UserOrGroupId;
				}else if(g != null){
					myId = g.Id;
				}
				return myId;
			}
		}

		public Id RoleId { get { return g.RelatedId; } }
		public String GroupName { get { return gm.Group.Name; } }

		private GroupMember gm;
		private Group g;

		public GroupMemberInfo(GroupMember gm){
			this.setByGroupMember(gm);
		}

		public GroupMemberInfo(Group g){
			this.setByGroup(g);
		}

		public void setBy(SObject obj){
			if(obj.getSObjectType() == Schema.GroupMember.SObjectType){
				this.setByGroupMember((GroupMember) obj);
			}else if(obj.getSObjectType() == Schema.Group.SObjectType){
				this.setByGroup((Group) obj);
			}
		}

		private void setByGroupMember(GroupMember gm){
			this.gm = gm;
		}

		private void setByGroup(Group g){
			this.g = g;
		}

	}
}