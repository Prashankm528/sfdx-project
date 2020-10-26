/*****************************************************************************************
*   Date: 06/06/2020
*   Author:   Pooja Deokar(TCS)
*   Description:  Scheduler class for processing monthly opportunity
*   Version 1.1 
****************************************************************************************/
global with Sharing class  PCRM_CloneOpportunityHierarchyMonthly implements Schedulable {
    //Execute method
    global void execute(SchedulableContext sc) {
        List<String> lstFrequency = new List<String>();
        lstFrequency.add('Monthly');
        lstFrequency.add('Monthly and Quarterly');
        PCRM_BatchCloneOpportunity objCloneOpportunities = new PCRM_BatchCloneOpportunity(lstFrequency);
		System.enqueueJob(objCloneOpportunities);
    }
}