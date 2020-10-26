/**
* @author         Sid
* @date           2/10/2019
* @description    Trigger on LC Parcels Object
* @Assumptions    NA 
*/
trigger GCP_TFD_LcParcelsTrigger on GCP_TFD_LC_Parcel__c (after update, after insert)
{
    /*  There are no recordtypes associated on LC-Parcels. So, no recordtype filter needed.
     */
      if(GCP_CheckRecursive.runOnce())
      { 
          if(!FeatureManagement.checkPermission(GCP_TFD_Constant.BPG_DISABLE_ALL))
          {
            GCP_TFD_LcParcelsTriggerHandler.updateCaseDetails(trigger.newmap);
            GCP_TFD_LcParcelsTriggerHandler.updateCaseAmount(trigger.newmap,trigger.oldmap,trigger.IsUpdate);
          }
      }
}