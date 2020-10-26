/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 4/2018
 *
 * This Controller is used by REIDP_UserService page to trigger User changes on behalf on Guest User.
 */
public class REIDP_UserServiceController {
    static Integer tries = 3;
    
    public class HTTPException extends Exception{}
    
    public PageReference processRequest() {                
        String uid = ApexPages.currentPage().getParameters().get('userId');
        
        if(uid != null) {
            REIDP_UserServices.setGeneralIDPProfileForUser(uid);
        }
        return new PageReference('/');
    }
    
    public static void updateUsersIDPProfile() {
        try {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setTimeout(40000); //Increased timeout, as it sometimes failed with read timeouts in production
            httpRequest.setEndpoint(getBaseURL() + Page.REIDP_UserService.getUrl() + '?userId=' + UserInfo.getUserId());
            
            if(!Test.isRunningTest()) {
                HttpResponse httpResponse = new Http().send(httpRequest);
            }
        } catch (Exception ex) {
            // WORKAROUND on retry connection issue with timeout
            tries--;
            if (tries > 0) {
                REIDP_UserServiceController.updateUsersIDPProfile();
            }
            
            // if none of the retry connections issues did not proceed further -- throw an exception.
            if (tries == 0) {
                REIDP_ErrorHandling.logCriticalErrorLog(REIDP_UserServiceController.class, 'Error updating users profile', ex);
                throw new HTTPException(ex.getMessage());
            }
        }
    }
    
        
    public static String getBaseURL() {
        Network n = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = :REIDP_Constants.DEFAULT_NETWORK_URL_PATH_PREFIX LIMIT 1];
        URL uri = new URL(Network.getLoginUrl(n.Id));
        String communityBaseUrl = 'https://' + uri.getHost();
        if(uri.getPath().startsWith('/' + n.UrlPathPrefix + '/'))
            communityBaseUrl += '/' + n.UrlPathPrefix;
        return communityBaseUrl;
    }
    
}