@isTest
public with sharing class ISTCP_WatchlistControllerTest {
    
    @IsTest
    static void test(){
        System.assertEquals(0, ISTCP_WatchlistController.getWatchlists(null).size());
        ISTCP_GTP_Watchlist__c watchlist = (ISTCP_GTP_Watchlist__c)ISTCP_WatchlistController.upsertWatchlist(null, 'test');
        System.assertEquals(1, ISTCP_WatchlistController.getWatchlists(null).size());
        System.assertEquals(0, ISTCP_WatchlistController.getWatchlistItems(watchlist.Id).size());
        Map<Object, Object> item = new Map<Object, Object>();
        String uniqueParam = 'test meter2';
        item.put('PipelineName','test pipeline');
        item.put('PipelineShortName','test pipeline');
        item.put('PipelineSourceSystemID','test pipeline');
        item.put('ZoneName','test zone');
        item.put('ZoneShortName','test zone');
        item.put('ZoneSourceSystemID','test zone');
        item.put('MeterName',uniqueParam);
        item.put('MeterNumber',uniqueParam);
        item.put('MeterSourceSystemID',uniqueParam);
        item.put('PortfolioName','test bpnumber');
        item.put('TraderName','test bpnumber');
        item.put('TraderNTID','test bpnumber');
        item.put('MarketKey','test bpnumber');
        item.put('BPNumber','test bpnumber');
        item.put('EndurId','test endurid');
        item.put('MarketStatus','test bpnumber');
        item.put('Volume',1000);
        item.put('VolumeUnitOfMeasure','test volumeunit');
        item.put('ProductType','test product type');
        item.put('DeliveryPeriod','test delivery period');
        item.put('CurrencyName','USD');
        item.put('ICENotificationGroupEmails','test bpnumber');
        item.put('ENDURIndexName','test bpnumber');
        item.put('EndurTemplateID','test bpnumber');
        item.put('BPLegalEntityShortName','test bpnumber');
        item.put('BPLegalEntityEndurID','test bpnumber');
        item.put('Direction','Buy');
        item.put('Watchlist',watchlist.Id);
        item.put('Price',0.23);
        List<Object> items = new List<Object>{item};
        ISTCP_WatchlistController.insertWatchlistItems(watchlist.Id, items);
        System.assertEquals(1, ISTCP_WatchlistController.getWatchlistItems(watchlist.Id).size());
    }
}