/**
 * @description       : Provides the logic to enroute the data request to the appropriate source (internal or external) for ISTCP.
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_genericDataService {
    
    public ISTCP_genericDataService() {

    }

    /**
    * @description Gets data either mock data or real data from external system or custom objects.
    * @param map<String Object> parameters 
    * @param map<String Object> runtimeInvocations 
    * @return virtual 
    **/
    public virtual Map<String,Object> getData(map<String,Object> parameters, map<String,Object> runtimeInvocations){
        Map<String,Object> dataMessage = new Map<String,Object>();
        Object response = '';
        String libraryName = null;
        String searchValue;
        String[] bpNum;
        Date startDate;
        Date endDate;
        Integer pageSize = 3;
        Integer pageNum = 0;

        System.debug('parameters keys' + parameters.keySet());
        if (parameters.containsKey('searchValue')) {
            searchValue = String.valueOf(parameters.get('searchValue'));
        }
        if (parameters.containsKey('BPNum')) {
            bpNum = String.valueOf(parameters.get('BPNum')).split(',');
        }
        if (parameters.containsKey('Start') && String.valueOf(parameters.get('Start')) != '' || String.valueOf(parameters.get('Start')) != null) {
            startDate = Date.parse((String)parameters.get('Start'));
        }
        if (parameters.containsKey('End') && String.valueOf(parameters.get('End')) != '' || String.valueOf(parameters.get('End')) != null) {
            endDate = Date.parse((String)parameters.get('End'));
        }
        if (parameters.containsKey('PageSize') && String.valueOf(parameters.get('PageSize')) != '' || String.valueOf(parameters.get('PageSize')) != null) {
            pageSize = Integer.valueOf(parameters.get('PageSize'));
        }
        if (parameters.containsKey('PageNum') && String.valueOf(parameters.get('PageNum')) != '' || String.valueOf(parameters.get('PageNum')) != null) {
            pageNum = Integer.valueOf(parameters.get('PageNum'));
        }

            
        if(runtimeInvocations.containsKey('DataService') && (String.valueof(runtimeInvocations.get('DataService')) != '' || String.valueof(runtimeInvocations.get('DataService')) != null)){
            System.debug('runtimeInvocations.get(DataService): ' +  runtimeInvocations.get('DataService'));
            
            ISTCP_Service__mdt sm = [SELECT ISTCP_Additional_Headers__c,
                            ISTCP_Custom_Data_Provider_Class__c,
                            DeveloperName,
                            ISTCP_Direct_Callout_Authenticators__c,
                            ISTCP_External_Service_Method_Type__c,
                            Id,
                            Label,
                            Language,
                            MasterLabel,
                            ISTCP_Named_Credential__c,
                            NamespacePrefix,
                            ISTCP_Object_API_Name__c,
                            QualifiedApiName,
                            ISTCP_Query__c,
                            ISTCP_Relative_Endpoint__c,
                            ISTCP_Request_Definition__c,
                            ISTCP_Response_Definition__c,
                            ISTCP_Service_Type__c,
                            ISTCP_Time_Out_Milliseconds__c
                            FROM ISTCP_Service__mdt WHERE DeveloperName =: (String)runtimeInvocations.get('DataService')];
            
            if (String.isNotBlank(sm.ISTCP_Request_Definition__c)) {
                String builtRequest = ISTCP_Utilities.generateJSONwithValues(sm.ISTCP_Request_Definition__c, parameters);
                System.debug('builtRequest: ' + builtRequest);
                if(sm.ISTCP_Service_Type__c == 'External - Named Credentials') {
                    if (!Test.isRunningTest()) {
                        // Pass mapped values as parameters for external callout
                        response = ISTCP_ExternalService.makeExternalCallout(sm, builtRequest).getBody();
                    } else {
                        response = ISTCP_mockAPIresponse.getTestItems(String.valueOf(sm.ISTCP_Response_Definition__c), builtRequest);
                    }
                } else if(sm.ISTCP_Service_Type__c == 'Internal - Objects'){
                    System.debug('TO DO write method to query Salesforce object (internal data) per the DataService definition.');
                }
            }
            
            if(String.valueof(runtimeInvocations.get('DataService')) == 'getInvoices'){
            	response = ISTCP_mockAPIresponse.getInvoices(bpNum, pageSize, pageNum);
            }
            else if(String.valueof(runtimeInvocations.get('DataService')) == 'getOtherDocuments'){
            	response = ISTCP_mockAPIresponse.getOtherDocuments(bpNum, pageSize, pageNum);
            }
            else if(String.valueof(runtimeInvocations.get('DataService')) == 'findInvoice'){
            	response = ISTCP_mockAPIresponse.findInvoice();
            }
            else if(String.valueof(runtimeInvocations.get('DataService')) == 'getWatchlistItems'){
                response = JSON.serializePretty(ISTCP_WatchlistController.getWatchlistItems(searchValue));
                System.debug('>>> response ' + response);
            }
        }
        
        dataMessage.put('externalResponse', response);

        return dataMessage;

    }
}