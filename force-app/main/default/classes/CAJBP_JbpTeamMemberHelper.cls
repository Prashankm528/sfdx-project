/**
 * @author			Jan Majling
 * @date			28/08/2018
 * @group			CAJBP
 * @description		helper functions for CAJBP_JbpTeamMember__c object
 *
 * history
 * 28/08/2018	Jan Majling			Created
 * 26/08/2020	Abhinit Kohar		Created a method to prevent the deletion of Marketing Approver and Finance Approver records
 * 10/09/2020   Pooja Dhiman        Created a boolean so that while updating activities preventJAFActivityWithApprovers doesn't get invoked by Team member
 */
public with sharing class CAJBP_JbpTeamMemberHelper {
    
    public static Boolean isExecutingFromTeamMemberTrigger = false;
    
	/**
	 * @description creates unique key consisting of CAJBP_Joint_Business_Plan__c Id
	 * and CAJBP_User__c Id
	 * @param teamMember of type CAJBP_JBP_Team_Member__c
	 * @return String
	 */
	public String createUniqueKey(CAJBP_JBP_Team_Member__c teamMember) {
		return (String)teamMember.CAJBP_Joint_Business_Plan__c + teamMember.CAJBP_User__c;
	}

	/**
	 * @description sets unique key to JBP Team Members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void setUniqueKeys(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMember.CAJBP_Unique_Key__c = this.createUniqueKey(teamMember);
		}
	}

	/**
	 * @description prevents duplicates of JBP Team Members by comparing unique keys
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>
	 */
	public void preventDuplicates(List<CAJBP_JBP_Team_Member__c> teamMembers) {
		Map<String,CAJBP_JBP_Team_Member__c> teamMembersByUniqueKey = new Map<String,CAJBP_JBP_Team_Member__c>();
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
			teamMembersByUniqueKey.put(teamMember.CAJBP_Unique_Key__c, teamMember);
		}

		List<CAJBP_JBP_Team_Member__c> existingTeamMembers = [
			SELECT CAJBP_Unique_Key__c
			FROM CAJBP_JBP_Team_Member__c
			WHERE CAJBP_Unique_Key__c IN :teamMembersByUniqueKey.keySet()
		];
		for(CAJBP_JBP_Team_Member__c existingTeamMember : existingTeamMembers) {
			String uniqueKey = existingTeamMember.CAJBP_Unique_Key__c;
			teamMembersByUniqueKey.get(uniqueKey).addError(Label.CAJBP_Duplicated_JBP_Team_Member);
		}
	}
	
	/**
	 * @description prevents duplicate roles of JBP Team Members
	 * @param teamMembers of type List<CAJBP_JBP_Team_Member__c>, Map<Id,CAJBP_JBP_Team_Member__c>
	 */
    public void preventDuplicateRoles(List<CAJBP_JBP_Team_Member__c> teamMembers, Map<Id,CAJBP_JBP_Team_Member__c> oldTeamMemberMap) {
        //Labels for Approvers' role
        String[] roleList = (Label.CAJBP_JBP_Team_Member_Role).split(',');
        List<CAJBP_JBP_Team_Member__c> approverRoleTeamMembers = new List<CAJBP_JBP_Team_Member__c>();
        Map<String,List<CAJBP_JBP_Team_Member__c>> teamMembersByRole = new Map<String,List<CAJBP_JBP_Team_Member__c>>();
        Map<String,List<CAJBP_JBP_Team_Member__c>> existingTeamMembersByRole = new Map<String,List<CAJBP_JBP_Team_Member__c>>();
        //Filter JBP team members with approvers role only
		for(CAJBP_JBP_Team_Member__c teamMember : teamMembers) {
            for(Integer i=0; i<roleList.size();i++){
                if(teamMember.CAJBP_Role__c.contains(roleList[i])){
                    approverRoleTeamMembers.add(teamMember);
                }
            }                      
        }
        //Logic will only run if user is inserting/updating JBP team members with aprover role
        if(!approverRoleTeamMembers.isEmpty()){
            for(CAJBP_JBP_Team_Member__c teamMember : approverRoleTeamMembers) {
                if(teamMembersByRole.containsKey(teamMember.CAJBP_Joint_Business_Plan__c)) {
                    teamMembersByRole.get(teamMember.CAJBP_Joint_Business_Plan__c).add(teamMember);
                } else {
                    teamMembersByRole.put(teamMember.CAJBP_Joint_Business_Plan__c, new List<CAJBP_JBP_Team_Member__c> { teamMember });
                }
            }
            
            for(CAJBP_JBP_Team_Member__c existingTeamMember : [SELECT CAJBP_Role__c, CAJBP_Joint_Business_Plan__c FROM CAJBP_JBP_Team_Member__c
                                                               WHERE CAJBP_Role__c IN :roleList 
                                                               AND CAJBP_Joint_Business_Plan__c IN :teamMembersByRole.keySet()]) {                                                                   
           		if(existingTeamMembersByRole.containsKey(existingTeamMember.CAJBP_Joint_Business_Plan__c)) {
                    existingTeamMembersByRole.get(existingTeamMember.CAJBP_Joint_Business_Plan__c).add(existingTeamMember);
                } else {
                    existingTeamMembersByRole.put(existingTeamMember.CAJBP_Joint_Business_Plan__c, new List<CAJBP_JBP_Team_Member__c> { existingTeamMember });
                }      
            }
            //Check number of approvers in new and existing JBP team members
            for(String jbp : teamMembersByRole.keySet()){
                for(CAJBP_JBP_Team_Member__c teamMember : teamMembersByRole.get(jbp)) {
                    if(oldTeamMemberMap == null) {
                        if(existingTeamMembersByRole.containsKey(jbp) && (existingTeamMembersByRole.get(jbp).size()==2 
                                                                      || existingTeamMembersByRole.get(jbp).size()+teamMembersByRole.get(jbp).size()>2
                                                                      || existingTeamMembersByRole.get(jbp)[0].CAJBP_Role__c.contains(teamMember.CAJBP_Role__c))){
                            teamMember.addError(Label.CAJBP_Duplicated_JBP_Team_Member_Role);
                        }
                    } else if(teamMember.CAJBP_Role__c != oldTeamMemberMap.get(teamMember.Id).CAJBP_Role__c) {
                        if(existingTeamMembersByRole.containsKey(jbp) && (existingTeamMembersByRole.get(jbp).size()==2 
                                                                      || existingTeamMembersByRole.get(jbp).size()+teamMembersByRole.get(jbp).size()>2
                                                                      || existingTeamMembersByRole.get(jbp)[0].CAJBP_Role__c.contains(teamMember.CAJBP_Role__c))){
                            teamMember.addError(Label.CAJBP_Duplicated_JBP_Team_Member_Role);
                        }
                    }                    
                }
            }
        }        
    }

    //This method finds out if the User with the role of Marketing Approver or Financial Approver has been updated on the Team Member.
    // If yes, then it updates all the Activities associated with the JBP with the new User selected in Team Member.
    // We are just calling the update of Activities, as the logic for getting the User from Team Member and updating it in Activities is there on Activities trigger.
    public static void updateApproversInActivity(Map<Id, CAJBP_JBP_Team_Member__c> oldMap, Map<Id, CAJBP_JBP_Team_Member__c> newMap){
        List<CAJBP_JBP_Activity__c> activities = new List<CAJBP_JBP_Activity__c>();
        String[] roleList = (Label.CAJBP_JBP_Team_Member_Role).split(',');
        Set<Id> jbpIds = new Set<Id>();

        for(CAJBP_JBP_Team_Member__c jtm : newMap.values()){
            if(oldMap != null && roleList.contains(jtm.CAJBP_Role__c) && (jtm.CAJBP_User__c != oldMap.get(jtm.Id).CAJBP_User__c || !roleList.contains(oldMap.get(jtm.Id).CAJBP_Role__c)) ){
                jbpIds.add(jtm.CAJBP_Joint_Business_Plan__c);
            } else if(oldMap == null && roleList.contains(jtm.CAJBP_Role__c)){
                jbpIds.add(jtm.CAJBP_Joint_Business_Plan__c);
            }
        }

        if(!jbpIds.isEmpty()){
            activities = [select id from CAJBP_JBP_Activity__c where CAJBP_Joint_Business_Plan__c in : jbpIds];
        }

        if(!activities.isEmpty()){
            isExecutingFromTeamMemberTrigger = true;
            update activities;
        }

    }

    //This method prevents the deletion of Marketing Approver and Financial Approver Team Member records.
    public static void preventMarketingFinanceApproverDeletion(List<CAJBP_JBP_Team_Member__c> teamMembers){
        String[] roleList = (Label.CAJBP_JBP_Team_Member_Role).split(',');
        for(CAJBP_JBP_Team_Member__c tm : teamMembers){
            if(roleList.contains(tm.CAJBP_Role__c)){
                tm.addError(Label.CAJBP_Cannot_Delete_Team_Member_With_Marketing_Or_Finance_Approver_Role);
            }
        }
    }
}