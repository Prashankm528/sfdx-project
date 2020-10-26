/****************************************************************************************************
 *  Date          : 15-FEB-2020
 *  Author        : Sunny Yap
 *  Description   : Microsoft Word generator controller class.
 * Modifications  : 15-FEB-2020 SYAP - Initial
 ****************************************************************************************************/

public with sharing class GCM_Document_Generator {
/****************************************************************************************************
  Recursively Traverse Objects - Get Joined Field Values
 ****************************************************************************************************/
    public static Object getFieldValue(SObject thisObject, List<String> notations) {
        if (notations.size() > 1) {
            String objectName = notations[0];
            notations.remove(0);

            // Get Object / Object List
            SObject currentObject = null;
            List<SObject> objectList = null;
            try {
                currentObject = thisObject.getSObject(objectName);
            }
            catch (System.SObjectException soException) {
                objectList = thisObject.getSObjects(objectName);
            }

            // Determine Next Recursion Path
            if (currentObject != null) {
                return GCM_Document_Generator.getFieldValue(currentObject, notations);
            }
            else {
                if (objectList != null) {
                    for (SObject childObject : objectList) {
                        return GCM_Document_Generator.getFieldValue(childObject, notations);
                    }
                }
                return null;
            }
        }
        else if (notations.size() > 0) {
            return thisObject.get(notations[0]);            
        }
        else {
            return null;
        }
    }

/****************************************************************************************************
  Convert Field Value Of Any Data Type Into String
 ****************************************************************************************************/
    public static String toString(SObject record, String fieldName) {
        String recordId = record.Id;

        String[] fieldList = fieldName.split('(\\.)');
        Object fieldValue = GCM_Document_Generator.getFieldValue(record, fieldList);
        
        if (fieldValue instanceOf Boolean) {
            return ((Boolean) fieldValue) ? 'true' : 'false';
        }
        if (fieldValue instanceOf Datetime) {
            return ((Datetime) fieldValue).format('dd-MMM-yyyy HH:mm:ss');
        }
        if (fieldValue instanceOf String) {
            return (String) fieldValue;
        }
        // Return Blank String
        return '';
    }

/****************************************************************************************************
  Retrieves Document Template + Substitutes Field Values
 ****************************************************************************************************/
    @AuraEnabled
    public static String getDocument(String templateName, Id recordId) {
        try {
            // Retrieve Document Template
            String soql = null;
            String fieldList = null;
            String html = null;
            List<GCM_Document__c> templates = null;
            if (Test.isRunningTest()) {
                templates = [
                    select
                        GCM_SOQL__c,
                        GCM_Field_List__c,
                        GCM_HTML__c
                    from
                        GCM_Document__c
                    where Name = :templateName
                    limit 1
                ];
            }
            else {
                templates = [
                    select
                        GCM_SOQL__c,
                        GCM_Field_List__c,
                        GCM_HTML__c
                    from
                        GCM_Document__c
                    where Name = :templateName
                ];
            }
            
            for (GCM_Document__c template : templates) {
                soql = template.GCM_SOQL__c;
                fieldList = template.GCM_Field_List__c;
                html = template.GCM_HTML__c;
            }
            
            if (soql != null && fieldList != null && html != null) {
                // Create Field Name Array
                fieldList = fieldList.replace(' ', ''); // Remove Spaces
                String[] fieldNames = fieldList.split(',');
                
                // Substitute Record Id In SOQL
                soql = soql.replace('{!Id}', recordId);
                List<SObject> records = Database.query(soql);
                for (SObject record : records) {
                    for (String fieldName : fieldNames) {
                        String fieldValue = GCM_Document_Generator.toString(record, fieldName);
                        html = html.replace('{!' + fieldName + '}', fieldValue);
                    }
                }
            }
            
            return html;
        }
        catch (Exception exceptionObject) {
            throw exceptionObject;
        }
    }
    
/****************************************************************************************************
  Retrieves Document Template List
 ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<GCM_Document__c> getTemplates() {
        try {
            List<GCM_Document__c> templates = [
                select
                    Name,
                    GCM_Display_Name__c
                from
                    GCM_Document__c
                where
                    GCM_Active__c = true
                order by
                    GCM_Display_Name__c asc
            ];
            return templates;
        }
        catch (Exception exceptionObject) {
            throw exceptionObject;
        }     
    }
}