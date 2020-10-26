/*
* Custom links aura controller, renders configured internal or external links.
*/
public class SFO_CustomLinksController {
    @TestVisible
    private static SFO_CustomLinksService LinkService = new SFO_CustomLinksService();

    /*
    * returns current active links and current user info.
    * @param config the unique identifier that links records for a particular component.
    * @param names return only specific links, uses developer name.
    */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getCustomLinksData(String config, List<String> names) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            User currentUser = LinkService.getUserInfo(UserInfo.getUserId());

            //aura does not support sets so must convert it from a list.
            List<SFO_Custom_Link__mdt> links = LinkService.getCustomLinks(config, new Set<String>(names));
            response.put('currentUser', currentUser);
            response.put('links', LinkService.filter(currentUser.Sales_Organisation__c,currentUser.Business_Unit__c,  links));
            

        } catch(System.Exception ex) {
            //to capture errors in aura....
            AuraHandledException error = new AuraHandledException(ex.getMessage());
            error.initCause(ex);

            throw error;
        }

        return response;
    }
}