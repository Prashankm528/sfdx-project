/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 7/2017  
*
*
* User services class that adds default Permission Sets to User, using REIDP_Auto_Assigned_Permission_Set__mdt metadata type and Sync's Contact object
* 
*/
public without sharing class REIDP_UserServices {



    
    //Fetch Network Details
    private static Map<Id, Network> networks {
        get {
            if(networks == null) {
                networks = new Map<Id, Network>();
                for(Network n : [SELECT Id, SelfRegProfileId, UrlPathPrefix FROM Network LIMIT 10000]) {
                    networks.put(n.Id, n);
                }
            }
            return networks;
        }
        set;
    }
    
    public static String generateCommunityNickName(String firstName, String lastName){
        //Set Nickname Field
        String nickname = '';
        
        nickname += (firstName != null && firstName.length() > 0) ? firstName + '.' : '';
        nickname += lastName;
        
        if(nickname.length() > 25)
            nickname = nickname.substring(0, 24);
        nickname += System.now().getTime();
        return nickname;
    }
    
    public static String formatMobileUsername(String countryCode, String phoneNumber) {
        if(String.isBlank(phoneNumber) || String.isBlank(countryCode))
            return null;
        
        phoneNumber = phoneNumber.replaceAll('[^0-9]','');
        countryCode = countryCode.replaceAll('[^0-9]','');
        
        if(String.isBlank(phoneNumber) || String.isBlank(countryCode))
            return null;
        
        return countryCode + '.' + phoneNumber + REIDP_Constants.MOBILE_USERS_SUFFIX;
    }
    
    public static void setDefaultFields(List<User> newRecords){
        
        //Fetch default orgs values
        Organization org = REIDP_Constants.ORG_DEFAULTS;
        
        String defaultNetworkId = null;
        
        //For some reason "Map<String, Network>([SELECT Id, SelfRegProfileId, UrlPathPrefix FROM Network LIMIT 100])" does not work (As of API 43)
        for(Network n : networks.values()) {
            if(REIDP_Constants.DEFAULT_NETWORK_URL_PATH_PREFIX.equals(n.UrlPathPrefix))
                defaultNetworkId = n.Id;                
        }
        
        for(User u : newRecords) {
            if(u.ContactId != null) {
                
                //Set Default Community
                try {
                    if(Network.getNetworkId() != null) {
                        u.REIDP_Default_Community__c = networks.get(Network.getNetworkId()).UrlPathPrefix;
                    }
                    else
                        u.REIDP_Default_Community__c = REIDP_Constants.DEFAULT_NETWORK_URL_PATH_PREFIX;
                } catch(Exception ex) {
                    u.REIDP_Default_Community__c = REIDP_Constants.DEFAULT_NETWORK_URL_PATH_PREFIX;
                }
                
                if(String.isBlank(u.ProfileId)) {
                    u.ProfileId =  String.isBlank(Network.getNetworkId()) ? networks.get(defaultNetworkId).SelfRegProfileId 
                        : networks.get(Network.getNetworkId()).SelfRegProfileId;
                }
                
                if(String.isBlank(u.Alias)) {
                    u.Alias = (!String.isBlank(u.FirstName) ? u.FirstName.substring(0, 1) : '') +
                        ((u.LastName.length() > 4) ? u.LastName.substring(0, 4) : u.LastName);
                }
                
                //System.debug('Nickname:' + u.CommunityNickname);
                if(String.isBlank(u.CommunityNickname))
                    u.CommunityNickname = generateCommunityNickName(u.FirstName, u.LastName);
                //System.debug('Nickname:' + u.CommunityNickname);
                if(String.isBlank(u.TimeZoneSidKey))
                    u.TimeZoneSidKey  = org.TimeZoneSidKey;
                if(String.isBlank(u.LocaleSidKey))
                    u.LocaleSidKey  = org.DefaultLocaleSidKey;
                if(String.isBlank(u.EmailEncodingKey))
                    u.EmailEncodingKey  = 'UTF-8';
                if(String.isBlank(u.LanguageLocaleKey))
                    u.LanguageLocaleKey = org.LanguageLocaleKey;
            } 
        }
    }
    
    public static void capitilizeName(List<User> newRecords) {
        for(User u : newRecords) {
            if(u.ContactId != null) {
                u.FirstName = (u.FirstName != null && u.FirstName.length() > 0) ? u.FirstName.capitalize() : '';
                u.LastName = u.LastName.capitalize();
            }
        }
    }
    
    public static void checkUserDetailUpdate(List<User> newRecords, Map<Id, User> oldRecords) {
        Set<Id> userIds = new Set<Id>();
        for(User u : newRecords) {
            if (u.ContactId != null && u.IsPortalEnabled &&
                (u.Email != oldRecords.get(u.Id).Email ||
                 u.FirstName != oldRecords.get(u.Id).FirstName ||
                 u.LastName != oldRecords.get(u.Id).LastName ||
                 u.Phone != oldRecords.get(u.Id).Phone)) {
                     userIds.add(u.Id);
                 }
        }
        if(userIds.size() > 0)
            syncContactRecord(userIds);
    }
    
    public static void checkEmailChangeForVerification(List<User> newRecords, Map<Id, User> oldRecords) {
        Map<String, User> userMap = new Map<String, User>();
        Set<Id> profileIds = new Set<Id>();
        for(REIDP_Email_Verification__mdt emailVer : [SELECT Profile_Id__c 
                                                      FROM REIDP_Email_Verification__mdt]) {
                                                          profileIds.add(emailVer.Profile_Id__c);
                                                      }
        
        for(User u : newRecords) {
            if(u.IsPortalEnabled && 
               (profileIds.contains(u.ProfileId) || Test.isRunningTest()) && 
               u.Email != oldRecords.get(u.Id).Email && 
               u.Email != u.REIDP_Verified_Email__c) {
                   u.REIDP_New_Email_Verification_Code__c = REIDP_EmailVerification.generateRandomString(36);
                   u.REIDP_New_Email__c = u.Email;
                   u.REIDP_New_Email_TimeStamp__c = System.now();
                   u.Email = oldRecords.get(u.Id).Email;
                   userMap.put(u.REIDP_New_Email__c, u);
               }
        }
        if(userMap.size() > 0) {
            for(User u : [SELECT Email FROM User WHERE Email in :userMap.keySet()]) {
                //Record might be aleady removed if this email is user by more that one Internal User
                if(userMap.get(u.Email) != null) {
                    userMap.get(u.Email).addError('User with this email already exists');
                    userMap.get(u.Email).REIDP_New_Email__c = null;
                    userMap.get(u.Email).REIDP_New_Email_Verification_Code__c = null;
                    userMap.remove(u.Email);
                }
            }
        }
        
        REIDP_EmailVerification.usersWithEmailChange = new Map<String, String>();
        for(User u :  userMap.values()) {
            REIDP_EmailVerification.usersWithEmailChange.put(u.Id, u.REIDP_New_Email__c);
        }
    }
    
    public static void sendEmailVerificationEmail() {
        if(REIDP_EmailVerification.usersWithEmailChange != null &&
           REIDP_EmailVerification.usersWithEmailChange.size() > 0)
            REIDP_EmailVerification.sendVerificationCode(REIDP_EmailVerification.usersWithEmailChange);
        
        
    }
    
    public static void setGeneralIDPProfileForUser(String uid) {
        String profileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
        User u = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :uid];
        
        /*
         * FASTLANE NO MFA FIX
         * Users with Fastlane Permission Set will not be moved to General Profile with MFA as they are phone number users and can not receive MFA to email
        */
        
        //Check if user has Fastlane Permission Set assigned
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name LIKE '%Fastlane%' AND AssigneeId = :u.Id];
		
        //Fastlane User => do not change profile
        if(psa.size() > 0) {
            return;
        }
        
        /*
         * FASTLANE NO MFA FIX END
        */
        
        if(u.ProfileId != profileId) {
            for(String pName : REIDP_Constants.SET_OF_WELCOME_PROFILE_NAMES) {
                if(u.Profile.Name == pName) {
                    update new User(Id = uid,
                                    ProfileId = profileId);
                    break;
                } 
            }
        }
    } 
    
    public static void assignDefaultPermissionSetsOnProfileChange(List<User> newRecords, Map<Id, User> oldRecords) {
        Set<Id> userIds = new Set<Id>();
        for(User u : newRecords) {
            if(u.ProfileId != oldRecords.get(u.Id).ProfileId) {
                userIds.add(u.Id);
            }
        }
        if(userIds.size() > 0)
            assignDefaultPermissionSets(userIds);
    }
    
    private static void assignDefaultPermissionSets(Set<Id> userIdSet) {
        List<REIDP_Auto_Assigned_Permission_Set__mdt> pSets = [SELECT Id,
                                                               DeveloperName,
                                                               Permission_Set_Id__c,
                                                               User_Profile_Id__c
                                                               FROM REIDP_Auto_Assigned_Permission_Set__mdt];
        List<PermissionSetAssignment> pSetAssignment = new List<PermissionSetAssignment>();
        for(User u : [SELECT Id,
                      ProfileId,
                      ContactId
                      FROM User
                      WHERE Id in :userIdSet
                      AND IsActive = TRUE]) {
                          for(REIDP_Auto_Assigned_Permission_Set__mdt pSet : pSets) {
                              if(pSet.User_Profile_Id__c == u.ProfileId ||
                                 pSet.User_Profile_Id__c == null) {
                                     pSetAssignment.add(new PermissionSetAssignment(AssigneeId = u.id,
                                                                                    PermissionSetId = pSet.Permission_Set_Id__c));   
                                 }
                          }
                          
                      }
        if(pSetAssignment.size() > 0)
            insert pSetAssignment;
    }
    
    public static void setPasswordAndSendSMSToMobileUser(List<User> users) {
        List<User> usersToProcess = new List<User>();
        
        for(User u : users) {
            if(u.Username.endsWith(REIDP_Constants.MOBILE_USERS_SUFFIX)) {
                usersToProcess.add(u);
            }
        }
        if(usersToProcess.size() > 0) {
            REIDP_ResetMobileUserPassword resetPassword = new REIDP_ResetMobileUserPassword(usersToProcess);
            ID jobID = System.enqueueJob(resetPassword);
        }
    }
    
    @future
    public static void syncContactRecord(Set<Id> userIds) {
        List<Contact> updateContacts = new List<Contact>();
        
        for(User u : [SELECT Id, FirstName, LastName, Email, Phone, ContactId FROM User WHERE Id in: userIds]) {
            if(u.ContactId != null) {
                updateContacts.add(new Contact(Id = u.ContactId,
                                               Email = u.Email,
                                               FirstName = u.FirstName,
                                               LastName = u.LastName,
                                               Phone = u.Phone));
            }
        }
        if(updateContacts.size() > 0)
            update updateContacts;
    }
    
    
    public static void setUserOnContact(Set<Id> userIdSet) {
        Set<Id> uIds = new Set<Id>();
        for(User u : [SELECT Id
                      FROM User WHERE Id in :userIdSet
                      AND ContactId != null AND Profile.Name like 'RE IDP %']) {
                          uIds.add(u.Id);
                      }
        if(uIds.size() > 0)
            futureSetUserOnContact(uIds);
    }
    
    @future
    public static void futureSetUserOnContact(Set<Id> userIdSet) {
        List<Account> aList = new List<Account>();
        List<Contact> cList = new List<Contact>();
        for(User u : [SELECT Id, Profile.Name, ContactId, Contact.AccountId
                      FROM User WHERE Id in :userIdSet
                      AND ContactId != null AND Profile.Name like 'RE IDP %']) {
                          aList.add(new Account(Id = u.Contact.AccountId, 
                                                Integration_ID__c = u.Id));
                          cList.add(new Contact(Id = u.ContactId,
                                                REIDP_User__c = u.Id));
                      }
        if(aList.size() > 0)
            update aList;
        if(cList.size() > 0)
            update cList;
    }
    
    public static  List<String> fieldsToCheck = new List<String>{'Country', 'IsActive', 'FirstName', 'LastName', 'Phone', 'REIDP_Loyalty_Card__c', 
        'Email', 'Birthdate__c',
        'Street', 'City', 'State', 'PostalCode', 'Address_Line_2__c'};
            /**
* Generates a new Platform Event when at least one of the fields specified is changed.
* Generated Event contains all the fields of interest and not only the changed field.
*/
             public static void generateUserEventsOnUpdate(Set<Id> userIdSet, Map<Id, User> oldUsers) {
                    List<REIDP_Platform_Event__e> eventsToGenerate = new List<REIDP_Platform_Event__e>();
                    Set<String> enabledApps = new Set<String>();
                    // collect application which have 'generate platform event' enabled
                    for(REIDP_Application__c app: [SELECT Id, Short_Name__c FROM REIDP_Application__c WHERE Generate_Platform_Events__c=True]) {
                        enabledApps.add(app.Short_Name__c);
                    }
                    
                    for(User u : [SELECT Id, FirstName, LastName, Country, IsActive, Phone, REIDP_Loyalty_Card__c, Birthdate__c, Street, City,
                                  State, PostalCode, Email,
                                  Address_Line_2__c,
                                  (SELECT Id, Application_Short_Name__c FROM User_Consents__r WHERE Accepted__c=True
                                   AND Type__c='Terms and Conditions' AND Application_Short_Name__c in :enabledApps
                                  )
                                  FROM User WHERE Id in :userIdSet
                                  AND Profile.Name like 'RE IDP %' AND REIDP_T_C_Accepted__c !=:null]) {
                                      Map<String, Object> jsonMap = new Map<String, Object>();
                                      Boolean changed = false;
                                      for (String fieldPath: fieldsToCheck) {
                                          if (u.get(fieldPath) != oldUsers.get(u.Id).get(fieldPath)) {
                                              // one of the fields change, add all to json map
                                              changed = true;
                                          }
                                      }
                                      if (!changed) {continue;}
                                      for (String fieldPath: fieldsToCheck) {
                                          jsonMap.put(fieldPath, u.get(fieldPath));
                                      }
                                      
                                      jsonMap.put('Id', u.get('Id'));
                                      
                                      String audience = '';
                                      for (REIDP_User_Consent__c c: u.User_Consents__r) {
                                          if(enabledApps.contains(c.Application_Short_Name__c)) {
                                              if(audience == '') {
                                                  audience = c.Application_Short_Name__c;
                                              } else {
                                                  audience += ';'+c.Application_Short_Name__c;
                                              }
                                          }
                                      }
                                      
                                      // no active audience is interested in this event, don't generate it
                                      if (audience == '') continue;
                                      
                                      eventsToGenerate.add(new REIDP_Platform_Event__e(Event_Type__c='User',
                                                                                       User__c =u.Id,
                                                                                       Audience__c=audience,
                                                                                       JSON__c=JSON.serialize(jsonMap)
                                                                                      ));
                                  }
                    
                    List<Database.SaveResult> results = EventBus.publish(eventsToGenerate);
                }
                
    // returns empty string when phone contains no digits
    public static String formatPhoneNumber(String phone) {
        if(phone == null) return '';
        // remove all non-numerics
        phone = phone.replaceAll('\\D','');
        
        return phone;
    }
    
    // returns empty string when countryCode contains only zeroes
    public static String formatCountryCode(String countryCode) {
        if(countryCode == null) return '';
        // remove all non-numerics
        countryCode = countryCode.replaceAll('\\D','');
        while(countryCode.startsWith('0') && countryCode.length() > 1) {
            countryCode = countryCode.substring(1);
        }
        
        if(countryCode == '0') return '';
        
        return countryCode;
    }
}