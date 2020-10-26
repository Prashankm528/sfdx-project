global with Sharing class LCP_RPColorCodingFieldsBatch implements Database.Batchable<Sobject>{
    //Returns all the RP records which are exeeding today's date
    global Database.QueryLocator start(Database.BatchableContext bc){
        LCP_BP_Query_Field__mdt queryFields = [select MasterLabel,DeveloperName, Condition__c, Object_Name__c, Query_Fields__c from LCP_BP_Query_Field__mdt where DeveloperName='LCP_RPColorCodingFields' limit 1];
        system.debug('queryFields'+queryFields);
        String query = 'SELECT ';							
        if(queryFields != NULL){
            query += queryFields.Query_Fields__c+' ';
            query +='FROM '+queryFields.Object_Name__c;
            if(queryFields.Condition__c != null){
                query +=' WHERE '+queryFields.Condition__c;
            }
        }
        system.debug('Query Constructed is '+ query);
        return Database.getQueryLocator(query);
    }
    //Execute method is updating all the Amber color coding fields to Red color when it exceeds today's date.
    global void execute(Database.BatchableContext bc, List<LCP_Reporting_Period__c> scope){
        List<LCP_Reporting_Period__c> Updaterpfields = new List<LCP_Reporting_Period__c>();
        for(LCP_Reporting_Period__c rp : scope){
            if(rp.LCP_ARBOC_Issuance_Date__c != null && rp.LCP_ARBOC_Issuance_Date__c < SYSTEM.Today() && rp.LCP_ARBOC_Issuance_Color_code__c != null && rp.LCP_ARBOC_Issuance_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_ARBOC_Issuance_Color_code__c = System.Label.LCP_Passed;
            if(rp.LCP_Delivery_Date2__c != null && rp.LCP_Delivery_Date2__c < SYSTEM.Today() && rp.LCP_Delivery_Date2_Color_code__c != null && rp.LCP_Delivery_Date2_Color_code__c == System.Label.LCP_Forecast )
                rp.LCP_Delivery_Date2_Color_code__c = System.Label.LCP_Passed ;
            if(rp.LCP_Conversion_Application__c != null && rp.LCP_Conversion_Application__c < SYSTEM.Today() && rp.LCP_Conversion_Application_Color_code__c != null && rp.LCP_Conversion_Application_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Conversion_Application_Color_code__c  = System.Label.LCP_Passed;
            if(rp.LCP_Conversion_Approval__c != null && rp.LCP_Conversion_Approval__c < SYSTEM.Today() && rp.LCP_Conversion_Approval_Color_code__c != null && rp.LCP_Conversion_Approval_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Conversion_Approval_Color_code__c  = System.Label.LCP_Passed ;
            if(rp.LCP_Delivery_Date__c != null && rp.LCP_Delivery_Date__c <  SYSTEM.Today() && rp.LCP_Delivery_Date_Color_code__c != null && rp.LCP_Delivery_Date_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Delivery_Date_Color_code__c = System.Label.LCP_Passed ;
            if(rp.LCP_End__c != null && rp.LCP_End__c < SYSTEM.Today() && rp.LCP_End_Color_code__c != null && rp.LCP_End_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_End_Color_code__c = System.Label.LCP_Passed ;
            if(rp.LCP_End_of_RP__c != null && rp.LCP_End_of_RP__c < SYSTEM.Today() && rp.LCP_End_of_RP_Color_Code__c !=null && rp.LCP_End_of_RP_Color_Code__c == System.Label.LCP_Forecast)
                rp.LCP_End_of_RP_Color_Code__c = System.Label.LCP_Passed ;
            if(rp.LCP_Issuance_Date__c != null && rp.LCP_Issuance_Date__c < SYSTEM.Today() && rp.LCP_Issuance_Date_Color_code__c != null && rp.LCP_Issuance_Date_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Issuance_Date_Color_code__c = System.Label.LCP_Passed ;
            if(rp.LCP_OPDR_Submitted__c != null && rp.LCP_OPDR_Submitted__c < SYSTEM.Today() && rp.LCP_OPDR_Submitted_Color_code__c != null && rp.LCP_OPDR_Submitted_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_OPDR_Submitted_Color_code__c  = System.Label.LCP_Passed ;
            if(rp.LCP_Report_Submitted__c != null && rp.LCP_Report_Submitted__c < SYSTEM.Today() && rp.LCP_Report_Submitted_Color_code__c != null && rp.LCP_Report_Submitted_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Report_Submitted_Color_code__c  = System.Label.LCP_Passed ;
            if(rp.LCP_ROC_Issuance_Date__c != null && rp.LCP_ROC_Issuance_Date__c < SYSTEM.Today() && rp.LCP_ROC_Issuance_Date_Color_code__c != null && rp.LCP_ROC_Issuance_Date_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_ROC_Issuance_Date_Color_code__c  = System.Label.LCP_Passed ;
            if(rp.LCP_Start__c != null && rp.LCP_Start__c < SYSTEM.Today() && rp.LCP_Start_Color_code__c != null && rp.LCP_Start_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Start_Color_code__c  = System.Label.LCP_Passed ;
            if(rp.LCP_Start_of_RP__c != null && rp.LCP_Start_of_RP__c < SYSTEM.Today() && rp.LCP_Start_of_RP_Color_code__c != null && rp.LCP_Start_of_RP_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Start_of_RP_Color_code__c  = System.Label.LCP_Passed;
            if(rp.LCP_Transfer_Date__c != null && rp.LCP_Transfer_Date__c < SYSTEM.Today() && rp.LCP_Transfer_Date_Color_code__c != null && rp.LCP_Transfer_Date_Color_code__c == System.Label.LCP_Forecast)
                rp.LCP_Transfer_Date_Color_code__c = System.Label.LCP_Passed ;
            
            rp.LCP_Channel__c = true;
            Updaterpfields.add(rp);
            
        }
        if(!Updaterpfields.IsEmpty()){
            try{
                Database.update(Updaterpfields);
            }Catch(Exception e){
                system.debug('Occured Exception'+e.getMessage()+e.getLineNumber());
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}