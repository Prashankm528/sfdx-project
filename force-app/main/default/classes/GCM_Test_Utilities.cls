/****************************************************************************************************
 *  Date          : 22-SEP-2020
 *  Author        : Sunny Yap
 *  Description   : Common class for test automation.
 *                  SeeAllData enabled because this test class is used to perform full regression test
 *                  It requires access to pre-existing test data.
 * Modifications  : 25-AUG-2020 SYAP - Initial
****************************************************************************************************/
@isTest(SeeAllData=true)
public with sharing class GCM_Test_Utilities
{
/****************************************************************************************************
 * Bulk Create Objects DMO
 ****************************************************************************************************/
    public static List<Database.SaveResult> testCreateObjectsDMO(String objectName, List<Map<String, String>> fieldMaps, Database.DMLOptions dmo) {
        List<SObject> records = new List<SObject>();
        
        for (Map<String, String> fieldMap : fieldMaps) {
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
                    fieldType == Schema.DisplayType.MULTIPICKLIST ||
                    fieldType == Schema.DisplayType.ID) {
                    record.put(fieldName, fieldValue);
                }
            }
            record.setOptions(dmo);
            records.add(record);        
        }
        
        if (records.size() > 0) {
            List<Database.SaveResult> results = Database.insert(records);
            return results;
        }
        
        return null;
    }

/****************************************************************************************************
 * Bulk Create Objects
 ****************************************************************************************************/
    public static List<Database.SaveResult> testCreateObjects(String objectName, List<Map<String, String>> fieldMaps) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        return GCM_Test_Utilities.testCreateObjectsDMO(objectName, fieldMaps, dmo);
    }
    
/****************************************************************************************************
 * Convert String Into Map
 ****************************************************************************************************/
    public static List<Map<String, String>> stringToMap(String nameList, List<String> valueList) {
        List<Map<String, String>> pairs = new List<Map<String, String>>();
        List<String> names = nameList.split(',');
        for (String value : valueList) {
            List<String> values = value.split(',');
            if (names.size() != values.size()) continue;
            Map<String, String> pair = new Map<String, String>();
            for (Integer count = 0; count < names.size(); count++) {
                pair.put(names[count], values[count]); 
            }
            pairs.add(pair);
        }
        return pairs;
    }
}