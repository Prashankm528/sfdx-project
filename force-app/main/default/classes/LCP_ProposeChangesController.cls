public with sharing class LCP_ProposeChangesController {
    
    @AuraEnabled
    public static WrapperClass fetchExistingRpProposalDetails(String rpId){
        WrapperClass wrapperdata = new WrapperClass();
        List<String> listOfFields = new List<String>();
        List<String> fieldsOfCP= new List<String>();
        
        //To retrieve the selected RP related program template Name
        LCP_Reporting_Period__c rprec = [SELECT id,LCP_Project__r.LCP_Program_Template_Name__c from LCP_Reporting_Period__c WHERE Id =:rpId limit 1];
        wrapperdata.CurrentRpTemplateName = rprec.LCP_Project__r.LCP_Program_Template_Name__c;
        
        //To retrieve the selected RP recordType id
        LCP_Template_ReportingPeriodViewAll__c tempRP = [SELECT id,Name,LCP_RP_Proposal_Record_Type__c from LCP_Template_ReportingPeriodViewAll__c where Name =: rprec.LCP_Project__r.LCP_Program_Template_Name__c limit 1]; 
        wrapperdata.selectedRPRecordTypeID = Schema.Sobjecttype.LCP_Reporting_Period_Proposal__c.getRecordTypeInfosByDeveloperName().get(tempRP.LCP_RP_Proposal_Record_Type__c).getRecordTypeId(); 
        
        //Retrieving rp fields form CustomMetaData
        LCP_BP_Query_Field__mdt queryFields = [select Query_Fields__c from LCP_BP_Query_Field__mdt where MasterLabel =: rprec.LCP_Project__r.LCP_Program_Template_Name__c limit 1];
        List<String> fieldsFromMetadata = queryFields.Query_Fields__c.split(',');
        // list of fields on basis of permission Set
        List<FieldPermissions>fields = [SELECT Field FROM FieldPermissions  WHERE SobjectType = 'LCP_Reporting_Period__c' AND Parent.Name='LCP_CP_Developers' AND PermissionsRead=true];
        for(FieldPermissions f : fields){
            List<String> s2 =String.valueOf(f.Field).split('\\.');
            fieldsOfCP.add(s2[1]); // contains field which are visible to CP developers 
        }  
        //Checking if the logged in user is BP Manager or Cp Developer
        if(LCP_RpProposalApprovalsController.fetchLoggedInInfo()){  
            listOfFields.addAll(fieldsFromMetadata);
        }else{      
            for(String field :fieldsFromMetadata){
                if(fieldsOfCP.contains(field)){
                    listOfFields.add(field);
                }
            }
            listOfFields.add('Name');
        }
        //Building RP query with dynamic fields based on permission set
        String query = 'select Id,LCP_Project__r.LCP_Program_Template_Name__c, ' + String.join(listOfFields, ', ') + ' from LCP_Reporting_Period__c WHERE id =: rpId limit 1'; 
        LCP_Reporting_Period__c rpList = Database.query(query);
        wrapperdata.rprecData = rpList;
        
        //Checking whether the selected RP is already having proposed changes
        try{
            LCP_Reporting_Period_Proposal__c toBeReviewedRPProposalRec = [select Id,LCP_Status__c from LCP_Reporting_Period_Proposal__c where  LCP_Reporting_Period__c =: rpId AND LCP_Status__c = 'To be reviewed' limit 1];
            wrapperdata.IsRpHavingToBeReviewedProposal = true;   
        }catch(Exception e){
            wrapperdata.IsRpHavingToBeReviewedProposal = false;   
        }
        System.debug('wrapperdata'+wrapperdata);
        return wrapperdata;
    }
    
    public with sharing class WrapperClass{
        @AuraEnabled Public LCP_Reporting_Period__c rprecData {get;set;}
        @AuraEnabled Public Boolean IsRpHavingToBeReviewedProposal {get;set;}
        @AuraEnabled Public String CurrentRpTemplateName {get;set;}
        @AuraEnabled Public ID selectedRPRecordTypeID {get;set;}
    }
}