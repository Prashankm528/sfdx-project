public with sharing class LCP_RpProposalApprovalsController {
    //To fetch current logged in user info
    @AuraEnabled
    public static Boolean fetchLoggedInInfo(){
         Boolean givePermission = false;
        List<PermissionSetAssignment> currentUserPerSetList = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for ( PermissionSetAssignment psa : currentUserPerSetList ) {
            if (psa.PermissionSet.Name.equals(SYSTEM.LABEL.LCP_BP_Project_Manager)) {
                givePermission = true;
            }
        }
        return givePermission;
    }
    // to fetch RP Proposal record details
    @AuraEnabled
    public static ViewRPCombinedWrapper fetchRPProposalRecord(Id rpproposalId){
        List<String> rpProposalfieldsFromMetadata = new List<String>();
        List<String> RPFieldslist = new List<String>();
        List<String> rpProposalFieldsList = new List<String>();
        List<String> rpApprovedRpFieldsList = new List<String>();
        List<String> labelsList = new List<String>();
        Map<String, String> listOflabelsMap= new Map<String, String> ();
        String rpProposalPageLayoutName;
        String TobereviewedRPproposal = SYSTEM.LABEL.LCP_Tobereviewed_Status;
        String ApprovedRPproposal = SYSTEM.LABEL.LCP_Approved_Status;
        String ReviewedRPproposal = SYSTEM.LABEl.LCP_Reviewed_Status;
        
        ViewRPCombinedWrapper combinedRPandRPProposalData= new ViewRPCombinedWrapper();
        
        LCP_Reporting_Period_Proposal__c rpproposalrecord = [SELECT Id,LCP_Status__c,LCP_Reporting_Period__c FROM LCP_Reporting_Period_Proposal__c WHERE id =: rpproposalId];
        Id rpRecId = rpproposalrecord.LCP_Reporting_Period__c;
        LCP_Reporting_Period__c rpRecordWithTemplate = [select Id,LCP_Project__r.LCP_Program_Template_Name__c from LCP_Reporting_Period__c where LCP_Project__r.LCP_Program_Template_Name__c != null and id =: rpRecId ORDER BY CreatedDate DESC];
        String templateName = rpRecordWithTemplate.LCP_Project__r.LCP_Program_Template_Name__c;
        String templateNamedup;
        if(templateName.equalsIgnoreCase('Conversion Only')){
            templateNamedup = 'LCP_RP_Proposal_Conversion_Only';
        }
        else if(templateName != ''){
            templateNamedup = 'LCP_RP_Proposal_'+templateName;
        }
        
        // Retrieving Rp proposal fields from CustomMetaData based on template
        LCP_BP_Query_Field__mdt queryFields = [SELECT MasterLabel,Query_Fields__c,Object_Name__c FROM LCP_BP_Query_Field__mdt WHERE Object_Name__c = 'LCP_Reporting_Period_Proposal__c' AND MasterLabel =: templateNamedup limit 1];
        rpProposalfieldsFromMetadata = queryFields.Query_Fields__c.split(',');
        
        Map<String, Schema.DisplayType> dataTypeMap= new Map<String, Schema.DisplayType> (); 
        for(LCP_Template_RPProposalMapping__c customSettingRPProposalData:[select name,LCP_Field_Names__c,LCP_PageLayoutName__c,LCP_RecordTypeName__c from LCP_Template_RPProposalMapping__c limit 100]){
            if(templateName == customSettingRPProposalData.name){
                rpProposalPageLayoutName=customSettingRPProposalData.LCP_PageLayoutName__c;
                for(String tempString : customSettingRPProposalData.LCP_Field_Names__c.split(',')){
                    rpApprovedRpFieldsList.add(tempString);
                }
            }
        }
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType proposalSchema = schemaMap.get('LCP_Reporting_Period_Proposal__c');
        Map<String, Schema.SObjectField> proposalSchemaFieldsMap = proposalSchema.getDescribe().fields.getMap();
		
        // Retrieving the list of Rp Proposal fields on basis of permission Set
        List<FieldPermissions> rpProposalfields=[SELECT id,Field,SobjectType FROM FieldPermissions  WHERE SobjectType = 'LCP_Reporting_Period_Proposal__c' AND Parent.Name='LCP_CP_Developers' AND PermissionsRead=true ];
        List<String> cpDevRpProposalfields = new List<String>();
        for(FieldPermissions f : rpProposalfields){
            List<String> splitFields = String.valueOf(f.Field).split('\\.');
            cpDevRpProposalfields.add(splitFields[1]); // contains fields which are visible to CP developers 
            system.debug('cpDevRpProposalfields'+cpDevRpProposalfields);
        } 
        
        if(fetchLoggedInInfo()){
            RPFieldslist.addAll(rpProposalfieldsFromMetadata);
            rpProposalFieldsList.addAll(rpProposalfieldsFromMetadata);
            rpApprovedRpFieldsList.addAll(rpProposalfieldsFromMetadata);
        }else{      
            for(String field :rpProposalfieldsFromMetadata){
                if(cpDevRpProposalfields.contains(field)){
                    RPFieldslist.add(field);
                    rpProposalFieldsList.add(field);
                    rpApprovedRpFieldsList.add(field);
                    system.debug('#####item.field'+field);
                }
            }
        }
        system.debug('rpApprovedRpFieldsList'+rpApprovedRpFieldsList);
        for(String fieldName:rpApprovedRpFieldsList){
            system.debug('Label'+proposalSchemaFieldsMap.get(fieldName).getDescribe().getLabel());
            labelsList.add(proposalSchemaFieldsMap.get(fieldName).getDescribe().getLabel());
            listOflabelsMap.put(fieldName, proposalSchemaFieldsMap.get(fieldName).getDescribe().getLabel());
        }
        
        String rpRecQuery = 'select Id, ' + String.join(RPFieldslist, ', ') + ' from LCP_Reporting_Period__c WHERE Id =: rpRecId '; //query using RP Id
        
        rpProposalFieldsList.add('LCP_Status__c');
        listOflabelsMap.put('LCP_Status__c', 'Status');
        String tobeReviewedRPProposalQuery = 'select Id, ' + String.join(rpProposalFieldsList, ', ') + ' from LCP_Reporting_Period_Proposal__c WHERE LCP_Reporting_Period__c =: rpRecId and LCP_Status__c = \'' + TobereviewedRPproposal + '\' limit 1'; //query using RP Id
        
        String approvedRPProposalQuery = 'select Id, ' + String.join(rpApprovedRpFieldsList, ', ') + ' from LCP_Reporting_Period_Proposal__c WHERE LCP_Reporting_Period__c =: rpRecId and LCP_Status__c IN ( \'' + ApprovedRPproposal + '\' , \'' + ReviewedRPproposal + '\')  Order by LastModifiedDate desc'; //query using RP Id
        
        try{
            LCP_Reporting_Period__c rpRecResult = Database.query(rpRecQuery);
            combinedRPandRPProposalData.wrapperRpRecords=rpRecResult;
        }catch(Exception e){
            system.debug('Error occured on retriving the RP records of RP Proposal Record'+e.getMessage()+'Line Number'+e.getLineNumber());
        }
        
        try{
            LCP_Reporting_Period_Proposal__c tobeRevProposalRecResult = Database.query(tobeReviewedRPProposalQuery);
            combinedRPandRPProposalData.wrapperTobeRevProposalRec = tobeRevProposalRecResult;
        }catch(Exception e){
            system.debug('Error occured on retriving the status to be reviewed  rp proposal records'+e.getMessage()+'Line Number'+e.getLineNumber());
            combinedRPandRPProposalData.noToBeReviewedRecordsErrorMsg = 'Currently there are no To be Reviewed status RP Proposal records present';
        }
        
        
        try{
            List<LCP_Reporting_Period_Proposal__c> approvedRppResult = Database.query(approvedRPProposalQuery);
            if(approvedRppResult.IsEmpty()){
                combinedRPandRPProposalData.noApprovedProposalRecordsErrorMsg = 'Currently there are no Approved or Reviewed Proposal Records';
            }else{
                combinedRPandRPProposalData.wrapperApprovedRpProposalsRecords = approvedRppResult;
            }
        }catch(Exception e){
            system.debug('Error occured on retriving the status to be Approved  rp proposal records'+e.getMessage()+'Line Number'+e.getLineNumber());
        }
        
        combinedRPandRPProposalData.wrapperrpfieldsList=RPFieldslist;
        combinedRPandRPProposalData.wrapperRpProposalFieldList = rpProposalFieldsList;
        combinedRPandRPProposalData.wrapperRpApprovedFieldList = rpApprovedRpFieldsList;
        combinedRPandRPProposalData.wrapperlistOflabelsMap=listOflabelsMap;
        combinedRPandRPProposalData.wrapperlabelList=labelsList;
        return combinedRPandRPProposalData;  
    }
    
    Public with sharing class ViewRPCombinedWrapper{
        @AuraEnabled public  LCP_Reporting_Period__c wrapperRpRecords{get;set;}
        @AuraEnabled public  LCP_Reporting_Period_Proposal__c wrapperTobeRevProposalRec{get;set;}
        @AuraEnabled public  List<LCP_Reporting_Period_Proposal__c> wrapperApprovedRpProposalsRecords{get;set;}
        @AuraEnabled public  List<String> wrapperrpfieldsList{get;set;}
        @AuraEnabled public  List<String> wrapperRpProposalFieldList{get;set;}
        @AuraEnabled public  List<String> wrapperRpApprovedFieldList{get;set;}
        @AuraEnabled public  Map<String, String> wrapperlistOflabelsMap {get;set;}
        @AuraEnabled public  List<String> wrapperlabelList{get;set;}
        @AuraEnabled public  String noToBeReviewedRecordsErrorMsg{get;set;}
        @AuraEnabled public  String noApprovedProposalRecordsErrorMsg{get;set;}
    } 
    
}