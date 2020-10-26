/***********************************************************************************************
 * @author           FX
 * @date             2020/07/14
 * @group            CHCRM
 * @description      CHCRM Opportunity Support Request trigger handler to use the trigger handler framework
 *
 * history
 * 2020/07/14  FX  Created
 ************************************************************************************************/
public with sharing class CHCRM_OpptySupportRequestProcess {
	public void syncHasCommnetsField(List<CHCRM_Opportunity_Support_Request__c> newRecords) {
        for(CHCRM_Opportunity_Support_Request__c req : newRecords) {
            if(String.isBlank(req.CHCRM_Comment_From_Approver__c)) {
                req.CHCRM_Has_Comment__c = false;
            } else {
                req.CHCRM_Has_Comment__c = true;
            }
        }
    }
}