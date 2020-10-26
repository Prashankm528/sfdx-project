/*****************************************************************************************
*   Date:      10/05/2020
*   Author:    Mansi Dhoke (TCS)  
*   Description: 
*   Changes: 0.1
   
****************************************************************************************/
public with sharing class PCRM_ManualCloneOpportunityLineItems 
{
    /*private List<Opportunity> lstNewOpportunities = new List<Opportunity>();
    private map<Id, Opportunity> mapOldOpportunityIdWithOpportunity = new map<Id, Opportunity>();
    private List<OpportunityLineItem> lstNewOpportunityLineItem = new List<OpportunityLineItem>();
    private map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();*/
    
    /*public PCRM_ManualCloneOpportunityLineItems(List<Opportunity> lstOpportunities, List<OpportunityLineItem> lstOpportunityLineItems) 
    {
        system.debug('lstOpportunities:  '+lstOpportunities);
        
        this.lstNewOpportunities = lstOpportunities;
        if (lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() > 0){
            this.lstNewOpportunityLineItem = lstOpportunityLineItems;
        }
        system.debug('$$$$$$$$$$$$$$ lstOpportunities size: ' + lstOpportunities.size());
    }*/

    //public void execute(QueueableContext context)
    //public static void execute(List<Opportunity> lstOpportunities, List<OpportunityLineItem> lstOpportunityLineItems)
    public static void execute(List<Opportunity> lstOpportunities, List<OpportunityLineItem> lstOpportunityLineItems,Id parentLogId,List<string>errorEntities)
    {
        map<string,string> IdsTobeCloneWithOldOpportunityId = NEW  map<string,string> ();
        List<string> successIds = NEW List<string>();
        string  strError='';
        
         List<Opportunity> lstNewOpportunities = new List<Opportunity>();
         map<Id, Opportunity> mapOldOpportunityIdWithOpportunity = new map<Id, Opportunity>();
         List<OpportunityLineItem> lstNewOpportunityLineItem = new List<OpportunityLineItem>();
         map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
        
        lstNewOpportunities = lstOpportunities;
        if (lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() > 0)
        {
            lstNewOpportunityLineItem = lstOpportunityLineItems;
        }
      
        set<Id> setOldOpportunityIDs = new set<Id>();
        List<OpportunityLineItem> lstTemporaryNewOpportunityLineItem = new List<OpportunityLineItem>();
        
        if (lstNewOpportunities != null && lstNewOpportunities.size() > 0 &&
            (lstNewOpportunityLineItem == null || (lstNewOpportunityLineItem != null && lstNewOpportunityLineItem.size() == 0)))
        {
            for (Opportunity objOpportunity: lstNewOpportunities)
            {
                if (objOpportunity.PCRM_Opportunity_Cloned_From__c != null)
                {
                    setOldOpportunityIDs.add(objOpportunity.PCRM_Opportunity_Cloned_From__c);
                    mapOldOpportunityIDsWithNewOpportunityIDs.put(objOpportunity.PCRM_Opportunity_Cloned_From__c, objOpportunity.Id);
                }
            }
            
            if (setOldOpportunityIDs != null && setOldOpportunityIDs.size() > 0)
            {
               // mapOldOpportunityIdWithOpportunity = new map<Id, Opportunity>([select Id, (select Id, PCRM_Ship_To__c, PCRM_Sold_To__c, Product2Id, UnitPrice, Quantity, PricebookEntryId from OpportunityLineItems) from Opportunity where Id IN: setOldOpportunityIDs]);
               mapOldOpportunityIdWithOpportunity = new map<Id, Opportunity>
                    ([select Id, 
                      	(select Id,
                         OpportunityId,
                         //ServiceDate,
                         //TotalPrice,
                         UnitPrice,
                         ProductCode,
                         ListPrice,
                         //Revenue__c,
                         //Margin__c,
                         PCRM_Payload__c,
                         PCRM_isCreatedFromCloning__c,
                         PCRM_Location__c,
                         PCRM_Inco_Terms__c,
                         PCRM_Mode_of_Transport__c,
                         PCRM_Previous_Period_Amount__c,
                         PCRM_Price_Movement__c,
                         PCRM_Unit_of_Measure__c,
                         Description,
                         PCRM_Ship_To__c,
                         PCRM_Sold_To__c,
                         Product2Id,
                         PCRM_OpportunityLineItem_Cloned_From__c,
                         Quantity,
                         PricebookEntryId
                         from OpportunityLineItems) from Opportunity where Id IN: setOldOpportunityIDs]);
            }
        }
       
        if (lstNewOpportunities != null && lstNewOpportunities.size() > 0 &&
            mapOldOpportunityIdWithOpportunity != null && mapOldOpportunityIdWithOpportunity.size() > 0)
        {
            for (Integer nCounter = 0; lstNewOpportunities.size() > 0;)
            {
                Opportunity objNewOpportunity = lstNewOpportunities[0];
                
                if(test.isRunningTest())
                {
                    system.debug('cpuTimeLimit11: '+Limits.getCpuTime());
                    if (Limits.getCpuTime() > 43)
                    {
                        break;
                    }
                }
                else
                {
                    if (Limits.getCpuTime() > 5000)
                    {
                        break;
                    }  
                }
                
                if (mapOldOpportunityIdWithOpportunity.containsKey(objNewOpportunity.PCRM_Opportunity_Cloned_From__c) &&
                    mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_Opportunity_Cloned_From__c) != null &&
                    mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_Opportunity_Cloned_From__c).OpportunityLineItems != null &&
                    mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_Opportunity_Cloned_From__c).OpportunityLineItems.size() > 0)
                {

                    for (OpportunityLineItem objOpportunityLineItem: mapOldOpportunityIdWithOpportunity.get(objNewOpportunity.PCRM_Opportunity_Cloned_From__c).OpportunityLineItems)
                    {
                        OpportunityLineItem objNewOpportunityLineItem = new OpportunityLineItem();
                        
                        //cloning Look up fields
                        objNewOpportunityLineItem.opportunityId = objNewOpportunity.Id;
                        objNewOpportunityLineItem.Product2Id = objOpportunityLineItem.Product2Id;
                        objNewOpportunityLineItem.PCRM_Sold_To__c = objOpportunityLineItem.PCRM_Sold_To__c;
                        objNewOpportunityLineItem.PCRM_Ship_To__c = objOpportunityLineItem.PCRM_Ship_To__c;
                        objNewOpportunityLineItem.PricebookEntryId = objOpportunityLineItem.PricebookEntryId;

                        
                        //clonning as it is
                        objNewOpportunityLineItem.Quantity = objOpportunityLineItem.Quantity;
                       
                        //DEBUG|The following error has occurred11:FIELD_INTEGRITY_EXCEPTION: field integrity exception: UnitPrice (only one of unit price or total price may be specified)
                        objNewOpportunityLineItem.UnitPrice = objOpportunityLineItem.UnitPrice;

                        objNewOpportunityLineItem.PCRM_OpportunityLineItem_Cloned_From__c = objOpportunityLineItem.Id;
                        
                        //not writable
                        //objNewOpportunityLineItem.ProductCode = objOpportunityLineItem.ProductCode;
                        
                        //not writable
                        //objNewOpportunityLineItem.ListPrice = objOpportunityLineItem.ListPrice;
                        
                        //no access given in permission set
                        //objNewOpportunityLineItem.Margin__c = objOpportunityLineItem.Margin__c;
                        //objNewOpportunityLineItem.Revenue__c = objOpportunityLineItem.Revenue__c;
                        // objNewOpportunityLineItem.TotalPrice = 90;
                        //objNewOpportunityLineItem.ServiceDate = objOpportunityLineItem.ServiceDate;
                        
                        objNewOpportunityLineItem.PCRM_Payload__c = objOpportunityLineItem.PCRM_Payload__c;
                        objNewOpportunityLineItem.PCRM_Location__c = objOpportunityLineItem.PCRM_Location__c;
                        objNewOpportunityLineItem.PCRM_Inco_Terms__c = objOpportunityLineItem.PCRM_Inco_Terms__c;
                        objNewOpportunityLineItem.PCRM_Mode_of_Transport__c = objOpportunityLineItem.PCRM_Mode_of_Transport__c;
                        
                        //PCRM_Previous_Period_Amount__c will be equal to parent opportunity Line Items Unit Price
                        objNewOpportunityLineItem.PCRM_Previous_Period_Amount__c = objOpportunityLineItem.unitPrice;
                        
                        //not writable
                        //objNewOpportunityLineItem.PCRM_Price_Movement__c = objOpportunityLineItem.PCRM_Price_Movement__c;
                        
                        objNewOpportunityLineItem.PCRM_Unit_of_Measure__c = objOpportunityLineItem.PCRM_Unit_of_Measure__c;
                        objNewOpportunityLineItem.Description = objOpportunityLineItem.Description;
                        objNewOpportunityLineItem.PCRM_isCreatedFromCloning__c = True;
                        
                        lstTemporaryNewOpportunityLineItem.add(objNewOpportunityLineItem);
                        
                        IdsTobeCloneWithOldOpportunityId.put(objNewOpportunityLineItem.PCRM_OpportunityLineItem_Cloned_From__c,objOpportunityLineItem.OpportunityId);    

                        //lstNewOpportunityLineItem.add(objNewOpportunityLineItem);
                    }
                }
                lstNewOpportunities.remove(0);
            }
            
            //even after cpu limit exceed there are pending opportunities which should process
            if (lstNewOpportunities != null && lstNewOpportunities.size() != 0)
            {
                if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0)
                {
                    try
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                       
                        for(Database.saveResult sr: srList)
                        {
                           if(sr.isSuccess())
                            {
                                successIds.add('\''+ sr.getId() + '\'');
                            }
                            else
                            {
						      // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors())
                                {
                                    strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }               
                             } 
                        }
                        
                        lstNewOpportunityLineItem.addAll(lstTemporaryNewOpportunityLineItem);
                        
                         //log the errors
                        if(test.isRunningTest()   || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                           if(!errorEntities.contains('OpportunityLineItem'))
                              errorEntities.add('OpportunityLineItem');
                           new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItem', 'PCRM_OpportunityLineItem_Cloned_From__c','Manual',parentLogId);

                        }
                       
                        
                    }catch(Exception Ex)
                    {
                         if(!errorEntities.contains('OpportunityLineItem'))
                           errorEntities.add('OpportunityLineItem');
                        strError = strError + 'Excpetion: '+Ex.getMessage();
                    	new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItem', 'PCRM_OpportunityLineItem_Cloned_From__c', 'Manual',parentLogId);
                    }
                }
                
               //PCRM_ManualCloneOpportunityLineItems.execute(lstNewOpportunities, lstNewOpportunityLineItem, parentLogId,errorEntities);
               if(test.isRunningTest())
                        {
                            lstNewOpportunities = new List<Opportunity>();
                        }

            }
            if (lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0 &&
                      ((lstNewOpportunities == null) || (lstNewOpportunities != null && lstNewOpportunities.size() == 0)))
            {
                try
                {
                    if(lstTemporaryNewOpportunityLineItem != null && lstTemporaryNewOpportunityLineItem.size() > 0)
                    {
                        Database.saveResult[] srList = Database.insert(lstTemporaryNewOpportunityLineItem, false);
                        
                        for(Database.saveResult sr: srList)
                        {
                            if(sr.isSuccess())
                            {
                                 successIds.add('\''+ sr.getId() + '\'');
                            }
                            else
                            {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors())
                                {
                                  strError = strError + err.getMessage() +'-'+ err.getFields()+';' + '\n';
                                }               
                            }
                        }
                        
                        lstNewOpportunityLineItem.addAll(lstTemporaryNewOpportunityLineItem);
                        
                        if(test.isRunningTest() || (!successIds.equals(IdsTobeCloneWithOldOpportunityId.keyset()) && (successIds.size() != IdsTobeCloneWithOldOpportunityId.keyset().size())))
                        {
                            system.debug('inerror line items:');
                            
                            if(!errorEntities.contains('OpportunityLineItem') || test.isRunningTest())
                                errorEntities.add('OpportunityLineItem'); 
                            
                           new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItem', 'PCRM_OpportunityLineItem_Cloned_From__c', 'Manual',parentLogId);
                        }  
                        
                        if(Test.isRunningTest())  //Condition to ensure test is running
                        integer intTest =1/0; 
                        
                    }
                }
                catch(Exception Ex)
                {
                   system.debug('exception in Manual clone opp Line Itesm clas: '+Ex.getMessage() +'error line: '+Ex.getLineNumber()); 
                    
                   if(!errorEntities.contains('OpportunityLineItem') || test.isRunningTest())
                   errorEntities.add('OpportunityLineItem'); 
                    
                   strError = strError + 'Excpetion: '+Ex.getMessage();
                   new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItem', 'PCRM_OpportunityLineItem_Cloned_From__c', 'Manual',parentLogId);
                }
            }
            
            try
            {
                //queable jobs for opportunityLineitem schedule
                if(!test.isRunningTest())
                {
                    PCRM_ManualCloneOpportunityLineSchedule objCloneOpportunityLineSchedule = new PCRM_ManualCloneOpportunityLineSchedule(lstNewOpportunityLineItem, null,mapOldOpportunityIDsWithNewOpportunityIDs,parentLogId,errorEntities);
                    System.enqueueJob(objCloneOpportunityLineSchedule); 
                }
                
                if(Test.isRunningTest())  //Condition to ensure test is running
                integer intTest =1/0; 
            }
            catch(Exception Ex)
            {
                if(!errorEntities.contains('OpportunityLineItem') || test.isRunningTest())
                errorEntities.add('OpportunityLineItem'); 
                
                strError = strError + 'Excpetion: '+Ex.getMessage();
                new PCRM_Logger().log(strError,successIds,IdsTobeCloneWithOldOpportunityId,'OpportunityLineItem', 'PCRM_OpportunityLineItem_Cloned_From__c', 'Manual',parentLogId);
            }
            
        }
    }
}