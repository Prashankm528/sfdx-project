/***********************************************************************************************
* @author           Xc
* @date             2020/09/19
* @group            CHCRM
* @description      Role Utility
* history
* 2020/09/19  Xc   Created 
************************************************************************************************/
public with sharing class CHCRM_RoleHierarchyUtils {
    static Map<Id, UserRole> roleMap
    {
        get
        {
            if(roleMap == null)
            {
                roleMap = new Map<Id, UserRole>([SELECT Id,Name,ParentRoleId FROM UserRole LIMIT 10000]);
            }
            return roleMap;
        }
        private set;
    }
    
    static Map<Id, List<UserRole>> hierarchy
    {
        get
        {
            if(hierarchy == null)
            {
                hierarchy = new Map<Id, List<UserRole>>();
                for(UserRole role : roleMap.values())
                {
                    if(!hierarchy.containsKey(role.ParentRoleId))
                        hierarchy.put(role.ParentRoleId, new List<UserRole>());
                    hierarchy.get(role.ParentRoleId).add(role);
                }
            }
            return hierarchy;
        }
        private set;
    }    
    
    static Map<String, UserRole> roleDevNameMap
    {
        get
        {
            if(roleDevNameMap == null)
            {
                roleDevNameMap = new Map<String, UserRole>();
                for(UserRole role : [SELECT Id , DeveloperName FROM  UserRole LIMIT 10000]){
                    roleDevNameMap.put(role.DeveloperName , role);
                }
            }
            return roleDevNameMap;
        }
        private set;
    }
    
    
    public static List<UserRole> getChildren(Id userRoleId){
        return hierarchy.containsKey(userRoleId) ? hierarchy.get(userRoleId) : new List<UserRole>();
    }
    
    //included top-level
    public static Set<Id> getSubHierarchyInclusive(Id userRoleId){
        Set<Id> roleIds = new Set<Id> { userRoleId };
        for (UserRole childRole : getChildren(userRoleId))
            roleIds.addAll(getSubHierarchyInclusive(childRole.Id));
        return roleIds;
    }
    
    public static Boolean isParentRoleSubordination(String parentName, Id childId){
        Set<Id> allChildIdSet = getSubHierarchyInclusive(roleDevNameMap.get(parentName).Id);        
        if(!allChildIdSet.isEmpty() && allChildIdSet.contains(childId)){
            return true;
        }
        return false;
    }
    
  
}