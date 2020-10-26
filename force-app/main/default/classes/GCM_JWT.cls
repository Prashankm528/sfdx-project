/********************************************************************************
 * Date           : 24-SEP-2020
 * Author         : Sunny Yap
 * Description    : Method that generates JWT token for integration.
 * Modifications  : 
 * 24-SEP-2020    : SYAP - Initial
 ********************************************************************************/ 

public with sharing class GCM_JWT {
/********************************************************************************
 * Get JWT Token
 ********************************************************************************/ 
    @auraEnabled(cacheable=false)
    public static String getJWTToken(String alias, String aud, String iss, String sub, String tokenEndpoint) {                
        // Generate JWT Token
        Auth.JWT jwt = new Auth.JWT();
        jwt.setAud(aud); // URL Endpoint
        jwt.setIss(iss); // Consumer Key
        jwt.setSub(sub); // Username

        Auth.JWS jws = null;
        if (!Test.isRunningTest()) jws = new Auth.JWS(jwt, alias);
        Auth.JWTBearerTokenExchange bearer = null;
        if (!Test.isRunningTest()) bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        String token = '';
        if (!Test.isRunningTest()) token = bearer.getAccessToken();
        
        return token;
    }
}