/*****************************************************************************************
*   Date:      10/05/2020
*   Author:    Mansi Dhoke (TCS)  
*   Description: 
*   Changes: 0.1
   
  
****************************************************************************************/
public with sharing  class PCRM_AccountHierarchyController 
{    
    //get Account on which Opprtunity is created
    @AuraEnabled
    public static string getParentAccount(string Param_OpportunityId)
    {
        string ParentAccountId = '';
        Opportunity opportunityObj = NEW Opportunity();
        
        if(string.isNotBlank(Param_OpportunityId))
        {
            opportunityObj = [SELECT Id , AccountId, Name FROM Opportunity WHERE Id = : Param_OpportunityId];
            ParentAccountId = opportunityObj.AccountId;
        }
        
        return ParentAccountId;
    }
    //get Account Hierarchy
    @AuraEnabled
    public static List<Account> findHierarchyData(string param_ParentAccountId)
    {
        List<Account> accList = new List<Account>();
        
        //Section to get all child account details from ultimate parent starts-------------------------
        List<String> currentParent      = new List<String>{};
        
        
        //method to find ultimate parent of account
        //string topMostparent = GetUltimateParentId(ParentAccountId );
        
        //Account(sold to/Customer Group) on which opportunity is created is considered as ULTIMATE PARENT
        string topMostparent = param_ParentAccountId;
        
        currentParent.add(topMostparent);
        
        //Loop though all children
        
        /*string queryString = 'select id,name,type,industry,parentId,PCRM_Inco_Terms__c,PCRM_Inco_Terms_2__c from Account ';
        Integer level               = 0;
        Boolean endOfStructure      = false;
        string finalQueryString = '';
        List<Account>  queryOutput = new List<Account> ();
        while ( !endOfStructure )
        {  
            if( level == 0 )
            {
                //to get topmost account record in hierarchy ...topmost Account can be either of type 'Customer Group' or 'Sold to'
                finalQueryString = queryString + ' where id IN : CurrentParent AND type IN (\'ZMSP\',\'ZMHI\') ORDER BY ParentId  Limit 10';//only sold to and customer group
            } 
            else
            {
                //to get all childern records of topmost account - can be Account of type either 'Sold to' or 'Ship To'
                finalQueryString = queryString + ' where ParentID IN : CurrentParent AND type IN (\'ZMSH\',\'ZMSP\') ORDER BY ParentId Limit 10';//only sold to and ship to
            }
            
            if(finalQueryString != null && finalQueryString !='')
            {
                try
                {
                    if(Limits.getLimitQueries()-Limits.getQueries()>0)
                    {
                        queryOutput = database.query(finalQueryString);
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                    }
                    else
                    {
                        endOfStructure = true;
                    }
                }
                catch(exception ex)
                { 
                    endOfStructure = true;
                }
            }
            
            if( queryOutput.size() == 0 )
            {
                endOfStructure = true;
            }
            else
            {
                currentParent.clear();
                
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ )
                {
                    currentParent.add(queryOutput[i].Id);
                    accList.add(queryOutput[i]);
                }
            }
            
            level++;
        }*/
        
        
        //To avoid query in while Loop//
        Map<Id,Account> responseMap = NEW Map<Id,Account>();
        if(currentParent.size() > 0 && currentParent != null) 
        {
            responseMap = getChildAccounts(currentParent,0);  //Query to get 'customer Group/Sold to' account
            accList.addall(responseMap.values());
            
            if(responseMap.keyset() != null && responseMap.keyset().size() > 0)
            {
            	responseMap = getChildAccounts(new List<Id>(responseMap.keyset()),1);  //Query to get children of  'Customer Group/Sold to' account
            	accList.addall(responseMap.values());
            }
            
            if(responseMap.keyset() != null && responseMap.keyset().size() > 0)
            {
                responseMap = getChildAccounts(new List<Id>(responseMap.keyset()),2);  //Query for get children of sold to
                system.debug('responseMap77:'+responseMap);
                
                accList.addall(responseMap.values());
            }
            
            /*if(responseMap.keyset() != null && responseMap.keyset().size() > 0)
            {
                responseMap = Method(new List<Id>(responseMap.keyset()),3);  //query to get childern of ship to
                 system.debug('responseMap88:'+responseMap);
                accList.addall(responseMap.values());
            }*/
            
        }
         //To avoid query in while Loop//
        
        system.debug('**********accList:'+accList);

        return accList;
    }
    
    //method getChildAccounts
    public static Map<Id,Account> getChildAccounts(List<Id> ListOfCurrentParentIds,Integer level)
    {
      List<Account>  queryOutput = new List<Account> ();  
      Map<Id,Account> mapOfAccountIdWithAccount = NEW   Map<Id,Account>(); 
       system.debug('getChildAccounts==='+ListOfCurrentParentIds +'===='+level); 
      string queryString = 'select id,name,type,industry,parentId,PCRM_Inco_Terms__c,PCRM_Inco_Terms_2__c from Account ';
 
      string finalQueryString = '';
        
      if(level == 0)  
      {
          finalQueryString = queryString + ' where id IN : ListOfCurrentParentIds AND type IN (\'ZMSP\',\'ZMHI\') ORDER BY ParentId  Limit 10';//only sold to and customer group
      }
      else  
      {
          finalQueryString = queryString + ' where ParentID IN : ListOfCurrentParentIds AND type IN (\'ZMSH\',\'ZMSP\') ORDER BY ParentId Limit 10';//only sold to and ship to
      }
        
      queryOutput = database.query(finalQueryString);  
       system.debug('queryOutput==='+queryOutput.size());
         if(queryOutput.size() > 0 && queryOutput != null )
            {
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ )
                {
                    mapOfAccountIdWithAccount.put(queryOutput[i].Id,queryOutput[i]);
                    system.debug('queryOutput[i]==='+queryOutput[i]);
                }

            }
            system.debug('mapOfAccountIdWithAccount====@@'+mapOfAccountIdWithAccount);      
      return mapOfAccountIdWithAccount;
    }
    
    
    // Find the tom most element in Heirarchy  
    // @return objId
   /*public static String GetUltimateParentId( string recId )
    {
        Boolean top = false;
        while ( !top ) 
        {
            string queryString = 'select id ,name, ParentId from Account where Id =:recId LIMIT 1';
            Account acc = database.query(queryString);
            if ( acc.parentId != null ) {
                recId = acc.parentId;
            }else {
                top = true;
            }
        }
        return recId ;
    }*/
   
    //All the selected Accounts would be linked to Opprtunity- Creating 'OpportunityAccounts' junction object records
    @AuraEnabled
    public static void createDeleteOpportunityAccounts(string paramOpportunityId,List<Account> paramAccountsTobAssociated)
     {
         try
         {
            Map<Id,Account> existingShipToResponse = NEW  Map<Id,Account>(); 
            Set<ID> setAllParentIdInHier = new Set<ID>();
            List<Id> ListOfShipTos = NEW List<Id>(); 
            Map<string,List<Id>> responseOpportunityRelatedAccountId = getOpportunityRelatedAccountId(paramOpportunityId);
            if(!responseOpportunityRelatedAccountId.isEmpty() ) 
            {
                ListOfShipTos = responseOpportunityRelatedAccountId.get('ShipToAccountId');
                 //get map of existing ship to account data
                 if(ListOfShipTos.size() > 0 )
                 {
                    existingShipToResponse = getExistingShipToAccounts(ListOfShipTos);                  
                }				
            }
             
           Map<Id,PCRM_Opportunity_Account__c> MapOfShipToId_OpprtunityAccount = NEW Map<Id,PCRM_Opportunity_Account__c> ();
            for(PCRM_Opportunity_Account__c existingOpportunityAccount : [SELECT Id,PCRM_Account__c ,PCRM_Opportunity__c,PCRM_Sold_To_Account__c FROM PCRM_Opportunity_Account__c
                                                                          WHERE PCRM_Opportunity__c =: paramOpportunityId 
                                                                         ])
            {
                MapOfShipToId_OpprtunityAccount.put(existingOpportunityAccount.PCRM_Account__c,existingOpportunityAccount);
            }   
            
             PCRM_Opportunity_Account__c  newOpportunityAccount = NEW PCRM_Opportunity_Account__c();
             
             List<PCRM_Opportunity_Account__c> ListOfNewOpportunityAccounts = NEW List<PCRM_Opportunity_Account__c>();
             List<PCRM_Opportunity_Account__c> ListOfOpportunityAccountsDeleted = NEW List<PCRM_Opportunity_Account__c>();
        	
             // Opportunity issues changes start
             Map<id, id> mapSoldToIdShipToId = new Map<id, id> ();
             //if (!paramAccountsTobAssociated.isEmpty() && paramAccountsTobAssociated.size() == 1 && (paramAccountsTobAssociated[0].Type == 'ZMSP' || paramAccountsTobAssociated[0].Type == 'Sold-To Party'))
             if (!paramAccountsTobAssociated.isEmpty())
             {
                 //create set of all the parentid in the hierarchey
                 for(Account act:findHierarchyData(paramAccountsTobAssociated[0].id)){
                     setAllParentIdInHier.add(act.parentid);
                 }
                 for (Account objAccount : paramAccountsTobAssociated)
                 {                     
                     if ((objAccount.Type == 'ZMSP' || objAccount.Type == 'Sold-To Party') && !mapSoldToIdShipToId.containsKey(objAccount.Id) )
                     {
                         mapSoldToIdShipToId.put(objAccount.Id, null);
                     }
                 }
                 for (Account objAccount : paramAccountsTobAssociated)
                 {
                     if (objAccount.Type == 'ZMSH' || objAccount.Type == 'Ship-To Party')
                     {   
                         if (mapSoldToIdShipToId.containsKey(objAccount.ParentId) && mapSoldToIdShipToId.get(objAccount.ParentId) == null)
                         {
                             mapSoldToIdShipToId.remove(objAccount.ParentId);                             
                         }
                         mapSoldToIdShipToId.put(objAccount.ParentId, objAccount.Id);
                     }
                 }                 
             }             
             //Opportunity issues  changes end
            //filter out the OpportunityAccounts which needs to be deleted and added
            for(Account accountTobeAssociated : paramAccountsTobAssociated)
             {  
                 // added setAllParentIdInHier condition to avoid creating OppAccount for sold to who has ship to.
                 if ((accountTobeAssociated.Type == 'ZMSP' || accountTobeAssociated.Type == 'Sold-To Party') &&
                    (!(setAllParentIdInHier.contains(accountTobeAssociated.Id))))
                 {
                     if(existingShipToResponse.containsKey(accountTobeAssociated.Id))
                         {
                             existingShipToResponse.remove(accountTobeAssociated.Id);
                         }
                     else if (mapSoldToIdShipToId.get(accountTobeAssociated.Id) == null )
                     {
                         newOpportunityAccount = NEW PCRM_Opportunity_Account__c();
                             
                         newOpportunityAccount.PCRM_Account__c = accountTobeAssociated.Id;
                         newOpportunityAccount.PCRM_Opportunity__c = paramOpportunityId;
                         newOpportunityAccount.Name = accountTobeAssociated.Name; 
                         newOpportunityAccount.PCRM_Sold_To_Account__c = accountTobeAssociated.Id; 
                         
                         ListOfNewOpportunityAccounts.add(newOpportunityAccount);
                     }                     
                 }
                 if(accountTobeAssociated.Type == 'Ship-To Party' ||  accountTobeAssociated.Type == 'ZMSH')                
                 {
                     if(!existingShipToResponse.isEmpty() )
                     {
                         //check if already exist
                         if(existingShipToResponse.containsKey(accountTobeAssociated.Id))
                         {
                             existingShipToResponse.remove(accountTobeAssociated.Id);
                         }                        
                         else {
                             newOpportunityAccount = NEW PCRM_Opportunity_Account__c();
                             
                             newOpportunityAccount.PCRM_Account__c = accountTobeAssociated.Id;
                             newOpportunityAccount.PCRM_Opportunity__c = paramOpportunityId;
                             newOpportunityAccount.Name = accountTobeAssociated.Name; 
                             newOpportunityAccount.PCRM_Sold_To_Account__c = accountTobeAssociated.ParentId; 
                             
                             ListOfNewOpportunityAccounts.add(newOpportunityAccount);
                         }                         
                     }
                     else
                     {
                         newOpportunityAccount = NEW PCRM_Opportunity_Account__c();
                             
                         newOpportunityAccount.PCRM_Account__c = accountTobeAssociated.Id;
                         newOpportunityAccount.PCRM_Opportunity__c = paramOpportunityId;
                         newOpportunityAccount.Name = accountTobeAssociated.Name; 
                         newOpportunityAccount.PCRM_Sold_To_Account__c = accountTobeAssociated.ParentId; 
                         
                         ListOfNewOpportunityAccounts.add(newOpportunityAccount);
                     }                     
                 }
             }             
           
             //insert OpportunityAccounts
             if(ListOfNewOpportunityAccounts.size() > 0)
             {
                 Database.SaveResult[] srList = Database.insert(ListOfNewOpportunityAccounts, true);//not partial
                 
                 new PCRM_OpportunityLineItemHelper().createOpportunitiesForShippingAccounts(ListOfNewOpportunityAccounts, true);
                 
                 //INSERT ListOf_OpportunityAccounts;
                 for (Database.SaveResult sr : srList) 
                 {
                     if (sr.isSuccess()) 
                     {
                         // Operation was successful, so get the ID of the record that was processed
                         //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                     }
                     else {
                         // Operation failed, so get all errors               
                         for(Database.Error err : sr.getErrors())
                         {
                             System.debug('The following error has occurred.');                   
                             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                             System.debug('Account fields that affected this error: ' + err.getFields());
                         }
                     }
                 }                 
             }
             
             //these shipTo are supposed to delete as they are not part of newly selected shipTos
             if(existingShipToResponse.keyset().size() > 0)
             {
                 for(Id shipToDeleted: existingShipToResponse.keyset())
                 {
                     //get corresponding opportunityAccount record
                     PCRM_Opportunity_Account__c opportunityAccountDeleted= MapOfShipToId_OpprtunityAccount.get(shipToDeleted);
                     ListOfOpportunityAccountsDeleted.add(opportunityAccountDeleted);                     
                 }
                 system.debug('ListOfOpportunityAccountsDeleted==='+ListOfOpportunityAccountsDeleted);
                 if(ListOfOpportunityAccountsDeleted.size()> 0 )
                 {
                    Delete  ListOfOpportunityAccountsDeleted;                                      
                 }
             }             
         }
         catch(Exception e)
         {
             throw new AuraHandledException(e.getMessage()); 
         }
     }
    
    //get existing ship to records for current Opportunity
    public static Map<Id,Account> getExistingShipToAccounts (List<Id> shipToIds)
    {
        Map<Id,Account> MapOfExistingShipToId_ShipToAccount = NEW Map<Id,Account>();
      
        if(shipToIds.size() > 0)
        {
            for(Account shipTo : [SELECT Id,name,ToLabel(type),PCRM_Inco_Terms_2__c,PCRM_Inco_Terms__c FROM Account WHERE Id  IN : shipToIds ])
            {
                MapOfExistingShipToId_ShipToAccount.put(shipTo.Id,shipTo);
            }
        }
        
        return MapOfExistingShipToId_ShipToAccount;
        
    }
    
    //get all accounts id which are related to opportunity
    public static map<string,List<Id>> getOpportunityRelatedAccountId (string paramOpportunityId)//covered in test class
    {
        Map<string,List<Id>> mapOfAccountIds = NEW Map<string,List<Id>>();
        List<Id>ListOfShipTo = NEW List<Id>();
        List<Id>ListOfSoldTo = NEW List<Id>();
        
        for(PCRM_Opportunity_Account__c existingOpportunityAccount : [SELECT Id,PCRM_Account__c ,PCRM_Opportunity__c,PCRM_Sold_To_Account__c FROM PCRM_Opportunity_Account__c
                                                                      WHERE PCRM_Opportunity__c =: paramOpportunityId 
                                                                     ])
        {
                ListOfShipTo.add(existingOpportunityAccount.PCRM_Account__c); //List of ship to account
                ListOfSoldTo.add(existingOpportunityAccount.PCRM_Sold_To_Account__c); //List of sold to account
        }
        
        if(ListOfSoldTo.size() > 0 )
        mapOfAccountIds.put('SoldToAccountId',ListOfSoldTo);
        
        if(ListOfShipTo.size() > 0  )
        mapOfAccountIds.put('ShipToAccountId',ListOfShipTo);
        
        return mapOfAccountIds;
    }
    
    @AuraEnabled
    //get all opportunity related accounts
    public static map<string,List<Account>> getOpportunityRelatedAccounts (string paramOpportunityId,string paramParentAccId)
    {
        system.debug('getOpportunityRelatedAccounts111');
        
        map<string,List<Account>>  responseMap = NEW map<string,List<Account>>();
        List<Account> OpportunityRelatedAccounts = NEW  List<Account>();
		Set<Account> OpportunityNotRelatedAccounts1 = NEW  Set<Account>();
        List<Account> OpportunityNotRelatedAccounts = NEW  List<Account>();//accounts available on left tree grid

        //getting opportunity related all accounts Ids, so that can fetch that accounts details
        Map<string,List<Id>> responseAccountIdMap  = getOpportunityRelatedAccountId(paramOpportunityId);
        
        //get available Account Hierarchy structure for account on which opportunity is created
        List<Account> accountHirarchyRecords = findHierarchyData(paramParentAccId);        
       
        //check opportunity has any associated OpportunityAccounts records
        if(!responseAccountIdMap.isEmpty() )
        {
            set<Id> setOfallrelatedIds = NEW set<Id> ();
            
            List<Id> ListOfAllIds = responseAccountIdMap.get('SoldToAccountId'); //sold to Ids related to opportunity
			ListOfAllIds.addAll(responseAccountIdMap.get('ShipToAccountId'));//ship to Ids related to opportunity    
			//List<Id> ListOfAllIds = responseAccountIdMap.get('ShipToAccountId');//ship to Ids related to opportunity          
           
            //converting list into set
            setOfallrelatedIds.addall(ListOfAllIds);
            
              //for(Account acc : [SELECT id,name,ToLabel(type),industry,parentId FROM Account WHERE Id IN : ListOfAllIds])
              for(Account acc : [SELECT id,name,type,industry,parentId,PCRM_Inco_Terms_2__c,PCRM_Inco_Terms__c FROM Account WHERE Id IN : ListOfAllIds])
               {
                   OpportunityRelatedAccounts.add(acc);
               }
            
            //ship to accounts on left tree grid
           List<Id> ListOfshipTos = responseAccountIdMap.get('ShipToAccountId');

            map<Id,Account> mapOfId_HierarchyAcc = NEW map<Id,Account>();
            for(Account acc : accountHirarchyRecords)
            {
               mapOfId_HierarchyAcc.put(acc.Id,acc);         
            }
           
           //to filter out account which are not associated yet to opportunity - i.e available on left grid
            //adding child and its parent.... removing parent without childern
           List<Id> nonrelatedAccountIds = NEW  List<Id>();
            for(Id hierarchyAccId : mapOfId_HierarchyAcc.keyset())
            {
                if(!setOfallrelatedIds.contains(hierarchyAccId))
                {
                    Account acc = mapOfId_HierarchyAcc.get(hierarchyAccId);
                    
                    if(string.isNotBlank(acc.parentId))
                    {
                            Account parentAccount = mapOfId_HierarchyAcc.get(acc.parentId);                           
                           
                           // if(parentAccount.Type != 'Customer Group')//parent would be added via child
                           // Commented below if condition to add sold-to without ship-to in not selected component list.
                           //if(parentAccount.Type != 'ZMHI')//parent would be added via child
                           // {
                                OpportunityNotRelatedAccounts1.add(acc);
    
                               if(!nonrelatedAccountIds.contains(parentAccount.Id) )//avoid duplicasy of parent
                                {
                                    OpportunityNotRelatedAccounts1.add(parentAccount);
                                    nonrelatedAccountIds.add(parentAccount.Id); 
                                 }
                            //}
                    }
                }

            }
			OpportunityNotRelatedAccounts.addAll(OpportunityNotRelatedAccounts1);
            
        }
        else// if not then user is selecting accounts for first time to associate with opportunity
        {
            OpportunityNotRelatedAccounts = accountHirarchyRecords;
            //OpportunityRelatedAccounts = NEW
        }
        
        system.debug('OpportunityRelatedAccounts: '+OpportunityRelatedAccounts);
        system.debug('OpportunityNotRelatedAccounts: '+OpportunityNotRelatedAccounts);

        
        responseMap.put('OpportunityRelatedAccounts', OpportunityRelatedAccounts);//right tree grid
        responseMap.put('OpportunityNotRelatedAccounts',OpportunityNotRelatedAccounts);//left tree grid
        
        return responseMap;
        
    }
    
    //wrapper class to store picklist value and lable
   public with sharing class picklistWrapper
    {
        @AuraEnabled 
		public string pickListLabel;
        @AuraEnabled 
		public string pickListValue;
    }
    
    //returns map of picklist lable and value
     @AuraEnabled  
    public static map<string,string> findPicklistOptions(string objAPIName, string fieldAPIname) 
    {
        Map<string,string> mapOfPicklistValueLable = NEW Map<string,string>();
        
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
		Schema.sObjectType objType = schemaMap.get(objAPIName);
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		// Get a map of fields for the SObject
		map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		// Get the list of picklist values for this field.
		list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
		picklistWrapper picklistDetails = new picklistWrapper();
		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a: values) 
        {
			picklistWrapper aa = new picklistWrapper();
			aa.pickListLabel = a.getLabel();
			aa.pickListValue = a.getValue();
			returnValue.add(aa);
            
            mapOfPicklistValueLable.put(aa.pickListValue,aa.pickListLabel);
		}
        system.debug('*****returnValue'+returnValue);
       // return returnValue;
        
        return mapOfPicklistValueLable;
    }
    
    
}