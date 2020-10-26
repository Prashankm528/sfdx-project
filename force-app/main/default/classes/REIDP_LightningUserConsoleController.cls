/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * Controller class for minimal User Console
 */
global class REIDP_LightningUserConsoleController {
    @AuraEnabled
    public static User getUserInformation() {
        return [SELECT Name, 
                	   Email, 
                	   Phone 
                FROM User 
                WHERE Id= :UserInfo.getUserId()];
    }
}