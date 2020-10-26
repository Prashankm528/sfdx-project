/* @author            Irfan Ahmed
*  @date              3rd Feb, 2020
*  @description       Handles trigger events on ICRM_Project_Team__c object 
*
@ ------------ Changed by ---
*  @author            Karishma Gurjar
*  @date              28th Apr, 2020
*  @description       979478 : Create a Team on Project Record MVP 
*/
public without sharing class ICRM_ProjectTeamTriggerHandler  extends BPG_Trigger_Handler_Utilities{
    
    /* After insert of Project Team Member */
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){ 
        list<ICRM_Project_Team__c> projectTeamList = new list<ICRM_Project_Team__c>();
        projectTeamList=n;
        set<id> projectIdSet= new set<id>();
        for(ICRM_Project_Team__c projectTeam : projectTeamList){
            if(!projectTeamList.isEmpty()){
                projectIdSet.add(projectTeam.ICRM_Project__c);
            }
        }
        if(!projectIdSet.isEmpty()){
            eligibilityForProjectTeam(projectTeamList,projectIdSet,oMap,nMap);
        }
        
    }
    /* After update of Project Team Member */
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){ 
        list<ICRM_Project_Team__c> projectTeamList = new list<ICRM_Project_Team__c>();
        projectTeamList=n;
        set<id> projectIdSet= new set<id>();
        for(ICRM_Project_Team__c projectTeam : projectTeamList){
            if(!projectTeamList.isEmpty()){
                projectIdSet.add(projectTeam.ICRM_Project__c);
            }
        }
        if(!projectIdSet.isEmpty()){
            eligibilityForProjectTeam(projectTeamList,projectIdSet,oMap,nMap);
        }
        
    }
    /* After delete of Project Team Member */
    public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){ 
        list<ICRM_Project_Team__c> projectTeamList = new list<ICRM_Project_Team__c>();
        projectTeamList=o;
        set<id> projectIdSet= new set<id>(); 
        for(ICRM_Project_Team__c projectTeam : projectTeamList){
            if(!projectTeamList.isEmpty()){
                projectIdSet.add(projectTeam.ICRM_Project__c);
            }
        }
        if(!projectIdSet.isEmpty()){
            eligibilityForProjectTeam(projectTeamList,projectIdSet,oMap,nMap);
        }
        
    }
    /* Check for logged in user eligibility to update Project Team */
    public void eligibilityForProjectTeam(list<ICRM_Project_Team__c> projectTeamList,Set<Id> projectIdSet,Map<Id, sObject> oMap,Map<Id, sObject> nMap){  
        Set<Id> setUserIds = new Set<Id>();
        setUserIds=permissionSetAssignmentCheck();
        map<id,ICRM_Project__c> mapProjectIDOwnerID= new map<id,ICRM_Project__c>([SELECT Id, ownerId,ICRM_BP_Confidential__c from ICRM_Project__c WHERE id in:projectIdSet]);
        
        for(ICRM_Project_Team__c projectTeam : projectTeamList){
            if(!projectTeamList.isEmpty() && UserInfo.getUserId() != mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ownerId && !setUserIds.contains(UserInfo.getUserId())){
                
                projectTeam.ICRM_User__c.addError('Please speak to project owner to modify Project Team');
                
            }
            if(!projectTeamList.isEmpty() && UserInfo.getUserId() != mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ownerId && setUserIds.contains(UserInfo.getUserId()) && mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ICRM_BP_Confidential__c == True){
                
                projectTeam.ICRM_User__c.addError('Please speak to project owner to modify Project Team');
                
            }
            if(!projectTeamList.isEmpty() && ((UserInfo.getUserId() != mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ownerId && setUserIds.contains(UserInfo.getUserId()) && mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ICRM_BP_Confidential__c == False) || (UserInfo.getUserId() == mapProjectIDOwnerID.get(projectTeam.ICRM_Project__c).ownerId))){
                updateProjectTeamMembers(oMap,nMap);
            }
            
        }
    }
    
    /* Check for logged in user permission set */
    public Set<Id> permissionSetAssignmentCheck(){
        Set<Id> setUserIds = new Set<Id>();
        for(PermissionSetAssignment AssignmentCheck : [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ICRM_CD_Super_User']){
            setUserIds.add(AssignmentCheck.AssigneeId);
            
        }
        return setUserIds;
    }
    /* Logic to update Project and give access to project team members*/
    public void updateProjectTeamMembers(Map<Id, sObject> oMap,Map<Id, sObject> nMap){ 
        Map<Id,ICRM_Project_Team__c> newMap = new Map<Id,ICRM_Project_Team__c>();
        Map<Id,ICRM_Project_Team__c> oldMap = new Map<Id,ICRM_Project_Team__c>();
        if(oMap!= NULL && !oMap.isEmpty()){
            for(Id recId : oMap.keySet()){
                oldMap.put(recId,(ICRM_Project_Team__c)oMap.get(recId));
            }
        }
        if(nMap!= NULL && !nMap.isEmpty()){
            for(Id recId : nMap.keySet()){
                newMap.put(recId,(ICRM_Project_Team__c)nMap.get(recId));
            }
        }
        Set<Id> projectIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        if(Trigger.isupdate || Trigger.isinsert){
            List<ICRM_Project__Share> projShares  = new List<ICRM_Project__Share>();
            for(ICRM_Project_Team__c team: newMap.values()){
                if(Trigger.oldMap!=null){
                    ICRM_Project_Team__c oldTeam = (ICRM_Project_Team__c )Trigger.oldMap.get(team.Id);
                    if(oldTeam!=null && oldTeam.ICRM_User__c!= team.ICRM_User__c){
                        projectIds.add(team.ICRM_Project__c);
                        userIds.add(oldTeam.ICRM_User__c);
                    } else {
                        projectIds.add(team.ICRM_Project__c);
                    }
                } else {
                    projectIds.add(team.ICRM_Project__c);
                }
            }
            
            for(ICRM_Project_Team__c proteam : newMap.values()){
                ICRM_Project__Share teamMemberShare = new ICRM_Project__Share();
                teamMemberShare.ParentId = proteam.ICRM_Project__c;    
                teamMemberShare.UserOrGroupId = proteam.ICRM_User__c; 
                teamMemberShare.AccessLevel = 'Edit';
                projShares.add(teamMemberShare);
            }
            Database.SaveResult[] coShareInsertResult = Database.insert(projShares,false);
            
        }
        if(Trigger.isdelete){
            for(ICRM_Project_Team__c team : oldMap.values()){
                projectIds.add(team.ICRM_Project__c);
                userIds.add(team.ICRM_User__c);
            }
        }
        
        Map<Id, Set<Id>> projectToTeam = new Map<Id, Set<Id>>();
        List<ICRM_Project_Team__c> projTeams = [Select Id, Name, ICRM_User__c, ICRM_Project__c from ICRM_Project_Team__c where ICRM_Project__c = :projectIds];
        for(ICRM_Project_Team__c team: projTeams){
            if(!projectToTeam.containsKey(team.ICRM_Project__c)){
                projectToTeam.put(team.ICRM_Project__c, new Set<Id>());
            }
            projectToTeam.get(team.ICRM_Project__c).add(team.ICRM_User__c);
        }
        
        //load blank project if no members found
        for(Id projId:projectIds){
            if(!projectToTeam.containsKey(projId)){
                projectToTeam.put(projId, new Set<Id>());
            }
        }
        
        List<ICRM_Project__c > projectsToUpdate = new List<ICRM_Project__c >();
        
        for(Id projId:projectToTeam.keySet()){
            Set<Id> teamMemberIds = projectToTeam.get(projId);
            List<Id> memberIdList = new List<Id>(teamMemberIds);
            String memberIdStr = String.join(memberIdList, ',');
            ICRM_Project__c  projToUpdate = new ICRM_Project__c ();
            projToUpdate.Id = projId;
            projToUpdate.ICRM_Team_Member_Ids__c = memberIdStr;
            projectsToUpdate.add(projToUpdate);
        }
        
        if(projectsToUpdate.size()>0){
            update projectsToUpdate;
        }
        if (userIds.size() > 0){
            ICRM_Project__Share[] shares2Delete = [select id from ICRM_Project__Share where parentid in :projectIds and
                                                   UserOrGroupId in :userIds ];
            delete shares2Delete;                    	
        }
    }             
}