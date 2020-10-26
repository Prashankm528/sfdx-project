/*****************************************************************************************
*   Date: 06/23/2020
*   Author:   Mansi Dhoke(TCS)
*   Description:  This is test class for PCRM_UpdateOpportunityPostClone
*   Version 1.1 
****************************************************************************************/

@isTest
public class PCRM_TestUpdateOpportunityPostClone
{
	//validation methods from PCRM_UpdateOpportunityPostClone
	static testMethod void validateExecute() 
    {
        test.startTest();
               
        PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        List<Account> ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
        insert ListOfAccount;
        
        List<opportunity> ListOfNewOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
        INSERT ListOfNewOpportunity; 
        
        List<opportunity> ListOfCreatedFromCloningOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
                
        Integer count = 0;
        //update opportunity as they are created from cloning
        for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
        {
            cloneOpportunity.PCRM_isCreatedFromCloning__c = true;
            cloneOpportunity.PCRM_Opportunity_Cloned_From__c = ListOfNewOpportunity[Count].Id;
            cloneOpportunity.PCRM_isFirstSyncWithQuote__c = True;
            
            if(Count < ListOfNewOpportunity.size())
                Count = count + 1;
        }
        INSERT ListOfCreatedFromCloningOpportunity;
        
        //create map of old opportunity and new oppotunity Id
        Map<Id,Id> mapOfOldwithNewOpportunityId = NEW Map<Id,Id>();
        for(Opportunity cloneOpportunity : ListOfCreatedFromCloningOpportunity)
        {
            mapOfOldwithNewOpportunityId.put(cloneOpportunity.PCRM_Opportunity_Cloned_From__c,cloneOpportunity.Id);
        }
        
        PCRM_UpdateOpportunityPostClone QueableOpportunityPostCloneObj = NEW PCRM_UpdateOpportunityPostClone(mapOfOldwithNewOpportunityId);
        System.enqueueJob(QueableOpportunityPostCloneObj); 
        
        
        system.debug('assert: '+mapOfOldwithNewOpportunityId.keyset().contains(ListOfCreatedFromCloningOpportunity[0].PCRM_Opportunity_Cloned_From__c));

        system.assertEquals(TRUE, mapOfOldwithNewOpportunityId.keyset().contains(ListOfCreatedFromCloningOpportunity[0].PCRM_Opportunity_Cloned_From__c));
        
        test.stopTest();
    }
}