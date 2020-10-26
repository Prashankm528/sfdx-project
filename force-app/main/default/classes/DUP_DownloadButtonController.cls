/****************************************************************************************
*   Date:           10FEB2020
*   Author:         Arron Kukadia - IBM
*   Description:    Component to check the custom permission assigned to a user     
****************************************************************************************/

public class DUP_DownloadButtonController {
    @AuraEnabled 
    public static Boolean checkPermission(String permissionName){
        Boolean hasPermission = FeatureManagement.checkPermission(permissionName);
        return hasPermission;		
    }
}