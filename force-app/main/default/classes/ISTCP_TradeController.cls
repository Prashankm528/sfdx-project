public with sharing class ISTCP_TradeController {

    /**
    * @description Returns List<ISTCP_Trade__c> previously created today similar to the one provided.
    * @author sebas.canseco@slalom.com | 6/19/2020 
    * @param Trade t 
    * @return List<ISTCP_Trade__c> 
    **/
    @TestVisible
    private static List<ISTCP_Trade__c> getSimilarTradesToday(ISTCP_Trade__c t) {
        return 
            [SELECT Id FROM ISTCP_Trade__c WHERE CreatedDate = TODAY AND ISTCP_Meter_Name__c =: t.ISTCP_Meter_Name__c AND ISTCP_Pipeline_Name__c =: t.ISTCP_Pipeline_Name__c
            AND ISTCP_Zone_Name__c =: t.ISTCP_Zone_Name__c AND ISTCP_BP_Number__c =: t.ISTCP_BP_Number__c AND ISTCP_Endur_Id__c =: t.ISTCP_Endur_Id__c AND ISTCP_Product_Type__c =: t.ISTCP_Product_Type__c 
            AND ISTCP_Delivery_Period__c =: t.ISTCP_Delivery_Period__c AND ISTCP_Direction__c =: t.ISTCP_Direction__c]
        ;
    }
    
    /**
    * @description Inserts ISTCP_Trade__c record with provided Trade data. Builds and sends request to external system.
    * @author sebas.canseco@slalom.com | 6/19/2020 
    * @param Trade t 
    * @return String 
    **/
    @AuraEnabled
    public static Object executeTrade(Map<Object,Object> trade) {
        
        System.debug('trade to insert: ' + JSON.serializePretty(trade));
        ISTCP_Trade__c istcp_trade = new ISTCP_Trade__c();
        String key = '';
        for(Object k : trade.keySet()){
            key = String.valueOf(k);
            switch on key {
                when 'PipelineName' {
                    istcp_trade.ISTCP_Pipeline_Name__c = String.valueOf(trade.get(key));
                }
                when 'PipelineShortName' {
                    istcp_trade.ISTCP_Pipeline_Short_Name__c = String.valueOf(trade.get(key));
                }
                when 'PipelineSourceSystemID' {
                    istcp_trade.ISTCP_Pipeline_Source_System_ID__c = String.valueOf(trade.get(key));
                }
                when 'ZoneName' {
                    istcp_trade.ISTCP_Zone_Name__c = String.valueOf(trade.get(key));
                }
                when 'ZoneShortName' {
                    istcp_trade.ISTCP_Zone_Short_Name__c = String.valueOf(trade.get(key));
                }
                when 'ZoneSourceSystemID' {
                    istcp_trade.ISTCP_Zone_Source_System_ID__c = String.valueOf(trade.get(key));
                }
                when 'MeterName' {
                    istcp_trade.ISTCP_Meter_Name__c = String.valueOf(trade.get(key));
                }
                when 'MeterNumber' {
                    istcp_trade.ISTCP_Meter_Number__c = String.valueOf(trade.get(key));
                }
                when 'MeterSourceSystemID' {
                    istcp_trade.ISTCP_Meter_Source_System_ID__c = String.valueOf(trade.get(key));
                }
                when 'PortfolioName' {
                    istcp_trade.ISTCP_Portfolio_Name__c = String.valueOf(trade.get(key));
                }
                when 'TraderName' {
                    istcp_trade.ISTCP_Trader_Name__c = String.valueOf(trade.get(key));
                }
                when 'TraderNTID' {
                    istcp_trade.ISTCP_Trader_NTID__c = String.valueOf(trade.get(key));
                }
                when 'MarketKey' {
                    istcp_trade.ISTCP_Market_Key__c = String.valueOf(trade.get(key));
                }
                when 'BPNumber' {
                    istcp_trade.ISTCP_BP_Number__c = String.valueOf(trade.get(key));
                }
                when 'EndurId' {
                    istcp_trade.ISTCP_Endur_Id__c = String.valueOf(trade.get(key));
                }
                when 'MarketStatus' {
                    istcp_trade.ISTCP_Market_Status__c = String.valueOf(trade.get(key));
                }
                when 'Volume' {
                    istcp_trade.istcp_Volume__c = Integer.valueOf(trade.get(key));
                }
                when 'VolumeUnitOfMeasure' {
                    istcp_trade.ISTCP_Volume_Unit_Of_Measure__c = String.valueOf(trade.get(key));
                }
                when 'ProductType' {
                    istcp_trade.istcp_Product_Type__c = String.valueOf(trade.get(key));
                }
                when 'DeliveryPeriod' {
                    istcp_trade.ISTCP_Delivery_Period__c = String.valueOf(trade.get(key));
                }
                when 'CurrencyName' {
                    istcp_trade.CurrencyIsoCode = String.valueOf(trade.get(key));
                }
                when 'ICENotificationGroupEmails' {
                    istcp_trade.istcp_ICE_Notification_Group_Emails__c = String.valueOf(trade.get(key));
                }
                when 'ENDURIndexName' {
                    istcp_trade.ISTCP_ENDUR_Index_Name__c = String.valueOf(trade.get(key));
                }
                when 'EndurTemplateID' {
                    istcp_trade.istcp_Endur_Template_ID__c = String.valueOf(trade.get(key));
                }
                when 'BPLegalEntityShortName' {
                    istcp_trade.ISTCP_BP_Legal_Entity_Short_Name__c = String.valueOf(trade.get(key));
                }
                when 'BPLegalEntityEndurID' {
                    istcp_trade.istcp_BP_Legal_Entity_Endur_ID__c = String.valueOf(trade.get(key));
                }
                when 'Direction' {
                    istcp_trade.ISTCP_Direction__c = String.valueOf(trade.get(key));
                }
                when 'Quantity' {
                    istcp_trade.istcp_Quantity__c = Integer.valueOf(trade.get(key));
                }
                when 'Price' {
                    istcp_trade.ISTCP_Price__c = Decimal.valueOf(String.valueOf(trade.get(key)));
                }
                when 'StartDate' {
                    istcp_trade.istcp_Start_Date__c = Date.valueOf(String.valueOf(trade.get(key)));
                }
                when 'EndDate' {
                    istcp_trade.ISTCP_End_Date__c = Date.valueOf(String.valueOf(trade.get(key)));
                }
            }
        }
        
        if (getSimilarTradesToday(istcp_trade).isEmpty()) {
            insert istcp_trade;
            istcp_trade = [SELECT Id, Name, CreatedDate FROM ISTCP_Trade__c WHERE Id=: istcp_trade.Id LIMIT 1];
            //TODO: create method to build request and send it. In the meantime, return inserted ISTCP_Trade__c record JSON string.
            
            return istcp_trade;
        } else {
            return JSON.deserializeUntyped('{"error":"A similar trade already exists."}');
        }
    }
}