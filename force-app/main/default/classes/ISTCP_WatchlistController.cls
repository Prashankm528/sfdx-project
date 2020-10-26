/**
 * @description       : Controller for operations with ISTCP watchlists
 * @group             : 
 * @last modified on  : 08-04-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_WatchlistController {

    /**
    * @description Queries the avaiable watchlists for a given user
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String userId 
    * @return List<ISTCP_GTP_Watchlist__c> 
    **/
    @AuraEnabled(cacheable=false)
    public static List<ISTCP_GTP_Watchlist__c> getWatchlists(String userId) {
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        
        return [SELECT Id, Name, OwnerId FROM ISTCP_GTP_Watchlist__c WHERE OwnerId =: userId ORDER BY Name ASC];
    }
    
    /**
    * @description Inserts new watchlist for a current user
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String name 
    * @return Object 
    **/
    @AuraEnabled
    public static Object upsertWatchlist(String id, String name) {
        try {
            String userId = UserInfo.getUserId();

            ISTCP_GTP_Watchlist__c watchlist = new ISTCP_GTP_Watchlist__c();
            if (id != null) {
                watchlist = [SELECT Id, Name, OwnerId FROM ISTCP_GTP_Watchlist__c WHERE Id =: Id LIMIT 1];
            }
            watchlist.Name = name;
            watchlist.OwnerId = userId;
            upsert watchlist;
            
            return watchlist;
        } catch(Exception e){
            String error = e.getMessage();
            System.debug(Logginglevel.ERROR, error);
            if (error.contains('DUPLICATE_VALUE')) {
                error = 'The watchlist can\'t be saved as you already have a watchlist with the same name.';
            }
            throw new AuraHandledException(error);
        }
    } 
    
    /**
    * @description Gets watchlist items for given watchlist
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String watchlistId 
    * @return List<ISTCP_Watchlist_Item__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<ISTCP_Watchlist_Item__c> getWatchlistItems(String watchlistId) {
        return [SELECT ISTCP_BP_Legal_Entity_Endur_ID__c, ISTCP_BP_Legal_Entity_Short_Name__c, ISTCP_BP_Number__c, ISTCP_Delivery_Period__c, 
        ISTCP_Direction__c, ISTCP_Endur_Id__c, ISTCP_End_Date__c, ISTCP_ENDUR_Index_Name__c, ISTCP_Endur_Template_ID__c, ISTCP_GTP_Watchlist__c, ISTCP_ICE_Notification_Group_Emails__c,
        ISTCP_Market_Key__c, ISTCP_Market_Status__c, ISTCP_Meter_Name__c, ISTCP_Meter_Number__c, ISTCP_Meter_Source_System_ID__c, ISTCP_Pipeline_Name__c,
        ISTCP_Pipeline_Short_Name__c, ISTCP_Pipeline_Source_System_ID__c, ISTCP_Portfolio_Name__c, ISTCP_Price__c, ISTCP_Product_Type__c, ISTCP_Start_Date__c, 
        ISTCP_Trader_Name__c, ISTCP_Trader_NTID__c, ISTCP_Unique_Name__c, ISTCP_Volume__c, ISTCP_Volume_Unit_Of_Measure__c, ISTCP_Zone_Name__c, 
        ISTCP_Zone_Short_Name__c, ISTCP_Zone_Source_System_ID__c 
        FROM ISTCP_Watchlist_Item__c WHERE ISTCP_GTP_Watchlist__c =: watchlistId ORDER BY Name ASC];
    }

    /**
    * @description Inserts provided watchlist items for given watchlist
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String watchlistId 
    * @param List<Object> wrappedItems 
    * @return List<ISTCP_Watchlist_Item__c> 
    **/
    @AuraEnabled
    public static List<ISTCP_Watchlist_Item__c> insertWatchlistItems(String watchlistId, List<Object> wrappedItems) {
        try {
            System.debug('>>> insertWatchlistItems watchlistId: ' + watchlistId + ' wrappedItems: ' + JSON.serializePretty(wrappedItems));
            List<ISTCP_Watchlist_Item__c> watchlistItems = new List<ISTCP_Watchlist_Item__c>();
            
            for (Object item : wrappedItems) {
                Map<Object, Object> wrappedItem = (Map<Object, Object>) item;
                ISTCP_Watchlist_Item__c watchlistItem = new ISTCP_Watchlist_Item__c();
                watchlistItem.ISTCP_GTP_Watchlist__c = watchlistId;
                String key = '';
                for(Object k : wrappedItem.keySet()){
                    key = String.valueOf(k);
                    switch on key {
                        when 'PipelineName' {
                            watchlistItem.ISTCP_Pipeline_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'PipelineShortName' {
                            watchlistItem.ISTCP_Pipeline_Short_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'PipelineSourceSystemID' {
                            watchlistItem.ISTCP_Pipeline_Source_System_ID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ZoneName' {
                            watchlistItem.ISTCP_Zone_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ZoneShortName' {
                            watchlistItem.ISTCP_Zone_Short_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ZoneSourceSystemID' {
                            watchlistItem.ISTCP_Zone_Source_System_ID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'MeterName' {
                            watchlistItem.ISTCP_Meter_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'MeterNumber' {
                            watchlistItem.ISTCP_Meter_Number__c = String.valueOf(wrappedItem.get(key));
                            watchlistItem.ISTCP_Unique_Name__c = watchlistId + '_' + watchlistItem.ISTCP_Meter_Number__c;
                        }
                        when 'MeterSourceSystemID' {
                            watchlistItem.ISTCP_Meter_Source_System_ID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'PortfolioName' {
                            watchlistItem.ISTCP_Portfolio_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'TraderName' {
                            watchlistItem.ISTCP_Trader_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'TraderNTID' {
                            watchlistItem.ISTCP_Trader_NTID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'MarketKey' {
                            watchlistItem.ISTCP_Market_Key__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'BPNumber' {
                            watchlistItem.ISTCP_BP_Number__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'EndurId' {
                            watchlistItem.ISTCP_Endur_Id__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'MarketStatus' {
                            watchlistItem.ISTCP_Market_Status__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'Volume' {
                            watchlistItem.ISTCP_Volume__c = Integer.valueOf(wrappedItem.get(key));
                        }
                        when 'VolumeUnitOfMeasure' {
                            watchlistItem.ISTCP_Volume_Unit_Of_Measure__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ProductType' {
                            watchlistItem.ISTCP_Product_Type__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'DeliveryPeriod' {
                            watchlistItem.ISTCP_Delivery_Period__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'CurrencyName' {
                            watchlistItem.CurrencyIsoCode = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ICENotificationGroupEmails' {
                            watchlistItem.ISTCP_ICE_Notification_Group_Emails__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'ENDURIndexName' {
                            watchlistItem.ISTCP_ENDUR_Index_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'EndurTemplateID' {
                            watchlistItem.ISTCP_Endur_Template_ID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'BPLegalEntityShortName' {
                            watchlistItem.ISTCP_BP_Legal_Entity_Short_Name__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'BPLegalEntityEndurID' {
                            watchlistItem.ISTCP_BP_Legal_Entity_Endur_ID__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'Direction' {
                            watchlistItem.ISTCP_Direction__c = String.valueOf(wrappedItem.get(key));
                        }
                        when 'Price' {
                            watchlistItem.ISTCP_Price__c = Decimal.valueOf(String.valueOf(wrappedItem.get(key)));
                        }
                        when 'StartDate' {
                            watchlistItem.ISTCP_Start_Date__c = Date.parse(String.valueOf(wrappedItem.get(key)));
                        }
                        when 'EndDate' {
                            watchlistItem.ISTCP_End_Date__c = Date.parse(String.valueOf(wrappedItem.get(key)));
                        }
                    }
                }
                watchlistItems.add(watchlistItem);
            }

            if (!watchlistItems.isEmpty()) {
                insert watchlistItems;
            }
            return watchlistItems;
        } catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }

    /**
    * @description Deletes watchlist items from provided watchlist
    * @author sebas.canseco@slalom.com | 07-09-2020 
    * @param String watchlistId 
    * @param List<Object> wrappedItems 
    **/
    @AuraEnabled
    public static void deleteWatchlistItems(String watchlistId, List<Object> wrappedItems){
        try {
            System.debug('>>> deleteWatchlistItems watchlistId: ' + watchlistId + ' wrappedItems: ' + JSON.serializePretty(wrappedItems));
            Set<Id> itemsIdsToDelete = new Set<Id>();
            for (Object item : wrappedItems) {
                Map<Object, Object> wrappedItem = (Map<Object, Object>) item;
                itemsIdsToDelete.add(String.valueOf(wrappedItem.get('Id')));
            }
            
            if (!itemsIdsToDelete.isEmpty()) {
                List<ISTCP_Watchlist_Item__c> watchlistItems = [SELECT Id FROM ISTCP_Watchlist_Item__c WHERE Id IN: itemsIdsToDelete];
                delete watchlistItems;
            }
        } catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}