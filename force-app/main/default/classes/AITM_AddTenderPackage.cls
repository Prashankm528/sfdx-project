/***************************************************************
 * @author           Prashank
 * @date             11/Oct/2020
 * @group            AirBP
 * @description      Class to Add Tender Package

 * history
 * 11/Oct/2020  	 Prashank       Created 
 **********************************************************/
public with sharing class AITM_AddTenderPackage {
    
    public static Set<String> setOfCountries =  new Set<String>();
    public static Set<String> setOfManagers =  new Set<String>();
    public static List<String> listOfOptionToFilter =  new List<String>();
    public final static String OBJECT_NAME = 'AITM_Tender_Location_Line_Item__c';
    public final static String CURRENCY_FIELD_NAME = 'AITM_Currency__c';
    public final static String UOM_FIELD_NAME = 'AITM_Unit_Of_Measure__c';
    public static List<locationInCustomersComponent> loccustomerList;
    private static final ID ID_TLLI_RECORD_TYPE_DEFAULT = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    
    @AuraEnabled
    public static List<locationInCustomersComponent> getTenderLocationLineItems(String TenderId, List<String> newTenderLocationtoInsert, 
       List<string> TenderLocationAlreadyInserted, String PackageId, String editPackageId) {
       system.debug('value is ' +'Tender id'+ TenderId+ 'Already Inserted Location' + TenderLocationAlreadyInserted + '' + 'Pack Id is ' + '' + editPackageId + 'Tender location to insert' + newTenderLocationtoInsert);
      
       Map<String, List<AITM_Tender_Location_Line_Item__c>> LocationCustomerMap = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
       Map<String, AITM_Tender_Location_Line_Item__c> locationLineItemMap = new Map<String, AITM_Tender_Location_Line_Item__c>();
       List<AITM_Tender_Location_Line_Item__c> clonedLocationLineItems = new List<AITM_Tender_Location_Line_Item__c>();
       List<AITM_Tender_Location__c> tenderLocationWithPackageId = new List<AITM_Tender_Location__c>();
       List<AITM_Tender_Location__c> listOfLocationToUpdate = new List<AITM_Tender_Location__c>();
       List<AITM_Tender_Location_Line_Item__c> locationlineItemsInserted = new List<AITM_Tender_Location_Line_Item__c>();
       List<AITM_Tender_Location_Line_Item__c> locationlineItems = new List<AITM_Tender_Location_Line_Item__c>();
       Set<Id> locationStatusToUpdate = new Set<Id>();
        
       locationlineItems = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Pricing_Basis__c,
                            AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c,
                            AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Internal_Notes_For_Package_Location__c,
                            AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c,AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
                            AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c,AITM_Account__r.Id, AITM_Package_Offered_Differential__c,AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c,
                            AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,AITM_Pricing_Basis__r.Name,AITM_Tender_Location__r.AITM_Location_Contribution_To_Package__c,
                            AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name,AITM_Tender_Location__r.AITM_Location__r.Id,AITM_Requested_Volume_USG__c,
                            AITM_Offered_Differential__c,AITM_Title__c,AITM_Standalone_Customer_Id__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
                            FROM AITM_Tender_Location_Line_Item__c 
                            WHERE AITM_Tender_Location__c in: newTenderLocationtoInsert AND AITM_Tender_Package__c = null AND  AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
                            AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false   order by AITM_Tender_Location__r.AITM_Location__r.Name asc ];

        if(!TenderLocationAlreadyInserted.isEmpty()){
            String packId = String.isBlank(editPackageId)? PackageId : editPackageId;
            locationlineItemsInserted = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Pricing_Basis__c,
                                         AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c,
                                         AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,AITM_Tender_Location__r.AITM_IATA_ICAO__c,AITM_Tender_Location__r.AITM_Internal_Notes_For_Package_Location__c,
                                         AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c, AITM_Package_Offered_Differential__c,AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c,
                                         AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.Id, AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
                                         AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,AITM_Pricing_Basis__r.Name,AITM_Tender_Location__r.AITM_Location_Contribution_To_Package__c,
                                         AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name, AITM_Tender_Location__r.AITM_Location__r.Id,AITM_Requested_Volume_USG__c,
                                         AITM_Offered_Differential__c,AITM_Title__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
                                         FROM AITM_Tender_Location_Line_Item__c 
                                         WHERE AITM_Tender_Package__c =:packId AND AITM_Tender_Location__c IN: TenderLocationAlreadyInserted 
                                         AND AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
                                         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false  order by AITM_Tender_Location__r.AITM_Location__r.Name asc ];
        }

        loccustomerList = new List<locationInCustomersComponent>();
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            locationLineItemMap.put(cloneLocationLine.Id, cloneLocationLine);
        }
        
           
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            locationStatusToUpdate.add(cloneLocationLine.AITM_Tender_Location__c);
            AITM_Tender_Location_Line_Item__c clonedLineItem = cloneLocationLine.clone(false);
            clonedLineItem.AITM_Tender_Package__c = PackageId != null ?  PackageId : editPackageId ;
            clonedLineItem.AITM_Standalone_Customer_Id__c = cloneLocationLine.Id;
            if(locationLineItemMap.containsKey(clonedLineItem.AITM_Standalone_Customer_Id__c)){
                clonedLineItem.AITM_Delivery_Point__c = locationLineItemMap.get(clonedLineItem.AITM_Standalone_Customer_Id__c).AITM_Delivery_Point__c != null? locationLineItemMap.get(clonedLineItem.AITM_Standalone_Customer_Id__c).AITM_Delivery_Point__c : null;
                clonedLineItem.AITM_Pricing_Basis__c = locationLineItemMap.get(clonedLineItem.AITM_Standalone_Customer_Id__c).AITM_Pricing_Basis__c != null  ? locationLineItemMap.get(clonedLineItem.AITM_Standalone_Customer_Id__c).AITM_Pricing_Basis__c : null;
            }
            clonedLocationLineItems.add(clonedLineItem);
        }

        if(clonedLocationLineItems.size()>0){
            Database.insert(clonedLocationLineItems, false);
        }
        List<AITM_Tender_Location__c> locations = [SELECT Id, AITM_Status__c FROM AITM_Tender_Location__c WHERE ID IN:locationStatusToUpdate];
        for(AITM_Tender_Location__c location : locations){
            location.AITM_Status__c = 'Awaiting price';
        }
           
        if(locations.size()>0){
            Database.update(locations, false);
        }

        if(locationlineItemsInserted.size()>0 ){
            clonedLocationLineItems.addAll(locationlineItemsInserted); // all location new+ laready inserted
        }
        
        List<String> listofTlli = new List<String>();
        clonedLocationLineItems.sort();
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : clonedLocationLineItems){
            cloneLocationLine.AITM_Tender_Location__r.AITM_Status__c = 'Awaiting price';
            if(LocationCustomerMap.ContainsKey(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name)){
                LocationCustomerMap.get(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name).add(cloneLocationLine);
            }else{
                list<AITM_Tender_Location_Line_Item__c> atli = new List<AITM_Tender_Location_Line_Item__c>();
                atli.add(cloneLocationLine);
                LocationCustomerMap.put(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name, atli);
            }
             
            String key = cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name + '-' + cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Id; 
            if(!listofTlli.contains(key)) {
                listofTlli.add(key);
                loccustomerList.add(new locationInCustomersComponent(key,cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r, cloneLocationLine.AITM_Tender_Location__r, LocationCustomerMap.get(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name)));
            }
        }
        return loccustomerList;
    }

    @AuraEnabled
    public static List<AITM_Delivery_Point__c> getDelieveryPointbylocations(String locationId){
        try {
            return [SELECT Id, AITM_Default_Delivery_Point__c, AITM_Service_Level_Provided__c,
                    AITM_BPInter_Location_DeliveryPoint_Cod__c, AITM_Delivery_Point_External_Name__c, AITM_Location__c
                    FROM AITM_Delivery_Point__c WHERE AITM_Location__c =: locationId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<AITM_Tender_Location__c> getTenderLocationAddPackage(String TenderId){
        List<AITM_Tender_Location__c> listOfLocationToShow =  new List<AITM_Tender_Location__c>();
        listOfLocationToShow = [SELECT Id , Name, AITM_Location__c, AITM_Is_Current_Round__c,AITM_Location__r.Name, AITM_Tender__c ,
                                 AITM_Location_Manager__r.Name, AITM_Location__r.AITM_Country__c, AITM_IATA_ICAO__c,AITM_Round__c
                                 FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:TenderId AND AITM_Is_Current_Round__c = true order by AITM_IATA_ICAO__c];

        return listOfLocationToShow;
    }
    
    @AuraEnabled
    public static List<AITM_Tender_Location__c> getTenderLocationToAddCustomer(String packageId, String tenderId, String AccountId, List<Id> listOfSelectedLocationIds){
        List<AITM_Tender_Location__c> listOfLocationToShow = new List<AITM_Tender_Location__c>();
        Set<Id> locationIds = new Set<Id>();
        Set<Id> packageLocIds = new Set<Id>(listOfSelectedLocationIds);
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT AITM_Tender_Location__c FROM AITM_Tender_Location_Line_Item__c 
                                                                     WHERE AITM_Is_Current_Round__c = true 
                                                                         AND AITM_Tender__c = :tenderId AND AITM_Account__c = :AccountId
                                                                         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false 
                                                                         AND AITM_Tender_Package__c = :packageId AND AITM_Is_Current_Round__c = true];
        for(AITM_Tender_Location_Line_Item__c item : locationlineItems){
            locationIds.add(item.AITM_Tender_Location__c);
        }
        
        for(Id objId : packageLocIds){
            if(locationIds.contains(objId)){
                packageLocIds.remove(objId);
            }  
        }
        
        if(packageLocIds != null){
            listOfLocationToShow = [SELECT Id , Name, AITM_Location__c, AITM_Is_Current_Round__c,AITM_Location__r.Name, AITM_Tender__c ,
                                 AITM_Location_Manager__r.Name, AITM_Location__r.AITM_Country__c, AITM_IATA_ICAO__c,AITM_Round__c,
                                 AITM_Tender__r.AITM_Start_Date__c, AITM_Tender__r.AITM_End_Date__c
                                 FROM AITM_Tender_Location__c WHERE Id IN :packageLocIds AND AITM_Tender__c =:TenderId AND AITM_Is_Current_Round__c = true order by AITM_IATA_ICAO__c];
        }
        return listOfLocationToShow;
    }

    @AuraEnabled
    public static List<String> getTenderLocationEditPackage(String TenderId, String PackId, String createPackId ){
        Set<String> locationset = new Set<String>();
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT AITM_Tender_Location__r.Id , AITM_Is_Current_Round__c
                                                                     FROM AITM_Tender_Location_Line_Item__c 
                                                                     WHERE AITM_Is_Current_Round__c = true 
                                                                         AND AITM_Tender__c = :tenderId 
                                                                         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false 
                                                                         AND AITM_Tender_Package__c =:PackId AND AITM_Is_Current_Round__c = true];

        for(AITM_Tender_Location_Line_Item__c tenderLocation : locationlineItems){
            locationset.add(tenderLocation.AITM_Tender_Location__r.Id);
        }
        List<String> locationId = new List<String>(locationset);
        return locationId;
    }
    
    @AuraEnabled
    public static Map<String, List<locationItem>> getLineItemsByPackage(String TenderId){
        List<locationItem> tenderLocationItem = new List<locationItem>();
        Map<String, List<locationItem>> LocationCustomerMap = new Map<String, List<locationItem>>();
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT Id, AITM_Tender_Package__c,AITM_Tender_Id__c,AITM_Volume__c,recordType.Name, 
                                                                     AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Delivery_Point_Info__c,AITM_Tender_Location__c,AITM_Offered_Volume__c,AITM_Tender_Location__r.AITM_Current_Round__c,
                                                                     AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Tender_Package__r.Name, AITM_Tender_Package__r.AITM_Package_Counter__c,
                                                                     AITM_Tender_Location__r.AITM_IATA_ICAO__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Tender_Location__r.AITM_Country__c,
                                                                     AITM_Tender_Location__r.AITM_Status__c, AITM_Tender_Location__r.AITM_Location_Manager__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
                                                                     AITM_Tender_Location__r.AITM_Round__c, Owner.Name, AITM_Tender_Result__c,AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c,AITM_Requested_Volume_USG__c,
                                                                     AITM_Tender_Location__r.AITM_Total_Requested_Volume__c,AITM_Record_Type_Name__c,AITM_Tender_Location__r.AITM_Total_Volume_Offered_To_The_Group__c,
                                                                     AITM_Account__r.Name,AITM_Tender_Location__r.AITM_Location_Contribution_To_Package__c
                                                                     FROM AITM_Tender_Location_Line_Item__c 
                                                                     WHERE AITM_Is_Current_Round__c = true AND AITM_Tender__c = :TenderId 
                                                                     AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false AND AITM_TENDER_PACKAGE__c != null order by AITM_Tender_Package__r.AITM_Package_Counter__c];

        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            locationItem locationItems = new locationItem();
            locationItems.Packageid =  cloneLocationLine.AITM_TENDER_PACKAGE__c;
            locationItems.PackageName = cloneLocationLine.AITM_Tender_Package__r.Name;
            locationItems.PackageCounter = cloneLocationLine.AITM_Tender_Package__r.AITM_Package_Counter__c;
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
        
        Map<String, Set<String>> mapOfPackWithUniqueLocationName = new Map<String, Set<String>>();
        for(locationItem tenderItem : tenderLocationItem){
            String Key = tenderItem.PackageCounter + tenderItem.Packageid + tenderItem.PackageName;
            if(!LocationCustomerMap.ContainsKey(Key)){
                LocationCustomerMap.put(Key, new List<locationItem>{tenderItem});
                mapOfPackWithUniqueLocationName.put(Key, new Set<String>{tenderItem.locationName});
            }else{
                Set<String> locationNames = mapOfPackWithUniqueLocationName.get(Key);
                if(!locationNames.contains(tenderItem.locationName)){
                    LocationCustomerMap.get(Key).add(tenderItem);
                    locationNames.add(tenderItem.locationName);
                }
            }
        }
        return LocationCustomerMap;
    }
    
    @AuraEnabled
    public static void deletePackage(String packageId){
        List<sObject> sObjectRecordsToDelete = new List<sObject>();
        List<AITM_Tender_Location_Line_Item__c> listOfLineItemsToDelete = [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE AITM_TENDER_PACKAGE__c =:packageId];
        sObjectRecordsToDelete.addAll(listOfLineItemsToDelete);
        
        List<AITM_TENDER_PACKAGE__c> listOfPackageToDelete = [SELECT Id FROM AITM_TENDER_PACKAGE__c WHERE Id =:packageId];
        sObjectRecordsToDelete.addAll(listOfPackageToDelete);
        
        Database.delete(sObjectRecordsToDelete, false);
    }

    @AuraEnabled
    public static List<locationInCustomersComponent> deletelocationLineItems(String packageId, String tenderId, List<Id> listOfLineItems){

        List<AITM_Tender_Location_Line_Item__c> listOfLineItemsToDelete = [SELECT Id FROM AITM_Tender_Location_Line_Item__c WHERE Id IN:listOfLineItems];
        delete listOfLineItemsToDelete;
        
        List<locationInCustomersComponent> wrapperAfterDelete = fillWrapperToShowUpdatedLineItems(packageId, tenderId);
        return wrapperAfterDelete;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getListOfCurrency(){
        return getPickValues(OBJECT_NAME,CURRENCY_FIELD_NAME);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getListOfUOMoptions(){
        return getPickValues(OBJECT_NAME,UOM_FIELD_NAME);
    }
    
    /**
     * @description returns list collection of picklist values for field of sobject
     * @param objectName of type string
     * @param fieldName of type string
     * @return List collection of string
     */
    @TestVisible
    private static List<String> getPickValues(String objectName, String fieldName){ 
        List<SelectOption> selectOptions = AITM_BaseUtils.getPickValues(objectName, fieldName, NULL);
        List<String> stringValues = new List<String>();
        for(SelectOption so : selectOptions){
            stringValues.add(so.getValue());
        }
        return stringValues;
    }

    @AuraEnabled()
    public static String getPackageCounter(String TenderId){
        String counter = null;
        List<AITM_Tender_Package__c> listOftenderPackage = [SELECT AITM_Package_Counter__c FROM AITM_Tender_Package__c WHERE AITM_Tender__c =:TenderId order by createdDate desc limit 1];
        if(listOftenderPackage.size() == 0){
            counter = 'Package 1';
        }else{
            String[] strArr = listOftenderPackage[0].AITM_Package_Counter__c.split(' ');
            String strNumber = '';
            Integer myNumber;
            if(strArr.size() == 2){
                strNumber = strArr[1];
                myNumber = Integer.valueOf(strNumber) + 1;
                counter = 'Package ' + myNumber;
            }
        }
        return counter;
    }

    @AuraEnabled
    public static List<AITM_Tender_Location_Line_Item__c> getListOfLineItemsOnStatusChange(String tenderLocationId){
        List<AITM_Tender_Location_Line_Item__c> lineItems = new AITM_LocationsDao().getTenderLocationLineItemsByRecordType(tenderLocationId, ID_TLLI_RECORD_TYPE_DEFAULT);
        return lineItems;
    }
    
    @AuraEnabled
    public static String updateDeliveryRecords(String deliveryRecordId, String lineItemId){
        String error = AITM_TenderLocationNewOffer.updateDeliveryRecords(deliveryRecordId, lineItemId);
        return error;
    }
    
    @AuraEnabled
    public static List<locationInCustomersComponent> wrapperToShowLocationLineItemDetails(List<AITM_Tender_Location_Line_Item__c> locationlineItems){
        List<String> listofTlli = new List<String>();
        loccustomerList = new List<locationInCustomersComponent>();
        Map<String, List<AITM_Tender_Location_Line_Item__c>> LocationCustomerMap = new Map<String, List<AITM_Tender_Location_Line_Item__c>>();
        
        //locationlineItemsAlreadyInserted.sort();
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            if(LocationCustomerMap.ContainsKey(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name)){
                LocationCustomerMap.get(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name).add(cloneLocationLine);
            }else{
                list<AITM_Tender_Location_Line_Item__c> atli = new List<AITM_Tender_Location_Line_Item__c>();
                atli.add(cloneLocationLine);
                LocationCustomerMap.put(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name, atli);
            }
             
            String key = cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name + '-' + cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Id; 
            if(!listofTlli.contains(key)) {
                listofTlli.add(key);
                loccustomerList.add(new locationInCustomersComponent(key,cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r, cloneLocationLine.AITM_Tender_Location__r, LocationCustomerMap.get(cloneLocationLine.AITM_Tender_Location__r.AITM_Location__r.Name)));
            }
        }
        
        return loccustomerList;
    }

    @AuraEnabled
    public static List<sobject> findRecords(String searchKeyWord, String ObjectName, string tender) {  
        String sQuery;
       
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(ObjectName == 'AITM_Pricing_Basis__c')  
        {
        sQuery =  'select id, Name,AITM_Description__c from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC LIMIT 100';
        }
        else if(ObjectName == 'AITM_Tender_Account__c'){
            searchKey = '%' + searchKey;
            sQuery  =  'select id, AITM_Account__c, AITM_Customer_Name__c, AITM_Credit_Days1__c,AITM_Security_Type__c,AITM_Invoice_Frequency__c, AITM_Payment_Currency__c , AITM_GRN__c from ' +ObjectName + ' where AITM_Customer_Name__c LIKE: searchKey AND AITM_Tender__c =:tender order by AITM_Customer_Name__c DESC LIMIT 100';
        }
        else{
           sQuery  =  'select id, Name from ' +ObjectName + ' where AITM_Tender__c =:tender AND Name LIKE: searchKey order by createdDate DESC LIMIT 100';
        }
            List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        system.debug('list of records-->' + returnList);
        return returnList;
    }
        
    @AuraEnabled
    public static List<locationInCustomersComponent> clonelocationLineItems(String packageId, String tenderId, List<Id> listOfLineItems){
        List<AITM_Tender_Location_Line_Item__c> locationlineItemsToBeClone = new List<AITM_Tender_Location_Line_Item__c>();
         
        List<AITM_Tender_Location_Line_Item__c> locationlineItems = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Pricing_Basis__c,
                                         AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c,
                                         AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,AITM_Tender_Location__r.AITM_IATA_ICAO__c,AITM_Tender_Location__r.AITM_Internal_Notes_For_Package_Location__c,
                                         AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c, AITM_Package_Offered_Differential__c,
                                         AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.Id,AITM_Requested_Volume_USG__c,AITM_Tender_Location__r.AITM_Location_Contribution_To_Package__c,
                                         AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,AITM_Pricing_Basis__r.Name,
                                         AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name, AITM_Tender_Location__r.AITM_Location__r.Id,AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
                                         AITM_Offered_Differential__c,AITM_Title__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
                                         FROM AITM_Tender_Location_Line_Item__c 
                                         WHERE Id IN :listOfLineItems AND AITM_Tender_Package__c = :packageId
                                         AND AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
                                         AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false order by AITM_Tender_Location__r.AITM_Location__r.Name asc];
        
        for(AITM_Tender_Location_Line_Item__c cloneLocationLine : locationlineItems){
            AITM_Tender_Location_Line_Item__c clonedLineItem = cloneLocationLine.clone(false);
            clonedLineItem.AITM_Tender_Package__c = PackageId;
            clonedLineItem.AITM_Standalone_Customer_Id__c = cloneLocationLine.Id;
            if(cloneLocationLine.AITM_Delivery_Point__c != null)
            clonedLineItem.AITM_Delivery_Point__c = cloneLocationLine.AITM_Delivery_Point__c;
            
            if(cloneLocationLine.AITM_Pricing_Basis__c != null)
            clonedLineItem.AITM_Pricing_Basis__c = cloneLocationLine.AITM_Pricing_Basis__c;
            
            locationlineItemsToBeClone.add(clonedLineItem);
        }
        
        if(locationlineItemsToBeClone.size()>0){
            Database.insert(locationlineItemsToBeClone, false);
        }
      
        List<locationInCustomersComponent> wrapperAfterClone = fillWrapperToShowUpdatedLineItems(packageId, tenderId);
        return wrapperAfterClone;
    }
    
    @AuraEnabled
    public static List<locationInCustomersComponent> updatelocationLineItems(String packageId, String tenderId, String listoflineItemtoUpdate, String locationToUpdate, String packagetoupdate){
        List<sObject> tenderItems = new List<sObject>();
        
        List<TenderLocationLineItemWrapper> wrappedLineItems = (List<TenderLocationLineItemWrapper>) JSON.deserialize(listoflineItemtoUpdate, List<TenderLocationLineItemWrapper>.class);
        for (TenderLocationLineItemWrapper wrappedRecord : wrappedLineItems) {
            tenderItems.add(wrappedRecord.unwrap());
        }
        
        List<TenderLocationWrapper> wrappedLocations = (List<TenderLocationWrapper>) JSON.deserialize(locationToUpdate, List<TenderLocationWrapper>.class);
        for (TenderLocationWrapper wrappedRecord : wrappedLocations) {
            tenderItems.add(wrappedRecord.unwrap());
        }
        
        List<TenderPackageWrapper> wrappedPackageDetails = (List<TenderPackageWrapper>) JSON.deserialize(packagetoupdate, List<TenderPackageWrapper>.class);
        for (TenderPackageWrapper wrappedRecord : wrappedPackageDetails) {
            tenderItems.add(wrappedRecord.unwrap());
        }
        
        Database.update(tenderItems);
        
        List<locationInCustomersComponent> wrapperAfterUpdate = fillWrapperToShowUpdatedLineItems(packageId, tenderId);
        return wrapperAfterUpdate;
    }
    
    @AuraEnabled
    public static List<locationInCustomersComponent> fillWrapperToShowUpdatedLineItems(String packageId, String tenderId){
        List<AITM_Tender_Location_Line_Item__c> locationlineItemsAlreadyInserted = [SELECT Id, AITM_Tender_Location__r.AITM_Round__c, AITM_Pricing_Basis__c,
                                                                                    AITM_Delivery_Method__c, AITM_Tender_Package__c,AITM_End_Date__c, AITM_Start_Date__c,AITM_Delivery_Point__c,AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c,
                                                                                    AITM_Location_Delivery_Point__c, AITM_Product_Default__c, AITM_Tender_Id__c,AITM_Volume__c,AITM_Tender_Location__r.AITM_IATA_ICAO__c,AITM_Tender_Location__r.AITM_Internal_Notes_For_Package_Location__c,
                                                                                    AITM_Tender__c, AITM_Tender__r.AITM_Tender_Sector__c, AITM_Tender_Location__c,AITM_Offered_Volume__c, AITM_Package_Offered_Differential__c,AITM_Tender_Location__r.AITM_Location_Contribution_To_Package__c,
                                                                                    AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c, AITM_Account__c, AITM_Account__r.Id, AITM_Tender_Location__r.AITM_Location__r.AITM_Country__c, AITM_Tender_Location__r.AITM_Location_Manager__r.Name,
                                                                                    AITM_Account__r.AITM_Account_Classification__c, recordType.Name, AITM_Previous_TLLI_Id__c, AITM_DEPE_Pricing_Basis__c,AITM_Pricing_Basis__r.Name,
                                                                                    AITM_Record_Type_Name__c, AITM_Tender_Location__r.AITM_Location__r.Name,AITM_Account__r.Name, AITM_Tender_Location__r.AITM_Location__r.Id,AITM_Requested_Volume_USG__c,
                                                                                    AITM_Offered_Differential__c,AITM_Title__c, AITM_Tender_Location__r.AITM_Status__c,AITM_Percentage_Volume_Offered__c,AITM_Unit_Of_Measure__c,AITM_Currency__c,AITM_Location__r.AITM_IATA_ICAO__c
                                                                                    FROM AITM_Tender_Location_Line_Item__c 
                                                                                    WHERE AITM_Tender_Package__c = :packageId
                                                                                    AND AITM_Is_Current_Round__c = true AND AITM_Tender__c = :tenderId 
                                                                                    AND AITM_Tender__r.AITM_Select_to_Apply_Old_Taxes_and_Fees__c = false order by AITM_Tender_Location__r.AITM_Location__r.Name asc];
        
        List<locationInCustomersComponent> wrapperDataUpdateAfterProcessing = wrapperToShowLocationLineItemDetails(locationlineItemsAlreadyInserted);
        return wrapperDataUpdateAfterProcessing;
    }

    @AuraEnabled
    public static void savelocationLineitems(String tenderId,String packageId, String lineitemsToInsert,String startDate, String endDate, String customerId){
        system.debug('list to insert' + lineitemsToInsert);
    }
    
    /**
     * @description updates the record
     * @param objectName of type string
     * @param recordId of type string
     * @param fieldName of type string
     * @param value of type string
     * @param lineItems value of type List collection AITM_Tender_Location_Line_Item__c
     * @return sObject
     */
    @AuraEnabled
    public static sObject updateRecord(String objectName, String recordId, String fieldName, String value, List<AITM_Tender_Location_Line_Item__c> lineItems) {
        sObject obj;
        obj = AITM_TenderLocationNewOffer.updateRecord(objectName, recordId, fieldName, value, lineItems);
        return obj;
    }
    
    public class TenderLocationLineItemWrapper{
        public @AuraEnabled Id lineItemId;
        public @AuraEnabled Date startDate;
        public @AuraEnabled Date endDate;
        public @AuraEnabled Integer offeredVolumeUom;
        public @AuraEnabled Integer requestedVolumeUom;
        public @AuraEnabled Integer differentialPackage;
        public @AuraEnabled Integer changedPercentage;
        public @AuraEnabled String unitOfMeasure;
        public @AuraEnabled String updatedcurrency;
        
        /**
         * @description returns tender location line item
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c unwrap() {
            AITM_Tender_Location_Line_Item__c item = new AITM_Tender_Location_Line_Item__c();
            item.id = this.lineItemId;
            if(this.startDate != null){
                item.AITM_Start_Date__c = this.startDate;
            }
            if(this.endDate != null){
                item.AITM_End_Date__c = this.endDate;
            }
            if(this.requestedVolumeUom != null){
                item.AITM_Requested_Volume_USG__c = this.requestedVolumeUom;
            }
            if(this.offeredVolumeUom != null){
                item.AITM_Offered_Volume__c = this.offeredVolumeUom;
            }
            if(this.changedPercentage != null){
                item.AITM_Percentage_Volume_Offered__c = this.changedPercentage;
            }
            if((String.valueOf(this.differentialPackage)) != '' && this.differentialPackage != null){
                item.AITM_Package_Offered_Differential__c = this.differentialPackage;
            }
            if(this.unitOfMeasure != null){
                item.AITM_Unit_Of_Measure__c = this.unitOfMeasure;
            }
            if(this.updatedcurrency != null){
                item.AITM_Currency__c = this.updatedcurrency;
            }
            return item;
        }
    }
    
    public class TenderLocationWrapper{
        public @AuraEnabled Id locationId;
        public @AuraEnabled Integer packageContribution;
        public @AuraEnabled String internalNotes;
        
        /**
         * @description returns tender location line item
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location__c unwrap() {
            AITM_Tender_Location__c location = new AITM_Tender_Location__c();
            location.id = this.locationId;
            if(this.packageContribution != null){
                location.AITM_Location_Contribution_To_Package__c = this.packageContribution;
            }
            if(this.internalNotes != null){
                location.AITM_Internal_Notes_For_Package_Location__c = this.internalNotes;
            }
            return location;
        }
    }
    
    public class TenderPackageWrapper{
        public @AuraEnabled Id packageId;
        public @AuraEnabled String packName;
        public @AuraEnabled String notes;
        public @AuraEnabled String description;
        
        /**
         * @description returns tender location line item
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Package__c unwrap() {
            AITM_Tender_Package__c packageData = new AITM_Tender_Package__c();
            packageData.id = this.packageId;
            if(this.packName != null){
                packageData.Name = this.packName;
            }
            if(this.notes != null){
                packageData.AITM_Internal_Notes__c = this.notes;
            }
            if(this.description != null){
                packageData.AITM_Description__c = this.description;
            }
            return packageData;
        }
    }

    public class locationItem{
        public @AuraEnabled String Packageid;
        public @AuraEnabled String PackageName;
        public @AuraEnabled String PackageCounter;
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

    public class locationInCustomersComponent{
        public @AuraEnabled String uniqueKey;
        public @AuraEnabled String locationName;
        public @AuraEnabled String iATAWithlocationName;
        public @AuraEnabled String locationInternalNotes;
        public @AuraEnabled String locationId;
        public @AuraEnabled String locationStatus;
        public @AuraEnabled String locationCountry;
        public @AuraEnabled String locationManager;
        public @AuraEnabled Double packageContribution;
        public @AuraEnabled List<AITM_Tender_Location_Line_Item__c> locationLineItemsList;
            
        public locationInCustomersComponent(String uniqueKey, AITM_Location__c location, AITM_Tender_Location__c tenderLocation, List<AITM_Tender_Location_Line_Item__c> locationLineItemsList){
            this.locationLineItemsList = locationLineItemsList;
            this.iATAWithlocationName = tenderLocation.AITM_IATA_ICAO__c + ' - ' +location.Name;
            this.locationInternalNotes = tenderLocation.AITM_Internal_Notes_For_Package_Location__c;
            this.uniqueKey = uniqueKey;
            this.locationName = location.Name;
            this.locationCountry =  location.AITM_Country__c;
            this.locationStatus = tenderLocation.AITM_Status__c;
            this.locationId = tenderLocation.Id;
            this.locationManager = tenderLocation.AITM_Location_Manager__r.Name;
            this.packageContribution = tenderLocation.AITM_Location_Contribution_To_Package__c;
        }
   }
}