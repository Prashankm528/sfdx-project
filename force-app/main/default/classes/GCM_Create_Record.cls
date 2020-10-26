/********************************************************************************
 * Date          : 14-APR-2020
 * Author        : Roselin Hephzibah
 * Description   : Generic Create Record Method
 * Modifications :
 * 				   27-AUG-2020 SYAP: Enabled handling of different data types.
 ********************************************************************************/
public without sharing class GCM_Create_Record {

/********************************************************************************
 * Create Function With object name and field map <name, value>
 ********************************************************************************/
    @auraEnabled(cacheable=false)
    public static ResponseWrapper createRecord(String objectName, Map<String, String> fieldMap, Boolean throwException) {
        Boolean isSuccess = false;
        ResponseWrapper res = new ResponseWrapper();
        
        try {
            /*
            // Not Needed - Retrieve RecordTypeId Using GCM_Query.query
            if(!fieldMap.isEmpty()){
                // Get Record Type Id
                Id recordTypeId = null;
                String recordTypeName = fieldMap.get('RecordType');
                if(String.isNOTBlank(recordTypeName)){
                    List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = :recordTypeName and SObjectType = : objectName];
                    for (RecordType thisRecordType : recordTypes) {
                      recordTypeId = thisRecordType.Id;
                    }
                }
            */    
            List<String> fieldNames = new List<String>();
            fieldNames.addAll(fieldMap.keySet());
            List<String> fieldValues = fieldMap.values();
            SObject record = Schema.getGlobalDescribe().get(objectName).newSObject();
                
            // Set Field Values
            for (Integer count = 0; count < fieldNames.size(); count++) {
                String fieldName = fieldNames[count];
                String fieldValue = fieldValues[count];
                Object fieldObject = record.get(fieldName);
                Schema.DisplayType fieldType = record.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType();

                //System.debug(fieldName + ' ' + fieldObject);
                if (fieldType == Schema.DisplayType.Boolean) {
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

            /*
                record.put('RecordTypeId', recordTypeId);
                for(String fieldName : fieldMap.keyset()){
                    record.put(fieldName, fieldMap.get(fieldName));
                }
			*/
			Database.SaveResult sr = Database.insert(record, false);
            if (sr.isSuccess()) {
            	// Operation was successful, so get the ID of the record that was processed
                // System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                res.recId = sr.getId();
                res.isSuccess = true;
                res.message = 'Record created successfully!';
			}
            else {
            	// Operation failed, so get all errors                
                for (Database.Error err : sr.getErrors()) {
                    // System.debug('The following error has occurred.');                    
                    // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    // System.debug('Account fields that affected this error: ' + err.getFields());
                    res.recId = null;
					res.isSuccess = false;
                    res.message = 'Error'+err.getMessage();
				}
			}
		}
        catch (Exception exceptionObject) {
        	if (throwException) {
            	// Aura Enabled Components May Catch The Exception
				res.recId = null;
                res.isSuccess = false;
                res.message = 'Error'+exceptionObject.getMessage();
                throw exceptionObject;
            }
            else {
                res.recId = null;
                res.isSuccess = false;
                res.message = exceptionObject.getMessage();
                BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Create_Record', 'createRecord', new Id[]{}, 'GCM_Application_Administrator');
            }
        }
        return res;
    }
    
/********************************************************************************
 * Create multiple records With Map of object name and field map <name, value>
 ********************************************************************************/
/*
    @auraEnabled(cacheable=false)
    public static List<ResponseWrapper> createRecords(Map<String,Map<String, String>> objFieldMap, Boolean throwException) {
        Boolean isSuccess = false;
        List<ResponseWrapper> resList = new List<ResponseWrapper>();
        
        try {         
            if(!objFieldMap.isEmpty()){
            List<SObject> sobjListToCreate = new List<SObject>();
                for(String objectName : objFieldMap.keyset()){
                    Map<String, String> fieldMap = objFieldMap.get(objectName);
                    // Get Record Type Id
                    Id recordTypeId = null;
                    String recordTypeName = fieldMap.get('RecordType');
                    if(String.isNOTBlank(recordTypeName)){
                        List<RecordType> recordTypes = [select Id from RecordType where DeveloperName = :recordTypeName and SObjectType = : objectName];
                        for (RecordType thisRecordType : recordTypes) {
                          recordTypeId = thisRecordType.Id;
                        }
                    }
                     // Instantiate Object
                    SObject record = Schema.getGlobalDescribe().get(objectName).newSObject();
                    
                    // Set Field Values
                    record.put('RecordTypeId', recordTypeId);
                    for(String fieldName : fieldMap.keyset()){
                        record.put(fieldName, fieldMap.get(fieldName));
                    }
                    sobjListToCreate.add(record);
            }
            if(!sobjListToCreate.isEmpty()){
                 Database.SaveResult[] srList = Database.insert(sobjListToCreate, false);
                  for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        ResponseWrapper res = new ResponseWrapper();
                        res.recId = sr.getId();
                        res.isSuccess = true;
                        res.message = 'Record created successfully!';
                        resList.add(res);
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            ResponseWrapper res = new ResponseWrapper();
                            res.recId = null;
                            res.isSuccess = false;
                            res.message = 'Error'+err.getMessage();
                            resList.add(res);
                         }
                    }
                  }
            }
            }
            
         }
        catch (Exception exceptionObject) {
            if (throwException) {
                // Aura Enabled Components May Catch The Exception
                ResponseWrapper res = new ResponseWrapper();
                res.recId = null;
                res.isSuccess = false;
                res.message = 'Error'+exceptionObject.getMessage();
                resList.add(res);
                throw exceptionObject;
            }
            else {
                ResponseWrapper res = new ResponseWrapper();
                res.recId = null;
                res.isSuccess = false;
                res.message = exceptionObject.getMessage();
                resList.add(res);
                BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Create_Record', 'createRecord', new Id[]{}, 'GCM_Application_Administrator');
            }
        }
        return resList;
    }
*/    

/****************************************************************************************************
 * ResponseWrapper class
 ****************************************************************************************************/       
    public with sharing class ResponseWrapper {
        public Boolean isSuccess;
        public String message;
        public Id recId;
        public ResponseWrapper() {}
    }
}