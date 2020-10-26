/**
* @author Santosh Verma
* @date 30/07/2019
* @company IBM Company
* @description - Handler class for triggers on Project object
* Currently we are converting Name, Type, Start and End date to text fields. These text fields are not used on screen but used for duplicate/matching rule
* Due to order of excution these field's mapping cannot be achieved by workflow or process-builder. 
* ProjectId will get populated if it is NULL 
* *
*/

public without sharing class ICRM_ProjectTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    
    // Operation on before insert    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        // get record id 
        string recTypeid = Schema.getGlobalDescribe().get('ICRM_Project__c').getDescribe().getRecordTypeInfosByName().get('ICRM_Project').getRecordTypeId();        
        integer projectId = 0; 
        // Get value from custom setting  
        ICRM_ProjectID__c CS_locPrjId = ICRM_ProjectID__c.getValues('projectid');   
        // Check for null to avoid any issue 
        List<Id> spaUserIds =new List<Id>();
        If(CS_locPrjId != Null){
            
            projectId = Integer.valueOf(CS_locPrjId.ICRM_Project_ID_Fld__c);  
        }
        
        
        
        List<ICRM_Project__c> PrjList = new List<ICRM_Project__c>();
        //move trigger new vale to list
        PrjList = n; 
        for(ICRM_Project__c prj:PrjList)
        {
            // Process only records which are created for 'IST CRM' project 
            If(prj.RecordTypeId == recTypeid){
                prj.ICRM_Project_Name_Text__c  = prj.name; 
                prj.ICRM_Project_Types_Text__c  = prj.ICRM_Project_Types__c;
                prj.ICRM_Start_Date_Text__c  = string.valueOf(prj.ICRM_Start_Date__c);
                prj.ICRM_End_Date_Text__c  = string.valueOf(prj.ICRM_End_Date__c);
                If(prj.ICRM_Project_ID__c == Null) {   /* Only populate Project Id when it is blank */
                    projectId = projectId + 1; // CS value increment 
                    prj.ICRM_Project_ID__c = projectId; 
                }
            }            
            if(prj.ICRM_Commercial_SPA__c != null && (prj.ICRM_Structurer_SPA__c == null || prj.ICRM_Structurer_SPA__c == prj.ICRM_Commercial_SPA__c)){
                prj.ICRM_Team_Member_Ids__c = prj.ICRM_Commercial_SPA__c;
                
            }
            if(prj.ICRM_Structurer_SPA__c != null && (prj.ICRM_Commercial_SPA__c == null || prj.ICRM_Structurer_SPA__c == prj.ICRM_Commercial_SPA__c)){
                prj.ICRM_Team_Member_Ids__c = prj.ICRM_Structurer_SPA__c;
                
            }
            if(prj.ICRM_Structurer_SPA__c != null && prj.ICRM_Commercial_SPA__c != null && prj.ICRM_Structurer_SPA__c != prj.ICRM_Commercial_SPA__c){
                spaUserIds.add(prj.ICRM_Structurer_SPA__c);
                spaUserIds.add(prj.ICRM_Commercial_SPA__c);
                String memberIdStr = String.join(spaUserIds, ',');
                prj.ICRM_Team_Member_Ids__c = memberIdStr;
                
            }
        }
        
        //update the custom setting with latest value 
        
        If(CS_locPrjId != Null){ 
            CS_locPrjId.ICRM_Project_ID_Fld__c = projectId; 
            Update CS_locPrjId;    
        }
        
        
    }
    
    // Operation on before update    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        List<ICRM_Project__c> PrjList = new List<ICRM_Project__c>();
        PrjList = n; 
        for(ICRM_Project__c prj:PrjList)
        {
            prj.ICRM_Project_Name_Text__c  = prj.name; 
            prj.ICRM_Project_Types_Text__c  = prj.ICRM_Project_Types__c;
            prj.ICRM_Start_Date_Text__c  = string.valueOf(prj.ICRM_Start_Date__c);
            prj.ICRM_End_Date_Text__c  = string.valueOf(prj.ICRM_End_Date__c);
        }        
    }
    // Operation on after insert    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {  
        Id proRecordTypeId = Schema.SObjectType.ICRM_Project__c.getRecordTypeInfosByName().get('ICRM_Project').getRecordTypeId();  
        List<ICRM_Project__c> newProjectList = new List<ICRM_Project__c>();
        Set<Id> projectIdShareSet = new Set<Id>();
        newProjectList = n;
        List<ICRM_Project__c> projectHeaderToInsert =new List<ICRM_Project__c>();  
        for(ICRM_Project__c pro:newProjectList)
        { 
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && pro.ICRM_BP_Confidential__c == True)
            {
                projectHeaderToInsert.add(pro);
            }  
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && (pro.ICRM_Commercial_SPA__c != null || pro.ICRM_Structurer_SPA__c != null))
            {
                projectIdShareSet.add(pro.id);
            } 			
        }
        if(!projectHeaderToInsert.isEmpty()){
            projectHeaderCreate(projectHeaderToInsert);
        }  
        if(!projectIdShareSet.isEmpty()){
            projectShareToSPAUsers(projectIdShareSet);
        }
        
    }
    
    // Operation on after update    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        Id proRecordTypeId = Schema.SObjectType.ICRM_Project__c.getRecordTypeInfosByName().get('ICRM_Project').getRecordTypeId(); 
        List<ICRM_Project__c> newProjectList = new List<ICRM_Project__c>();
        List<ICRM_Project__c> newProjectCreate = new List<ICRM_Project__c>();
        newProjectList = n;
        Map<Decimal,ICRM_Project__c> mapOfProject= new Map<Decimal,ICRM_Project__c>();
        Map<Decimal,ICRM_Project__c> mapOfProjectToDelete= new Map<Decimal,ICRM_Project__c>();
        Set<Id> setOwnerChanged = new Set<Id>();
        Set<Id> setNPVChanged = new Set<Id>();
        Set<Id> setStageChanged = new Set<Id>();
        for(ICRM_Project__c pro:newProjectList)
        {
			if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && (((ICRM_Project__c)nMap.get(pro.id)).name != ((ICRM_Project__c)oMap.get(pro.id)).name || ((ICRM_Project__c)nMap.get(pro.id)).ownerid != ((ICRM_Project__c)oMap.get(pro.id)).ownerid || ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Inception_Date__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_Inception_Date__c || ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Stage__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_Stage__c || ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Priority__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_Priority__c || ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Commercial_SPA__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_Commercial_SPA__c) && pro.ICRM_BP_Confidential__c == True){
                
                mapOfProject.put(pro.ICRM_Project_ID__c,pro);
            }
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_BP_Confidential__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_BP_Confidential__c && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_BP_Confidential__c == True){
                
                newProjectCreate.add(pro);
            }
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_BP_Confidential__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_BP_Confidential__c && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_BP_Confidential__c == False){
                
                mapOfProjectToDelete.put(pro.ICRM_Project_ID__c,pro);
            }
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && ((ICRM_Project__c)nMap.get(pro.id)).ownerid != ((ICRM_Project__c)oMap.get(pro.id)).ownerid)
            {
                setOwnerChanged.add(pro.id);
            }
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_NPV__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_NPV__c)
            {
				setNPVChanged.add(pro.id);
            }
            if(!newProjectList.isEmpty() && pro.recordTypeId == proRecordTypeId && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Stage__c != ((ICRM_Project__c)oMap.get(pro.id)).ICRM_Stage__c && ((ICRM_Project__c)nMap.get(pro.id)).ICRM_Stage__c == 'Execute')
            {
                setStageChanged.add(pro.id);
            }
        }
        if(!mapOfProject.isEmpty()){
            projectHeaderUpdate(mapOfProject);
        }
        if(!newProjectCreate.isEmpty()){
            projectHeaderCreate(newProjectCreate);
        }
        if(!mapOfProjectToDelete.isEmpty()){
            projectHeaderDelete(mapOfProjectToDelete);
        }
        if(!setOwnerChanged.isEmpty()){
            projectTeamShareRevise(setOwnerChanged);
        }
        if(!setNPVChanged.isEmpty()){
            Map<Id,List<Opportunity>> mapProjectWiseOpptyforNPV = getOpportunityRelatedToProject(setNPVChanged);
            NPVSyncToOpportunity(setNPVChanged,mapProjectWiseOpptyforNPV,oMap);
        }
        if(!setStageChanged.isEmpty()){
            Map<Id,List<Opportunity>> mapProjectWiseOpptyforStage = getOpportunityRelatedToProject(setStageChanged);
            stageSyncToOpportunity(setStageChanged,mapProjectWiseOpptyforStage);
        }
    }
    // Operation on after delete    
    public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        Id proRecordTypeId = Schema.SObjectType.ICRM_Project__c.getRecordTypeInfosByName().get('ICRM_Project').getRecordTypeId();  
        List<ICRM_Project__c> projectDeleteList = new List<ICRM_Project__c>();
        projectDeleteList = o;
        Map<Decimal,ICRM_Project__c> mapOfProject= new Map<Decimal,ICRM_Project__c>();
        for(ICRM_Project__c pro:projectDeleteList)
        { 
            if(!projectDeleteList.isEmpty() && pro.recordTypeId == proRecordTypeId && pro.ICRM_BP_Confidential__c == True)
            {
                mapOfProject.put(pro.ICRM_Project_ID__c,pro);
            }  
        }
        if(!mapOfProject.isEmpty()){
            projectHeaderDelete(mapOfProject);
        }    
    }
    /** Method to get list of Opportunity related to particular Project**/
    public Map<Id,List<Opportunity>> getOpportunityRelatedToProject(Set<Id> setProjectChanged){
        
        Map<Id,List<Opportunity>> mapProjectWiseOppty = new Map<Id,List<Opportunity>>();
        for(Opportunity opp : [SELECT id,Name,ICRM_Project__c,StageName,ICRM_Send_Email__c,Description,ICRM_Reason__c from Opportunity WHERE ICRM_Project__c in:setProjectChanged]){
            if(mapProjectWiseOppty.containsKey(opp.ICRM_Project__c))
            {
                mapProjectWiseOppty.get(opp.ICRM_Project__c).add(opp);
            }
            else
            {
                mapProjectWiseOppty.put(opp.ICRM_Project__c,new List<Opportunity>{opp});
            }
        }
        return mapProjectWiseOppty;
        
    }
    
    /** Method to Sync NPV value to Opportunity if Project is asociated with Single Opportunity**/
    public void NPVSyncToOpportunity(Set<Id> setNPVChanged, Map<Id,List<Opportunity>> mapProjectWiseOpptyforNPV,Map<Id, SObject> oMap){
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> opptyDetailSet = new Set<Id>();
        List<Id> otmUserIds = new List<Id>();
        List<Opportunity> opptyNPVUpdateList  = new List<Opportunity>();
        Opportunity opptyToUpdate = new Opportunity();
        for(ICRM_Project__c prj : [SELECT id,ICRM_NPV__c from ICRM_Project__c WHERE Id in:setNPVChanged]){
            if(mapProjectWiseOpptyforNPV.containsKey(prj.Id)){
                if(mapProjectWiseOpptyforNPV.get(prj.Id).size() == 1){
                    opptyIdSet.add(mapProjectWiseOpptyforNPV.get(prj.Id).get(0).id);
                    opptyToUpdate.id = mapProjectWiseOpptyforNPV.get(prj.Id).get(0).id;
                    opptyToUpdate.ICRM_NPV__c = prj.ICRM_NPV__c;
                    opptyNPVUpdateList.add(opptyToUpdate);
                }
            }
        }
        Map<Id,Opportunity> opptyDetailMap = new Map<Id,Opportunity>([Select Id, Name,Description,ICRM_Send_Email__c,ICRM_Project__c  FROM Opportunity WHERE ICRM_Project__c =: setNPVChanged]);
		Map<Id,ICRM_Project__c> projectDetailMap = new Map<Id,ICRM_Project__c>([Select Id, Name,LastModifiedBy.name,ICRM_NPV__c FROM ICRM_Project__c WHERE Id=: setNPVChanged]);
        EmailTemplate emailTemplate=[Select id,name,HtmlValue,Body,Subject from EmailTemplate where Developername  = 'ICRM_NPV_Sync_Notify' limit 1];
        Set<Id> setUserIds = new Set<Id>();
        setUserIds=permissionSetAssignmentCheck();
        if(!setUserIds.contains(UserInfo.getUserId())){
            for(OpportunityTeamMember otm : [SELECT id,UserId,TeamMemberRole,OpportunityId,ICRM_Team_member_name__c from OpportunityTeamMember WHERE OpportunityId in:opptyIdSet]){
                if(opptyDetailMap.get(otm.OpportunityId).ICRM_Send_Email__c !=null){
                    if(opptyDetailMap.get(otm.OpportunityId).ICRM_Send_Email__c.contains('NPV Update') && !(opptyDetailMap.get(otm.OpportunityId).ICRM_Send_Email__c.contains('No Email'))){
                        String subject = emailTemplate.Subject; 
                        String htmlBody = emailTemplate.HtmlValue;
                        if(projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).ICRM_NPV__c != null){
                            htmlBody = htmlBody.replace('{!ICRM_Project__c.ICRM_NPV__c}', String.valueOf(projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).ICRM_NPV__c));
                        }
                        else{
                            htmlBody = htmlBody.replace('{!ICRM_Project__c.ICRM_NPV__c}',' ');
                        }
                        if(((ICRM_Project__c)oMap.get(projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).id)).ICRM_NPV__c != null){
                            htmlBody = htmlBody.replace('{!ICRM_Project__c.Previous_ICRM_NPV__c}', String.valueOf(((ICRM_Project__c)oMap.get(projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).id)).ICRM_NPV__c));
                        }
                        else{
                            htmlBody = htmlBody.replace('{!ICRM_Project__c.Previous_ICRM_NPV__c}',' ');
                        }
                        setHTMLBodyForEmail(otm,subject,htmlBody, projectDetailMap, opptyDetailMap,emailTemplate);
                        
                    }
                }
            }
        }
        if(!opptyNPVUpdateList.isEmpty()){
            Update opptyNPVUpdateList;
        }
        
    }
    /* Check for logged in user permission set */
    public Set<Id> permissionSetAssignmentCheck(){
        Set<Id> setUserIds = new Set<Id>();
        for(PermissionSetAssignment AssignmentCheck : [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ICRM_Data_Load']){
            setUserIds.add(AssignmentCheck.AssigneeId);
            
        }
        return setUserIds;
    }
    /* Method to override the merge field for email alert */
    public void setHTMLBodyForEmail(OpportunityTeamMember otm,String subject,String htmlBody,Map<Id,ICRM_Project__c> projectDetailMap, Map<Id,Opportunity> opptyDetailMap,EmailTemplate emailTemplate ){
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE Address='do-not-reply@bp.com'limit 1];
        subject = subject.replace('{!Opportunity.Name}', opptyDetailMap.get(otm.OpportunityId).Name);
        if(otm.ICRM_Team_member_name__c  != null){
            htmlBody = htmlBody.replace('{!OpportunityTeamMember.ICRM_Team_member_name__c}', otm.ICRM_Team_member_name__c );
        }
        htmlBody = htmlBody.replace('{!ICRM_Project__c.LastModifiedBy}', projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).LastModifiedBy.name );
        htmlBody = htmlBody.replace('{!ICRM_Project__c.Name}', projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).Name);
        htmlBody = htmlBody.replace('{!Opportunity.Name}', opptyDetailMap.get(otm.OpportunityId).Name);
        htmlBody = htmlBody.replace('{!OpportunityTeamMember.TeamMemberRole}', otm.TeamMemberRole);
        htmlBody = htmlBody.replace('{!Opportunity.Id}', opptyDetailMap.get(otm.OpportunityId).Id);
        htmlBody = htmlBody.replace('{!ICRM_Project__c.Id}', projectDetailMap.get(opptyDetailMap.get(otm.OpportunityId).ICRM_Project__c).id);
        
        if(opptyDetailMap.get(otm.OpportunityId).Description != null){
            htmlBody = htmlBody.replace('{!Opportunity.Description}',opptyDetailMap.get(otm.OpportunityId).Description);
        }
        else{
            htmlBody = htmlBody.replace('{!Opportunity.Description}',' ');
        }
        Messaging.SingleEmailMessage  Email = new Messaging.SingleEmailMessage();
        Email.setSubject(subject);
        Email.setHtmlBody(htmlBody);
        Email.setTemplateId(emailTemplate.id); 
        Email.setSaveAsActivity(false);
        Email.setTargetObjectId(otm.UserId);
        Email.setOrgWideEmailAddressId(owa.id);
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {Email});
        
    }
    
    /** Method to Sync Stage value from Project to Opportunity**/
    public void stageSyncToOpportunity(Set<Id> setStageChanged,Map<Id,List<Opportunity>> mapProjectWiseOpptyforStage){
        
        List<Opportunity> opptyStageUpdateList  = new List<Opportunity>(); 
        Set<Id> opptyIdSet = new Set<Id>();
        Map<Id,Opportunity> opptyStageChangeMap = new Map<Id,Opportunity>();
        for(ICRM_Project__c prj : [SELECT id from ICRM_Project__c WHERE Id in:setStageChanged]){
            if(mapProjectWiseOpptyforStage.containsKey(prj.Id)){
                for(Opportunity opty : mapProjectWiseOpptyforStage.get(prj.Id)){
                    if(!(opty.StageName == 'Closed - Won' || opty.StageName == 'Closed - Lost' || opty.StageName == 'Closed - Abandoned')){
                        opptyIdSet.add(opty.id);
                        opptyStageChangeMap.put(opty.id,opty);
                        Opportunity opptyToUpdate = new Opportunity();
                        opptyToUpdate.id = opty.id;
                        opptyToUpdate.StageName = 'Closed - Won';	
                        if(opty.ICRM_Reason__c == null){
                            opptyToUpdate.ICRM_Reason__c = 'Project Execution';
                        }
                        opptyStageUpdateList.add(opptyToUpdate);
                    }
                }
            }
        }
        Set<Id> setUserIds = new Set<Id>();
        setUserIds=permissionSetAssignmentCheck();
        if(!setUserIds.contains(UserInfo.getUserId())){
			Map<Id,ICRM_Project__c> projectStageMap = new Map<Id,ICRM_Project__c>([Select Id, Name,LastModifiedBy.name FROM ICRM_Project__c WHERE Id=: setStageChanged]);
            EmailTemplate emailTemplate=[Select id,name,HtmlValue,Body,Subject from EmailTemplate where Developername  = 'ICRM_Stage_Sync_Notify' limit 1];
            for(OpportunityTeamMember otm : [SELECT id,UserId,TeamMemberRole,OpportunityId,ICRM_Team_member_name__c from OpportunityTeamMember WHERE OpportunityId in:opptyIdSet]){
                if(opptyStageChangeMap.get(otm.OpportunityId).ICRM_Send_Email__c !=null && opptyStageChangeMap.get(otm.OpportunityId).StageName != 'Closed - Won'){
                    if(opptyStageChangeMap.get(otm.OpportunityId).ICRM_Send_Email__c.contains('Stage Change') && !(opptyStageChangeMap.get(otm.OpportunityId).ICRM_Send_Email__c.contains('No Email'))){
                        String subject = emailTemplate.Subject;
                        String htmlBody = emailTemplate.HtmlValue;
                        htmlBody = htmlBody.replace('{!Opportunity.Previous_StageName}',opptyStageChangeMap.get(otm.OpportunityId).StageName);
                        htmlBody = htmlBody.replace('{!Opportunity.StageName}', 'Closed - Won');
                        setHTMLBodyForEmail(otm,subject,htmlBody, projectStageMap, opptyStageChangeMap,emailTemplate);
                        
                    }
                }
            }
        }
        if(!opptyStageUpdateList.isEmpty()){
            Update opptyStageUpdateList;
        }
    }
    /** Method to give Edit access to Structurer SPA and Commercial SPA Users to the project**/
    public void projectShareToSPAUsers(Set<Id> projectIdShareSet){
        
        List<ICRM_Project__Share> projShareList  = new List<ICRM_Project__Share>();
        for(ICRM_Project__c prj : [Select id,ICRM_Commercial_SPA__c,ICRM_Structurer_SPA__c FROM ICRM_Project__c where id in : projectIdShareSet]){
            
            if(prj.ICRM_Commercial_SPA__c != null){
                ICRM_Project__Share spaShare = new ICRM_Project__Share();
                spaShare.ParentId = prj.id;    
                spaShare.UserOrGroupId = prj.ICRM_Commercial_SPA__c; 
                spaShare.AccessLevel = 'Edit';
                projShareList.add(spaShare);
            }
            if(prj.ICRM_Structurer_SPA__c != null){
                ICRM_Project__Share spaShare1 = new ICRM_Project__Share();
                spaShare1.ParentId = prj.id;    
                spaShare1.UserOrGroupId = prj.ICRM_Structurer_SPA__c; 
                spaShare1.AccessLevel = 'Edit';
                projShareList.add(spaShare1);
            }
            
        }
        if(!projShareList.isEmpty()){
            Database.SaveResult[] coShareInsertResult = Database.insert(projShareList,false);
        }
    }
    
    /** Method to give Project team member access to project again when ownership changes**/
    public void projectTeamShareRevise(Set<Id> setOwnerChanged){
        
        List<ICRM_Confidential_Project__c> projectHeaderListDelete= new List<ICRM_Confidential_Project__c>();
        List<ICRM_Project__Share> projShares  = new List<ICRM_Project__Share>();
        for(ICRM_Project_Team__c pTeam : [Select id,ICRM_User__c,ICRM_Project__c FROM ICRM_Project_Team__c where ICRM_Project__c in : setOwnerChanged]){
            ICRM_Project__Share teamMemberShare = new ICRM_Project__Share();
            teamMemberShare.ParentId = pTeam.ICRM_Project__c;    
            teamMemberShare.UserOrGroupId = pTeam.ICRM_User__c; 
            teamMemberShare.AccessLevel = 'Edit';
            projShares.add(teamMemberShare);
        }
        if(!projShares.isEmpty()){
            Database.SaveResult[] coShareInsertResult = Database.insert(projShares,false);
        }
    }
    /** Method to create Project Header record whenever a Confidential Project got create **/
    public void projectHeaderCreate(List<ICRM_Project__c> projectHeaderToInsert){
        
        List<ICRM_Confidential_Project__c> projectHeaderListToInsert = new List<ICRM_Confidential_Project__c>();
        ICRM_Confidential_Project__c projectHed = new ICRM_Confidential_Project__c();
        for(ICRM_Project__c pro:projectHeaderToInsert){
            projectHed.name = pro.name;
            projectHed.ownerid = pro.ownerid;
            projectHed.ICRM_Related_Project__c = pro.id;
            projectHed.ICRM_Commercial_SPA__c = pro.ICRM_Commercial_SPA__c;
            projectHed.ICRM_Inception_Date__c = pro.ICRM_Inception_Date__c;
            projectHed.ICRM_Stage__c = pro.ICRM_Stage__c;
            projectHed.ICRM_Priority__c = pro.ICRM_Priority__c;
            projectHed.ICRM_Project_ID__c = pro.ICRM_Project_ID__c;
            projectHeaderListToInsert.add(projectHed);
        }
        if(!projectHeaderListToInsert.isEmpty()){
            Insert projectHeaderListToInsert; 
        }
    }
    /** Method to update Project Header record whenever a Confidential Project got updated **/
    public void projectHeaderUpdate(Map<Decimal,ICRM_Project__c> mapOfProject){
        
        List<ICRM_Confidential_Project__c> projectHeaderToUpdate = new List<ICRM_Confidential_Project__c>();
        ICRM_Confidential_Project__c projectHed = new ICRM_Confidential_Project__c();
        for(ICRM_Confidential_Project__c proHead : [Select id,Name,ownerid,ICRM_Inception_Date__c,ICRM_Commercial_SPA__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c FROM ICRM_Confidential_Project__c where ICRM_Project_ID__c in : mapOfProject.keyset()]){
            projectHed.id = proHead.id;
            projectHed.name = mapOfProject.get(proHead.ICRM_Project_ID__c).name;
            projectHed.ownerid = mapOfProject.get(proHead.ICRM_Project_ID__c).ownerid;
            projectHed.ICRM_Commercial_SPA__c = mapOfProject.get(proHead.ICRM_Project_ID__c).ICRM_Commercial_SPA__c;
            projectHed.ICRM_Inception_Date__c = mapOfProject.get(proHead.ICRM_Project_ID__c).ICRM_Inception_Date__c;
            projectHed.ICRM_Stage__c = mapOfProject.get(proHead.ICRM_Project_ID__c).ICRM_Stage__c;
            projectHed.ICRM_Priority__c = mapOfProject.get(proHead.ICRM_Project_ID__c).ICRM_Priority__c;
            projectHeaderToUpdate.add(projectHed);
        }
        if(!projectHeaderToUpdate.isEmpty()){
            Update projectHeaderToUpdate; 
        }
    }
    /** Method to delete Project Header record whenever a Confidential Project got deleted **/
    public void projectHeaderDelete(Map<Decimal,ICRM_Project__c> mapOfProject){
        
        List<ICRM_Confidential_Project__c> projectHeaderListDelete= new List<ICRM_Confidential_Project__c>();
        ICRM_Confidential_Project__c projectHed = new ICRM_Confidential_Project__c();
        for(ICRM_Confidential_Project__c proHead : [Select id,ICRM_Project_ID__c FROM ICRM_Confidential_Project__c where ICRM_Project_ID__c in : mapOfProject.keyset()]){
            projectHed.id = proHead.id;
            projectHeaderListDelete.add(projectHed);
        }
        if(!projectHeaderListDelete.isEmpty()){
            Delete projectHeaderListDelete; 
        }
    }
    
}