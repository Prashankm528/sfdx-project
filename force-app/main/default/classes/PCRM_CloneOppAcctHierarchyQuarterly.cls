/*****************************************************************************************
*   Date: 08/28/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Scheduler class for processing quaterly opportunity Account
*   Version 1.1 
****************************************************************************************/
global with Sharing class PCRM_CloneOppAcctHierarchyQuarterly implements Schedulable {
    //Execute method
    global void execute(SchedulableContext sc) {
        List<String> lstFrequency = new List<String>();
        lstFrequency.add('Quarterly');        
        PCRM_BatchCloneOpportunityAccounts objCloneOppAccount = new PCRM_BatchCloneOpportunityAccounts(lstFrequency);
		System.enqueueJob(objCloneOppAccount);
    }
}