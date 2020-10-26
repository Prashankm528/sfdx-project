/**
* @author      Avinash Jain
* @date      20/08/2019
* @description    Trigger on open credit object      
*/
/**
 * Change history:
 * Date             Author            Description
 * 11/11/2019       Sid               Logic to run the trigger on Update of OC record. This has to run only 
 *                                    on update of GCP_TFD_Run_Update_Trigger__c record to true.  
 * 
 */ 
trigger GCP_TFD_OpenCreditTrigger on GCP_TFD_OpenCredit__c (After insert,after update)
{
    List<GCP_TFD_OpenCredit__c> opencredits = new List<GCP_TFD_OpenCredit__c>();
    /* As trigger has to run on both Invoice & Schedule recordtypes, we are not filtering trigger logic based
     * on Recordtype. However, logic specific to each recordtype is manintained in controller class.
     */
    if(!FeatureManagement.checkPermission(GCP_TFD_Constant.BPG_DISABLE_ALL))
    {
        GCP_TFD_OpenCreditTriggerHandler OCT = new GCP_TFD_OpenCreditTriggerHandler();
        if(trigger.isinsert)
        {
            OCT.onAfterInsert(Trigger.new);
        }
        //Checking if update trigger and GCP_TFD_Run_Update_Trigger__c field is updated...
        if(trigger.isupdate)
        {
            for(GCP_TFD_OpenCredit__c oc:trigger.newmap.values())
            {
                GCP_TFD_OpenCredit__c oldoc = trigger.oldmap.get(oc.id);
                if(oc.GCP_TFD_Run_Update_Trigger__c && oldoc.GCP_TFD_Run_Update_Trigger__c != oc.GCP_TFD_Run_Update_Trigger__c)
                {
                    opencredits.add(oc);
                }
            }
            //Calling required method only if records are present...
            if(!opencredits.isEmpty())
            {
            	OCT.onAfterInsert(opencredits);
            }
        }
    }
}