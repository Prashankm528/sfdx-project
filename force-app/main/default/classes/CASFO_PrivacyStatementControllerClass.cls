/************************************************************************************************************
* Description : Controller for custom lightning commponent named "CASFO_Terms_And_Conditions" for providing
*               sales organisation of current user.
*				This controller is used temporarily in "Useful Links" component to show SIT link to only UK01
*				users. This is temporary untill proper SIT integration is implemented.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-OCT-19   1.0                 Maros Zilka         Initial version
* 2018-FEB-20   1.1                 Maros Zilka         Added getProfile() to support LCF/SFO with one controller
* 2019-JUL-10   1.2                 Adam Janicko        Added isOpenTextPilotCountry() to support OpenText functionality
*
*************************************************************************************************************/

public class CASFO_PrivacyStatementControllerClass {
    
    /************************************************************************
    * getSalesOrg
    * ------------------------
    * Method to get sales org of current user   
    ************************************************************************/
    @AuraEnabled
    public static String getSalesOrg() {
        return [SELECT Sales_Organisation__c FROM User WHERE Id = :UserInfo.getUserId()].Sales_Organisation__c;
    }
    
    /************************************************************************
    * getProfile
    * ------------------------
    * Method to get sales org of current user   
    ************************************************************************/
    @AuraEnabled
    public static String getProfile() {
        User user = [SELECT ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
        return [SELECT Name FROM Profile WHERE Id = :user.ProfileId].Name;
    }
    
    /************************************************************************
    * isOpenTextPilotCountry
    * ------------------------
    * Method to check whether given country is an Open Text pilot country 
    ************************************************************************/
    @AuraEnabled
    public static Boolean isOpenTextPilotCountry(String salesOrg) {
      return (database.countQuery('SELECT COUNT() FROM SFO_OpenText_Country__mdt WHERE DeveloperName = :salesOrg LIMIT 1') == 1 ? true : false);
    }
}