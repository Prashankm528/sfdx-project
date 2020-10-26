///**********Created for testing of RP Proposal Page and should not be deployed**************/////

public with sharing class LCP_ViewRPProposalController {

    // to fetch RP picklist values w.r.t. template selected
    @AuraEnabled
    public static Map<ID,String> getRPPicklistvalues(String templatename){
        Map<Id,string> rpList = new Map<Id,string>();
        for (LCP_Reporting_Period__c rpRecord: [SELECT id,Name,LCP_Project__r.LCP_Program_Template_Name__c from LCP_Reporting_Period__c where LCP_Project__r.LCP_Program_Template_Name__c =: templatename ORDER BY CreatedDate DESC limit 10000 ]){
            rpList.put(rpRecord.Id, rpRecord.Name);
        }
        return rpList;
    }
    
    // to fetch Template values
    @AuraEnabled
    public static List<String> getPicklistTemplatevalues(){
        List<String> optionsList = new List<String>();
        for(String opts: System.Label.LCP_Template_Name.split(',')){
            optionsList.add(opts);
        }
        return optionsList;
    }
   
    // to fetch RP Proposal record details w.r.t. RP selected
    @AuraEnabled
    public static ViewRPCombinedWrapper fetchRPProposalRecord(String templateName, Id rpId){//Id rpId
        ViewRPCombinedWrapper combinedRpProposalData= new ViewRPCombinedWrapper();
        List<String> rpPropfieldsFromMetadata = new List<String>();
        List<String> listOfRPFields = new List<String>();
        List<String> listOfRpProposalFields = new List<String>();
        List<String> listOfrpApprovedRpFields = new List<String>();
        List<String> listOfRPLabels = new List<String>();
        Map<String, String> listOfLabelMap= new Map<String, String> ();
        String pageLayoutName;
        String TobereviewedRPprosal = SYSTEM.LABEL.LCP_Tobereviewed_Status;
        String ApprovedRPprosal = SYSTEM.LABEL.LCP_Approved_Status;
        String ReviewedRPprosal = SYSTEM.LABEl.LCP_Reviewed_Status;
        String duplicatetemplateName;
        
        if(templateName.equalsIgnoreCase('Conversion Only')){
            duplicatetemplateName = 'LCP_RP_Proposal_Conversion_Only';
        }
        else if(templateName != ''){
            duplicatetemplateName = 'LCP_RP_Proposal_'+templateName;
        }
        
        // Retrieving Rp proposal fields from CustomMetaData based on template
        LCP_BP_Query_Field__mdt rpproposalqueryFields = [SELECT MasterLabel,Query_Fields__c,Object_Name__c FROM LCP_BP_Query_Field__mdt WHERE Object_Name__c = 'LCP_Reporting_Period_Proposal__c' AND MasterLabel =: duplicatetemplateName limit 1];
        rpPropfieldsFromMetadata = rpproposalqueryFields.Query_Fields__c.split(',');
        
        Map<String, Schema.DisplayType> dataTypeMap= new Map<String, Schema.DisplayType> (); 
        for(LCP_Template_RPProposalMapping__c tempRP:[select name,LCP_Field_Names__c,LCP_PageLayoutName__c,LCP_RecordTypeName__c from LCP_Template_RPProposalMapping__c limit 100]){
            if(templateName == tempRP.name){
                pageLayoutName=tempRP.LCP_PageLayoutName__c;
                for(String tempString : tempRP.LCP_Field_Names__c.split(',')){
                    listOfrpApprovedRpFields.add(tempString);
                }
            }
        }
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('LCP_Reporting_Period_Proposal__c');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
         // Retrieving the list of Rp Proposal fields on basis of permission Set
        List<FieldPermissions> rpProposalfields=[SELECT id,Field,SobjectType FROM FieldPermissions  WHERE SobjectType = 'LCP_Reporting_Period_Proposal__c' AND Parent.Name='LCP_CP_Developers' AND PermissionsRead=true ];
        List<String> cpDevRpProposalfields = new List<String>();
        for(FieldPermissions f : rpProposalfields){
            List<String> splitFields = String.valueOf(f.Field).split('\\.');
            cpDevRpProposalfields.add(splitFields[1]); // contains fields which are visible to CP developers 
        } 
        
        if(LCP_RpProposalApprovalsController.fetchLoggedInInfo()){
            listOfRPFields.addAll(rpPropfieldsFromMetadata);
            listOfrpProposalFields.addAll(rpPropfieldsFromMetadata);
            listOfrpApprovedRpFields.addAll(rpPropfieldsFromMetadata);
        }else{      
            for(String field :rpPropfieldsFromMetadata){
                if(cpDevRpProposalfields.contains(field)){
                    listOfRPFields.add(field);
                    listOfrpProposalFields.add(field);
                    listOfrpApprovedRpFields.add(field);
                    system.debug('#####item.field'+field);
                }
            }
            listOfRPFields.add('Name');
        }
        
        for(String rpfieldName:listOfrpApprovedRpFields){
            listOfRPLabels.add(fieldMap.get(rpfieldName).getDescribe().getLabel());
            listOfLabelMap.put(rpfieldName, fieldMap.get(rpfieldName).getDescribe().getLabel());
        }
        
        String query = 'select Id, ' + String.join(listOfRPFields, ', ') + ' from LCP_Reporting_Period__c WHERE Id =: rpId '; //query using RP Id
        listOfRpProposalFields.add('LCP_Status__c');
        listOfLabelMap.put('LCP_Status__c', 'Status');
        String tobeReviewedRPProposal = 'select Id, ' + String.join(listOfRpProposalFields, ', ') + ' from LCP_Reporting_Period_Proposal__c WHERE LCP_Reporting_Period__c =: rpId and LCP_Status__c = \'' + TobereviewedRPprosal + '\' limit 1'; //query using RP Id
        String approvedRPProposal = 'select Id, ' + String.join(listOfrpApprovedRpFields, ', ') + ' from LCP_Reporting_Period_Proposal__c WHERE LCP_Reporting_Period__c =: rpId and LCP_Status__c IN ( \'' + ApprovedRPprosal + '\' , \'' + ReviewedRPprosal + '\') Order by LastModifiedDate desc'; //query using RP Id
        
        try{
            LCP_Reporting_Period__c rpRec = Database.query(query);
            combinedRpProposalData.wrapperRpRecs=rpRec;
        }catch(Exception e){
            system.debug('Error occured on retriving the RP records of RP Proposal Record'+e.getMessage()+'Line Number'+e.getLineNumber());
        }
        
        try{
            LCP_Reporting_Period_Proposal__c tobeRevProposalRec = Database.query(tobeReviewedRPProposal);
            combinedRpProposalData.tobeRevProposalRec = tobeRevProposalRec;
        }catch(Exception e){
            system.debug('Error occured on retriving the status to be reviewed  rp proposal records'+e.getMessage()+'Line Number'+e.getLineNumber());
            combinedRpProposalData.noToBeReviewedRecords = 'Currently there are no To be Reviewed status RP Proposal records present';
        }
        
        try{
            List<LCP_Reporting_Period_Proposal__c> approvedrpp = Database.query(approvedRPProposal);
            if(approvedrpp.IsEmpty()){
                combinedRpProposalData.noApprovedProposalRecords = 'Currently there are no Approved or Reviewed Proposal Records';
            }
            combinedRpProposalData.approvedrpProposalsrecords = approvedrpp;
        }catch(Exception e){
            system.debug('Error occured on retriving the status to be Approved  rp proposal records'+e.getMessage()+'Line Number'+e.getLineNumber());
        }
        
        combinedRpProposalData.rpfieldList=listOfRPFields;
        combinedRpProposalData.rpproposalfieldList = listOfRpProposalFields;
        combinedRpProposalData.rplabelMap=listOfLabelMap;
        combinedRpProposalData.rplabelList=listOfRPLabels;
        combinedRpProposalData.rpapprovedfieldList = listOfrpApprovedRpFields;
        return combinedRpProposalData;  
        
    }
    Public with sharing class ViewRPCombinedWrapper{
        @AuraEnabled public  LCP_Reporting_Period__c wrapperRpRecs{get;set;}
        @AuraEnabled public  LCP_Reporting_Period_Proposal__c tobeRevProposalRec{get;set;}
        @AuraEnabled public  List<LCP_Reporting_Period_Proposal__c> approvedrpProposalsrecords{get;set;}
        @AuraEnabled public  List<String> rpfieldList{get;set;}
        @AuraEnabled public  List<String> rpproposalfieldList{get;set;}
        @AuraEnabled public  List<String> rpapprovedfieldList{get;set;}
        @AuraEnabled public  Map<String, String> rplabelMap {get;set;}
        @AuraEnabled public  List<String> rplabelList{get;set;}
        @AuraEnabled public  String noToBeReviewedRecords{get;set;}
        @AuraEnabled public  String noApprovedProposalRecords{get;set;}
        
    }  
}