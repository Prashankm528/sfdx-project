/**
* @author Karishma Gurjar
* @date 04/05/2020
* @company IBM Company
* @description - PBI 1149806: Class for ICRM_SuperUserForOpportunity component to get data of users who a delete a particular Opportunity
* *
*/
public with sharing class ICRM_getSuperUserController {
    
    /** get the user details who can delete particular Opportunity **/
    @AuraEnabled
    public static List <User> getSuperUserList(List<Id> OpportunityIds) {
        Set<Id> setOfSuperUserIds = new Set<Id>();
        Set<Id> setOfLNGUser = new Set<Id>();
        Set<Id> setOfConfidentialUser = new Set<Id>();
        Set<Id> setOfFinBPECUser = new Set<Id>();
        Set<Id> setOfFinancialUser = new Set<Id>();
        Set<Id> setOfPhysicalUser = new Set<Id>();
        Set<Id> setOfGlobalUser = new Set<Id>();
        Set<Id> finalUser = new Set<Id>();
        List<User> userList= new List<User>();
        Id oppRecordTypeGlobalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId(); 
        List<Opportunity> opptyList= new List<Opportunity>([SELECT Id, ICRM_BP_Confidential__c,ICRM_RBU__c,ICRM_Phy_Fin__c,ICRM_Client_Order__c,RecordTypeId from Opportunity WHERE id in:OpportunityIds]);
        for(PermissionSetAssignment AssignmentCheck : [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ICRM_M_O_Super_User']){
            /** get the user id of those users who are assigned with ICRM_M_O_Super_User permission set**/
            setOfSuperUserIds.add(AssignmentCheck.AssigneeId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST LNG']){
            /** get the user id of those users who are assigned with IST LNG public group**/
            setOfLNGUser.add(grp.UserOrGroupId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST Confidential']){
            /** get the user id of those users who are assigned with IST Confidential public group**/
            setOfConfidentialUser.add(grp.UserOrGroupId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST Financial - BPEC Spa & Power']){
            /** get the user id of those users who are assigned with IST Financial - BPEC Spa & Power public group**/
            setOfFinBPECUser.add(grp.UserOrGroupId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST Financial - RoW']){
            /** get the user id of those users who are assigned with IST Financial - RoW public group**/
            setOfFinancialUser.add(grp.UserOrGroupId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST Physical']){
            /** get the user id of those users who are assigned with IST Physical public group**/
            setOfPhysicalUser.add(grp.UserOrGroupId);     
        }
        for(GroupMember grp : [select userorgroupid from groupmember where group.name = 'IST Global']){
            /** get the user id of those users who are assigned with IST Global public group**/
            setOfGlobalUser.add(grp.UserOrGroupId);     
        }
        if(!setOfSuperUserIds.isEmpty()){
            for(Opportunity opp : opptyList){
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == False && opp.ICRM_RBU__c == 'LNG'){
                    for(Id u1 : setOfLNGUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                    
                }
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == True){
                    for(Id u1 : setOfConfidentialUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                }
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == False && opp.ICRM_Phy_Fin__c == 'Financial' && (opp.ICRM_RBU__c == 'SPA' || opp.ICRM_RBU__c == 'NAGP Power')){
                    for(Id u1 : setOfFinBPECUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                }
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == False){
                    for(Id u1 : setOfGlobalUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                }
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == False && opp.ICRM_Phy_Fin__c == 'Financial' && opp.ICRM_Client_Order__c == True && (opp.ICRM_RBU__c != 'LNG' || opp.ICRM_RBU__c != 'SPA' || opp.ICRM_RBU__c != 'NAGP Power')){
                    for(Id u1 : setOfFinancialUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                }
                if(opp.recordTypeId == oppRecordTypeGlobalId && opp.ICRM_BP_Confidential__c == False && opp.ICRM_Phy_Fin__c == 'Physical' && opp.ICRM_RBU__c != 'LNG'){
                    for(Id u1 : setOfPhysicalUser){
                        if(setOfSuperUserIds.contains(u1)){
                            finalUser.add(u1);
                        }
                    }
                }
            }
        }
        return [SELECT id, name,ICRM_RBU__c,Email FROM User WHERE id in :finalUser and isActive=True and (not username like 'ghousalesforcesupport%') limit 100];
        
    }
}