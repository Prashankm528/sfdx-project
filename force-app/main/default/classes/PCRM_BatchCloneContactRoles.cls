/************************************************************************************************************************
*   Date: 08/25/2020
*   Author: Pooja Deokar(TCS)
* 	Description: The job processes recurrsively to create Contact Roles clones and navigates to next job in line thereafter.
* 	Change Log: initial draft created for cloning Contact Roles associated with given set of Opportunities & Accounts.
*************************************************************************************************************************/

public with Sharing class PCRM_BatchCloneContactRoles implements Queueable
{
    Map<Id, Id> mapOldOpportunityIdWithNewOpportunityId = new map<Id, Id>();
    List<OpportunityContactRole> lstContactRolesWithOldOpportunities = new List<OpportunityContactRole>();
    List<OpportunityContactRole> lstNewContactRoles = new List<OpportunityContactRole>();
    List<PCRM_Batch_Clone__mdt> lstOppContRoleCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
    SET<ID> keys = new SET<ID>();
    //constructor
    public PCRM_BatchCloneContactRoles(Map<Id, Id> mapOldOppIdWithNewOppId)
    {
        if (mapOldOppIdWithNewOppId != null && mapOldOppIdWithNewOppId.size() > 0){
            this.mapOldOpportunityIdWithNewOpportunityId = mapOldOppIdWithNewOppId;
        }
        keys.addAll(mapOldOpportunityIdWithNewOpportunityId.keySet());
        lstOppContRoleCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('OpportunityContactRole');
    }

    //execute method
    public void execute(QueueableContext context) 
    {
        PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
        String strQuery1 = 'SELECT ';        
        for (PCRM_Batch_Clone__mdt BC : lstOppContRoleCustomCloneField){
            strQuery1 += BC.PCRM_TargetField__c + ',';
        }  
        strQuery1 += 'Id From OpportunityContactRole Where OpportunityId IN: keys';
        
        For(OpportunityContactRole objOldOpportunityContactRole : Database.query(strQuery1)){
         	OpportunityContactRole objNewOpportunityContactRole = new OpportunityContactRole();
            for(PCRM_Batch_Clone__mdt BatchClone:lstOppContRoleCustomCloneField){
                objNewOpportunityContactRole.put(BatchClone.PCRM_TargetField__c ,objOldOpportunityContactRole.get(BatchClone.PCRM_SourceField__c)); 
            }  
            objNewOpportunityContactRole.OpportunityId = mapOldOpportunityIdWithNewOpportunityId.get(objOldOpportunityContactRole.OpportunityId);
            objNewOpportunityContactRole.PCRM_isCreatedFromCloning__c = True;    
    
            lstNewContactRoles.add(objNewOpportunityContactRole);                                                             
    	}     
        try{
            if(lstNewContactRoles != null && (!lstNewContactRoles.isEmpty())) {
                result = PCRM_BatchCloneUtil.insertRecords(lstNewContactRoles,'insert');  
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityContactRole','PCRM_BatchCloneContactRoles','Scheduled','PCRM_IT_Support');
            }
            //Call next Batch
            PCRM_BatchCloneQuotes objCloneQuotes = new PCRM_BatchCloneQuotes(this.mapOldOpportunityIdWithNewOpportunityId);
            system.enqueueJob(objCloneQuotes); 
        }catch(Exception Ex){
            PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityContactRole','PCRM_BatchCloneContactRoles','Scheduled','PCRM_IT_Support');
        }   
            
    }
}