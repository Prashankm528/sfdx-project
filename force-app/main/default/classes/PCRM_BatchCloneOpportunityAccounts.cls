/************************************************************************************************************************
*   Date: 08/25/2020
*   Author:   Pooja Deokar(TCS)
* 	Description: The job processes recurrsively to create OpportunityAccounts clones and navigates to next job in line thereafter.
* 	Change Log: initial draft created for cloning OpportunityAccounts associated with given set of Opportunities & Accounts.
*************************************************************************************************************************/

public with Sharing class PCRM_BatchCloneOpportunityAccounts implements Queueable
{
    List<PCRM_Opportunity_Account__c> lstNewOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
    map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs = new map<Id, Id>();
    List<PCRM_Batch_Clone__mdt> lstOppAcctCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
    SET<ID> keys = new SET<ID>();
    
    //constructor
    public PCRM_BatchCloneOpportunityAccounts(List<String> lstFrq) {
        DateTime dt = System.Now().addHours(-1);
        Id opportunityRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PCRM_PetChems_Acetyls').getRecordTypeId();
		
        for(Opportunity opty:[Select id,PCRM_Opportunity_Cloned_From__c,PCRM_isFirstSyncWithQuote__c 
                              From Opportunity 
                              Where CreatedDate >: dt AND PCRM_isFirstSyncWithQuote__c = true AND 
                              recordTypeId =: opportunityRTId AND StageName = 'Prospecting' AND PCRM_Opportunity_Cloned_From__c != null
                              AND PCRM_Quote_Frequency__c IN: lstFrq ]){
            mapOldOpportunityIDsWithNewOpportunityIDs.put(opty.PCRM_Opportunity_Cloned_From__c,opty.Id);
            keys.add(opty.PCRM_Opportunity_Cloned_From__c);           
        }  
        
        //get the PCRM_Opportunity_Account__c clone field details from custom metadata
        lstOppAcctCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('PCRM_Opportunity_Account__c');
    }    
    
	//Execute Method    
    public void execute(QueueableContext context)
    {
         PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
         Id opportunityAccountRTId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get('PCRM_Opportunity_Account').getRecordTypeId();
         String strQuery1 = 'SELECT ';
        
        for (PCRM_Batch_Clone__mdt BC : lstOppAcctCustomCloneField){
            strQuery1 += BC.PCRM_TargetField__c + ',';
        }  
        strQuery1 += 'ID From PCRM_Opportunity_Account__c Where PCRM_Opportunity__c IN: keys';
        
        for(PCRM_Opportunity_Account__c objOpportunityAccount : Database.query(strQuery1)){            
            PCRM_Opportunity_Account__c objNewOpportunityAccount = new PCRM_Opportunity_Account__c();
            for(PCRM_Batch_Clone__mdt BatchClone:lstOppAcctCustomCloneField){
                objNewOpportunityAccount.put(BatchClone.PCRM_TargetField__c ,objOpportunityAccount.get(BatchClone.PCRM_SourceField__c)); 
            }  
            objNewOpportunityAccount.PCRM_isCreatedFromCloning__c = True;  
            objNewOpportunityAccount.PCRM_Opportunity__c = mapOldOpportunityIDsWithNewOpportunityIDs.get(objOpportunityAccount.PCRM_Opportunity__c);
            
            lstNewOpportunityAccount.add(objNewOpportunityAccount);
        }
        
        try{
            if(lstNewOpportunityAccount != null && (!lstNewOpportunityAccount.isEmpty())) {
                result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunityAccount,'insert');  
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'PCRM_Opportunity_Account__c','PCRM_BatchCloneOpportunityAccounts','Scheduled','PCRM_IT_Support');
         	}   
            //Call next Batch For opportunity contact Role cloning
            PCRM_BatchCloneContactRoles objCloneContactRoles = new PCRM_BatchCloneContactRoles(mapOldOpportunityIDsWithNewOpportunityIDs);
            system.enqueueJob(objCloneContactRoles);                            
        }catch(Exception Ex){
            PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'PCRM_Opportunity_Account__c','PCRM_BatchCloneOpportunityAccounts','Scheduled','PCRM_IT_Support');
        }   
    }    
}