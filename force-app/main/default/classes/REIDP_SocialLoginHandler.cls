/**
*
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 03/06/2019
*
**/
global class REIDP_SocialLoginHandler implements Auth.RegistrationHandler {
    
    global boolean canCreateUser(Auth.UserData data) {
        return (data != null 
                && data.email != null
                && data.lastName != null
                && data.firstName != null);
    }
    
    /**
    * Create the User - A required method to implement the Handler Interface
    * 
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    * 
    * @return User that has been initialized
    **/ 
    global User createUser(Id portalId, Auth.UserData data) {
        if(!canCreateUser(data)) {
            return null;
        }
        // Is this a Community Context?
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            String networkName;
            if(Test.isRunningTest())
                networkName = 'BP';
            
            try {
                Network n = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = : data.attributeMap.get('sfdc_networkid')];
                networkName = n.UrlPathPrefix;
            } catch(Exception e) {
                //Do Nothing
            }
            List<User> existingUsers = [SELECT Id FROM User WHERE Username =:data.email and IsActive = true and Profile.Name LIKE 'RE IDP External%'];
            User u;
            if (existingUsers.size() == 0) {
                String body;
                HttpRequest req = new HttpRequest();

                String lang = 'en';
                if(data.locale=='pl'){
                    lang = 'pl';   
                }

                body = '{"reqData" : {"firstname":"' + data.firstname + '","lastname":"' + data.lastname + '","email":"' + data.email + '","language":"' + lang + '","socialUser":true}}';
                
                req.setbody(body);       
                
                req.setHeader('Content-Type','application/json');
                
                req.setMethod('POST'); 
                req.setEndpoint(REIDP_CommunityEmailController.communityBaseUrl + '/services/apexrest/IdPUser');
                
                Http http = new Http(); 
                HTTPResponse res = http.send(req); 
                
                REIDP_UserResource.UserCreateResponse response = (REIDP_UserResource.UserCreateResponse) JSON.deserialize(res.getBody(), REIDP_UserResource.UserCreateResponse.class);
                u = [SELECT Id FROM User WHERE Id = :response.userId];
            } else {
                u = existingUsers.get(0);
            }
             
            return u;      

        } else {
            return null;
        }
    }
    
    /**
    * Update the user
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    **/     
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User u = new User(id = userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        
        update(u);
    }

}