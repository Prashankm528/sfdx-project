/* @author            Utkarsh Gupta
*  @date              15th July, 2019
*  @description       handles trigger events on Account object for IST CRM Project
*  @ -----------------------------------
*  @ ------------ Changed by ---
*  @author            Santosh Verma
*  @date              05th Nov, 2019
*  @description       680897 : Add Opportunity createdby as owner to OppTeam if both are different
@ ------------ Changed by ---
*  @author            Karishma Gurjar
*  @date              05th Dec, 2019
*  @description       821778 : Defaulting Deal ID = Opportunity Name for SPE and SPEH Won Deals 
@ ------------ Changed by ---
*  @author            Santosh Verma
*  @date              17th Feb, 2020
*  @description       795767 : Record lock issue- removed CS and added new child record adding by PB  
@ ------------ Changed by ---
*  @author            Santosh Verma
*  @date              10th Mar, 2020
*  @description       1057815 : Updated Team owner logic

*/
public without sharing class ICRM_OpportunityTriggerHandler extends BPG_Trigger_Handler_Utilities{            
    
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /*  To Update the Order ID after Insert of Opportunity  */
    { 
        //Update Closed Won Opportunity Deal ID upon Opportuntiy creation for SPE and SPEH BU
        Id oppRecordTypeNewId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();  
        Id oppRecordTypeGlobalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId(); 
        List<Opportunity> listNewOppty = new List<Opportunity>();   
        List<Opportunity> eligibleNewOpptyList = new List<Opportunity>();   
        Set<Id> ownerIDSet = new Set<Id>();
        listNewOppty = n;  
        //==================================================================
        // change current owner from assigned owner if it is not blank 
        //  populateOwnerICRMAssignedOwnerProperties(n); 
        for(Opportunity newOpps: listNewOppty){
            If((newOpps.recordTypeId == oppRecordTypeNewId) || (newOpps.recordTypeId == oppRecordTypeGlobalId))
            {
                
                If(newOpps.ICRM_Send_Email__c == Null){
                    string values = 'NPV Update;Stage Change;Team Member';
                    newOpps.ICRM_Send_Email__c=values;
                }
                If(newOpps.ICRM_Assigned_Owner__c != Null){
                    newOpps.OwnerId =newOpps.ICRM_Assigned_Owner__c ;
                    //system.debug('oppty owner is '+newOpps.OwnerId);
                } // this field is used in PB 
                If(newOpps.ICRM_Send_Email__c != Null){
                    newOpps.ICRM_Send_email_text__c  = newOpps.ICRM_Send_Email__c;                
                }   
                Else{
                    newOpps.ICRM_Send_email_text__c  = ' '; 
                }
            }
        }
        //==================================================================
        for(Opportunity newOpps: listNewOppty){
            If((newOpps.recordTypeId == oppRecordTypeNewId || newOpps.recordTypeId == oppRecordTypeGlobalId) && newOpps.StageName=='Closed - Won')
            {
                OwnerIDSet.add(newOpps.OwnerId);
                eligibleNewOpptyList.add(newOpps);
            }   
        }
        if(eligibleNewOpptyList.size() > 0){
            OppDealIdUpdate(eligibleNewOpptyList,OwnerIDSet);
        }
        
    }
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /*  To Update Opportunity */
    {  
        Id oppRecordTypeNewIdU = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();  
        Id oppRecordTypeGlobalIdU = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId(); 
        List<Opportunity> listNewOpptyU = new List<Opportunity>();   
        
        listNewOpptyU = n;  
        // change send email value from send email owner if it is not blank 
        
        for(Opportunity newOpps2: listNewOpptyU){
            If((newOpps2.recordTypeId == oppRecordTypeNewIdU) || (newOpps2.recordTypeId == oppRecordTypeGlobalIdU))
            {
                // this field is used in PB 
                If(newOpps2.ICRM_Send_Email__c != Null){
                    newOpps2.ICRM_Send_email_text__c  = newOpps2.ICRM_Send_Email__c; 
                } 
                Else{
                    newOpps2.ICRM_Send_email_text__c  = ' '; 
                }
            }   
        }
    }
    
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Add Opportunity createdby as owner to OppTeam if both are different */
    {   
        OppTeamUpdate(o,  oMap,  n,  nMap, sot, params, debug); 
    }
    
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Add Opportunity createdby as owner to OppTeam if both are different */
    {   
        OppTeamUpdate(o,  oMap,  n,  nMap, sot, params, debug);
    }
    
    
    Public void OppDealIdUpdate(List<Opportunity> listNewOppty,Set<Id> OwnerIDSet)
    {
        // To Update Deal ID on Closed Won SPE or SPEH Opportunities
        map<id,User> mapOpptyOwner= new map<id,User>([SELECT Id, ICRM_RBU__c from User WHERE Id in: OwnerIDSet]);
        Id LoggedUserId = UserInfo.getUserId();
        List<Profile> BPIntProfile = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'BP Integration Base']);
        List<User> UserIDList = new List<User>([SELECT Id from User where ProfileId =: BPIntProfile[0].Id]);
        //List<User> UserIDList = new List<User>([SELECT Id from User where PROFILE.NAME='BP Integration Base']); 
        Set<Id> UserIDSet = (new Map<Id,User>(UserIDList)).keySet();
        
        for(Opportunity newOpps: listNewOppty){
            
            if((UserIDSet.Contains(LoggedUserId))&& ((newOpps.ICRM_RBU__c == 'Default' && (mapOpptyOwner.get(newOpps.OwnerId).ICRM_RBU__c=='SPE' || mapOpptyOwner.get(newOpps.OwnerId).ICRM_RBU__c =='SPEH'))  || (newOpps.ICRM_RBU__c == 'SPE' || newOpps.ICRM_RBU__c =='SPEH')) && String.isBlank(newOpps.ICRM_Deal_ID__c)){
                
                newOpps.ICRM_Deal_ID__c = newOpps.Name;
            }
            
            else If((!UserIDSet.Contains(LoggedUserId)) && ((newOpps.ICRM_RBU__c == 'Default' && (mapOpptyOwner.get(newOpps.OwnerId).ICRM_RBU__c=='SPE' || mapOpptyOwner.get(newOpps.OwnerId).ICRM_RBU__c =='SPEH'))  || (newOpps.ICRM_RBU__c == 'SPE' || newOpps.ICRM_RBU__c =='SPEH')) && (String.isBlank(newOpps.ICRM_Deal_ID__c) || newOpps.ICRM_Deal_ID__c != newOpps.Name))
            {
                newOpps.ICRM_Deal_ID__c = newOpps.Name;
                
            }
            
        }
    }
    
    
    Public void OppTeamUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        /* Add Opportunity createdby as owner to OppTeam  */ 
        Map<Id, String> iCRMRTMap = getISTRecordTypes();
        List<Opportunity> NewOppsListRecs = new List<Opportunity>();      
        NewOppsListRecs = n;
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity newOPT:NewOppsListRecs){
            if(iCRMRTMap.containsKey(newOpt.recordTypeId)){
                oppIds.add(newOpt.Id);
            }
        }
        
        if(oppIds.size()>0){
            Map<Id, OpportunityTeamMember> oppTeamRecs = new Map<Id, OpportunityTeamMember>([Select Id, OpportunityId, UserId, TeamMemberRole From OpportunityTeamMember 
                                                                                             Where OpportunityId = :oppIds and TeamMemberRole in ('Owner', 'Previous Owner')]); 
            
            List<OpportunityTeamMember> oppTeamRecsToUpsert = new List<OpportunityTeamMember>();
            Map<Id, Set<Id>> oppToTeamMap = new Map<Id, Set<Id>>();
            Map<String, Id> oppUserToTeamMemberId = new Map<String, Id>();
            for(OpportunityTeamMember teamMember:oppTeamRecs.values()){
                if(!oppToTeamMap.containsKey(teamMember.OpportunityId)){
                    oppToTeamMap.put(teamMember.OpportunityId, new Set<Id>());
                }
                oppToTeamMap.get(teamMember.OpportunityId).add(teamMember.UserId);
                oppUserToTeamMemberId.put(teamMember.OpportunityId+'_'+teamMember.UserId, teamMember.Id);
            }
            
            
            for (Opportunity newOPT:NewOppsListRecs){
                if(oppToTeamMap.containsKey(newOPT.Id)){
                    //existing opportunity
                    //team member exists, check to insert or update
                    Set<Id> teamMemberUserIds = oppToTeamMap.get(newOPT.Id);
                    
                    if(!teamMemberUserIds.contains(newOPT.OwnerId)){
                        //insert team member as owner
                        OpportunityTeamMember oppTeamToUpdate = new OpportunityTeamMember ();
                        oppTeamToUpdate.UserId = newOPT.OwnerId;
                        oppTeamToUpdate.TeamMemberRole = 'Owner';
                        oppTeamToUpdate.OpportunityId = newOPT.Id;
                        oppTeamRecsToUpsert.add(oppTeamToUpdate);
                    }
                    for(Id teamMemberUserId:teamMemberUserIds){
                        //update existing team member to owner
                        if(newOPT.OwnerId==teamMemberUserId){
                            Id teamMemberId = oppUserToTeamMemberId.get(newOPT.Id + '_' + newOPT.OwnerId);
                            OpportunityTeamMember oppTeamToUpdate = oppTeamRecs.get(teamMemberId);
                            oppTeamToUpdate.TeamMemberRole = 'Owner';
                            oppTeamRecsToUpsert.add(oppTeamToUpdate);
                        }
                        else {
                            Id teamMemberId = oppUserToTeamMemberId.get(newOPT.Id + '_' + teamMemberUserId);
                            OpportunityTeamMember oppTeamToUpdate = oppTeamRecs.get(teamMemberId);
                            oppTeamToUpdate.TeamMemberRole = 'Previous Owner';
                            oppTeamRecsToUpsert.add(oppTeamToUpdate);
                        }
                    }
                    
                } else {
                    //new opportunity. add new team member and creator
                    OpportunityTeamMember oppTeamToUpdate = new OpportunityTeamMember ();
                    oppTeamToUpdate.UserId = newOPT.OwnerId;
                    oppTeamToUpdate.TeamMemberRole = 'Owner';
                    /* to check if opportunity is closed do not send notification to assigned owner */
                    if(newOPT.StageName == 'Closed - Won' || newOPT.StageName == 'Closed - Lost' || newOPT.StageName == 'Closed - Abandoned'){
                        oppTeamToUpdate.ICRM_Do_not_Send_Notification__c = true;
                    }
                    oppTeamToUpdate.OpportunityId = newOPT.Id;
                    oppTeamRecsToUpsert.add(oppTeamToUpdate);
                    if( newOPT.OwnerId != newOPT.CreatedById){
                        OpportunityTeamMember oppTeamToUpdate1 = new OpportunityTeamMember ();
                        oppTeamToUpdate1.UserId = newOPT.CreatedById;
                        oppTeamToUpdate1.TeamMemberRole = 'Previous Owner';
                        oppTeamToUpdate1.OpportunityId = newOPT.Id;
                        oppTeamRecsToUpsert.add(oppTeamToUpdate1);
                    }
                }
            }
            
            If(!oppTeamRecsToUpsert.isEmpty()){
                Upsert oppTeamRecsToUpsert;
                
            }
        }
    }
    
    
    Map<Id, String> istRecordTypesMap;
    private Map<Id, String> getISTRecordTypes(){
        if(istRecordTypesMap==null){
            istRecordTypesMap = new Map<Id, String>();
            istRecordTypesMap.put(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId(), Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST New Opportunity').getDeveloperName());
            istRecordTypesMap.put(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId(), Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IST Global Opportunity').getDeveloperName());   
        }
        return istRecordTypesMap;
    }
    
} // end of class