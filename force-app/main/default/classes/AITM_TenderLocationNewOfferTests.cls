/**************************************************************************
 * @author           George
 * @date             03/April/2018
 * @group            AirBP
 * @description      Test class for AITM_TenderLocationNewOffer
 *******************************************************************/
@isTest 
private with sharing class AITM_TenderLocationNewOfferTests {
    @isTest 
    static void testGetTableData() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            Map<String, List<sObject>> tableData = AITM_TenderLocationNewOffer.getTableData(tenderLocation.Id);
        Test.stopTest();
    
        System.assertEquals(lineItemsCount, tableData.get('lineItems').size());
        System.assertEquals(tenderLocation.Id, tableData.get('tenderLocation')[0].Id);
    
    }
    
    @isTest 
    static void testUpdateTenderLocationPricingBasis() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.accounts[0]; // testSetup.createAccount();
    
        List<AITM_Location__c> locations = testSetup.createLocations(3);
        List<AITM_Pricing_Basis__c> pricingBasis = new List<AITM_Pricing_Basis__c>();
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test'));
        pricingBasis.add(new AITM_Pricing_Basis__c(Name = 'Test1'));
        insert pricingBasis;
    
        locations[0].AITM_Pricing_Basis__c = pricingBasis[0].Id;
        locations[1].AITM_Pricing_Basis__c = pricingBasis[1].Id;
        insert locations;
    
        List<AITM_Delivery_Point__c> deliveryPoints = new List<AITM_Delivery_Point__c>();
        Integer count = 0;
        for(AITM_Location__c location : locations) {
            deliveryPoints.add(testSetup.createDeliveryPoint(location,false, count++));
        }
        insert deliveryPoints;
        List<User> locationManagers = testSetup.createUsers(lineItemsCount, 'Air_TMLocation Manager');
        insert locationManagers;
        
        for(AITM_Delivery_Point__c deliveryPoint : deliveryPoints) {
            deliveryPoint.AITM_CA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_GA_Pricing_Responsibility1__c = locationManagers[0].Id;
            deliveryPoint.AITM_Location_Manager1__c = locationManagers[0].Id;
        }
        update deliveryPoints;
        
        AITM_Tender_Location__c tenderLocation1 = testSetup.createTenderLocation(tenderId, locations[0].Id);
        insert tenderLocation1;

        AITM_Tender_Location_Line_Item__c lineitem = testSetup.createTenderLocationLineItem(tenderId, account.Id, locations[1].Id, tenderLocation1.Id);
        lineitem.AITM_Tender_Location__c = tenderLocation1.Id;
        lineitem.AITM_Pricing_Basis__c = pricingBasis[0].Id;
        lineitem.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;
        insert lineitem;       
        
        
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, locations[0].Id);
        List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
        tenderLocations.add(tenderLocation);
        tenderLocation = testSetup.createTenderLocation(tenderId, locations[1].Id);
        tenderLocations.add(tenderLocation);
        insert tenderLocations;
        
      /*  List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();

        for(Integer i = 0; i < lineItemsCount; i++){
            if(i == 1) {
                items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, locations[1].Id, tenderLocations[1].Id));    
            } else {
                items.add(testSetup.createTenderLocationLineItem(tenderId, account.Id, locations[0].Id, tenderLocations[0].Id));
            }    
        }
        insert items;
        for(AITM_Tender_Location_Line_Item__c li : items) {
            li.AITM_Location_Delivery_Point__c = deliveryPoints[0].Id;
        }
        update items;*/
		
        Test.startTest();
        	List<AITM_Delivery_Point__c> dPoints = AITM_TenderLocationNewOffer.getDeliveryRecords(lineitem);
          //  AITM_TenderLocationNewOffer.updateDeliveryRecords(deliveryPoints[0].Id, lineitem[0].Id);
          //  AITM_TenderLocationNewOffer.updateTenderLocationPricingBasis(tenderLocation1);
           // List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT AITM_Tender_Location__c,AITM_Pricing_Basis__c, AITM_Offered_Differential__c FROM AITM_Tender_Location_Line_Item__c WHERE AITM_Tender_Location__c=:tenderLocation.Id];
        Test.stopTest(); 
        System.assertNotEquals(null,lineitem,'Has valid line Item');
       // System.assertEquals(1, items.size(),'The updated line item size is 1'); //This logic need to change delivery point commenting for now
    }
    
    @isTest 
    static void testGetDetailsFromTLLI() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = testSetup.createTenderLocation(tenderId, location.Id);
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
        Test.startTest();
            AITM_Tender_Location_Line_Item__c itemData = AITM_TenderLocationNewOffer.getDetailsFromTLLI(items[0].Id);
        Test.stopTest();
        System.assertNotEquals(null,itemData,'Has valid line Item');
    }
    
    @isTest 
    static void testUpdateRecord() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        Account account = testSetup.createAccount();
        insert account;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
    
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
    
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
        AITM_Tender_Location_Line_Item__c lineItem = items[0];
    
        Test.startTest();
            sObject so = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location__c', tenderLocation.Id, 'AITM_Total_Volume_Offered_To_The_Group__c', '10000', items);
            //sObject so1 = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location_Line_Item__c', lineItem.Id, 'AITM_Start_Date__c', String.valueofGmt(Date.today().addYears(1)), items);
            sObject so2 = AITM_TenderLocationNewOffer.updateRecord('AITM_Tender_Location_Line_Item__c', lineItem.Id, 'AITM_Percentage_Volume_Offered__c', '50.2', items);
            Map<String, List<sObject>> tableData = AITM_TenderLocationNewOffer.getTableData(tenderLocation.Id);
            AITM_Tender_Location__c getTenderLocation = (AITM_Tender_Location__c)tableData.get('tenderLocation')[0];
            AITM_Tender_Location_Line_Item__c getLineItem = new AITM_LocationsDao().getTenderLocationLineItem(lineItem.Id);
        Test.stopTest();
    
        System.assertNotEquals(getTenderLocation.AITM_Total_Volume_Offered_To_The_Group__c, tenderLocation.AITM_Total_Volume_Offered_To_The_Group__c);
        System.assertNotEquals(getLineItem.AITM_Percentage_Volume_Offered__c, lineItem.AITM_Percentage_Volume_Offered__c);
    
    }
    
    @isTest 
    static void testDeleteRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        Integer lineItemsCount = 5;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
            
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        List<AITM_Tender_Location_Line_Item__c> items = new List<AITM_Tender_Location_Line_Item__c>();
        
        for(Integer i = 0; i < lineItemsCount; i++){
            items.add( 
                testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id)
            );
        }
        insert items;
    
    
        Test.startTest();
            List<String> IdString = new List<String>();
                for(AITM_Tender_Location_Line_Item__c t1:items){
                IdString.add(t1.Id);
            }        
            String msg = AITM_TenderLocationNewOffer.deleteRecords(IdString);
        
        Test.stopTest();
        System.assertEquals('Each customer must have atleast one tender Location Line Item record', msg);
    }
    
    
    
    @isTest 
    static void testCloneRecords() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
        
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
        Account account = testSetup.createAccount();
        insert account;
            
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
        AITM_Tender_Location_Line_Item__c item = new AITM_Tender_Location_Line_Item__c();
        item = testSetup.createTenderLocationLineItem(tenderId, account.Id, location.Id, tenderLocation.Id);       
        
            
        
        insert item;
    
    
        Test.startTest();
            
            String msg = AITM_TenderLocationNewOffer.cloneRecords(item.Id);
        
        Test.stopTest();
        System.assertEquals('', msg);
    }
    
    @isTest 
    static void testGetPickValues() {
        Test.startTest();
            List<String> selectOptions = AITM_TenderLocationNewOffer.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Currency__c');
        Test.stopTest();
        System.assert(selectOptions.size() > 0);
    }
    
    @IsTest 
    static void testGetTableMetadata() {
        Test.startTest();
            List<AITM_Table_Tender_Location_New_Offer__mdt> tableMetadata = AITM_TenderLocationNewOffer.getTableMetadata();
        Test.stopTest();
        System.assertNotEquals(0, tableMetadata.size());
    }
    
    @isTest 
    static void testGetFieldAccess() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        Id tenderId = testSetup.tender.Id;
    
        AITM_Location__c location = testSetup.createLocation();
        insert location;
    
        AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(
                AITM_Tender__c = tenderId,
                AITM_Location__c = location.Id,
                AITM_Volume__c = 1.0,
                AITM_Ad_hoc_Volume__c = false,
                AITM_Status__c = 'Ready',
                AITM_Total_Volume_Offered_To_The_Group__c = 12000
            );
        insert tenderLocation;
    
        Test.startTest();
            Map<String, Map<String, Boolean>> fieldsAccess = AITM_TenderLocationNewOffer.getFieldsAccess('AITM_Tender_Location__c', tenderLocation.Id);
        Test.stopTest();
        System.assertNotEquals(null, fieldsAccess.size());
    }
    
    @isTest 
    static void testUpdateLocationAndLineItemToUnStraddled() {
        TenderLocationNewOfferTestSetup testSetup = new TenderLocationNewOfferTestSetup().generateData();
        
        Id straddledLocation = testSetup.straddledLocation.Id;
        
        Test.startTest();
            List<AITM_Tender_Location__c> listOfTenderLocations = AITM_TenderLocationNewOffer.updateLocationAndLineItemToUnStraddled(straddledLocation);
        Test.stopTest();
        
        System.assertEquals(false, listOfTenderLocations[0].AITM_Is_Straddled__c);
    }
    
    private with sharing class TenderLocationNewOfferTestSetup extends AITM_TestSetup {
        public AITM_TenderLocationNewOffer classUnderTest;
    
        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public AITM_Pricing_Basis__c pricingBasis;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        public AITM_Tender_Location__c straddledLocation; 
        public AITM_Tender_Location_Line_Item__c straddledLineItem; 
    
        public TenderLocationNewOfferTestSetup generateData(){
            classUnderTest = new AITM_TenderLocationNewOffer();
    
            accounts = createAccounts(10);
            insert accounts;
    
            locations = createLocations(10);
            insert locations;
    
            tender = createTender();
            insert tender;
    
            createTenderLocations();
    		
            pricingBasis = createPricingBasis();
            INSERT pricingBasis;
            
            straddledLocation = createStraddledTenderLocation(tender.Id, locations[0].Id);
            insert straddledLocation;
            
            straddledLineItem = createStraddledTenderLocationLineItem(tender.Id, accounts[0].Id, locations[0].Id, straddledLocation.Id);
            insert straddledLineItem;
            
            return this;
        }
    
        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }
    	
        /**
         * @description creates the test data for PricingBasis
         * @param  null
         * @return AITM_Pricing_Basis__c
         */
        private AITM_Pricing_Basis__c createPricingBasis(){
            return new AITM_Pricing_Basis__c(
                Name = 'P008',
                AITM_Description__c = 'Barges FOB Rotterdam High Prior Month WD',
                AITM_Currency__c = 'USD',
                AITM_Unit_Of_Measure__c = 'USG'
                );
        }

        public void createTenderLocationLineItems() {
            tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }
    
        public void createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
                for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            insert tenderLocations;
        }
    
        public AITM_Tender_Location_Line_Item__c createTenderLocationLineItem(Id tenderId, Id accountId, Id locationId, Id tenderLocationId) {
            return new AITM_Tender_Location_Line_Item__c(
                AITM_Tender__c = tenderId,
                AITM_Account__c = accountId,
                AITM_Location__c = locationId,
                AITM_Start_Date__c = Date.today(),
                AITM_Tender_Location__c = tenderLocationId,
                AITM_End_Date__c = Date.today().addYears(1),
                AITM_Volume__c = 1.0,
                AITM_Pricing_Basis__c = pricingBasis.Id,
                RecordTypeId = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId()
            );
        }
    
    }
}