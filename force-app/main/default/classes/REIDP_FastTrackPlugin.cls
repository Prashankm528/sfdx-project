/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 9/2017
*
* Plugin for Fast Track Connected App, user to add custom attributes to SAML
*/
global class REIDP_FastTrackPlugin extends Auth.ConnectedAppPlugin{

    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context)  {  
        for(User u : [SELECT Id, ContactId, Contact.Account.Name, Contact.Account.BillingAddress, TimeZoneSidKey 
                      FROM User WHERE Id = :userId AND ContactId != NULL]) {
        
            String siteName = u.Contact.Account.Name;
            String strAddr = null;
            
            Address addr = u.Contact.Account.BillingAddress;
            if(addr != null) {
                strAddr = (addr.street + ', ' + 
                           addr.city + ', ' +
                           addr.postalcode).trim();
            }
            
            formulaDefinedAttributes.put('sitename', siteName);
            formulaDefinedAttributes.put('address', strAddr);
            formulaDefinedAttributes.put('timezone', u.TimeZoneSidKey);
        }
        return formulaDefinedAttributes;
    }

}