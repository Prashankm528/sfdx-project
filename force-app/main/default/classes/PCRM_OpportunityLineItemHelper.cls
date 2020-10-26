/************************************************************************************************************************
* Name: PCRM_OpportunityLineItemHelper
* Description: The class is the helper class used on opportunityLineItem object and is invoked from its trigger.
************************************************************************************************************************/
Public with sharing class PCRM_OpportunityLineItemHelper
{
   // The method eventually adds opportunity line items for newly inserted product line items (with shipping to Account blank) and
   //associate them with the accounts available with PCRM_Opportunity_Account__c    
    public void autoCreateOpportunityLineItemOnProductInsertion(List<OpportunityLineItem> lstOpportunityLineItems)
    {
        
        set<Id> setOpportunityId = new set<Id>();
        List<PCRM_Opportunity_Account__c> lstOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
        
        if (lstOpportunityLineItems != null)
        {
            for (OpportunityLineItem objOpportunityLineItem: lstOpportunityLineItems)
            {
                if (objOpportunityLineItem.PCRM_Ship_To__c == null)
                {
                    setOpportunityId.add(objOpportunityLineItem.opportunityId);
                }
            }
        }
        
        if (setOpportunityId != null && setOpportunityId.size() > 0)
        {            
            lstOpportunityAccount = [select Id, PCRM_Opportunity__c, PCRM_Account__c,PCRM_Sold_To_Account__c from PCRM_Opportunity_Account__c where PCRM_Opportunity__c IN: setOpportunityId];
            if (lstOpportunityAccount != null && lstOpportunityAccount.size() > 0)
            {
                this.createOpportunitiesForShippingAccounts(lstOpportunityAccount, false);
            }
        }
    }
    
    // The method creates Opportunities for all shipping accounts when they are selected by the user from UI component on Opportunity
    public void createOpportunitiesForShippingAccounts(List<PCRM_Opportunity_Account__c> lstOpportunityAccount, boolean bIsAccountAdded)
    {        
        map<Id, set<Id>> mapOpportunityWithsetNewAccount = new map<Id, set<Id>>();
        set<OpportunityLineItem> setOppLineItemsToBeDeleted = new set<OpportunityLineItem>();
        set<Id> setShipToAccountIDs = new set<Id>();		
        map<Id, Id> mapShipingAccountWithSoldToAccount = new map<Id, Id>();
		map<Id,Account> mapAccount = new Map<Id,Account>();
        for(PCRM_Opportunity_Account__c objOpportunityAccount: lstOpportunityAccount)
        {
            if(mapOpportunityWithsetNewAccount != null && mapOpportunityWithsetNewAccount.size() > 0 &&
               mapOpportunityWithsetNewAccount.containsKey(objOpportunityAccount.PCRM_Opportunity__c) &&
               mapOpportunityWithsetNewAccount.get(objOpportunityAccount.PCRM_Opportunity__c) != null)
            {
                
                set<Id> setAccountId = mapOpportunityWithsetNewAccount.get(objOpportunityAccount.PCRM_Opportunity__c);
                setAccountId.add(objOpportunityAccount.PCRM_Account__c);
                mapOpportunityWithsetNewAccount.put(objOpportunityAccount.PCRM_Opportunity__c, setAccountId);
            }
            else if(mapOpportunityWithsetNewAccount != null)
            {
                set<Id> setAccountId = new set<Id>();
                setAccountId.add(objOpportunityAccount.PCRM_Account__c);
                mapOpportunityWithsetNewAccount.put(objOpportunityAccount.PCRM_Opportunity__c, setAccountId);
            }
            setShipToAccountIDs.add(objOpportunityAccount.PCRM_Account__c);	
				
			setShipToAccountIDs.add(objOpportunityAccount.PCRM_Sold_To_Account__c);
			
        }
        //Opportunity issues changes start
        /*if (setShipToAccountIDs != null && setShipToAccountIDs.size() > 0)
        {          
            List<Account> lstShipToAccounts = [select Id, ParentId,PCRM_Inco_Terms_2__c,PCRM_Inco_Terms__c from Account WHERE Id IN: setShipToAccountIDs AND ParentId != null];
            if (lstShipToAccounts != null && lstShipToAccounts.size() > 0)
            {
                for (Account objShipingAcct: lstShipToAccounts)
                {
                    mapShipingAccountWithSoldToAccount.put(objShipingAcct.Id, objShipingAcct.ParentId);                    
                }
            }
        }*/
        if (setShipToAccountIDs != null && setShipToAccountIDs.size() > 0)
        {          
            List<Account> lstShipToAccounts = [select Id, Type, ParentId,PCRM_Inco_Terms_2__c,PCRM_Inco_Terms__c,
											   PCRM_Transportation_mode_Code__c,PCRM_Payment_Terms__c
											   from Account WHERE Id IN: setShipToAccountIDs];
            if (lstShipToAccounts != null && lstShipToAccounts.size() > 0)
            {
                for (Account objShipingAcct: lstShipToAccounts)
                {
                    if (objShipingAcct.Type == 'Ship-To Party' || objShipingAcct.Type == 'ZMSH'){
                        mapShipingAccountWithSoldToAccount.put(objShipingAcct.Id, objShipingAcct.ParentId);
                    }
                    else {
                        mapShipingAccountWithSoldToAccount.put(objShipingAcct.Id, objShipingAcct.Id);
                    }
                    mapAccount.put(objShipingAcct.Id,objShipingAcct);                    
                }               
            }
        }
        //Opportunity issues changes end
        opportunityWrapper objopportunityWrapper = getProcessedData(lstOpportunityAccount);
        
        if (objopportunityWrapper.mapOpportunityIdWithListofAccounts != null &&
            objopportunityWrapper.mapOpportunityIdWithListofAccounts.size() > 0 &&
            objopportunityWrapper.mapIdWithParentOpportunity != null &&
            objopportunityWrapper.mapIdWithParentOpportunity.size() > 0)
        {
            
            List<OpportunityLineItem> lstOpportunityLineItemsToBeInserted = new List<OpportunityLineItem>();
            for (Id OpportunityId: objopportunityWrapper.mapIdWithParentOpportunity.keyset())
            {
                if (mapOpportunityWithsetNewAccount != null &&
                    mapOpportunityWithsetNewAccount.size() > 0 &&
                    mapOpportunityWithsetNewAccount.containsKey(OpportunityId) &&
                    mapOpportunityWithsetNewAccount.get(OpportunityId) != null)
                {
                    for (Id AccountId: mapOpportunityWithsetNewAccount.get(OpportunityId))
                    {
                        if (objopportunityWrapper.mapIdWithParentOpportunity.containsKey(OpportunityId) &&
                            objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId) != null &&
                            objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId).OpportunityLineItems != null &&
                            objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId).OpportunityLineItems.size() > 0)
                        {
                            map<Id, set<Id>> mapProductIdWithSetAccountId = new map<Id, set<Id>>();
                            set<Id> setNewProductIDs = new set<Id>();
                            
                            for (OpportunityLineItem objOpportunityLineItem: objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId).OpportunityLineItems){
                                if (objOpportunityLineItem.PCRM_Ship_To__c == null)
                                {                                    
                                    setNewProductIDs.add(objOpportunityLineItem.product2Id);
                                }
                            }
                            for (OpportunityLineItem objOpportunityLineItem: objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId).OpportunityLineItems){
                                  
                                if (mapProductIdWithSetAccountId != null &&
                                    objOpportunityLineItem.PCRM_Ship_To__c != null &&
                                    objOpportunityLineItem.PCRM_Ship_To__c == AccountId &&
                                    bIsAccountAdded)
                                {
                                    if (mapProductIdWithSetAccountId != null && mapProductIdWithSetAccountId.size() > 0 &&
                                        mapProductIdWithSetAccountId.containsKey(objOpportunityLineItem.Product2Id) &&
                                        mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id) != null)
                                    {
                                        
                                        set<Id> setAcctId = mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id);
                                        setAcctId.add(objOpportunityLineItem.PCRM_Ship_To__c);
                                        mapProductIdWithSetAccountId.put(objOpportunityLineItem.Product2Id, setAcctId);
                                    }
                                    else if (mapProductIdWithSetAccountId != null)
                                    {
                                        set<Id> setAcctId = new set<Id>();
                                        setAcctId.add(objOpportunityLineItem.PCRM_Ship_To__c);
                                        mapProductIdWithSetAccountId.put(objOpportunityLineItem.Product2Id, setAcctId);                                     
                                    }
                                } 
                                else if (mapProductIdWithSetAccountId != null &&
                                         objOpportunityLineItem.PCRM_Ship_To__c != null &&
                                         objOpportunityLineItem.PCRM_Ship_To__c == AccountId &&
                                         setNewProductIDs != null && setNewProductIDs.size() > 0 &&
                                         setNewProductIDs.contains(objOpportunityLineItem.Product2Id) &&
                                         !bIsAccountAdded)
                                {
                                    if (mapProductIdWithSetAccountId != null && mapProductIdWithSetAccountId.size() > 0 &&
                                        mapProductIdWithSetAccountId.containsKey(objOpportunityLineItem.Product2Id) &&
                                        mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id) != null)
                                    {
                                        
                                        set<Id> setAcctId = mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id);
                                        setAcctId.add(objOpportunityLineItem.PCRM_Ship_To__c);
                                        mapProductIdWithSetAccountId.put(objOpportunityLineItem.Product2Id, setAcctId);
                                    }
                                    else if (mapProductIdWithSetAccountId != null)
                                    {
                                        set<Id> setAcctId = new set<Id>();
                                        setAcctId.add(objOpportunityLineItem.PCRM_Ship_To__c);
                                        mapProductIdWithSetAccountId.put(objOpportunityLineItem.Product2Id, setAcctId);                                     
                                    }                                    
                                }
                            }
                            for (OpportunityLineItem objOpportunityLineItem: objopportunityWrapper.mapIdWithParentOpportunity.get(OpportunityId).OpportunityLineItems){
                                
                                if (objOpportunityLineItem.PCRM_Ship_To__c == null)
                                {
                                    setOppLineItemsToBeDeleted.add(objOpportunityLineItem);
                                    
                                    if (mapProductIdWithSetAccountId != null && mapProductIdWithSetAccountId.size() > 0 &&
                                        mapProductIdWithSetAccountId.containsKey(objOpportunityLineItem.Product2Id) &&
                                        mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id) != null)
                                    {                                        
                                        set<Id> setAcctId =  mapProductIdWithSetAccountId.get(objOpportunityLineItem.Product2Id);
                                        if (!setAcctId.contains(AccountId))
                                        {
                                            OpportunityLineItem objNewOpportunityLineItem = new OpportunityLineItem();
                                            objNewOpportunityLineItem.OpportunityId = OpportunityId;
                                            objNewOpportunityLineItem.Product2Id = objOpportunityLineItem.product2Id;
                                            objNewOpportunityLineItem.PCRM_Ship_To__c = AccountId;
											
											objNewOpportunityLineItem.PCRM_Inco_Terms__c = mapAccount.get(AccountId).PCRM_Inco_Terms__c ;  
											objNewOpportunityLineItem.PCRM_Location__c = mapAccount.get(AccountId).PCRM_Inco_Terms_2__c ;  
											objNewOpportunityLineItem.PCRM_Mode_of_Transport__c = mapAccount.get(AccountId).PCRM_Transportation_mode_Code__c ;
											
                                            
                                            objNewOpportunityLineItem.Quantity = objOpportunityLineItem.Quantity;
                                            if (mapShipingAccountWithSoldToAccount != null && mapShipingAccountWithSoldToAccount.size() > 0 &&
                                                mapShipingAccountWithSoldToAccount.containsKey(AccountId) &&
                                                mapShipingAccountWithSoldToAccount.get(AccountId) != null)
                                            {
                                                objNewOpportunityLineItem.PCRM_Sold_To__c = mapShipingAccountWithSoldToAccount.get(AccountId);
												objNewOpportunityLineItem.PCRM_Payment_Terms__c = mapAccount.get(mapShipingAccountWithSoldToAccount.get(AccountId)).PCRM_Payment_Terms__c ;
                                            }
                                            
                                            lstOpportunityLineItemsToBeInserted.add(objNewOpportunityLineItem);
                                        }
                                    }
                                    else if((mapProductIdWithSetAccountId != null && mapProductIdWithSetAccountId.size() == 0) ||
                                            (mapProductIdWithSetAccountId != null && mapProductIdWithSetAccountId.size() > 0 && !(mapProductIdWithSetAccountId.containsKey(objOpportunityLineItem.Product2Id)))){
                                                
                                                OpportunityLineItem objNewOpportunityLineItem = new OpportunityLineItem();
                                                objNewOpportunityLineItem.OpportunityId = OpportunityId;
                                                objNewOpportunityLineItem.Product2Id = objOpportunityLineItem.product2Id;
                                                objNewOpportunityLineItem.PCRM_Ship_To__c = AccountId;
                                                objNewOpportunityLineItem.PCRM_Inco_Terms__c = mapAccount.get(AccountId).PCRM_Inco_Terms__c ;  
												objNewOpportunityLineItem.PCRM_Location__c = mapAccount.get(AccountId).PCRM_Inco_Terms_2__c ;  
												objNewOpportunityLineItem.PCRM_Mode_of_Transport__c = mapAccount.get(AccountId).PCRM_Transportation_mode_Code__c ;
                                                
                                                if (mapShipingAccountWithSoldToAccount != null && mapShipingAccountWithSoldToAccount.size() > 0 &&
                                                    mapShipingAccountWithSoldToAccount.containsKey(AccountId) &&
                                                    mapShipingAccountWithSoldToAccount.get(AccountId) != null)
                                                {                                                    
                                                    objNewOpportunityLineItem.PCRM_Sold_To__c = mapShipingAccountWithSoldToAccount.get(AccountId);
													objNewOpportunityLineItem.PCRM_Payment_Terms__c = mapAccount.get(mapShipingAccountWithSoldToAccount.get(AccountId)).PCRM_Payment_Terms__c ;
                                                }
                                                objNewOpportunityLineItem.UnitPrice = objOpportunityLineItem.UnitPrice;
                                                objNewOpportunityLineItem.Quantity = objOpportunityLineItem.Quantity;
                                               
                                                lstOpportunityLineItemsToBeInserted.add(objNewOpportunityLineItem);                                     
                                            }
                                }
                            }
                        }
                    }
                }
            }
                        
            if (lstOpportunityLineItemsToBeInserted != null && lstOpportunityLineItemsToBeInserted.size() > 0)
            {
                insert lstOpportunityLineItemsToBeInserted;
            }
            
            if (setOppLineItemsToBeDeleted != null && setOppLineItemsToBeDeleted.size() > 0)
            {
                List<OpportunityLineItem> lstOppLineItemsToBeDeleted = new List<OpportunityLineItem>();
                lstOppLineItemsToBeDeleted.addAll(setOppLineItemsToBeDeleted);
                delete lstOppLineItemsToBeDeleted;
            }
            
        }
    }
    //method is used to get the data
    public opportunityWrapper getProcessedData(List<PCRM_Opportunity_Account__c> lstOpportunityAccount)
    {
        set<Id> setAccountId = new set<Id>();
        map<Id, Account> mapAcctIdwithAccount = new map<Id, Account>();
        map<Id, set<Id>> mapOpportunityIdWithListofAccounts = new map<Id, set<Id>>();
        set<Id> setOpportunityIDs = new set<Id>();
        map<Id, Opportunity> mapIdWithParentOpportunity = new map<Id, Opportunity>();
        
        if (lstOpportunityAccount != null && lstOpportunityAccount.size() > 0)
        {
            for (PCRM_Opportunity_Account__c objOpportunityAccount: lstOpportunityAccount)
            {
                setAccountId.add(objOpportunityAccount.PCRM_Account__c);
                setOpportunityIDs.add(objOpportunityAccount.PCRM_Opportunity__c);
            }
            
            if (setAccountId != null && setAccountId.size() > 0)
            {
                mapAcctIdwithAccount = new map<Id, Account>([select Id from Account where Id IN: setAccountId and Type = 'ZMSH']);
            }
            
            if (setOpportunityIDs != null && setOpportunityIDs.size() > 0){
                mapIdWithParentOpportunity = new map<Id, Opportunity>([select Id, AccountId, (select Id, PCRM_Ship_To__c, PCRM_Sold_To__c, OpportunityId, Product2Id, Quantity, UnitPrice, TotalPrice
                                                                                              from OpportunityLineItems  /*WHERE  PCRM_Ship_To__c = null AND PCRM_isCreatedFromCloning__c = false*/) from Opportunity where Id IN: setOpportunityIDs]);
            }
            
            for (PCRM_Opportunity_Account__c objOpportunityAccount: lstOpportunityAccount)
            {
                if (mapOpportunityIdWithListofAccounts != null && mapOpportunityIdWithListofAccounts.size() > 0 &&
                    mapOpportunityIdWithListofAccounts.containsKey(objOpportunityAccount.PCRM_Opportunity__c) &&
                    mapOpportunityIdWithListofAccounts.get(objOpportunityAccount.PCRM_Opportunity__c) != null)
                {
                    
                    set<Id> setAcctIDs = mapOpportunityIdWithListofAccounts.get(objOpportunityAccount.PCRM_Opportunity__c);
                    if (objOpportunityAccount.PCRM_Account__c != null)
                    {
                        setAcctIDs.add(objOpportunityAccount.PCRM_Account__c);
                        mapOpportunityIdWithListofAccounts.put(objOpportunityAccount.PCRM_Opportunity__c, setAcctIDs);
                    }
                    
                }else if (mapOpportunityIdWithListofAccounts != null)
                {
                    
                    set<Id> setAcctIDs = new set<Id>();
                    if (objOpportunityAccount.PCRM_Account__c != null)
                    {
                        setAcctIDs.add(objOpportunityAccount.PCRM_Account__c);
                        mapOpportunityIdWithListofAccounts.put(objOpportunityAccount.PCRM_Opportunity__c, setAcctIDs);                        
                    }
                }
            }
        }
        
        opportunityWrapper objopportunityWrapper = new opportunityWrapper(mapOpportunityIdWithListofAccounts, mapIdWithParentOpportunity);
        
        return objopportunityWrapper;
    }	
    
    //Method is used when opportunity account is deleted
    public void onDeleteOfOpportunityAccount(List<PCRM_Opportunity_Account__c> lstOpportunityAccount)
    {
        set<Id> setFilterAccountsBeingDeleted = new set<Id>();
        set<OpportunityLineItem> setOpportunityLineItemsBeingDeleted = new set<OpportunityLineItem>();
        set<Id> setOpportunityIDsToBeProcessed = new set<Id>();
        
        if (lstOpportunityAccount != null && lstOpportunityAccount.size() > 0)
        {
            for (PCRM_Opportunity_Account__c objOpportunityAccount: lstOpportunityAccount)
            {
                setFilterAccountsBeingDeleted.add(objOpportunityAccount.PCRM_Account__c);
                setOpportunityIDsToBeProcessed.add(objOpportunityAccount.PCRM_Opportunity__c);
            }
            if (setFilterAccountsBeingDeleted != null && setFilterAccountsBeingDeleted.size() > 0)
            {
                //try{
                List<OpportunityLineItem> lstUnFilteredOpportunityLineItemsToBeDeleted = [select Id, OpportunityId, Quantity, UnitPrice, TotalPrice, PCRM_Sold_To__c from OpportunityLineItem where PCRM_Ship_To__c IN: setFilterAccountsBeingDeleted];
                if (lstUnFilteredOpportunityLineItemsToBeDeleted != null && lstUnFilteredOpportunityLineItemsToBeDeleted.size() > 0)
                {
                    for (OpportunityLineItem objDeleteOpportunityLineItem: lstUnFilteredOpportunityLineItemsToBeDeleted){
                        if (setOpportunityIDsToBeProcessed != null && setOpportunityIDsToBeProcessed.size() > 0 &&
                            setOpportunityIDsToBeProcessed.contains(objDeleteOpportunityLineItem.OpportunityId))
                        {
                            
                            setOpportunityLineItemsBeingDeleted.add(objDeleteOpportunityLineItem);
                        }
                    }
                }
                
                if (setOpportunityLineItemsBeingDeleted != null && setOpportunityLineItemsBeingDeleted.size() > 0)
                {
                    List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
                    lstOpportunityLineItem.addAll(setOpportunityLineItemsBeingDeleted);
                    delete lstOpportunityLineItem;
                   
                }
            }
        }
    }
    //Wrapper class
    Public with sharing class opportunityWrapper
    {
        map<Id, set<Id>> mapOpportunityIdWithListofAccounts = new map<Id, set<Id>>();
        map<Id, Opportunity> mapIdWithParentOpportunity = new map<Id, Opportunity>();
        
        public opportunityWrapper(map<Id, set<Id>> mapOppIdAnaLstAccount, map<Id, Opportunity> mapOpportunityIdAndOpportunity)
        {
            mapOpportunityIdWithListofAccounts = mapOppIdAnaLstAccount;
            mapIdWithParentOpportunity = mapOpportunityIdAndOpportunity;
        }
        
    }
    
    // method is used when clone for the first time
    public void updateIsClonedForTheFirstTime(List<OpportunityLineItem> lstOpportunityLineItems)
    {
        set<Id> setOpportunityId = new set<Id>();
        map<Id, Opportunity> mapIdWithOpportunity = new map<Id, Opportunity>();
        
        if (lstOpportunityLineItems != null && lstOpportunityLineItems.size() > 0 && setOpportunityId != null) {
            for (OpportunityLineItem objOppLineItem: lstOpportunityLineItems){
                setOpportunityId.add(objOppLineItem.OpportunityId);
            }
            if (setOpportunityId != null && setOpportunityId.size() > 0) {
                try
                {
                    mapIdWithOpportunity = new map<Id, Opportunity>([select Id, PCRM_isFirstSyncWithQuote__c FROM Opportunity WHERE Id IN: setOpportunityId]);
                    
                    if (mapIdWithOpportunity != null && mapIdWithOpportunity.size() > 0)
                    {
                        for (OpportunityLineItem objOppLineItem: lstOpportunityLineItems)
                        {
                            if (mapIdWithOpportunity.containsKey(objOppLineItem.opportunityId) &&
                                mapIdWithOpportunity.get(objOppLineItem.opportunityId) != null &&
                                mapIdWithOpportunity.get(objOppLineItem.opportunityId).PCRM_isFirstSyncWithQuote__c)
                            {
                                
                                objOppLineItem.PCRM_isClonedOppLineItem__c = true;
                            }
                        }
                    }                    
                }
                catch(QueryException Ex)
                {
                    system.debug('########## Exlception Occured: ' + Ex.getMessage());
                }
            }            
        }
    }
    
    private static boolean run = true;
     //method is used to set OLI field values from Soldto and shipto fields
    public void populateOLIValues(List<OpportunityLineItem> lstOpportunityLineItems){            
		if(run){
    		 run=false;
            List<OpportunityLineItem> lstOpportunityLineItemsInsert = new List<OpportunityLineItem> ();
            Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PCRM_PetChems_Acetyls').getRecordTypeId();
         	Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
            Boolean flag = false;
            for(OpportunityLineItem oli:[select id,PCRM_Ship_To__r.PCRM_Inco_Terms__c,PCRM_Ship_To__r.PCRM_Inco_Terms_2__c,
                                         PCRM_Ship_To__r.PCRM_Transportation_mode_Code__c,PCRM_Sold_To__r.PCRM_Payment_Terms__c,
                                         PCRM_Ship_To__c,PCRM_Sold_To__c,opportunity.RecordTypeId,PCRM_Inco_Terms__c,PCRM_Location__c,
                                         PCRM_Mode_of_Transport__c,PCRM_Payment_Terms__c,PCRM_Ship_To__r.RecordTypeId,
                                         PCRM_Sold_To__r.RecordTypeId,Description
                                        From OpportunityLineItem
                                        Where id in :lstOpportunityLineItems]){  
                flag = false;
                if(oli.opportunity.RecordTypeId == opportunityRecordTypeId || 
                  oli.PCRM_Ship_To__r.RecordTypeId == accountRecordTypeId ||
                  oli.PCRM_Sold_To__r.RecordTypeId == accountRecordTypeId){
                    
                    if(oli.PCRM_Ship_To__c != null && oli.PCRM_Inco_Terms__c == Null ) {
                        oli.PCRM_Inco_Terms__c = oli.PCRM_Ship_To__r.PCRM_Inco_Terms__c ;
                        flag = true;
                    }
                    if(oli.PCRM_Ship_To__c != null && (oli.PCRM_Location__c == Null || oli.PCRM_Location__c == '') ){
                        oli.PCRM_Location__c = oli.PCRM_Ship_To__r.PCRM_Inco_Terms_2__c ;
                        flag = true;
                    }
                    if(oli.PCRM_Ship_To__c != null && oli.PCRM_Mode_of_Transport__c == Null ){
                        oli.PCRM_Mode_of_Transport__c = oli.PCRM_Ship_To__r.PCRM_Transportation_mode_Code__c ;
                        flag = true;
                    }
                    
                    if(oli.PCRM_Sold_To__c != null && oli.PCRM_Payment_Terms__c == null){
                        oli.PCRM_Payment_Terms__c = oli.PCRM_Sold_To__r.PCRM_Payment_Terms__c ;
                        flag = true;
                    }                     
                     if(oli.Description == null || oli.Description != oli.id){
                        oli.Description = oli.id ;
                        flag = true;
                    } 
                      if(flag == true){
                          lstOpportunityLineItemsInsert.add(oli);
                      }                    
                }
            }
            if(!lstOpportunityLineItemsInsert.IsEmpty()){
                update lstOpportunityLineItemsInsert;
            }
        }
    } 
}