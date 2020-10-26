public with sharing class ICRM_SharingRelatedOpps {
    
    /*
Fetch all the related opportunities which are shared with the users 
*/  
    public static List<Opportunity> fetchSharedOpportunities(String recId){
        
        return [SELECT Name, ICRM_RBU__c, ICRM_Phy_Fin__c, Owner.Name, CreatedDate FROM Opportunity WHERE AccountId =:recId 
                AND ICRM_BP_Confidential__c = false]; 
        
    }
}