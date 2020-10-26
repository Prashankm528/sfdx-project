/*****************************************************************************************
* Date:          27MAY17
* Author:        Jon Marson (Forcify)
* Comments:      Lead allocation engine.  
*                Prerequisites - the 'Allocation_Group__c' field should have been set.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* ***************************************************************************************/
public without sharing class SOM_BP_Lead_Allocation 
{   static Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
 
 /***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method use to call allocateHelper() method.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
 @InvocableMethod(label='Allocate Lead' description='Allocates a list of leads to accounts with sufficient budget cover on a round-robin basis')    
 public static void allocate(List<Lead> leadList)
 {   List<Lead> lstNew = new List<Lead>();
  try
  {
      for(Lead leadObj : leadList)
      { 
          
          lstNew.add(leadObj);
          if(lstNew.size()>0)
          {
              allocateHelper(lstNew, false);
          }
      }
  }
  catch (Exception e)
  {
      System.debug('Exception occurred'+e.getMessage());
  }     
 }
 
/***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method used to Allocates a list of leads to accounts.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
 public static void allocateHelper(List<Lead> leadList, Boolean overrideManualAssignment)
 {            
     //Populate a set containing the different allocation groups (tiers of lead) for the leads we are dealing with
     system.debug(leadList+'leadList');
     Set<Id> allocationGroupIdSet = new Set<Id>(); 
     List<Id> leadIdList = new List<Id>();
     try
     {
         for (Lead l : leadList)
         {          
     system.debug(l.SOM_Allocation_Group__c+'l.SOM_Allocation_Group__c');
             leadIdList.add(l.Id);
             if (l.SOM_Allocation_Group__c != null)
                 allocationGroupIdSet.add(l.SOM_Allocation_Group__c);         
         }
         system.debug(allocationGroupIdSet+'allocationGroupIdSet');
         //Populate a map containing the allocation groups
         Map<Id, SOM_Allocation_Group__c> agMap = new Map<Id, SOM_Allocation_Group__c>([SELECT Id, SOM_Product__c, SOM_Last_Lead_Allocated_To__c, SOM_Allocation_Mode__c, OwnerId, (SELECT Id, SOM_Account__c FROM Account_Allocation_Groups__r ORDER BY SOM_Sequence__c ASC) FROM SOM_Allocation_Group__c WHERE Id IN :allocationGroupIdSet FOR UPDATE]);
         
         //Populate a map containg all current budget items, using a concatenation of the budget's productId and AccountId as the index
         Map<String, SOM_Budget_Item__c> budgetItemMap = new Map<String, SOM_Budget_Item__c>();
         for (SOM_Budget_Item__c budgetItem : [SELECT Id, SOM_Product__c, SOM_Budget__r.Account__c, SOM_Budget__r.Account__r.SOM_Primary_Partner_User__c, SOM_Budget__r.Account__r.SOM_Email_on_Lead_Assignment__c, SOM_Unit_Price__c, SOM_Max_Spend__c,  SOM_Actual_Spend__c, SOM_Budget__r.SOM_Max_Spend__c, SOM_Budget__r.SOM_Actual_Spend__c FROM SOM_Budget_Item__c WHERE SOM_Budget__r.SOM_Status__c='Current' AND SOM_Budget_Spent__c = false])
             budgetItemMap.put(budgetItem.SOM_Product__c +'|' +budgetItem.SOM_Budget__r.Account__c, budgetItem);
         
         //Populate a set containing all the existing lead allocations.  Use a concatenation of the leadId and accountId as the index.
         //This will be used as part of the re-allocation process where a lead has been rejected by a distributor and we need to reallocate it to a DIFFERENT distributor   
         Set<String> leadAllocationSet = new Set<String>();
         for (SOM_Lead_Allocation__c la : [SELECT Id, Lead__c, Account__c FROM SOM_Lead_Allocation__c WHERE Lead__c IN :leadIdList])
             leadAllocationSet.add(la.Lead__c +'|' +la.Account__c);
          
        
          
         //For each allocation group, locate all the relevant budget items belonging to the group members and store them in a map, using allocation group id as the index
         Map<Id, List<SOM_Budget_Item__c>> agIdToBudgetItemsMap = new Map<Id, List<SOM_Budget_Item__c>>();
         for (SOM_Allocation_Group__c ag : agMap.values())
         {
             agIdToBudgetItemsMap.put(ag.Id, new List<SOM_Budget_Item__c>());
             
             for (SOM_Account_Allocation_Group__c aag : ag.Account_Allocation_Groups__r)
             {
                 if (budgetItemMap.containsKey(ag.SOM_Product__c +'|' +aag.SOM_Account__c))  
                     agIdToBudgetItemsMap.get(ag.Id).add(budgetItemMap.get(ag.SOM_Product__c +'|' +aag.SOM_Account__c));        
             }
         }
           system.debug(leadAllocationSet+'leadAllocationSet');
          system.debug(budgetItemMap+'budgetItemMap');
           system.debug(agMap+' ');
           system.debug(agIdToBudgetItemsMap+'agIdToBudgetItemsMap');
           
         
         //Now we loop through each lead and perform the allocation       
         List<Lead> leadListForUpdate = new List<Lead>();
         List<SOM_Budget_Item__c> budgetItemList;
         List<SOM_Lead_Allocation__c> leadAllocationListForInsert = new List<SOM_Lead_Allocation__c>();
         SOM_Budget_Item__c budgetItem;
         SOM_Allocation_Group__c allocationGroup;
         Id lastLeadAllocatedToAccountId;
         Integer indexWhenFound;
         Integer nextBudgetAllocationIndex;
         Boolean found;
         
         //23JUN17 - JMARSON - Added to send email
         EmailTemplate templateId = [Select id from EmailTemplate where name = 'Notify Distributor of Lead Assignment'];
         List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage email;
         system.debug('l.agIdToBudgetItemsMap'+agIdToBudgetItemsMap);
         for (Lead l : leadList)
         { 
             found = false;
             system.debug('SOM_Allocation_Group__c'+found );
             if (l.SOM_Allocation_Group__c == null)
             {
                 leadListForUpdate.add(new Lead(Id=l.Id, Status='Allocation Failed - Allocation Group not set'));
                 continue;
             }
             system.debug('l.agIdToBudgetItemsMap'+agIdToBudgetItemsMap);
             allocationGroup = agMap.get(l.SOM_Allocation_Group__c);
             
             //In manual mode we assign the leads to the owner of the Allocation Group rather than to the group members directly.  The owner of
             //the group can then press the 'Allocate' button if they wish to assign the lead to the group members.
             if (allocationGroup.SOM_Allocation_Mode__c == 'Manual' && !overrideManualAssignment)
             {
                 leadListForUpdate.add(new Lead(Id=l.Id, OwnerId=allocationGroup.OwnerId));
                 continue;
             }
            //Find out which product (tier) this lead belongs to, and the distributor to which the last lead in that tier was allocated.
             //Then loop through the open budgets in sequence, until we find the budget belonging to the distributor who was allocated the last lead.
             system.debug('l.SOM_Allocation_Group__c'+l.SOM_Allocation_Group__c );           
system.debug('l.agIdToBudgetItemsMap'+agIdToBudgetItemsMap);             
             budgetItemList = agIdToBudgetItemsMap.get(l.SOM_Allocation_Group__c);  
system.debug('budgetItemListbudgetItemList'+budgetItemList );            
             lastLeadAllocatedToAccountId = allocationGroup.SOM_Last_Lead_Allocated_To__c;       
             indexWhenFound = 0;  
             for (SOM_Budget_Item__c bi : budgetItemList)
             {                            
                 if (bi.SOM_Budget__r.Account__c == lastLeadAllocatedToAccountId)
                     break;
                 
                 indexWhenFound++;    
             }
             
             //Now we know the index of the budget belonging to the distributor to which the last lead was allocated, we can allocated the lead to the
             //next budget in the list.  If the last lead was allocated to the final budget in the list, or if we couldn't find a budget belonging to the 
             //distributor who was last allocated a lead, then allocate the lead to the first budget in the list.
             nextBudgetAllocationIndex = ++indexWhenFound;   
             if (nextBudgetAllocationIndex >= budgetItemList.size())
                 nextBudgetAllocationIndex = 0;        
             
             //Check that the 'next' budget in the list is not already spent, or that allocating this lead to it would cause the budget to be exceeded.  
             //If this is the case then keep looping through the remaining budgets in sequence until we find one that isn't.
             system.debug('inside for loop going' );
             
             for (Integer i=0; i<budgetItemList.size(); i++)
             {                  
                 budgetItem = budgetItemList[Math.mod(nextBudgetAllocationIndex + i, budgetItemList.size())];      
                  system.debug('budgetItembudgetItem'+budgetItem );
             
                 //The found variable allows us to track the scenario where ALL the budgets in the list are already spent, and therefore we cannot assign the lead.
                 found = (budgetItem.SOM_Actual_Spend__c + budgetItem.SOM_Unit_Price__c <= budgetItem.SOM_Max_Spend__c && budgetItem.SOM_Budget__r.SOM_Actual_Spend__c + budgetItem.SOM_Unit_Price__c <= budgetItem.SOM_Budget__r.SOM_Max_Spend__c);
                 system.debug('foundfoundfound'+found );
                 system.debug(leadAllocationSet+'leadAllocationSetleadAllocationSet');
                 system.debug(budgetItem.SOM_Budget__r.Account__c+'budgetItem.SOM_Budget__r.Account__c');
                 //Also check whether the distributor to which we are about to assign this lead has already been allocated this lead e.g. if they rejected it
                 //and the administrator is re-allocating it.
                 if (leadAllocationSet.contains(l.Id +'|' +budgetItem.SOM_Budget__r.Account__c))
                     found = false;
                 
                 if (found)
                     break;     
             }
             
             //Didn't find a budget which (a) has sufficient funds and (b) belongs to a distributor which has not already rejected this lead
             if (!found)
             {
                 leadListForUpdate.add(new Lead(Id=l.Id, Status='Allocation Failed'));
                 continue;
             }
             
             //Perform updates
             leadListForUpdate.add(new Lead(Id=l.Id, Status='Allocated', SOM_Allocated_Date__c=DateTime.now(), SOM_Budget_Item__c=budgetItem.Id, OwnerId=budgetItem.SOM_Budget__r.Account__r.SOM_Primary_Partner_User__c));
             leadAllocationListForInsert.add(new SOM_Lead_Allocation__c(Lead__c=l.Id, SOM_Budget_Item__c=budgetItem.Id, Account__c=budgetItem.SOM_Budget__r.Account__c, SOM_Status__c='Allocated'));
             allocationGroup.SOM_Last_Lead_Allocated_To__c = budgetItem.SOM_Budget__r.Account__c;
             
             //Send an email to the distributor to notify them they have been assigned a lead
             if (budgetItem.SOM_Budget__r.Account__r.SOM_Email_on_Lead_Assignment__c != null)
             {
             System.debug('Exception occurred'+budgetItem.SOM_Budget__r.Account__r.SOM_Email_on_Lead_Assignment__c.split(';'));
                 email = new Messaging.SingleEmailMessage();
                 email.setToAddresses(budgetItem.SOM_Budget__r.Account__r.SOM_Email_on_Lead_Assignment__c.split(';'));
                 email.setTemplateID(templateId.Id); 
                 email.setTargetObjectId(l.Id);
                 email.setTreatTargetObjectAsRecipient(false);
                 email.setSaveAsActivity(false);
                 emailList.add(email);    
             }
             
         }
         
         if(agMap.size()>0 || agMap.isEmpty()  )
            update agMap.values();      
         
         if(leadListForUpdate.size()>0 || leadListForUpdate.isEmpty())
            update leadListForUpdate;
         
         if(leadAllocationListForInsert.size()>0 || leadAllocationListForInsert.isEmpty())
             insert leadAllocationListForInsert;
 System.debug('Exception emailList'+emailList);
         if (!emailList.isEmpty())
            Messaging.sendEmail(emailList,false);
         
     }
     catch (Exception e)
     {
         System.debug('Exception occurred'+e.getMessage());
     }  
 }
}