/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 01/2019
*
**/

public class REIDP_AppLauncherController {
    
    @AuraEnabled
    public static List<REIDP_Application__c> getAppList() {
        
        List<REIDP_Application__c> appList = new List<REIDP_Application__c>();
        List<String> permSetIdList = new List<String>();
        List<Network> currentCommunity = [SELECT Name 
                                          FROM Network
                                          WHERE id =: Network.getNetworkId()];

        //Set default value
        String communityName = 'BP';
        if(currentCommunity.size() > 0)
            communityName = currentCommunity[0].Name;         
            
        for(PermissionSetAssignment perm : [SELECT PermissionSetId 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId =: UserInfo.getUserId()]) {
                                                permSetIdList.add(perm.PermissionSetId);
                                            }
        
        for(REIDP_User_Consent__c userCons : [SELECT User__c, Accepted__c,
                                              Application__c, 
                                              Application__r.Name, 
                                              Application__r.Permission_Set__c, 
                                              Application__r.URL__c, 
                                              Application__r.App_Icon__c 
                                              FROM REIDP_User_Consent__c
                                              WHERE User__c = :UserInfo.getUserId()
                                              AND Accepted__c = TRUE
                                              AND Type__c = 'Terms and Conditions'
                                              AND Application__r.Is_Active__c = TRUE
                                              AND Application__r.Community__c = :communityName // Community should Match
                                              AND Application__r.Add_to_App_Launcher__c = 'If user accepted T&C']) {
                                                  //Add only if user has also permission set assinged
                                                  if(permSetIdList.contains(userCons.Application__r.Permission_Set__c))
                                                      appList.add(userCons.Application__r);
                                              }
        
        for (REIDP_Application__c app : [SELECT Id, Name, 
                                         URL__c, 
                                         App_Icon__c
                                         FROM REIDP_Application__c 
                                         WHERE Add_to_App_Launcher__c = 'If user has permission' 
                                         AND Permission_Set__c in :permSetIdList
                                         AND Community__c = :communityName // Community should Match
                                         AND Is_Active__c = TRUE]) {
                                             appList.add(app);
                                         }
        return appList;
    }
    
}