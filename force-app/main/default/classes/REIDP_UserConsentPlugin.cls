/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 1/2019
 *
 * This web service that is used by External Applications to manage User Consents
 * 
 */
global class REIDP_UserConsentPlugin extends Auth.ConnectedAppPlugin {
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context)  {
        
        REIDP_UserConsentHelper.addUserConsentToCustomAttributes(userId, connectedAppId, formulaDefinedAttributes);
        
        return formulaDefinedAttributes;
    }
}