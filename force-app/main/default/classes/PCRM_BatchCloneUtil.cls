/*****************************************************************************************
*   Date: 08/25/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Utility class for Batch class 
*   Version 1.1 
****************************************************************************************/
public with Sharing class PCRM_BatchCloneUtil {
	    
    //Method is used to get record from customer metadata
    public static List<PCRM_Batch_Clone__mdt> getCustomMetatdata(String ObjectName){
        List<PCRM_Batch_Clone__mdt> lstOppCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
        lstOppCustomCloneField = [SELECT Id,Label,PCRM_Object_Name__c,PCRM_SourceField__c,PCRM_TargetField__c FROM PCRM_Batch_Clone__mdt WHERE PCRM_Object_Name__c =:ObjectName];
        return lstOppCustomCloneField;
    }
    //method is used to get the next month in mmm formate
    public static String getMonth(){
       String strNextMonth = Datetime.now().addMonths(1).format('MMM');
       return strNextMonth;
    }
    //Method is used to get the next quarter number
    public static String getQuarter(){       
        Integer NextQuarter;
        String strQtr = 'Q';
        NextQuarter =(((System.Today().month())-1)/3) + 2;                    
        if(NextQuarter == 5 ){
            strQtr = 'Q1';            
        }else{
            strQtr+=NextQuarter ;
        }   
        return strQtr;
    }
    //Method is used to get the year of next month or quarter
    public static String getYear(String frequency){       
        String strYear = String.valueof(System.Today().year());
        if(frequency == 'Quarterly'){
            Integer NextQuarter =(((System.Today().month())-1)/3) + 2;                    
            if(NextQuarter == 5 ){
                strYear = String.valueof(System.Today().year() + 1);   
            }
        }
        else if(frequency == 'Monthly'){
            if (System.Today().Month() == 12){
                strYear = String.valueof(System.Today().year() + 1);
            }     
        }
        return strYear;
    }
    
    //Method is used to get new end date
     public static Date getEndDate(Date startdate ,Date enddate){  
         Date newStartdate = enddate.addDays(1);     	 
         Date newEndDate = newStartdate.addDays(startdate.daysBetween(enddate)); 
        /*if(startdate.MonthsBetween(enddate) <=1 ){        
            Integer endDayOfStartDate = startdate.toStartOfMonth().addMonths(1).addDays(-1).day();
            Integer endDayOfNewStartDate = newStartdate.toStartOfMonth().addMonths(1).addDays(-1).day();          
            Integer daysdiff = (endDayOfStartDate-endDayOfNewStartDate);            
            newEndDate = enddate.adddays(1 + startdate.daysBetween(enddate) - daysdiff)  ; 
            
        }else{           
            newEndDate = (startdate.month() == enddate.month() ? enddate.addMonths( startdate.MonthsBetween(enddate)):
                           enddate.addMonths( 1+ startdate.MonthsBetween(enddate))) ;    
        }*/
        return newEndDate;
     }
    
    //perform DML on records
    public static DMLResponseWrapper deleteRecords(List<SObject> recordsToBeDeleted )
    {
        DMLResponseWrapper respWrapper = NEW DMLResponseWrapper();
        Database.DeleteResult[] srList = Database.delete(recordsToBeDeleted, false); 
        for(Database.DeleteResult sr :srList ){
            if(sr.isSuccess()) {
                respWrapper.successIds.add(sr.getId());                
            }else{
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    respWrapper.strError =  respWrapper.strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';                    
                }               
            }
        }
        return respWrapper;        
    }  

    //perform DML on records
    public static DMLResponseWrapper insertRecords(List<SObject> recordsToBeInserted,String dmlOperation)
    {
        DMLResponseWrapper respWrapper = NEW DMLResponseWrapper();                 
        Database.saveResult[] srList = (dmlOperation == 'insert')? Database.insert(recordsToBeInserted, false) : Database.update(recordsToBeInserted, false);      
        
        for( Database.saveResult sr :srList ) {
            if(sr.isSuccess()){
                respWrapper.successIds.add(sr.getId());                
            }else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    respWrapper.strError =  respWrapper.strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';                    
                }               
            } 
        }
        return respWrapper;        
    }  
    
    //Returns First SObject Returned By SOQL
    public static SObject queryFirstRecord(String soql) {
        List<SObject> objectList = Database.query(soql);
        for (SObject thisObject: objectList) {
            return thisObject;
        }
        return null;
    }
    
    //log Error
    //public void log(String strException,List<string>SuccessIDs,map<string,string>IdsTobeCloneWithOlOpportunityId, String strObjectName,string clonefromFieldName, string cloneType,Id ParentLogId)
    public static void logResult(String strException,List<ID>SuccessIDs,String strObjectName, String methodName,String cloneType,String ownerQueue){
        Group queue = (Group) queryFirstRecord('select Id, DeveloperName from Group where Type = \'Queue\' and DeveloperName = \'' + ownerQueue + '\' limit 1');
   		if (queue != null) {
            
            PCRM_Logger__c objLogger = new PCRM_Logger__c();    
            List<Id> successCloneFromIds = NEW List<Id>();
            Id RecordTypeIdLogger = Schema.SObjectType.PCRM_Logger__c.getRecordTypeInfosByDeveloperName().get('PCRM_Logger').getRecordTypeId();
           
            objLogger.PCRM_Object_Name__c = strObjectName;   
            objLogger.OwnerId = queue.Id;
     		objLogger.PCRM_User__c = UserInfo.getUserId();
            objLogger.PCRM_Processed_IDs__c = (SuccessIDs != null && (!SuccessIDs.isEmpty())) ? string.join(SuccessIDs,',') : null;
            objLogger.PCRM_Object_Name__c = strObjectName;      
            objLogger.PCRM_Method__c = methodName;
            objLogger.PCRM_Clone_Type__c = cloneType;
            objLogger.PCRM_Failure_Records__c = strException ; 
            objLogger.PCRM_Compete__c = (String.isEmpty(strException)) ? true : false ;
            insert objLogger;
        }
    }
    
    //wrapper class to return response of class saveResult
    public with sharing class DMLResponseWrapper
    {
        public List<Id> successIds {get;set;}
        public string strError {get;set;}
        public DMLResponseWrapper(){
            successIds = new List<ID>();
            strError = '';
        }
    }
    
}