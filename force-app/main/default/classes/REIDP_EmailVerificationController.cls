/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * Controller for REIDP_EmailVerification page that validates requests and updates user object on success.
 * 
 */
public class REIDP_EmailVerificationController {
    public PageReference checkCode() {
        String userId = ApexPages.currentPage().getParameters().get('uid');
        String code = ApexPages.currentPage().getParameters().get('code');
        String newEmail = ApexPages.currentPage().getParameters().get('email');
        if(userId == UserInfo.getUserId() && code != null && newEmail != null) {
            try {
                User u = [SELECT Id, Email, REIDP_New_Email__c, REIDP_New_Email_Verification_Code__c
                          FROM User 
                          WHERE Id = :userId 
                          AND REIDP_New_Email_Verification_Code__c = :code 
                          AND REIDP_New_Email__c = :newEmail];
                u.Email = u.REIDP_New_Email__c;
                u.REIDP_Verified_Email__c = u.REIDP_New_Email__c;
                u.Username = u.REIDP_New_Email__c;
                update u;
                return null;
            }
            catch(Exception ex){
                REIDP_ErrorHandling.logWarningErrorLog(REIDP_EmailVerificationController.class, 'Failed to update users new email address', ex);
            }
        }
        return new PageReference('/?retUrl=' + ApexPages.currentPage().getUrl().replace('reidp_emailverification','emailverification'));
    }
}