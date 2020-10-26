/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 * A test class for REIDP_RootSiteUrlRewrite
 */
@IsTest 
public class REIDP_RootSiteUrlRewriteTest {
	@IsTest
    public static void testGenerateUrlFor() {
        REIDP_RootSiteUrlRewrite rsur = new REIDP_RootSiteUrlRewrite();
        List<PageReference> prList = new List<PageReference>();
        prList.add(new PageReference('/.well-known/assetlinks.json'));
        prList.add(new PageReference('/.well-known/apple-app-site-association'));
        prList.add(new PageReference('/.well-known/custom'));
        rsur.generateUrlFor(prList);
    }
    
    @IsTest
    public static void testMapRequestUrlIos() {
        REIDP_RootSiteUrlRewrite rsur = new REIDP_RootSiteUrlRewrite();
        PageReference pRef = rsur.mapRequestUrl(new PageReference('/.well-known/apple-app-site-association'));
        System.assertEquals(Page.REIDP_IosUniversalLinks.getUrl(), pRef.getUrl());
    }
    
    @IsTest
    public static void testMapRequestUrlAndroid() {
        REIDP_RootSiteUrlRewrite rsur = new REIDP_RootSiteUrlRewrite();
        PageReference pRef = rsur.mapRequestUrl(new PageReference('/.well-known/assetlinks.json'));
        System.assertEquals(Page.REIDP_AndroidAssetLinks.getUrl(), pRef.getUrl());
    }
    
    @IsTest
    public static void testMapRequestUrlVisualforce() {
        REIDP_RootSiteUrlRewrite rsur = new REIDP_RootSiteUrlRewrite();
        PageReference pRef = rsur.mapRequestUrl(new PageReference('/changepassword'));
        System.assertEquals('REIDP_changepassword', pRef.getUrl());
    }
}