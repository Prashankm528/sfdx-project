/**
 * @description       : Provides data to lwc ISTCP_genericLWCcomponent
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_genericLWCController {
    
    /**
    * @description Orchestrates the steps to preprocess, postprocess, transform and get data. 
    * @param Map<Object Object> JSON_parameters 
    * @param Map<Object Object> JSON_runtimeInvocations 
    * @return object 
    **/
    @AuraEnabled
    public static object getData(Map<String,Object> JSON_parameters, Map<String,Object> JSON_runtimeInvocations){
        try {
            ISTCP_genericTransformModule transformModule = new ISTCP_genericTransformModule('JSON','JSON','UI');
            
            system.debug(JSON_runtimeInvocations);
            
            if(JSON_runtimeInvocations.containsKey('PreProcessor')){
                if((String.valueof(JSON_runtimeInvocations.get('PreProcessor')) != '' || String.valueof(JSON_runtimeInvocations.get('PreProcessor')) != null)){
                    transformModule.setPreProcessor(String.valueof(JSON_runtimeInvocations.get('PreProcessor')));
                }
            }

            if(JSON_runtimeInvocations.containsKey('PostProcessor')){
                if((String.valueof(JSON_runtimeInvocations.get('PostProcessor')) != '' || String.valueof(JSON_runtimeInvocations.get('PostProcessor')) != null)){
                    transformModule.setPostProcessor(String.valueof(JSON_runtimeInvocations.get('PreProcessor')));
                }
            }
            
            transformModule.setTransformer('ISTCP_TMUItransformer');
            transformModule.setPreProcessor('ISTCP_TMGenericPreProcessor');
            transformModule.setPostProcessor('ISTCP_TMGenericPostProcessor');
            
            ISTCP_genericDataService dataService = new ISTCP_genericDataService();
            

            ISTCP_TMTransformMessage inputMessage = new ISTCP_TMTransformMessage();
            System.debug('getData received parameters: ' + JSON.serializePretty(JSON_parameters));
            Map<String,Object> data = dataService.getData(JSON_parameters, JSON_runtimeInvocations);
            system.debug(data);
            inputMessage.inputData = data.get('externalResponse');
            inputmessage.runtimeInvocations = JSON_runtimeInvocations;

            ISTCP_TMTransformMessage outputMessage = transformModule.transform(inputMessage);

            return outputMessage.outputData;
        } catch (System.Exception e) {
            String error = e.getMessage() + ' StackTrace: ' + e.getStackTraceString(); 
            System.debug(Logginglevel.ERROR, error);
            throw new AuraHandledException(e.getMessage());
        }
    }
}