/********************************************************************************
 * Date          : 13-MAY-2020
 * Author        : Roselin Hephzibah
 * Description   : Query Picklist value label and Append in target field.
 * Modifications :.
 ********************************************************************************/
public with sharing class GCM_PicklistLabelUpdate {
    
/********************************************************************************
 * Invocable Update Record Method
 ********************************************************************************/
    @InvocableMethod
    public static void getPicklistLabel(List<InputData> inputDataList) {
        Id recordId;
        List<SObject> sObjectList = new List<SObject>();
        try {
        for(InputData ipd : inputDataList){
            recordId = ipd.recordId;
            String fieldFrom = ipd.fieldFrom;
            String fieldTo = ipd.fieldTo;
            String byPassTime = ipd.byPassTimeStamp;
            system.debug('input***'+inputDataList);
            
            List<String> fieldNames = fieldFrom.split('(\\|)');
            List<String> fieldNamesList = new List<String>();
            
            Map<String, Schema.SObjectField> fieldMap = recordId.getSObjectType().getDescribe().fields.getMap();
            SObject record = recordId.getSObjectType().newSObject(recordId);
            if(String.isNOTBlank(byPassTime)){
                Schema.DisplayType fieldType = fieldMap.get(byPassTime).getDescribe().getType();
                if(fieldType == Schema.DisplayType.DateTime)
                record.put(byPassTime, system.now());
            }
            
            if(!fieldNames.isEmpty()){
                for(String fName: fieldNames){
                    Schema.DisplayType fieldType = fieldMap.get(fName).getDescribe().getType();
                    if(fieldType == Schema.DisplayType.Picklist){
                        String picklistFName = 'toLabel('+fName+')';
                        fieldNamesList.add(picklistFName);
                    } else {
                        fieldNamesList.add(fName);
                    }
                }
            }
            fieldNamesList.add(fieldTo);
    
            Schema.SObjectType objectName = recordId.getSobjectType();
            SObject recordobj = Database.query('SELECT '+ String.join(fieldNamesList, ',') + ' from ' + objectName + ' where Id =\'' +recordId + '\'');
    
            String fieldToValue = recordobj.get(fieldTo) +'\n';
            for(String fName : fieldNames){
                if(String.isNOTBlank(String.valueOf(recordobj.get(fName))))
                fieldToValue = fieldToValue + recordobj.get(fName)+' ';
            }
            record.put(fieldTo, fieldToValue);
            sObjectList.add(record);
        }
        if(!sObjectList.isEmpty()){
            update sObjectList;
        }
        
        }catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_PicklistLabelUpdate', 'getPicklistLabel', new Id[]{recordId}, 'GCM_Application_Administrator');
        }
    }


    public with sharing class InputData 
    {
        @InvocableVariable(required = true description='Id of the record' label='Record Id')
        public Id recordId;
        
        @InvocableVariable(required = true description='Picklist field' label='Picklist Field')
        public String fieldFrom;

        @InvocableVariable(required = true description='Field where picklist label will be updated/appended' label='Field To')
        public String fieldTo;
        
        @InvocableVariable(description='Timestamp to skip validations' label='ByPassTimeStamp Field Name')
        public String byPassTimeStamp;

    }

}

/*****************************
List<GCM_PicklistLabelUpdate.InputData> ipdlist = new List<GCM_PicklistLabelUpdate.InputData>();
GCM_PicklistLabelUpdate.InputData ipd = new GCM_PicklistLabelUpdate.InputData();
ipd.recordId = //CaseId ;
ipd.fieldFrom = 'GCM_BOT_Resolution_Code__c|GCM_Additional_Order_Info__c';
ipd.fieldTo = 'Description';
ipd.byPassTimeStamp = 'GCM_ByPassValidation_Timestamp__c';
ipdlist.add(ipd);
GCM_PicklistLabelUpdate.getPicklistLabel(ipdlist);

*********************************/