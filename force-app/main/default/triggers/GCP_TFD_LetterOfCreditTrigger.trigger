/**
* @author      Avinash Jain
* @date      17/09/2019
* @description    Trigger on Letter Of credit object      
*/
trigger GCP_TFD_LetterOfCreditTrigger on GCP_TFD_Letter_of_Credit__c (After insert,after update)
{
    List<GCP_TFD_Letter_of_Credit__c> letterofcredits = new list<GCP_TFD_Letter_of_Credit__c>();
    /* As trigger has to run on both Export & import recordtypes, we are not filtering trigger logic based
     * on Reccordtype. However, logic specific to each recordtype is manintained in controller class.
     */
    if(!FeatureManagement.checkPermission(GCP_TFD_Constant.BPG_DISABLE_ALL))
    {
        GCP_TFD_LetterOfCreditTriggerHandler LCT = new GCP_TFD_LetterOfCreditTriggerHandler();
    	if(trigger.isinsert)
        {
        	LCT.onAfterInsert(Trigger.new);
    	}
        //Checking if update trigger and GCP_TFD_Run_Update_Trigger__c field is updated...
        if(trigger.isupdate)
        {
            system.debug('Entering Update Trigger');
            for(GCP_TFD_Letter_of_Credit__c lc:trigger.newmap.values())
            {
                GCP_TFD_Letter_of_Credit__c oldlc = trigger.oldmap.get(lc.id);
                if(lc.GCP_TFD_Run_Update_Trigger__c && 
                   oldlc.GCP_TFD_Run_Update_Trigger__c != lc.GCP_TFD_Run_Update_Trigger__c)
                {
                    letterofcredits.add(lc);
                }
            }
            //Calling relevant method only if records are present...
            if(!letterofcredits.isEmpty())
            {
            	LCT.onAfterInsert(letterofcredits);
            }
        }
    }    
}