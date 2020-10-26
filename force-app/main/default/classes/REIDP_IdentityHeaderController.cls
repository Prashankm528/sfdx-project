/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 02/2019
*
*/
public with sharing class REIDP_IdentityHeaderController {
    
    public class CommunityUrls {
        @AuraEnabled
        public String baseURL;
        @AuraEnabled
        public String homeURL;
        @AuraEnabled
        public String profileURL;
    }
    
    @AuraEnabled
    public static CommunityUrls fetchCommunityUrls() {
        CommunityUrls cu = new CommunityUrls();
        cu.baseURL = Network.getNetworkId() == null ? '' : Site.getBaseUrl();
        cu.homeURL = Network.getNetworkId() == null ? '' : Network.communitiesLanding().getUrl();
        cu.profileURL = Network.getNetworkId() == null ? '' : (Network.communitiesLanding().getUrl() + 'profile/' + UserInfo.getUserId());
        return cu;
    }
}