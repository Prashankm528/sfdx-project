/****************************************************************************************************
 * Date          : 28-MAY-2020
 * Author        : IBM
 * Description   : Invocable class for Posting Chatter message.
 * Modifications : 28-MAY-2020 Initial
 ****************************************************************************************************/

global with sharing class GCM_ChatterPost_Service {
	/****************************************************************************************************
     * Notify to Case Owner
     ****************************************************************************************************/
    @InvocableMethod(label = 'Notify Case Owner')
    public static void notifyCaseOwner(List<Id> caseIds) {
        	    
        List<Case> caseList = [SELECT Id, OwnerId, Owner.FirstName, Owner.LastName, CaseNumber FROM Case WHERE Id IN :caseIds];
        if(caseList.size() > 0){
            String Lightning_Base_Url = getLightningBaseUrl();
            String caseLink = Lightning_Base_Url + '/' + caseList[0].Id;            
            String chatterMessage = Label.GCM_Notify_Case_Owner_Message;
            chatterMessage = chatterMessage.replace('{!CaseNumber}', caseList[0].CaseNumber).replace('{!CaseLink}', caseLink);
            List<GCM_Post_Chatter.InputData> inputDataList = new List<GCM_Post_Chatter.InputData>();
            GCM_Post_Chatter.InputData inputData = new GCM_Post_Chatter.InputData(caseList[0].Id, caseList[0].OwnerId, chatterMessage);
            inputDataList.add(inputData);
            GCM_Post_Chatter.post(inputDataList);
        }        
    }
    /****************************************************************************************************
    * Get the Lightning Base URL
    ****************************************************************************************************/    
    public static String getLightningBaseUrl() {
        String UrlPrefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0].removeEnd('--c');	    
        return UrlPrefix.toLowerCase() + '.lightning.force.com';
    }
}