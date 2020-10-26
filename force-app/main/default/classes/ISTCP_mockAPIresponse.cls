/**
 * @description       : Generates mock data and api responses for ISTCP
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_mockAPIresponse {

    /**
    * @description Autogenerates JSON string response with generic mock data per provided parameters
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String iterateBy 
    * @param String[] identifiers 
    * @param Map<String String> fieldsDefinition 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getMockDatatableRows(String iterateBy, String[] identifiers, Map<String,String> fieldsDefinition, Integer pageSize, Integer pageNum) {
        JSONGenerator gen = JSON.createGenerator(true);
        String fieldValue;
        Map<Integer, String> periods = new Map<Integer, String>{1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};

        gen.writeStartObject();
            gen.writeFieldName('MetadataPropertyList');
            gen.writeStartArray();
            
            for (String identifier : identifiers) {
                
                for (Integer i=1; i < pageSize + 1; i++) {
                    gen.writeStartObject();
                    
                    for (String key : fieldsDefinition.keySet()) {
                        if (key == iterateBy) {
                            fieldValue = String.valueOf(pageNum) + key + '_' + i + '_' + identifier;
                        } else if (key == 'DocumentLink') {
                            fieldValue = 'Download';
                        } else if (fieldsDefinition.get(key) == 'Date') {
                            fieldValue = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
                        } else if (fieldsDefinition.get(key) == 'Year') {
                            fieldValue = String.valueOf(Date.today().year());
                        } else if (fieldsDefinition.get(key) == 'Period') {
                            fieldValue = periods.get(Date.today().month());
                        } else {
                            fieldValue = key + '_' + identifier;
                        }
                        gen.writeObjectField(key, fieldValue);
                    }
                    gen.writeEndObject();
                } 
            }
                
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
    * @description Get mock response for test units
    * @param String paramsJSON
    * @return String 
    **/
    public static String getTestItems(String responseDefinition, String paramsJSON){
        String[] identifiers;
        Integer pageSize;
        Integer pageNum;

        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJSON);
        if (params.containsKey('PageSize')) {
            pageSize = Integer.valueOf(params.get('PageSize'));
        }

        if (params.containsKey('PageNum')) {
            pageNum = Integer.valueOf(params.get('PageNum'));
        }

        if (params.containsKey('FilterList')) {
            if(ISTCP_Utilities.getType(params.get('FilterList')) == 'List') {
                for (Object f : (List<Object>)params.get('FilterList')) {
                    Map<String, Object> filter = (Map<String, Object>)f;
                    if (filter.containsKey('BPNum')) {
                        identifiers = String.valueOf(filter.get('BPNum')).split(',');
                    }
                }
            }
        }

        Map<String,String> fieldsDefinitions = new Map<String,String>();
        Map<String, Object> resDef = (Map<String, Object>) JSON.deserializeUntyped(responseDefinition);
        if (resDef.containsKey('MetadataPropertyList')) {
            if (ISTCP_Utilities.getType(resDef.get('MetadataPropertyList')) == 'List') {
                
                for(Object obj : (List<Object>)resDef.get('MetadataPropertyList')){
                    System.debug('obj before deserialize it: ' + obj);
                    Map<String, Object> subValues = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(JSON.serialize(obj)));

                    for (String k : subValues.keySet()) {
                        System.debug('(String)subValues.get(k): ' + (String)subValues.get(k));
                        if (k == 'DueDate' || k == 'Created' || k == 'DateOfReport') {
                            fieldsDefinitions.put(k, 'Date');
                        } else if (k == 'Year' || k == 'Period') {
                            fieldsDefinitions.put(k, k);
                        } else {
                            fieldsDefinitions.put(k, 'Text');
                        }
                    }
                    // Add last field to represent download button
                    fieldsDefinitions.put('DocumentLink', 'DocumentLink');
                }
            }
        }

        return ISTCP_mockAPIresponse.getMockDatatableRows('ID', identifiers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock invoices data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getInvoices(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('invoiceNumber', 'Text');
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('market', 'Text');
        fieldsDefinitions.put('invoiceDate', 'Date');
        fieldsDefinitions.put('dateOfPosting', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('bpNumber', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock other documents data
    * @author sebas.canseco@slalom.com | 07-30-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getOtherDocuments(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('ID', 'Text');
        fieldsDefinitions.put('FileLeafRef', 'Text');
        fieldsDefinitions.put('FileType', 'Text');
        fieldsDefinitions.put('BPNum', 'text');
        fieldsDefinitions.put('DateUploaded', 'Date');
        fieldsDefinitions.put('Commodity', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('id', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock response for findInvoice call
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @return String 
    **/
    public static String findInvoice(){
        String responseBody = '{ "results": [{ "invoiceNumber" : "Inv-002243", "invoiceVersion" : "1", "invoiceDate" : "02-04-2020", "invoiceURL" : "Download" }]}';
        
        return responseBody;
    }

    /**
    * @description Generates mock DFDM data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getDFDM(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('created', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('modified', 'Date');
        fieldsDefinitions.put('modifiedBy', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('fileSize', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock DFPRM data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getDFPRM(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('created', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('modified', 'Date');
        fieldsDefinitions.put('modifiedBy', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('fileSize', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock REP Positions Risks data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getREPPositionsRisks(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('created', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('modified', 'Date');
        fieldsDefinitions.put('modifiedBy', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('fileSize', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock REP Credits data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getREPCredits(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('created', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('modified', 'Date');
        fieldsDefinitions.put('modifiedBy', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('fileSize', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }
    
    /**
    * @description Generates mock REP Schedules data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getREPSchedules(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('created', 'Date');
        fieldsDefinitions.put('createdBy', 'Text');
        fieldsDefinitions.put('modified', 'Date');
        fieldsDefinitions.put('modifiedBy', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('fileSize', 'Text');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates mock trade configurations data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getTradeConfigurations(String[] endurId) {
        String responseBody;
        String records =  
            '{'
                +'"PipelineName": "pipeline A",'
                +'"PipelineShortName": "pipeline short A",'
                +'"PipelineSourceSystemID": "pipeline source A",'
                +'"ZoneName": "zone A",'
                +'"ZoneShortName": "zone short A",'
                +'"ZoneSourceSystemID": "zone source A",'
                +'"MeterName": "meter A",'
                +'"MeterNumber": "meter number A",'
                +'"MeterSourceSystemID": "meter source A",'
                +'"PortfolioName": "portfolio A",'
                +'"TraderName": "trader A",'
                +'"TraderNTID": "trader ntid A",'
                +'"MarketKey": "market key A",'
                +'"BPNumber": "10487",'
                +'"EndurId": "12345",'
                +'"MarketStatus": "market status A",'
                +'"Volume": "1000",'
                +'"VolumeUnitOfMeasure": "MMBtu",'
                +'"ProductType": "product type A",'
                +'"DeliveryPeriod": "delivery period A",'
                +'"Currency": "USD",'
                +'"ICENotificationGroupEmails": "icenotification@im.ice",'
                +'"ENDURIndexName": "endur index name A",'
                +'"EndurTemplateID": "endur template id A",'
                +'"BPLegalEntityShortName": "bp legal entity short name A",'
                +'"BPLegalEntityEndurID": "bp legal entity endur id A",'
                +'"LastTradedOn": "2020-05-03",'
                +'"StartDate": "2020-05-01",'
                +'"EndDate": "2020-05-03",'
                +'"Price": ".7413"'
            +'},{'
                +'"PipelineName": "pipeline B",'
                +'"PipelineShortName": "pipeline short B",'
                +'"PipelineSourceSystemID": "pipeline source B",'
                +'"ZoneName": "zone B",'
                +'"ZoneShortName": "zone short B",'
                +'"ZoneSourceSystemID": "zone source B",'
                +'"MeterName": "meter B",'
                +'"MeterNumber": "meter number B",'
                +'"MeterSourceSystemID": "meter source B",'
                +'"PortfolioName": "portfolio B",'
                +'"TraderName": "trader B",'
                +'"TraderNTID": "trader ntid B",'
                +'"MarketKey": "market key B",'
                +'"BPNumber": "10487",'
                +'"EndurId": "12345",'
                +'"MarketStatus": "market status B",'
                +'"Volume": "1000",'
                +'"VolumeUnitOfMeasure": "MMBtu",'
                +'"ProductType": "product type B",'
                +'"DeliveryPeriod": "delivery period B",'
                +'"Currency": "USD",'
                +'"ICENotificationGroupEmails": "icenotification@im.ice",'
                +'"ENDURIndexName": "endur index name B",'
                +'"EndurTemplateID": "endur template id B",'
                +'"BPLegalEntityShortName": "bp legal entity short name B",'
                +'"BPLegalEntityEndurID": "bp legal entity endur id B",'
                +'"LastTradedOn": "2020-05-03",'
                +'"StartDate": "2020-05-01",'
                +'"EndDate": "2020-05-03",'
                +'"Price": ".7413"'
            +'},{'
                +'"PipelineName": "pipeline C",'
                +'"PipelineShortName": "pipeline short C",'
                +'"PipelineSourceSystemID": "pipeline source C",'
                +'"ZoneName": "zone C",'
                +'"ZoneShortName": "zone short C",'
                +'"ZoneSourceSystemID": "zone source C",'
                +'"MeterName": "meter C",'
                +'"MeterNumber": "meter number C",'
                +'"MeterSourceSystemID": "meter source C",'
                +'"PortfolioName": "portfolio C",'
                +'"TraderName": "trader C",'
                +'"TraderNTID": "trader ntid C",'
                +'"MarketKey": "market key C",'
                +'"BPNumber": "10487",'
                +'"EndurId": "12345",'
                +'"MarketStatus": "market status C",'
                +'"Volume": "1000",'
                +'"VolumeUnitOfMeasure": "MMBtu",'
                +'"ProductType": "product type C",'
                +'"DeliveryPeriod": "delivery period C",'
                +'"Currency": "USD",'
                +'"ICENotificationGroupEmails": "icenotification@im.ice",'
                +'"ENDURIndexName": "endur index name C",'
                +'"EndurTemplateID": "endur template id C",'
                +'"BPLegalEntityShortName": "bp legal entity short name C",'
                +'"BPLegalEntityEndurID": "bp legal entity endur id C",'
                +'"LastTradedOn": "2020-05-03",'
                +'"StartDate": "2020-05-01",'
                +'"EndDate": "2020-05-03",'
                +'"Price": ".7413"'
            +'},{'
                +'"PipelineName": "pipeline D",'
                +'"PipelineShortName": "pipeline short D",'
                +'"PipelineSourceSystemID": "pipeline source D",'
                +'"ZoneName": "zone D",'
                +'"ZoneShortName": "zone short D",'
                +'"ZoneSourceSystemID": "zone source D",'
                +'"MeterName": "meter D",'
                +'"MeterNumber": "meter number D",'
                +'"MeterSourceSystemID": "meter source D",'
                +'"PortfolioName": "portfolio D",'
                +'"TraderName": "trader D",'
                +'"TraderNTID": "trader ntid D",'
                +'"MarketKey": "market key D",'
                +'"BPNumber": "10487",'
                +'"EndurId": "12345",'
                +'"MarketStatus": "market status D",'
                +'"Volume": "1000",'
                +'"VolumeUnitOfMeasure": "MMBtu",'
                +'"ProductType": "product type D",'
                +'"DeliveryPeriod": "delivery period D",'
                +'"Currency": "USD",'
                +'"ICENotificationGroupEmails": "icenotification@im.ice",'
                +'"ENDURIndexName": "endur index name D",'
                +'"EndurTemplateID": "endur template id D",'
                +'"BPLegalEntityShortName": "bp legal entity short name D",'
                +'"BPLegalEntityEndurID": "bp legal entity endur id D",'
                +'"LastTradedOn": "2020-05-03",'
                +'"StartDate": "2020-05-01",'
                +'"EndDate": "2020-05-03",'
                +'"Price": ".7413"'
            +'}';
        
        responseBody = '{ "Markets": [ ' + records + ']}';
        return responseBody;
    }

    /**
    * @description Generates mock Mark to markets data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static String getMarkToMarkets(String[] bpNumbers, Integer pageSize, Integer pageNum){
        Map<String,String> fieldsDefinitions = new Map<String,String>();
        fieldsDefinitions.put('fileName', 'Text');
        fieldsDefinitions.put('counterparty', 'Text');
        fieldsDefinitions.put('gspId', 'Text');
        fieldsDefinitions.put('reportDate', 'Date');
        fieldsDefinitions.put('documentLink', 'Text');
        return ISTCP_mockAPIresponse.getMockDatatableRows('fileName', bpNumbers, fieldsDefinitions, pageSize, pageNum);
    }

    /**
    * @description Generates dummy data
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String[] bpNumbers 
    * @param Integer pageSize 
    * @param Integer pageNum 
    * @return String 
    **/
    public static void dummy(){
        String strJSON = '{ "test": "abc", "best": "cde", "rest": {"efg": "here"} }';

        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(strJSON);
        system.debug(objMap);
        for (String p : objMap.keySet()) {
            if(objMap.get(p) instanceof Map<string,Object>){
            Map<String,Object>  pp = (Map<String,Object>)objMap.get(p);
            system.debug(pp);
            }
            else if(objMap.get(p) instanceof String){
            system.debug(p+' --> '+objMap.get(p));
            }
        }
    }
}