/********************************************************************************
 * Date          : 10-FEB-2020
 * Author        : Sunny Yap
 * Description   : Generic Update Record Invocable Method
 *               : Auto-Detects Field Data Type
 *                 Limited Only By Formula Maximum Length
 *                 "without sharing" class because there is use case to update
 *                 User.ManagerId 
 * Modifications :
 * 10-FEB-2020   : SYAP Supports Boolean, Date Time, String Data Types
 * 09-MAR-2020   : SYAP Added aura support, expose to lightning web components.
 * 24-MAR-2020   : Roselin Added return value to updateRecord method.
 * 01-APR-2020   : Roselin Added updateRecords to handle multiple records.
 ********************************************************************************/
public without sharing class GCM_Update_Record {
/********************************************************************************
 * Update Function With Field, Value Lists Separated By Pipe 
 ********************************************************************************/
@auraEnabled(cacheable=false)
    public static ResponseWrapper updateRecord(Id recordId, Map<String, String> fieldMap, Boolean throwException) {
        Boolean isSuccess = false;
        ResponseWrapper res = new ResponseWrapper();
        try {            
            List<String> fieldNames = new List<String>();
            fieldNames.addAll(fieldMap.keySet());
            List<String> fieldValues = fieldMap.values();
            String objectName = recordId.getSObjectType().getDescribe().getName();
            SObject record = recordId.getSObjectType().newSObject(recordId);
            record = Database.query('select ' + String.join(fieldNames, ',') + ' from ' + objectName + ' where Id =\'' +recordId + '\'');
            
            for (Integer count = 0; count < fieldNames.size(); count++) {
                String fieldName = fieldNames[count];
                String fieldValue = fieldValues[count];
                Object fieldObject = record.get(fieldName);
                Schema.DisplayType fieldType = recordId.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType();

                if (fieldObject instanceOf Boolean) {
                    Boolean value = fieldValue == 'true' ? true : false;
                    record.put(fieldName, value);
                }
                if (fieldType == Schema.DisplayType.DateTime) {
                    record.put(fieldName, DateTime.valueOf(fieldValue));
                }
                if (fieldType == Schema.DisplayType.String || 
                    fieldType == Schema.DisplayType.Picklist ||
                    fieldType == Schema.DisplayType.Reference ||
                    fieldType == Schema.DisplayType.TextArea ||
                    fieldType == Schema.DisplayType.Email ||
                    fieldType == Schema.DisplayType.MULTIPICKLIST) {
                    record.put(fieldName, fieldValue);
                }
            }

            update record;
            res.recId = recordId;
            res.isSuccess = true;
            res.message = 'Success';
         }
        catch (Exception exceptionObject) {
            if (throwException) {
                // Aura Enabled Components May Catch The Exception
                res.recId = recordId;
                res.isSuccess = false;
                res.message = 'Error'+exceptionObject.getMessage();
                throw exceptionObject;
            }
            else {
                res.recId = recordId;
                res.isSuccess = false;
                res.message = exceptionObject.getMessage();
                BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Update_Record', 'updateRecord', new Id[]{recordId}, 'GCM_Application_Administrator');
            }
        }
        return res;
    }
    
/********************************************************************************
 * Invocable Update Record Method
 ********************************************************************************/
    @InvocableMethod(label = 'GCM Update Record' description = 'GCM Update Record')
    public static void updateRecordInvocable(List<InputData> inputDataList) {
        Id recordId = null;
        recordId = (Id) inputDataList[0].recordId;         
        String fieldList = inputDataList[0].fieldNames;
        String valueList = inputDataList[0].fieldValues;

        // Construct Map
        List<String> fieldNames = fieldList.split('(\\|)');
        List<String> fieldValues = valueList.split('(\\|)');
        Map<String, String> fieldMap = new Map<String, String>();
        for (Integer count = 0; count < fieldNames.size(); count++) {
            if (fieldValues.size() > count) {
                fieldMap.put(fieldNames[count], fieldValues[count]);
            }
        }
        
        GCM_Update_Record.updateRecord(recordId, fieldMap, false);
    }
/********************************************************************************
 * Update Function to handle multiple records. Input - Map of RecordId and fieldMap
 ********************************************************************************/
    @auraEnabled(cacheable=false)
    public static List<ResponseWrapper> updateRecords(Map<Id,Map<String, String>> mapofIdandFieldMap, Boolean throwException) {
        Boolean isSuccess = false;
        List<ResponseWrapper> resList = new List<ResponseWrapper>();
        try {            
            List<SObject> sobjListToUpdate = new List<SObject>();
            for( Id recordId : mapofIdandFieldMap.keySet()){
                Map<String, String> fieldMap = mapofIdandFieldMap.get(recordId);
                List<String> fieldNames = new List<String>();
                fieldNames.addAll(fieldMap.keySet());
                List<String> fieldValues = fieldMap.values();
                String objectName = recordId.getSObjectType().getDescribe().getName();
                SObject record = recordId.getSObjectType().newSObject(recordId);
                record = Database.query('select ' + String.join(fieldNames, ',') + ' from ' + objectName + ' where Id =\'' +recordId + '\'');
                
                for (Integer count = 0; count < fieldNames.size(); count++) {
                    String fieldName = fieldNames[count];
                    String fieldValue = fieldValues[count];
                    Object fieldObject = record.get(fieldName);
                    Schema.DisplayType fieldType = recordId.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType();

                    if (fieldObject instanceOf Boolean) {
                        Boolean value = fieldValue == 'true' ? true : false;
                        record.put(fieldName, value);
                    }
                    if (fieldType == Schema.DisplayType.DateTime) {
                        record.put(fieldName, DateTime.valueOf(fieldValue));
                    }
                    if (fieldType == Schema.DisplayType.Date) {
                        record.put(fieldName, Date.valueOf(fieldValue));
                    }
                    if (fieldType == Schema.DisplayType.String || 
                        fieldType == Schema.DisplayType.Picklist ||
                        fieldType == Schema.DisplayType.Reference ||
                        fieldType == Schema.DisplayType.TextArea ||
                        fieldType == Schema.DisplayType.Email ||
                        fieldType == Schema.DisplayType.MULTIPICKLIST) {
                        record.put(fieldName, fieldValue);
                    }
                }
                 sobjListToUpdate.add(record);
            }
            if(!sobjListToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(sobjListToUpdate, false);
                // Database method to update the records in List

                // Iterate through each returned result by the method
                for (Database.SaveResult sr : srList) {
                   if (sr.isSuccess()) {
                      // This condition will be executed for successful records and will fetch
                      // the ids of successful records
                      System.debug('Successfully updated. ID is : ' + sr.getId());
                      ResponseWrapper res = new ResponseWrapper();
                      res.isSuccess = true;
                      res.message = 'Success';
                      res.recId = sr.getId();
                      resList.add(res);
                   } else {
                      // This condition will be executed for failed records
                      for(Database.Error objErr : sr.getErrors()) {
                         System.debug('The following error has occurred.');
                         
                         // Printing error message in Debug log
                         System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                         System.debug('Invoice oject field which are affected by the error:' 
                            + objErr.getFields());
                        ResponseWrapper res = new ResponseWrapper();
                        res.isSuccess = false;
                        res.message = objErr.getMessage();
                        res.recId = null;
                        resList.add(res);
                      }
                   }
                }
            }else {
                ResponseWrapper res = new ResponseWrapper();
                res.isSuccess = false;
                res.message = 'No records found to update';
                res.recId = null;
                resList.add(res);
            }
            }
        catch (Exception exceptionObject) {
            if (throwException) {
                // Aura Enabled Components May Catch The Exception
                ResponseWrapper res = new ResponseWrapper();
                res.isSuccess = false;
                res.message = 'Error'+exceptionObject.getMessage();
                res.recId = null;
                resList.add(res);
                throw exceptionObject;
            }
            else {
                ResponseWrapper res = new ResponseWrapper();
                res.isSuccess = false;
                res.message = exceptionObject.getMessage();
                res.recId = null;
                resList.add(res);
                BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Update_Record', 'updateRecord', new Id[]{}, 'GCM_Application_Administrator');
            }
        }
        return resList;
    }

    public with sharing class InputData 
    {
        @InvocableVariable(required = true description='Object Id' label='Object Id')
        public String recordId;
        
        @InvocableVariable(required = true description='Pipe-Separated Field List' label='Field Names')
        public String fieldNames;

        @InvocableVariable(required = true description='Pipe-Separated Field Values' label='Field Values')
        public String fieldValues;
        
/****************************************************************************************************
 * InputData Constructor
 ****************************************************************************************************/
        public InputData() {}

/****************************************************************************************************
 * InputData Constructor
 ****************************************************************************************************/       
       public InputData(String recordId, String fieldNames, String fieldValues) {
            this.recordId = recordId;
            this.fieldNames = fieldNames;
            this.fieldValues = fieldValues;           
        }
    }
    
    public with sharing class ResponseWrapper {
        public Boolean isSuccess;
        public String message;
        public Id recId;
        public ResponseWrapper() {}
    }
}