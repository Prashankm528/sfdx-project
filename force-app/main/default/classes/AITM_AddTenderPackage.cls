public with sharing class AITM_AddTenderPackage {
    // Fetching all the records of tenderLocationLineItem 
   
     public static Set<String> setOfCountries =  new Set<String>();
     public static Set<String> setOfManagers =  new Set<String>();
     public static List<String> listOfOptionToFilter =  new List<String>();


    @AuraEnabled
    //next
    public static  Map<string , List<AITM_Tender_Location_Line_Item__c>> getTenderLocationLineItems(string TenderId, List<string> newTenderLocationtoInsert, 
                                        List<string> TenderLocationAlreadyInserted, string PackageId, string editPackageId){
        system.debug('value is ' + TenderLocationAlreadyInserted + '' + 'Pack Id is ' + '' + editPackageId + '' + newTenderLocationtoInsert);

       Map<string , List<AITM_Tender_Location_Line_Item__c>> LocationCustomerMap =  new Map<string , List<AITM_Tender_Location_Line_Item__c>>();
        List<AITM_Tender_Location_Line_Item__c> clonedLocationLineItems = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> tenderLocationWithPackageId =  new List<AITM_Tender_Location__c>();
        List<AITM_Tender_Location__c> listOfLocationToUpdate =  new List<AITM_Tender_Location__c>();
        List<AITM_Tender_Location_Line_Item__c> locationlineItemsInserted = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = new List<AITM_Tender_Location_Line_Item__c>();
        
         locationlineItems = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, 
         AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,
         AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,
         AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c,
         AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c,
         AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,
         AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name,
         AITM_Offered_Differential__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
         FROM AITM_Tender_Location_Line_Item__c 
         WHERE  AITM_Tender_Location__c in: newTenderLocationtoInsert  AND AITM_Tender_Package__c = null AND  AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false order by AITM_Tender_Location__r.AITM_Location__r.Name asc ];

         if(!TenderLocationAlreadyInserted.isEmpty()){
             locationlineItemsInserted = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, 
            AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,
            AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,
            AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c,
            AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c,
            AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,
            AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name,
            AITM_Offered_Differential__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
            FROM AITM_Tender_Location_Line_Item__c 
            WHERE AITM_Tender_Package__c =:editPackageId   AND AITM_Tender_Location__c in: TenderLocationAlreadyInserted 
            AND  AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
            AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false order by AITM_Tender_Location__r.AITM_Location__r.Name asc ];
         }


         //system.assert(false,'List size is' + locationlineItemsInserted.size());

         for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
           
            AITM_Tender_Location_Line_Item__c clonedLineItem = cloneLocationLine.clone(false);
            clonedLineItem.AITM_Tender_Package__c = PackageId != null ?  PackageId : editPackageId ;
            
            
            clonedLocationLineItems.add(clonedLineItem);
         }


         
         system.debug('Cloned LocationLineItems is ' + clonedLocationLineItems.size());
         if(clonedLocationLineItems.size()>0){
            Database.insert(clonedLocationLineItems, false) ;
           // Database.update(listOfLocationToUpdate, false);
            system.debug(clonedLocationLineItems[0].Id);
           
            system.debug('Cloned with Previous LocationLineItems is ' + clonedLocationLineItems.size());
         }

         if(locationlineItemsInserted.size()>0 ){
            clonedLocationLineItems.addAll(locationlineItemsInserted);
        }

        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : clonedLocationLineItems){
            if(LocationCustomerMap.ContainsKey(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name)){
                LocationCustomerMap.get(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name).add(cloneLocationLine);
            }
            else{
                list<AITM_Tender_Location_Line_Item__c> atli=new list<AITM_Tender_Location_Line_Item__c>();
                atli.add(cloneLocationLine);
                LocationCustomerMap.put(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name, atli );
            }
        }

       


         
         return LocationCustomerMap; 
         //return null;
    }

    // to fetch all the location based on tender
    @AuraEnabled
    public static list<AITM_Tender_Location__c> getTenderLocationAddPackage(string TenderId){
        List<AITM_Tender_Location__c> listOfLocationToShow =  new List<AITM_Tender_Location__c>();
        
        listOfLocationToShow =  [SELECT Id , Name, AITM_Location__c, AITM_Is_Current_Round__c,AITM_Location__r.Name, AITM_Tender__c ,
        AITM_Location_Manager__r.Name, AITM_Location__r.AITM_Country__c
        FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:TenderId AND AITM_Is_Current_Round__c = true];

    
        return listOfLocationToShow;
    }

    
    // to fetch all the selected location based on package in edit case
    @AuraEnabled
    public static List<string> getTenderLocationEditPackage(string TenderId, string PackId ){
        system.debug('list of package id ' + PackId);
        set<string> locationset = new set<string>();
       
       List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT 
         AITM_Tender_Location__r.Id , AITM_Is_Current_Round__c
         FROM AITM_Tender_Location_Line_Item__c 
         WHERE  AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false AND 
         AITM_Tender_Package__c =:PackId AND AITM_Is_Current_Round__c = true ];
         system.debug('List size is' + locationlineItems.size()); 

         for(AITM_Tender_Location_Line_Item__c tenderLocation : locationlineItems){
            locationset.add(tenderLocation.AITM_Tender_Location__r.Id);
         }
         list<string> locationId = new list<string>(locationset);
         system.debug('list of location are' + locationId);
         return locationId;
    }
    // packages Tab
     @AuraEnabled
    public static  Map<string , List<locationItem>> getLineItemsByPackage(string TenderId){
        system.debug('Tender Id is' +TenderId);
        list<locationItem> tenderLocationItem = new list<locationItem>();
        Map<string , List<locationItem>> LocationCustomerMap =  new Map<string , List<locationItem>>();
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT Id, AITM_Tender_Package__c,AITM_Tender_Id__c,AITM_Volume__c,recordType.Name, 
        AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Delivery_Point_Info__c,AITM_Tender_Location__c,AITM_Offered_Volume__c,AITM_Tender_Location__r.AITM_Current_Round__c,
        AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_TENDER_PACKAGE__r.Name,
        AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Tender_Location__r.AITM_Country__c,
		AITM_Tender_Location__r.AITM_Status__c, AITM_Tender_Location__r.AITM_Location_Manager__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
        AITM_Tender_Location__r.AITM_Round__c, Owner.Name, AITM_Tender_Result__c,AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c,
        AITM_Tender_Location__r.AITM_Total_Requested_Volume__c,AITM_Record_Type_Name__c,AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c,
        AITM_Account__r.Name
        FROM AITM_Tender_Location_Line_Item__c 
        WHERE AITM_Is_Current_Round__c = true AND AITM_Tender__c = :TenderId 
        AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false AND  AITM_TENDER_PACKAGE__c !=null ];

        system.debug('list value is ' + locationlineItems.size());
       /* for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            string Key = cloneLocationLine.AITM_TENDER_PACKAGE__c + cloneLocationLine.AITM_TENDER_PACKAGE__r.Name;
            if(LocationCustomerMap.ContainsKey(Key)){
                LocationCustomerMap.get(Key).add(cloneLocationLine);
            }
            else{
                list<AITM_Tender_Location_Line_Item__c> atli=new list<AITM_Tender_Location_Line_Item__c>();
                atli.add(cloneLocationLine);
                LocationCustomerMap.put(Key, atli);
            }
        }*/
        //return LocationCustomerMap;
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
           
            locationItem locationItems = new locationItem();
            locationItems.Packageid =  cloneLocationLine.AITM_TENDER_PACKAGE__c;
            locationItems.PackageName = cloneLocationLine.AITM_TENDER_PACKAGE__r.Name;
            locationItems.recordId = cloneLocationLine.AITM_Tender_Location__r.Id;
            locationItems.locationIdentificator = cloneLocationLine.AITM_Tender_Location__r.AITM_IATA_ICAO__c;
            locationItems.locationName = cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name;
            locationItems.country = cloneLocationLine.AITM_Tender_Location__r.AITM_Country__c;
            locationItems.status = cloneLocationLine.AITM_Tender_Location__r.AITM_Status__c;
            locationItems.locationManagerId = cloneLocationLine.AITM_Tender_Location__r.AITM_Location_Manager__c;
            locationItems.locationManager = cloneLocationLine.AITM_Tender_Location__r.AITM_Location_Manager__r.Name;
            locationItems.lastTenderResult = cloneLocationLine.AITM_Tender_Result__c;
            locationItems.includeRevisedOffer = (cloneLocationLine.AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c)? 'Yes' : 'No';
            locationItems.round = cloneLocationLine.AITM_Tender_Location__r.AITM_Round__c;
            locationItems.currentRound = cloneLocationLine.AITM_Tender_Location__r.AITM_Current_Round__c;
            locationItems.volumeUSG = (cloneLocationLine.AITM_Tender_Location__r.AITM_Total_Requested_Volume__c !=null ? cloneLocationLine.AITM_Tender_Location__r.AITM_Total_Requested_Volume__c.round(system.roundingMode.HALF_UP) : null);
            locationItems.defaultDelPoint = (cloneLocationLine.AITM_Delivery_Point_Info__c != 'Select')? cloneLocationLine.AITM_Delivery_Point_Info__c : 'None';
            locationItems.pricingResponsibility = cloneLocationLine.Owner.Name;
            locationItems.offeredVolumeUSG = (cloneLocationLine.AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c != null ? cloneLocationLine.AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c.round(system.roundingMode.HALF_UP) : null);
            tenderLocationItem.add(locationItems);

        }
         system.debug('wrapperList is ' + tenderLocationItem);

         for(locationItem tenderItem : tenderLocationItem){
            string Key = tenderItem.Packageid + tenderItem.PackageName;
            if(LocationCustomerMap.ContainsKey(Key)){
                LocationCustomerMap.get(Key).add(tenderItem);
            }
            else{
                list<locationItem> atli=new list<locationItem>();
                atli.add(tenderItem);
                LocationCustomerMap.put(Key, atli);
            }
        }
       
        system.debug('Map is ' + LocationCustomerMap);
        return LocationCustomerMap;
    }


    //Wrapper with PackageId & Location associated to its locationLineItems
  /* public class PackageLocationAdapter{
        public @AuraEnabled string PackageidName ;
        public @AuraEnabled list<LocationItems> locationItems ;
    }*/

        public class locationItem{
        public @AuraEnabled string Packageid;
        public @AuraEnabled string PackageName;
        public @AuraEnabled String recordId;
        public @AuraEnabled String locationIdentificator;
        public @AuraEnabled String locationName;
        public @AuraEnabled String country;
        public @AuraEnabled Decimal volumeUSG;
        public @AuraEnabled Decimal offeredVolumeUSG;
        public @AuraEnabled String lastTenderResult;
        public @AuraEnabled String locationManager;
        public @AuraEnabled String locationManagerId;
        public @AuraEnabled String status;
        public @AuraEnabled Decimal round;
        public @AuraEnabled Decimal currentRound;
        public @AuraEnabled String includeRevisedOffer;
        public @AuraEnabled String defaultDelPoint;
        public @AuraEnabled String pricingResponsibility;
        }
    



    }

