/**
 * @author			Jan Majling
 * @date			22/08/2018
 * @group			CAJBP
 * @description		contains helper functions for CAJBP_Objective
 *
 * history
 * 22/08/2018	Jan Majling				Created 
 */
public with sharing class CAJBP_ObjectiveHelper {
	/**
	 * @description provides access to new objectives for already created team members
	 * @param newObjectives of type List<CAJBP_Objective__c>
	 */
	public void shareObjectivesWithTeamMembers(List<CAJBP_Objective__c> newObjectives) {
		CAJBP_JbpSharing jbpShare = new CAJBP_JbpSharing(); 
		jbpShare.grantAccessToRelatedRecords(newObjectives);
        jbpShare.shareObjectivesToJBPOwner(newObjectives);
	}
}