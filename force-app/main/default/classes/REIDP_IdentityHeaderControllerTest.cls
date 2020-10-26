/**
 * 
 * @author Anna Mokhubova
 * @company Bluewolf, an IBM Company
 * @date 02/2019
 *
 **/

@isTest
public class REIDP_IdentityHeaderControllerTest {
    
    @isTest
    public static void testfetchCommunityUrls() {
        System.assertEquals('', REIDP_IdentityHeaderController.fetchCommunityUrls().baseURL);
        System.assertEquals('', REIDP_IdentityHeaderController.fetchCommunityUrls().homeURL);
        System.assertEquals('', REIDP_IdentityHeaderController.fetchCommunityUrls().profileURL);
    }
}