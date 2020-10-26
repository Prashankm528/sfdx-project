/**
*
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 03/2019
*
**/

public class REIDP_ProfileController {
    
    @AuraEnabled
    public static User getUser() {
        User u = [SELECT Id, Name, Username, Email, Address, Title, Phone, MobilePhone
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        
        return u;
    }
}