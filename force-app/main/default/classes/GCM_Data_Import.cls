/****************************************************************************************************
*  Date          : 12-MAR-2020
*  Author        : Sunny Yap
*  Description   : Data import controller class.
* Modifications  : 
* 12-MAR-2020    : SYAP - Initial
12-May-2020    : Apoorv - Modifed the class for task and case insert logic with callable interface
****************************************************************************************************/
public with sharing class GCM_Data_Import {
    
    /****************************************************************************************************
* Parse Comma Separated, Double Quote Qualified Data Helper Method
****************************************************************************************************/    
    public static List<List<String>> parseData(String data) {
        try
        {
            // Parse Comma Delimited, Double Quote Qualified Fields
            List<String> records = data.split('\n(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
            List<List<String>> recordSets = new List<List<String>>();
            for (String record : records) {
                List<String> fields = record.split(',(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
                List<String> values = new List<String>();
                for (String field : fields) {
                    if (String.isNotBlank(field)) {
                        field = field.trim();
                        if (field.substring(field.length() - 1, field.length()) == '"') {
                            field = field.substring(0, field.length() - 1);
                        }
                        if (field.substring(0, 1) == '"') {
                            field = field.substring(1, field.length());
                        }
                        
                        // Replace Qualified Double Quotes
                        // With Single Double Quotes
                        field = field.replace('\"\"', '\"');
                    }
                    values.add(field);
                }
                recordSets.add(values);
            }
            return recordSets;
        }
        catch(exception ex)
        {
            system.debug('Error : GCM_Data_Import.ParseData'+ex.getMessage());
            return null;
        }
    }
    
    
    /****************************************************************************************************
* Import Data Utility
* Returns Error File (If Applicable)
****************************************************************************************************/    
    @auraEnabled(cacheable=false)
    public static string  importData_Callable(String template, String data) {
        String automationCode = null;
        
        try
        {
            GCM_File_Import__c objFileImportData = [select Id, GCM_Automation__c, GCM_Class__c, GCM_Method__c from GCM_File_Import__c where Name = :template];
            
            if(objFileImportData.GCM_Class__c == null || objFileImportData.GCM_Method__c == null)
                return 'ErrorCode_1';
            else
            {
                GCM_File_Import_Log__c log = new GCM_File_Import_Log__c();
                log.GCM_Input__c = data;
                insert log;
                
                Callable CallableDemo = (Callable) Type.forName(objFileImportData.GCM_Class__c).newInstance();
                string result = (string)CallableDemo.call(objFileImportData.GCM_Method__c, new Map<String, Object> { 
                    'idImportLogID' => log.Id 
                        });
                return log.id;
            }
        }
        catch(exception ex)
        {
            system.debug('Error : GCM_Data_Import.ParseData'+ex.getMessage());
            return null;
        }
    }
    
    /****************************************************************************************************
* return the status of the import file with number of success and error records
****************************************************************************************************/   
    @auraEnabled(cacheable=false)
    public static list<string> getLogStatus(ID idRecordID) {
        String[] strStatus;
        list<string> lstLogValues = new list<string>();
        GCM_File_Import_Log__c objFileLog ;
        try
        {
            string strFailed = 'Failed';
            if(idRecordID != null)
            {
                objFileLog = [select GCM_Status__c,GCM_Output__c from GCM_File_Import_Log__c where id =:idRecordID];
                if(objFileLog.GCM_Status__c != null)
                {
                    lstLogValues = objFileLog.GCM_Status__c.split(',');
                    lstLogValues.add(objFileLog.GCM_Output__c);
                    return lstLogValues;
                }
            }else
            {
                lstLogValues.add(strFailed);
                return lstLogValues;
            }  
        }
        catch(exception ex)
        {
            system.debug('Error : GCM_Data_Import.ParseData'+ex.getMessage());
            return null;
        }
        return null;
    }  
}