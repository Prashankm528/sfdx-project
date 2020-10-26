/**
* @author Neha
* @company Bluewolf, an IBM Company        
* @date 6/2020   
*
*
*/
@RestResource(urlMapping='/ThirdPartyToken/*')
global with sharing class REIDP_UberWebservice  {
    
    

  global class AuthRequest{
          public String authProvider;

     
       }
      @HttpPost
      global static String doPost(AuthRequest reqData) {
        String responseJson;
        String AuthProvider=reqData.authProvider;
        Map<String, Object> responseMap = new Map<String,Object>();
          string newAccessToken;
        try{
            AuthProvider authP= new AuthProvider();
            if(AuthProvider!=null && AuthProvider=='REIDP_Uber'){
            authP= [select id,FriendlyName,DeveloperName from AuthProvider where developername=:AuthProvider];
           
                String authProviderId=authP.id; 
                String AuthProviderName=authP.FriendlyName;
                String accessToken = Auth.AuthToken.getAccessToken(authProviderId, AuthProviderName);
               
                REIDP_Custom_Auth_Config__mdt CustomAuthConfig = [select User_Endpoint__c from REIDP_Custom_Auth_Config__mdt where DeveloperName =: AuthProvider];
                String userAPIUrl = CustomAuthConfig.User_Endpoint__c;
                

                    if(!Test.isRunningTest()){
                        Map<String, String> refreshToken = Auth.AuthToken.refreshAccessToken(authProviderId, AuthProviderName, accessToken);
                        responseMap = REIDP_UberAuthProvider.callUserapi(accessToken,userAPIUrl);
                        newAccessToken=refreshToken.get('AccessToken');
                    }
                    else{
                        responseMap.put('AccessToken',(Object)'accesstoken');
                        newAccessToken='Test';
                        
                    }
                   
                    
                    String driverid = (String)responseMap.get('driver_id');
                    responseJson='{';
                    responseJson+='"driver_id":'+'"'+driverid+'",';
                    responseJson+='"access_token":'+'"'+newAccessToken+'"}'; 
            }else{
                  responseJson='{';
                    responseJson+='"Bad Request":"Wrong Provider Value"';
                    responseJson+='}'; 
            }
          

         }catch(exception e){
           responseJson=e.getStackTraceString(); 
         }
        Return responseJson;
      }    
    

}