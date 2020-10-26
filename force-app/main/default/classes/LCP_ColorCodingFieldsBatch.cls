/****************************************************************************************
*        Date:          6th June 2020
*       Author:         Indraganti Praneeth
*       Description:    This Batch Class runs on the daily basis to update the Project color coding fields to red when the respective color coding date exceeds today's date.
*       Modifications:  
********************************************************************************************/
global with Sharing class LCP_ColorCodingFieldsBatch implements Database.Batchable<Sobject>{
    //Returns all the project records which are exeeding today's date
    global Database.QueryLocator start(Database.BatchableContext bc){
        LCP_BP_Query_Field__mdt queryFields = [select MasterLabel,DeveloperName, Condition__c, Object_Name__c, Query_Fields__c from LCP_BP_Query_Field__mdt where DeveloperName='LCP_ColorCodingFieldsBatch' limit 1];
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
    global void execute(Database.BatchableContext bc, List<LCP_Project__c> scope){
        List<LCP_Project__c> Updateprojectfields = new List<LCP_Project__c>();
        for(LCP_Project__c projects : scope){
            if(projects.LCP_Application_documents__c != null && projects.LCP_Application_documents__c < SYSTEM.Today() && projects.LCP_Application_documents_color_code__c != null && projects.LCP_Application_documents_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Application_documents_color_code__c = System.Label.LCP_Passed;
            if(projects.LCP_Design_documents__c != null && projects.LCP_Design_documents__c < SYSTEM.Today() && projects.LCP_Design_documents_color_code__c != null && projects.LCP_Design_documents_color_code__c == System.Label.LCP_Forecast )
                projects.LCP_Design_documents_color_code__c         = System.Label.LCP_Passed ;
            if(projects.LCP_Val_start__c != null && projects.LCP_Val_start__c < SYSTEM.Today() && projects.LCP_Val_Start_color_code__c != null && projects.LCP_Val_Start_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Val_Start_color_code__c                = System.Label.LCP_Passed;
            if(projects.LCP_Val_end__c != null && projects.LCP_Val_end__c < SYSTEM.Today() && projects.LCP_Val_end_color_code__c != null && projects.LCP_Val_end_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Val_end_color_code__c                  = System.Label.LCP_Passed ;
            if(projects.LCP_Req_for_registration__c != null && projects.LCP_Req_for_registration__c < SYSTEM.Today() && projects.LCP_Req_for_registration_color_code__c != null && projects.LCP_Req_for_registration_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Req_for_registration_color_code__c     = System.Label.LCP_Passed ;
            if(projects.LCP_Listed__c != null && projects.LCP_Listed__c < SYSTEM.Today() && projects.LCP_Listed_color_code__c != null && projects.LCP_Listed_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Listed_color_code__c                   = System.Label.LCP_Passed ;
            if(projects.LCP_Registered__c != null && projects.LCP_Registered__c < SYSTEM.Today() && projects.LCP_Registered_color_code__c !=null && projects.LCP_Registered_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Registered_color_code__c               = System.Label.LCP_Passed ;
            if(projects.LCP_Operational_start_date__c != null && projects.LCP_Operational_start_date__c < SYSTEM.Today() && projects.LCP_Operational_start_date_color_code__c != null && projects.LCP_Operational_start_date_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Operational_start_date_color_code__c   = System.Label.LCP_Passed ;
            if(projects.LCP_Contract_date__c != null && projects.LCP_Contract_date__c < SYSTEM.Today() && projects.LCP_Contract_date_color_code__c != null && projects.LCP_Contract_date_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Contract_date_color_code__c            = System.Label.LCP_Passed ;
            if(projects.LCP_CP_start__c != null && projects.LCP_CP_start__c < SYSTEM.Today() && projects.LCP_CP_start_color_code__c != null && projects.LCP_CP_start_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_CP_start_color_code__c                 = System.Label.LCP_Passed ;
            if(projects.LCP_CP_end__c != null && projects.LCP_CP_end__c < SYSTEM.Today() && projects.LCP_CP_end_color_code__c != null && projects.LCP_CP_end_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_CP_end_color_code__c                   = System.Label.LCP_Passed ;
            if(projects.LCP_Date__c != null && projects.LCP_Date__c  <SYSTEM.Today() && projects.LCP_Date_color_code__c != null && projects.LCP_Date_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Date_color_code__c                     = System.Label.LCP_Passed ;
            if(projects.LCP_Date2__c != null && projects.LCP_Date2__c < SYSTEM.Today() && projects.LCP_Date2_color_code__c != null && projects.LCP_Date2_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_Date2_color_code__c                    = System.Label.LCP_Passed;
            if(projects.LCP_California_DEBS_approved__c != null && projects.LCP_California_DEBS_approved__c < SYSTEM.Today() && projects.LCP_California_DEBS_approved_color_code__c != null && projects.LCP_California_DEBS_approved_color_code__c == System.Label.LCP_Forecast)
                projects.LCP_California_DEBS_approved_color_code__c = System.Label.LCP_Passed ;
            Updateprojectfields.add(projects);
            
        }
        if(!Updateprojectfields.IsEmpty()){
            try{
                Database.update(Updateprojectfields);
            }Catch(Exception e){
                system.debug('Occured Exception'+e.getMessage()+e.getLineNumber());
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}