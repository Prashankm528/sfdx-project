@isTest
public with sharing class ISTCP_TradeControllerTest {
    
    static ISTCP_Trade__c trade = new ISTCP_Trade__c(
        ISTCP_Meter_Name__c = 'test meter', ISTCP_Pipeline_Name__c = 'test pipeline', ISTCP_Zone_Name__c = 'test zone', 
        ISTCP_BP_Number__c = 'test bpnumber', ISTCP_Endur_Id__c = 'test endurid', ISTCP_Volume__c = 1000, ISTCP_Volume_Unit_Of_Measure__c = 'test volumeunit',
        ISTCP_Product_Type__c = 'test product type', ISTCP_Delivery_Period__c = 'test delivery period', CurrencyIsoCode = 'USD', ISTCP_Direction__c = 'Buy',
        ISTCP_Quantity__c = 800, ISTCP_Price__c = 0.23
    );
  
    @IsTest
    static void getSimilarTradesToday(){
        insert trade;
        // Assert a similar trade exists
        System.assertEquals(false, ISTCP_TradeController.getSimilarTradesToday(trade).isEmpty());
        trade.ISTCP_Meter_Name__c = 'random meter name';
        // Assert a similar trade doesn't exist
        System.assertEquals(true, ISTCP_TradeController.getSimilarTradesToday(trade).isEmpty());
    }

    @IsTest
    static void executeTrade(){
        Map<Object, Object> t = new Map<Object, Object>();
        String uniqueParam = 'test meter2';
        t.put('PipelineName','test pipeline');
        t.put('PipelineShortName','test pipeline');
        t.put('PipelineSourceSystemID','test pipeline');
        t.put('ZoneName','test zone');
        t.put('ZoneShortName','test zone');
        t.put('ZoneSourceSystemID','test zone');
        t.put('MeterName',uniqueParam);
        t.put('MeterNumber',uniqueParam);
        t.put('MeterSourceSystemID',uniqueParam);
        t.put('PortfolioName','test bpnumber');
        t.put('TraderName','test bpnumber');
        t.put('TraderNTID','test bpnumber');
        t.put('MarketKey','test bpnumber');
        t.put('BPNumber','test bpnumber');
        t.put('EndurId','test endurid');
        t.put('MarketStatus','test bpnumber');
        t.put('Volume',1000);
        t.put('VolumeUnitOfMeasure','test volumeunit');
        t.put('ProductType','test product type');
        t.put('DeliveryPeriod','test delivery period');
        t.put('CurrencyName','USD');
        t.put('ICENotificationGroupEmails','test bpnumber');
        t.put('ENDURIndexName','test bpnumber');
        t.put('EndurTemplateID','test bpnumber');
        t.put('BPLegalEntityShortName','test bpnumber');
        t.put('BPLegalEntityEndurID','test bpnumber');
        t.put('Direction','Buy');
        t.put('Quantity',800);
        t.put('Price',0.23);
        t.put('StartDate','2020-06-15');
        t.put('EndDate','2020-06-20');

        System.assertEquals(0, [SELECT count() FROM ISTCP_Trade__c WHERE ISTCP_Meter_Name__c =: uniqueParam]);
        ISTCP_TradeController.executeTrade(t);
        System.assertEquals(1, [SELECT count() FROM ISTCP_Trade__c WHERE ISTCP_Meter_Name__c =: uniqueParam]);
    }
}