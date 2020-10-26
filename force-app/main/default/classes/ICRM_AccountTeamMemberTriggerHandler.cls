/* @author            Irfan Ahmed
*  @date              19th Nov, 2019
*  @description       Handles trigger events on AccountTeamMember object 
*  @ -----------------------------------
*  @ ------------ Changed by -----------
*  @author		Karishma Gurjar            
*  @date   		29-11-2019            
*  @description 848803 : GSP Account Holder - Clear account holder field 
*/
public without sharing class ICRM_AccountTeamMemberTriggerHandler  extends BPG_Trigger_Handler_Utilities{            
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
		/* validating that one account can have only one GSP as an Account Team Member */
        map<id,list<AccountTeamMember>> mapAccountWithAtm= new map<id,list<AccountTeamMember>>();
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        list<AccountTeamMember> newAtmList = n;
        for(AccountTeamMember atm : newAtmList){
            if(atm.TeamMemberRole=='GSP Account Holder'){
                if(mapAccountWithAtm.containskey(atm.AccountId)){
                    mapAccountWithAtm.get(atm.AccountId).add(atm);
                }
                else{
                    mapAccountWithAtm.put(atm.AccountId,new List<AccountTeamMember>{atm});
                }
            }
        }
        if(!mapAccountWithAtm.isEmpty()){
            for(id accId : mapAccountWithAtm.keyset()){
                if(mapAccountWithAtm.containskey(accId)){
                    for(AccountTeamMember atm : mapAccountWithAtm.get(accId)){
                        if(!mapAccountWithAtm.isEmpty() && mapAccountWithAtm.get(atm.AccountId).size()>1){
                            atm.TeamMemberRole.addError('Only one account team member can be a GSP Account Holder');
                        }
                        else{
                            atmList.addall(mapAccountWithAtm.get(accId));
                        }
                        break;
                    }
                }
            }
        }
        checkExistingGSPAcHolder(atmList);
        
    }
    
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /*  Before Update of Opportunity */
    {   
        list<AccountTeamMember> atmNewList = nMap.Values();
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        for(AccountTeamMember atm : atmNewList){
            if(atm.TeamMemberRole!=((AccountTeamMember)oMap.get(atm.id)).TeamMemberRole && atm.TeamMemberRole =='GSP Account Holder'){
                atmList.add(atm);
            }
        }
        checkExistingGSPAcHolder(atmList);
    }
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
       
    { 
        /* GSP Account holder must be populated with team member having GSP Account Holder role.  */
        List<AccountTeamMember> newAtmList = n;
        List<AccountTeamMember> eligibleAtms= new List<AccountTeamMember>();
        for(integer i = 0; i < newAtmList.size(); i++){
            if('GSP Account Holder'.equalsIgnoreCase(newAtmList[i].TeamMemberRole)){
                eligibleAtms.add(newAtmList[i]);
            }
        }
        System.debug('Eligible Atms List-----'+ eligibleAtms);
        if(eligibleAtms.size() > 0){
            updateGSPAccountHolder(eligibleAtms,false);
        }
    }
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        
    {  
        /* GSP Account holder must be populated with team member having GSP Account Holder role.  */	
        List<AccountTeamMember> newAtmList = n;
        List<AccountTeamMember> oldAtmList = o;
        List<AccountTeamMember> atmPopulateGSPList = new List<AccountTeamMember>();
        List<AccountTeamMember> atmRemoveGSPList = new List<AccountTeamMember>();
        
        for(integer i = 0; i < oldAtmList.size(); i++){
            if(oldAtmList[i].Id == newAtmList[i].Id && oldAtmList[i].TeamMemberRole != newAtmList[i].TeamMemberRole){
                if('GSP Account Holder'.equalsIgnoreCase(oldAtmList[i].TeamMemberRole) && newAtmList[i].TeamMemberRole != 'GSP Account Holder'){
                    atmRemoveGSPList.add(newAtmList[i]);
                }else if('GSP Account Holder'.equalsIgnoreCase(newAtmList[i].TeamMemberRole) && oldAtmList[i].TeamMemberRole != 'GSP Account Holder'){
                    atmPopulateGSPList.add(newAtmList[i]);
                }
            }
        }
        
        if(atmPopulateGSPList.size()>0){
            updateGSPAccountHolder(atmPopulateGSPList,false);
        }
        if(atmRemoveGSPList.size()>0){
            updateGSPAccountHolder(atmRemoveGSPList,true);
        }
    }
    public override void beforeDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /*  before delete */
    {  
    }
    public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* GSP Account holder must be cleared out when team member with GSP Account Holder role is deleted  */
    {  
        
        List<AccountTeamMember> oldAtmList = o;
        List<AccountTeamMember> atmGSPListToDelete = new List<AccountTeamMember>();
        for(integer i = 0; i < oldAtmList.size(); i++){
            if('GSP Account Holder'.equalsIgnoreCase(oldAtmList[i].TeamMemberRole)){
                atmGSPListToDelete.add(oldAtmList[i]);
            }
        }
        if(atmGSPListToDelete.size()>0){
            updateGSPAccountHolder(atmGSPListToDelete,true);
        }
        
    }
    
    public void checkExistingGSPAcHolder(List<sObject> teamMemberListNew){
		/* validating that one account can have only one GSP as an acc team member */     
        List<AccountTeamMember> listAccTeamMember = teamMemberListNew;
        map<id,list<AccountTeamMember>> mapAccIdWithAtm = new map<Id,list<AccountTeamMember>>();
        for(AccountTeamMember atm : listAccTeamMember){
            if(atm.TeamMemberRole=='GSP Account Holder'){
                if(mapAccIdWithAtm.containskey(atm.AccountId)){
                    mapAccIdWithAtm.get(atm.AccountId).add(atm);
                }
                else{
                    mapAccIdWithAtm.put(atm.AccountId,new List<AccountTeamMember>{atm});
                }
            }
        }
        for(AccountTeamMember atm : [SELECT Id,TeamMemberRole,AccountId, UserId from AccountTeamMember where AccountId in:mapAccIdWithAtm.keyset() AND TeamMemberRole ='GSP Account Holder']){
            if(!mapAccIdWithAtm.isEmpty() && mapAccIdWithAtm.containskey(atm.AccountId)){
                for(AccountTeamMember atmnew : mapAccIdWithAtm.get(atm.AccountId)){
                    atmnew.TeamMemberRole.addError('Only one account team member can be a GSP Account Holder');
                }
            }
        }
    }
    
    public void updateGSPAccountHolder(List<AccountTeamMember> teamMemberList,Boolean isDelete){
        /* GSP Account holder must be populated with team member having GSP Account Holder role.  */
        Map<Id,Id> gspAccountsTeamMembersMap = new Map<Id,Id>();
        for(AccountTeamMember atm : teamMemberList){
            gspAccountsTeamMembersMap.put(atm.AccountId,atm.UserId);
        }
        List<Account> accToUpdate = new List<Account>();
        if(gspAccountsTeamMembersMap.size() > 0){
            List<Account> accList = [SELECT Id,ICRM_GSP_Account_Holder__c 
                                     FROM Account 
                                     WHERE Id IN: gspAccountsTeamMembersMap.keySet()];
            System.debug('Database Account List-----'+ accList);					 
            for(Account acc : accList){
                if(isDelete){
                    acc.ICRM_GSP_Account_Holder__c = NULL;
                }            
                else{
                    acc.ICRM_GSP_Account_Holder__c = gspAccountsTeamMembersMap.get(acc.Id);
                }
                accToUpdate.add(acc);
            }
        }
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
    }   
} // end of class