/****************************************************************************************************
 *  Date          : 22-SEP-2020
 *  Author        : Sunny Yap
 *  Description   : Class that handles value set metadata.
 * Modifications  : 22-SEP-2020 SYAP - Initial
****************************************************************************************************/
public with sharing class GCM_Value_Set
{
/****************************************************************************************************
 * Get Pick List Values Related To Record Type
 ****************************************************************************************************/  
    public static Map<String, List<String>> getRecordTypePickList(String objectName, String recordTypeName, Set<String> fieldSet) {
        // Initialise Result Map
        Map<String, List<String>> resultMap = null;
        resultMap = new Map<String, List<String>>();
        for (String fieldName : fieldSet) {
            resultMap.put(fieldName, new List<String>());
        }

        // Dynamically Get Record Id
        RecordType recordType = [select Id from RecordType where SObjectType = :objectName and DeveloperName = :recordTypeName limit 1];
        String recordTypeId = recordType.Id;

        // Call UI API
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/ui-api/object-info/Case/picklist-values/' + recordTypeId);  
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        Http http = new Http();
        HttpResponse httpResponse = null;

        if (!Test.isRunningTest()) httpResponse = http.send(httpRequest);

        // Test Data For Test Class
        String body = '';
        body += '{';
        body += '"picklistFieldValues" : ';
        body += '{';
        body += '"Type" : ';
        body += '{';
        body += '"values" : ';
        body += '[{"label" : "Test"}]';
        body += '}';
        body += '}';
        body += '}'; 
        
        if (httpResponse != null) {  
            body = httpResponse.getBody();
        }

        Map<String, Object> metadata = (Map<String, Object>) System.JSON.deserializeUntyped(body);
        Map<String, Object> picklists = (Map<String, Object>) metadata.get('picklistFieldValues');
        for (String key : picklists.keySet()) {
            if (fieldSet.contains(key)) {
                List<String> resultList = resultMap.get(key);
                Map<String, Object> picklist = (Map<String, Object>) picklists.get(key);
                List<Object> values = (List<Object>) picklist.get('values');
                for (Object value : values) {
                    Map<String, Object> valueMap = (Map<String, Object>) value;
                    resultList.add((String) valueMap.get('label'));
                }
            }
        }
        
        return resultMap;
    }

/****************************************************************************************************
 * Test Field Dependencies
 * recordTypeName - Record Type
 * fieldMap - Controlling / Dependent Field Mapping
 ****************************************************************************************************/  
    public static List<String> getFieldDependencies(String objectName, String recordTypeName, Map<String, String> fieldMap) {
        // Initialise Result Data Set
        List<String> keys = new List<String>();
        
        // Get Field List
        Map<String, String> fields = new Map<String, String>();
        for (String field : fieldMap.keySet()) {
            fields.put(field, null);
            fields.put(fieldMap.get(field), null);
        }
        
        // ### Part 1: Record Type Pick List ###
        Map<String, List<String>> valueMap = GCM_Value_Set.getRecordTypePickList(objectName, recordTypeName, fields.keySet());

        // ### Part 2: Field Dependencies ###
        // Initialise Results Map
        Map<String, Map<String, List<String>>> mapResults = new Map<String, Map<String, List<String>>>();

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Case');
        Map<String, Schema.SObjectField> objectFieldMap = objectType.getDescribe().fields.getMap();

        // Build Base64 Map
        String base64Map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

        for (String controlFieldName : fieldMap.keySet()) {
            // Initialise Results Map
            Map<String, List<String>> mapResult = new Map<String, List<String>>();
            mapResults.put(controlFieldName, mapResult);

            String dependFieldName = fieldMap.get(controlFieldName);
            List<Schema.PicklistEntry> controlPicklist = objectFieldMap.get(controlFieldName).getDescribe().getPicklistValues();
            List<Schema.PicklistEntry> dependPicklist = objectFieldMap.get(dependFieldName).getDescribe().getPicklistValues();

            // Initialize Results Mapping
            for (Integer count = 0; count < controlPicklist.size(); count++) {           
                mapResult.put(controlPicklist[count].getLabel(), new List<String>());
            }

            List<Object> dependEntries = (List<Object>) System.JSON.deserializeUntyped(System.JSON.serialize(dependPicklist));
            List<Object> controlEntries = (List<Object>) System.JSON.deserializeUntyped(System.JSON.serialize(controlPicklist));
            
            for (Object dependEntry : dependEntries) {
                List<Integer> indexes = new List<Integer>();
                Map<String, Object> dependEntryMap = (Map<String, Object>) dependEntry;
                String dependValidFor = (String) dependEntryMap.get('validFor');
                Boolean dependActive = (Boolean) dependEntryMap.get('active');
                if (!String.isBlank(dependValidFor) && dependActive) {
                    List<String> base64Characters = dependValidFor.split('');
                    for (Integer index = 0; index < controlEntries.size(); index++) {
                        Integer bitIndex = index / 6;
                        if (bitIndex > base64Characters.size() - 1) {
                                break;
                        }

                        Integer bitShift = 5 - Math.mod(index, 6);
                        Map<String, Object> controlEntryMap = (Map<String, Object>) controlEntries[index];
                        Boolean controlActive = (Boolean) controlEntryMap.get('active');
                        if (!controlActive) continue;
                        if (controlEntryMap.get('label') == null) continue;
                        if ((base64Map.indexOf(base64Characters[bitIndex]) & (1 << bitShift)) == 0) continue;
                        String controlValue = (String) controlEntryMap.get('label');
                        controlValue = controlValue.replace('&', '&amp;');
                        String dependValue = (String) dependEntryMap.get('label');
                        dependValue = dependValue.replace('&', '&amp;');
                        if (!valueMap.get(controlFieldName).contains(controlValue)) continue;
                        if (!valueMap.get(fieldMap.get(controlFieldName)).contains(dependValue)) continue;
                        String key = dependFieldName + ',' + controlValue + ',' + dependValue;
                        keys.add(key);
                    }
                }
            }
        }
        
        return keys;
    }
}