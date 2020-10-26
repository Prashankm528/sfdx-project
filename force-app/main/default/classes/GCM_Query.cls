/********************************************************************************
 * Date           : 26-FEB-2020
 * Author         : Sunny Yap
 * Description    : Class that generates SObject list based on any arbitrary
 *                  query.
 * Modifications  : 26-FEB-2020 SYAP - Initial
 12-May-2020    : Apoorv - Modifed the class fo query method to add try and catch method
 ********************************************************************************/ 
public without sharing class GCM_Query {

/********************************************************************************
 * Returns SObject List
 ********************************************************************************/ 
    @auraEnabled(cacheable=false)
    public static List<SObject> query(String recordId, String soql) {
        soql = soql.replace('{!Id}', recordId);
        List<SObject> records = Database.query(soql);
        return records;
    }
   

/********************************************************************************
 * Returns SObject List Based On Results Of Another Sub Query
 ********************************************************************************/
    @auraEnabled(cacheable=false)
    public static List<SObject> queryNested(String recordId, String soql, String subsoql, String subField) {
        subsoql = subsoql.replace('{!Id}', recordId);
        List<SObject> records = Database.query(subsoql);
        List<String> idList = new List<String>();
        for (SObject record : records) {
            idList.add('\'' + (String) record.get(subField) + '\'');
        }
        String idListString = '(' + String.join(idList, ',') + ')';
        
        soql = soql.replace('{!Id}', recordId);
        soql = soql.replace('{!IdList}', idListString);
        records = Database.query(soql);
        return records;
    }

/********************************************************************************
 * Returns Field Value Set (Label, Value)
 ********************************************************************************/
    @auraEnabled(cacheable=true)
    public static List<Map<String, String>> getValueSet(String objectName, String fieldName){
        List<Map<String, String>> values = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> metaValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry metaValue : metaValues){
            Map<String, String> keyValue = new Map<String, String>();
            keyValue.put('Label', metaValue.getLabel());
            keyValue.put('Value', metaValue.getValue());
            values.add(keyValue);
        }
        return values;
    }
    
/********************************************************************************
 * Get Timezone Offset
 ********************************************************************************/
    @auraEnabled(cacheable=true)
    public static Integer getTimeZoneOffset() {
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(Datetime.now());
    }

/********************************************************************************
 * Get logged in user's timezone
 ********************************************************************************/ 
    @auraEnabled(cacheable=false)
    public static String getTimeZoneName() {
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getDisplayName();
    }

/********************************************************************************
 * Query API Data
 * Works For Data From Other Salesforce Orgs
 ********************************************************************************/
    @auraEnabled(cacheable=false)
    public static String queryAPI(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = null;
        if (!Test.isRunningTest()) {
            response = http.send(request);
        }
        if (response != null && response.getStatusCode() == 200) {
            // Successful
            return response.getBody();
        }
        
        return '';
    }
}