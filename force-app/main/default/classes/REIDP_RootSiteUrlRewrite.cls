/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 6/2017
 *
 * This class is responsible for URL rewriting on the subdomain root directory.
 */
global class REIDP_RootSiteUrlRewrite implements Site.UrlRewriter {
    
    public static final String PROJECT_PREFIX = 'REIDP_';
    
    public static final String ANDROID_URL = '/.well-known/assetlinks.json';
    public static final String IOS_URL = '/.well-known/apple-app-site-association';
    
    
    global PageReference mapRequestUrl(PageReference incoming) {
        String url = incoming.getUrl();
        if(url == IOS_URL)
            return Page.REIDP_IosUniversalLinks;
        else if(url == ANDROID_URL)
            return Page.REIDP_AndroidAssetLinks;
        
        PageReference pf = null;
        
        String pageName = PROJECT_PREFIX + (url.contains('?') ? url.substringBetween('/', '?') :
        														url.substringAfterLast('/'));
        
        //Checks if such visualforce page exists and only then creates a PageReference
        for(ApexPage page : [SELECT Id FROM ApexPage WHERE Name = :pageName LIMIT 1]) {
            pf = new PageReference(pageName);
        	pf.getParameters().putAll(incoming.getParameters());    
        }
        return pf;
    }
    
    global PageReference[] generateUrlFor(PageReference[] salesforceUrls) {
        for(PageReference pageRef :  salesforceUrls) {
            pageRef = this.mapRequestUrl(pageRef);
        }
        return salesforceUrls;
    } 
}