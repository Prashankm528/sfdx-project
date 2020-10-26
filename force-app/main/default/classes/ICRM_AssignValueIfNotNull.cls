/* @author            Utkarsh Gupta
*  @date              15th July, 2019
*  @description       handles the mapping of IST Prospect Account field values to IST legal Entity Values only if it is null.
*/
public inherited Sharing class ICRM_AssignValueIfNotNull {
    
        /*@Description
* handles the IST Prospect account values mapping to IST Legal Entity Account values to the fields which are passed through field set.
*/
    
    public static void assignIfNotNull(Map<sObject,sObject> oldAndNewRecordIdMap, List<String> fieldSet){
        try{
            //Nested for loop is used to itereate through all the fields in the fieldList and update each field.
            for(sObject newObj : oldAndNewRecordIdMap.keySet()){
                if(newObj != NULL
                   && oldAndNewRecordIdMap.containsKey(newObj)
                   && oldAndNewRecordIdMap.get(newObj) != NULL) {
                       sObject oldObj = oldAndNewRecordIdMap.get(newObj);
                       for(String fieldName : fieldSet){
                           if(newObj.get(fieldName) == NULL
                              && oldObj.get(fieldName) != NULL){
                                  newObj.put(fieldName,oldObj.get(fieldName));
                              }
                       }
                   }
            }
        }catch(Exception e){
            System.debug('Excetion caught at line: '+e.getLineNumber()+' Error: '+e.getMessage());
        }
    }
}