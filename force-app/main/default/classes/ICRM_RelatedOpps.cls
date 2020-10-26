/* @author            Palash Awasthi
*  @date              15th July, 2019
*  @description       Get all the related opportunities to the account and contacts ignoring the sharing rules.
*/
public without sharing class ICRM_RelatedOpps {
    
    /*
Fetch all the related opportunities irrespective of the Sharing
*/    
    @AuraEnabled
    public static List<Opportunity> getAccountRelatedOpportunities(String recId){
        //Get the List of opportunities already shared with the current user
        List<Opportunity> nonSharedOpportunities = new List<Opportunity>();
        Set<Opportunity> finalOpptySet = new Set<Opportunity>();
        List<Opportunity> accountOpportunities;
        try{
            accountOpportunities = [SELECT Name, ICRM_RBU__c, ICRM_Phy_Fin__c, Owner.Name, CreatedDate FROM Opportunity WHERE AccountId =:recId 
                                    AND ICRM_BP_Confidential__c = false];
        }catch(QueryException qe){
            System.debug('Exception thrown at this line'+ qe.getLineNumber()+'with message'+ qe.getMessage() );
        }
        
        finalOpptySet.addAll(accountOpportunities);
        List<Opportunity> sharedOpportunities;
        try{
            sharedOpportunities = ICRM_SharingRelatedOpps.fetchSharedOpportunities(recId);
        }catch(QueryException queryExc){
            System.debug('Exception thrown in the return on this line'+ queryExc.getLineNumber()+ 'with message'+ queryExc.getMessage() );
        }
        
        finalOpptySet.removeAll(sharedOpportunities);
        nonSharedOpportunities.addAll(finalOpptySet);
        return nonSharedOpportunities;        
    }    
}