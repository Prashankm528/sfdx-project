/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * REIDP_CommunityEmailController Class that helps Email templates to generate merge fields
 * 
 */
public class REIDP_CommunityEmailController {
    public static String NETWORK_URL_PATH_PREFIX {public get; public set;}
    
    public static String defaultCommunity {
        public get;
        public set {
            defaultCommunity = value;
            if(defaultCommunity != null && NETWORK_URL_PATH_PREFIX != null && defaultCommunity != NETWORK_URL_PATH_PREFIX) 
                throw new EmailException('Welcome Email was already sent by Default community');
        }
    }
    
    public String cId {get;set;}
    public static String forgotPasswordUrl {
        public get {
            return communityBaseUrl + '/s/login/ForgotPassword';
        }
        private set;
    }
    
    public static String selfRegisterUrl {
        public get {
            return communityBaseUrl + '/s/login/SelfRegister';
        }
        private set;
    }
    
    public String userCountry {
        get {
            if(userCountry == null && cId != null) {
                try {
                    User u = [SELECT Id, REIDP_Country_Of_App__c, Profile.Name FROM User WHERE ContactId = :cId LIMIT 1];
                    if(u.Profile.Name == 'RE IDP External Identity FastTrack')
                        userCountry = 'AU';
                    else
                        userCountry = u.REIDP_Country_Of_App__c;
                } catch(Exception ex){}
            }
            if(userCountry == null)
                userCountry = 'NULL';
            return userCountry;
        }
        public set;
    }
    
    public static String communityBaseUrl {
        get {
            if(communityBaseUrl == null) {
                try {
                    Network n;
                    if(Network.getNetworkId() != null)
                        n = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
                    else
                        n = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = :NETWORK_URL_PATH_PREFIX LIMIT 1];
                    
                    URL uri = new URL(Network.getLoginUrl(n.Id));
                    
                    communityBaseUrl = 'https://' + uri.getHost();

                    if(uri.getPath().startsWith('/' + n.UrlPathPrefix + '/'))
                        communityBaseUrl += '/' + n.UrlPathPrefix;
                } catch(Exception ex) {
                    REIDP_ErrorHandling.logCriticalErrorLog(REIDP_CommunityEmailController.class, 'Failed to get Community absolute URL while sending email', ex);  
                }
            }
            return communityBaseUrl;
        }
        private set;
    }
    
    public static Map<String, String> customMergeFields {
        get {
            if(customMergeFields == null)
                customMergeFields = new Map<String, String>{'webservice' => 'New Service Name'};
            return customMergeFields;
        }
        private set;
    }
    
     public static String communityName {
         get {
             try {
                 Network n;
                 if(Network.getNetworkId() != null)
                     n = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
                 else
                     n = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = :NETWORK_URL_PATH_PREFIX LIMIT 1];
                 
                 return REIDP_Constants.COMMUNITY_NAMES.get(n.UrlPathPrefix);
             } catch(Exception ex) {
                 REIDP_ErrorHandling.logCriticalErrorLog(REIDP_CommunityEmailController.class, 'Failed to get Community Network Name while sending email', ex);  
             }
             return null;
         }
         private set;
    }
}