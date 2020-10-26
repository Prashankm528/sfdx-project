/**
 * @description       : Transforms input data into a format defined by custom metadata
 * @group             : 
 * @last modified on  : 07-29-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_TMUItransformer implements ISTCP_TMTransformerInterface{
    
    /**
    * @description Transforms input data into a format defined by custom metadata
    * @param ISTCP_TMTransformMessage dataMessage 
    * @return ISTCP_TMTransformMessage 
    **/
    public ISTCP_TMTransformMessage transform(ISTCP_TMTransformMessage dataMessage){
        
        ISTCP_TMTransformMessage transformedMessage = new ISTCP_TMTransformMessage();
        transformedMessage.inputData = dataMessage.inputData;
        
        system.debug(String.valueof(dataMessage.runtimeInvocations.get('DataService'))+', '+String.valueof(dataMessage.runtimeInvocations.get('UIDataService')));
        
        // Queries custom metadata to get the data service
        sobject dsd = getDataServiceDefinition(String.valueof(dataMessage.runtimeInvocations.get('DataService')));
        System.debug('dsd' + dsd);
        // Queries custom metadata to get the UI component type definitions
        sobject udd = getUIDataDefinition(String.valueof(dataMessage.runtimeInvocations.get('DataService')), String.valueof(dataMessage.runtimeInvocations.get('UIDataService')));
        System.debug('udd' + udd);

        String inputData = String.valueof(dataMessage.inputData);
        system.debug(inputData);
        if ((String)dsd.get('ISTCP_Service_Type__c') == 'Internal - Objects') {
            // Amend received JSON of serialized sObject so it can be mapped out via JSON.deserializeUntyped
            inputData = '{ "results": ' + inputData + '}';

        } 
            
        // Map Input Data values (e.g. mock data)
        Map<String,Object> iDataMap = (Map<String, Object>) JSON.deserializeUntyped(inputData);
        System.debug('iDataMap' + iDataMap);
        // Map Output Definition (JSON structure)
        Map<String,Object> oDataDefMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueof(udd.get('ISTCP_Output_Data_Definition__c')));
        System.debug('oDataDefMap' + oDataDefMap);
        
        // Get field from UI component type over which the data iteration will happen
        String iterateOver = (String) udd.get('ISTCP_Iterate_Over_Service_Field__c');
        
        // Map 'data' JSON node from Output Definition. This is expected to have the fields and their corresponding placeholders. Example: "FieldName": "$fieldName"
        Map<String,Object> dataRow= (Map<String,Object>) ((List<Object>) oDataDefMap.get('data'))[0];
        
        // ** THIS IS STILL NOT BEING USED **
        // Parser for Response Definition (JSON structure)
        //JSONParser iDataDefparser = JSON.createParser((String)dsd.get('Response_Definition__c'));

        // Use generator to build up the Request JSON structure
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        // Call to recursive method
        // ISTCP_Utilities.buildJSON(gen, oDataDefMap, iDataMap);

        for(String k : oDataDefMap.keyset()){
            if(k != 'data'){
                system.debug(k);
                system.debug(oDataDefMap.get(k));
                gen.writeObjectField(k, oDataDefMap.get(k));
            }
            else{
                gen.writeFieldName('data');
                for(String key : iDataMap.keyset()){
                    system.debug(key);
                    system.debug(ISTCP_Utilities.getType(iDataMap.get(key)));
                    if(ISTCP_Utilities.getType(iDataMap.get(key)) == 'List'){
                        gen.writeStartArray();
                        for(Object i : (List<Object>) iDataMap.get(key)){
                            Map<String,Object> innerMap = (Map<String,Object>) i;
                            system.debug(innerMap);
                            if(innerMap.containsKey(iterateOver)){
                                gen.writeStartObject();
                                for(String dk: dataRow.keyset()){
                                    if (innerMap.get((String) dataRow.get(dk)) == null) {
                                        gen.writeObjectField(dk, '');
                                    } else {
                                        gen.writeObjectField(dk, innerMap.get((String) dataRow.get(dk)));
                                    }
                                }                        
                                gen.writeEndObject();
                            }
                        }
                        gen.writeEndArray();
                    }
                    else if(iDataMap.get(key) instanceof Map<string,Object>){
                        Map<String,Object>  innerMap = (Map<String,Object>)iDataMap.get(key);
                        system.debug(innerMap);
                    }
                    else if(iDataMap.get(key) instanceof String){
                        system.debug(key+' --> '+iDataMap.get(key));
                    }
                }
            }
        }
        
        gen.writeEndObject();
        
        system.debug(gen.getAsString());
        transformedMessage.outputData = gen.getAsString();
        transformedMessage.transformModuleInput = dataMessage.transformModuleInput;
        
        return transformedMessage;
    }
    
    /**
    * @description Queries custom metadata to get output data definition (per the UI element type) and which field to iterate over
    * @param String DataService 
    * @param String UIComponentType 
    * @return sObject 
    **/
    private sObject getUIDataDefinition(String DataService, String UIDataService){
        sObject returnObj;
        returnObj = (sObject)[SELECT ISTCP_Output_Data_Definition__c, ISTCP_Iterate_Over_Service_Field__c FROM ISTCP_UI_Data_Service__mdt WHERE ISTCP_Service__r.DeveloperName =: DataService AND DeveloperName =: UIDataService LIMIT 1][0];
        return returnObj;
    }
    
    /**
    * @description Queries custom metadata to get the response definition
    * @param String DataService 
    * @return sObject 
    **/
    private sObject getDataServiceDefinition(String DataService){
        sObject returnObj;
        returnObj = (sObject)[SELECT ISTCP_Response_Definition__c, ISTCP_Service_Type__c, ISTCP_Object_API_Name__c FROM ISTCP_Service__mdt WHERE DeveloperName =: DataService LIMIT 1][0];
        return returnObj;
    }
}