/*************************************************************************************************
* Date:          14JUL17
* Author:        Jon Marson (Forcify Ltd)
* Comments:      Whenever the stage gets updated on the Opportunity, we need to denormalise the
*                stage name onto the 'Opporutnity Stage' field for all related Contacts.  This
*                is because the Contact record gets sync'd to DotMailer, and Dotmailer needs this
*                information to trigger various marketing programmes. 
* Modification:  7OCT2019 ABHISHEK- UK Fuel Card Migration.
* ***********************************************************************************************/

public without sharing class SOM_ContactStagehandler extends BPG_Trigger_Handler_Utilities 
{
/***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method use to call SOM_ContactStagehelper.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration.
* *********************************************************************************/
    public override void afterupdate(List<SObject> lstOldOpportunity, Map<Id, SObject> mapOpportunity, List<SObject> lstnewOpportunity, Map<Id, SObject> mapNewOpportunity, Schema.SObjectType sOpportunity, String params, Boolean debug) 
    {
        SOM_ContactStageHelper.updateContactOpptyStage(lstOldOpportunity,lstnewOpportunity);
    }
    
}