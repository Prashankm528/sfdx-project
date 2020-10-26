/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company        
* @date 6/2017   
*
* This web service wraps the apex Site.createPortalUser method, to allow self registration via the API..
* Access to this WebService should be added to BP Identity Community Guest User’s Profile, so app can call it as an unauthenticated user.
*/
@RestResource(urlMapping='/IdPUser/*')
global class REIDP_UserResource {

    
    global class UserCreateRequest {
        public String firstname;
        public String lastname;
        public String country;
        public Boolean generalMarketing;
        public Boolean personalMarketing;
        public String language;
        public List<String> apps;
        public String legacyId;
        public String returnApp;
        
        public String title;
        public Date birthdate;
        public String addressStreet;
        public String addressCity;
        public String addresspostalCode;
        public String addressState;
        public String addressCountry;
        public String addressStreetLine2;
        
        // check for external community guest Profiles
        public String communityPath;
        
        //Social User Registration Field
        public Boolean socialUser {
            public get {
                if(socialUser == null)
                    socialUser = false;
                return socialUser;
            }    
            public set;
        }
        
        public List<REIDP_UserConsentResource.UserConsentCreateRequest> consents;
        
        //Email User Registration Fields
        public String email;
        public String phone;
        
        
        //Mobile User Registration Fields
        public Boolean mobileRegistration {
            public get {
                if(mobileRegistration == null)
                    mobileRegistration = false;
                return mobileRegistration;
            }    
            public set;
        }
        public String phoneCountryCode;
        public String phoneNumber;
        
        private String getGeneratedUsername() {
            return mobileRegistration ? REIDP_UserServices.formatMobileUsername(phoneCountryCode, phoneNumber) 
                : email;
        }
        
        private String getGeneratedPhone() {
            return mobileRegistration ? phoneCountryCode + phoneNumber
                : phone;
        }
        
    }
    
    global class UserCreateResponse {
        public String message;
        public String userId;
    }
    
    @HttpPost
    global static UserCreateResponse selfRegister(UserCreateRequest reqData) {
        RestContext.request.addHeader('Accept', 'application/json');
        RestContext.response.addHeader('Content-Type', 'application/json');
        UserCreateResponse ucr = new UserCreateResponse();
        try {
            ucr = noRestSelfRegister(reqData);
            
            RestContext.response.statuscode = 201;
        }
        catch(Exception ex) {
            RestContext.response.statuscode = (ex.getTypeName() == 'REIDP_UserResource.DuplicateException') ? 409 : 400;
            ucr.message = ex.getMessage();
            if(RestContext.response.statuscode != 409)
                REIDP_ErrorHandling.logWarningErrorLog(REIDP_UserResource.class, 'Error during user registration using API', ex);
        }
        return ucr;
    }
    
    public static UserCreateResponse noRestSelfRegister(UserCreateRequest reqData) {
        UserCreateResponse ucr = new UserCreateResponse();
        
            if(!isValidRequest(reqData))
                throw new JSONException('Bad Request');
            
            User u = createPortalUser(reqData);
            
            ucr.userId = u.Id;
            
            //Add Access to restricted apps if service user is defined on the App
            if(ucr.userId != null && reqData.apps != null) {
                List<REIDP_Application_Access_Request__c> accessRequests = new List<REIDP_Application_Access_Request__c>();
                
                for(REIDP_Application__c app : [SELECT Id,
                                                (SELECT Id 
                                                 FROM Application_Service_Users__r 
                                                 WHERE User__c = :UserInfo.getUserId())
                                                FROM REIDP_Application__c 
                                                WHERE Short_Name__c in :reqData.apps]) {
                                                    if(app.Application_Service_Users__r.size() > 0) {
                                                        
                                                        //Add Access Request with Status Approved, so that Trigger can pick that up and assign proper Permission Set
                                                        accessRequests.add(new REIDP_Application_Access_Request__c(Application__c = app.Id,
                                                                                                                   Status__c = 'Approved',
                                                                                                                   User__c = u.Id,
                                                                                                                   Contact__c = u.ContactId));     
                                                    }
                                                    
                                                }
            
                if(accessRequests.size() > 0)
                    insert accessRequests;
            }
            
            //Add Consents
            if(ucr.userId != null && reqData.consents != null && reqData.consents.size() > 0) {
                REIDP_Application__c app = [SELECT Connected_App__c FROM REIDP_Application__c WHERE Short_Name__c = :reqData.consents[0].appName];
                REIDP_UserConsentHelper.createUserConsent(reqData.consents, app.Connected_App__c, ucr.userId);
            }
       
        return ucr;
    }
        
    private static Set<String> getSupportedLanguages() {
        Set<String> supportedLanguages = new Set<String>();
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            supportedLanguages.add(picklistEntry.getValue());
        }
        return supportedLanguages;
    }
    
    private static Boolean isValidRequest(UserCreateRequest reqData) {
        //Check general required fields
        if(reqData == null || reqData.firstname == null || 
           reqData.lastname == null || reqData.getGeneratedUsername() == null)
            return false;
        return true;
    }
    
    public static User createPortalUser(UserCreateRequest reqData) {
        String username = reqData.getGeneratedUsername();
        User u;
        
        List<User> existingUsers = [SELECT Email, ContactId FROM User WHERE Email= :username];
        List<User> usersToUpdate = new List<User>();
        if (!existingUsers.isEmpty())  {
            //Suppress error only if API is executed by authenticated user
            if(!Test.isRunningTest() && UserInfo.getUserType() != 'Guest') {
                u = existingUsers.get(0);
                
                //Check if current user has access to update Legacy Id field
                if(Schema.SObjectType.User.fields.REIDP_Legacy_ID__c.isUpdateable()) {
                    u.REIDP_Legacy_ID__c = reqData.legacyId;
                    update u;
                }
            } 
            else {
                throw new DuplicateException(Label.BPDuplicateEmail);
            }
        }
        else {
            u = new User();
            u.Username = username;
            u.put('Email', username);
            u.FirstName = (reqData.firstname != null && reqData.firstname.length() > 0) ? reqData.firstname.capitalize() : '';
            u.LastName = reqData.lastname.capitalize();    
            u.put('Phone', reqData.getGeneratedPhone());
            u.REIDP_T_C_Accepted__c = System.now();
            u.REIDP_Privacy_Accepted__c  = System.now();
            u.REIDP_Country_Of_App__c = reqData.country;
            u.REIDP_Legacy_ID__c = reqData.legacyId;
            u.REIDP_Return_App__c = reqData.returnApp;
            
            u.Title = reqData.title;
            u.Street = reqData.addressStreet;
            u.City = reqData.addressCity;
            u.PostalCode = reqData.addressPostalCode;
            u.State = reqData.addressState;
            u.Country = reqData.addressCountry;
            u.Address_Line_2__c = reqData.addressStreetLine2;
            u.Birthdate__c = reqData.birthdate;
            
            
            if(reqData.generalMarketing != null) {
                u.REIDP_General_Marketing_Info__c = reqData.generalMarketing;
                u.REIDP_General_Marketing_TimeStamp__c = System.now();
            }
            
            if(reqData.personalMarketing != null) {
                u.REIDP_Personal_Marketing_Info__c = reqData.personalMarketing;
                u.REIDP_Personal_Marketing_TimeStamp__c = System.now();
            }
            
            if(reqData.language != null && getSupportedLanguages().contains(reqData.language)) {
                u.LanguageLocaleKey = reqData.language;
            }
            
            /*
            NONE OF DEFAULT METHODS WORK (as of API v43), if class is being called by authenticated user (Service Users). "You are already logged in" is being thrown.
            */
            //u = Site.createPortalUser(u, null, null);
            //u = Site.createPersonAccountPortalUser(u, '00558000003pclU', '01258000000FRwx', null);
            //u = Site.createExternalUser(u, null, null, false);
            //USER Creation Start
            
            //String adminId = Site.getAdminId();
            //Workaround to Support Communities where "IDP Admin" is not set as Community Admin
            String adminId = [SELECT Id, AdminId FROM Site WHERE Name = 'BP' LIMIT 1].AdminId;
            
            if(Test.isRunningTest()) {
                //Getting Admin Id of BP Community
                adminId = [SELECT Id, AdminId FROM Site WHERE Name = 'BP' LIMIT 1].AdminId;
            }

            Account a = new Account(RecordTypeId = REIDP_Constants.PERSON_ACCOUNT_RECORD_TYPE_ID, 
                                    FirstName = u.FirstName, 
                                    LastName = u.LastName, 
                                    PersonEmail = u.Email,
                                    OwnerId = adminId);
            
            insert a;

            a = [SELECT PersonContactId FROM Account WHERE Id = :a.Id];
            
            u.ContactId = a.PersonContactId;
            
            try {
                if (reqData.socialUser) {
                    u.profileId = [SELECT Id FROM Profile WHERE Name =: REIDP_Constants.GENERAL_IDP_PROFILE_NAME].Id;
                } else {
                    if (!String.isEmpty(reqData.communityPath))
                        u.ProfileId = [SELECT Id, SelfRegProfileId FROM Network WHERE UrlPathPrefix =:reqData.communityPath LIMIT 1].SelfRegProfileId;
                    else {
                        if(Network.getNetworkId() != null)
                            u.ProfileId = [SELECT Id, SelfRegProfileId FROM Network WHERE Id =:Network.getNetworkId() LIMIT 1].SelfRegProfileId;
                        else
                            u.ProfileId = [SELECT Id, SelfRegProfileId FROM Network WHERE UrlPathPrefix = :REIDP_Constants.DEFAULT_NETWORK_URL_PATH_PREFIX LIMIT 1].SelfRegProfileId;   
                    }
                }
            } catch(Exception ex) {
                REIDP_ErrorHandling.logCriticalErrorLog(REIDP_CommunityEmailController.class, 'Failed to get Community Path Prefix while retriving profile', ex);  
            }
            
            insert u;
            //User Creation End
        }
        
        return u;
    }
    
    public class DuplicateException extends Exception {}
}