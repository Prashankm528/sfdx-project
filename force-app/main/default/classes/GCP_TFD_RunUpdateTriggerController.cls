/**
* @author         Sid
* @date           11/11/2019
* @description    Controller class for GCP_TFD_UPDATE_DATA_LINKAGE Component
* @Assumptions    NA 
*/
public with sharing class GCP_TFD_RunUpdateTriggerController 
{
    /**   
      * @description       This method updates the Run update trigger as True on OC
      * @param             ocid             
      * @return            NULL
      * @throws            NA      
      */
	@auraEnabled
    public static void updaterunupdatetrigger(string ocid)
    {
        GCP_TFD_OpenCredit__c oc = new GCP_TFD_OpenCredit__c();
        oc.GCP_TFD_Run_Update_Trigger__c = TRUE;
        oc.id = ocid;
        update oc;
    }
    /**   
      * @description       This method updates the Run update trigger as True on LC
      * @param             lcid             
      * @return            NULL
      * @throws            NA      
      */
	@auraEnabled
    public static void updaterunupdatetriggerlc(string lcid)
    {
        GCP_TFD_Letter_of_Credit__c lc = new GCP_TFD_Letter_of_Credit__c();
        lc.GCP_TFD_Run_Update_Trigger__c = TRUE;
        lc.id = lcid;
        update lc;
    }
}