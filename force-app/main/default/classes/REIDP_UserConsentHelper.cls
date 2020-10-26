/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 2/2019
*
* User Consent Management Helper Class
* 
*/
public class REIDP_UserConsentHelper {
    
    private static Boolean isUserConsentExecuted = false;
    
    //Sets default owner on User Consent to External Identity user related to the consent
    public static void setDefaultOwnerOnUserConsent(List<REIDP_User_Consent__c> newRecords) {
        for(REIDP_User_Consent__c uc : newRecords) {
            //Changes to allow creation of consent record without linking with User record
            if (uc.User__c != null) {
                uc.OwnerId = uc.User__c;
            }
            
        }
    }
    
    
    public static List<REIDP_User_Consent__c> createUserConsent(List<REIDP_UserConsentResource.UserConsentCreateRequest> reqData, String appName, String userId) {
        List<REIDP_User_Consent__c> consentsToInsert = new List<REIDP_User_Consent__c>();
        Map<String, REIDP_Application__c> apps = new Map<String, REIDP_Application__c>();
        Set<String> appsName = new Set<String>();
        
        User u = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        
        //Get all appName's if there are multiple in the request
        for (REIDP_UserConsentResource.UserConsentCreateRequest ucr : reqData) {
            appsName.add(ucr.appName);
        }
        
        String query = 'SELECT Id, Short_Name__c, Latest_Terms_Conditions_Version__c, Latest_Privacy_Policy_Version__c  ' +
            'FROM REIDP_Application__c ' +
            'WHERE Connected_App__c = :appName ' +
            ((appsName.size() > 0) ? 'AND Short_Name__c in :appsName' : '');
        
        for (REIDP_Application__c app : Database.query(query)) {
            apps.put(app.Short_Name__c, app);
        }
        
        for (REIDP_UserConsentResource.UserConsentCreateRequest ucr : reqData) {
            REIDP_User_Consent__c consent = new REIDP_User_Consent__c();
            consent.User__c = u.Id;
            consent.Application__c = apps.get(ucr.appName).Id;
            consent.Accepted__c = ucr.accepted;
            consent.Accepted_Time__c = System.now();
            consent.Type__c = ucr.consentType;
            consent.Channel__c = (ucr.channel != null) ? String.join(ucr.channel, ';') 
                : null;
            
            //Set latest T&C and PP version if it was not included in the request
            if(ucr.version == null) {
                if('Terms and Conditions'.equals(ucr.consentType))
                    consent.Version__c = apps.get(ucr.appName).Latest_Terms_Conditions_Version__c;        
                else if('Privacy Policy'.equals(ucr.consentType))
                    consent.Version__c = apps.get(ucr.appName).Latest_Privacy_Policy_Version__c;        
            } else
                consent.Version__c = ucr.version;
            
            consent.Contact__c = u.ContactId;
            consentsToInsert.add(consent);
        }
        
        List<Database.SaveResult> srList = Database.insert(consentsToInsert, false);
        
        //Handle gracefully cases where consent already exists.
        for (Database.SaveResult sr : srList) {
            for(Database.Error err : sr.getErrors()) {
                if(err.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                    //Throw exception if DML error is not caused by Duplicate Value
                    throw new UserConsentException(err.getMessage());
                }
            }
        }
        
        return consentsToInsert;
    }
    
    public static void addUserConsentToCustomAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes) {
        String appName;
        
        if(!Test.isRunningTest()) {
            List<ConnectedApplication> apps = [SELECT Name FROM ConnectedApplication WHERE Id = :connectedAppId];
            
            if(apps.size() == 0)
                return;
            
            appName = apps.get(0).Name;
        } else
            appName = 'TestApp';
        
        for(REIDP_User_Consent__c con : [SELECT Id, Accepted__c, Type__c, Version__c, User__c, 
                                         Application__r.Is_Multi_Region__c, 
                                         Application__r.Short_Name__c,
                                         Application__r.Latest_Terms_Conditions_Version__c,
                                         Application__r.Latest_Privacy_Policy_Version__c,
                                         Channel__c
                                         FROM REIDP_User_Consent__c
                                         WHERE User__c = :userId
                                         AND Application__r.Connected_App__c = :appName]) {
                                             switch on con.Type__c {
                                                 when 'Terms and Conditions' {
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'tc', String.valueOf(con.Accepted__c));
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'tc-latest-version', con.Application__r.Latest_Terms_Conditions_Version__c);
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'tc-accepted', con.Version__c);    
                                                 }   
                                                 when 'Privacy Policy' {
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'pp', String.valueOf(con.Accepted__c));
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'pp-latest-version', con.Application__r.Latest_Privacy_Policy_Version__c);
                                                     formulaDefinedAttributes.put(getRegionSafePrefix(con) + 'pp-accepted', con.Version__c);    
                                                 }
                                                 when else {
                                                     formulaDefinedAttributes.put(getConsentName(con), 'true' + getChannelList(con.Channel__c));    
                                                 }
                                             }
                                         }
    }
    
    public static void getConsentPlatformEvent(List<REIDP_User_Consent__c> newRecords, Map<Id, REIDP_User_Consent__c> oldRecords) {
        
        List<REIDP_User_Consent__c> consents = new List<REIDP_User_Consent__c>(); // temporary list for consents w/same app name
        List<REIDP_Platform_Event__e> platformEventList = new List<REIDP_Platform_Event__e>(); // list for platform events
        
        Map<Id, List<REIDP_User_Consent__c>> usersAndConsents = new Map<Id, List<REIDP_User_Consent__c>>(); // contains user id and consents related with that user
        Map<String, List<REIDP_User_Consent__c>> appConsentTempMap = new Map<String, List<REIDP_User_Consent__c>>(); // temporary map for consents 
        Map<String, List<REIDP_User_Consent__c>> appConsentMap = new Map<String, List<REIDP_User_Consent__c>>(); // map of App Name and related consents w/same app name
        Map<String, Map<String, List<REIDP_User_Consent__c>>> userAppConsentMap = new Map<String, Map<String, List<REIDP_User_Consent__c>>>(); // map of User ID and map of App Name and consents with same app name
        
        Set<String> userIds = new Set<String>(); // contains Users unique Ids
        Set<String> appShortNames = new Set<String>(); // contains unique app names that are used in trigger
        
        Set<String> enabledApps = new Set<String>();
        for(REIDP_Application__c app: [SELECT Id, Short_Name__c FROM REIDP_Application__c WHERE Generate_Platform_Events__c=True]) {
            enabledApps.add(app.Short_Name__c);
        }
        for(REIDP_User_Consent__c consent : newRecords) {
            if(enabledApps.contains(consent.Application_Short_Name__c)) {
                userIds.add(consent.User__c);
                appShortNames.add(consent.Application_Short_Name__c);
            }
        }
        
        // set for each user the list of consents it has
        for(User u :  [SELECT Id, Firstname, Lastname, 
                       (SELECT Id, Type__c, Channel__c, Accepted__c, Application_Short_Name__c, Version__c, User__c, Unique_ID__c 
                        FROM User_Consents__r
                        WHERE Id in :newRecords) 
                       FROM User
                       WHERE Id in :userIds
                       AND ContactId != NULL
                       AND IsPortalEnabled = TRUE]){          
                           usersAndConsents.put(u.Id, u.User_Consents__r);
                       }
        
        Boolean isChanged = true; // is used to check for no duplicates
        for (String uid : userIds) {
            for (String appName : appShortNames) {
                for (REIDP_User_Consent__c consent : usersAndConsents.get(uid)) {
                    consents = new List<REIDP_User_Consent__c>();
                    if (consent.Application_Short_Name__c.equalsIgnoreCase(appName) 
                        && consent.User__c == uid 
                        && ((Trigger.isUpdate && (consent.Accepted__c != oldRecords.get(consent.Id).Accepted__c || consent.Channel__c != oldRecords.get(consent.Id).Channel__c) && consent.Unique_ID__c == oldRecords.get(consent.Id).Unique_ID__c) 
                            || Trigger.isInsert)) {
                                consents.add(consent);
                                isChanged = true;
                            } else {
                                isChanged = false;
                            }
                }
                appConsentMap.put(appName, consents);
            }
            userAppConsentMap.put(uid, appConsentMap);
        }
        
        for (User u : [SELECT Id, Country, IsActive, FirstName, LastName, Phone, REIDP_Loyalty_Card__c, Birthdate__c, Street, City,
                       State, PostalCode, Email, 
                       Address_Line_2__c,
                       (SELECT Id, Type__c, Channel__c, Accepted__c, Application_Short_Name__c, Version__c
                        FROM User_Consents__r
                        WHERE Id in :newRecords) 
                       FROM User
                       WHERE Id in :userAppConsentMap.keySet()]) {
                           for (String appName : appShortNames) {
                               if (isChanged) {
                                   REIDP_Platform_Event__e peUserConsent = new REIDP_Platform_Event__e();
                                   peUserConsent.Event_Type__c = 'Consent';
                                   peUserConsent.User__c = u.Id;
                                   peUserConsent.Audience__c = appName;
                                   
                                   appConsentTempMap = userAppConsentMap.get(u.Id);
                                   u.User_Consents__r.addAll(appConsentTempMap.get(appName));
                                   Map<String,Object> JSONMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(u));
                                   stripJSON(JSONMap);
                                   for(String f: REIDP_UserServices.fieldsToCheck) {
                                       if(JSONMap.containsKey(f)) continue;
                                       JSONMap.put(f, u.get(f));
                                   }
                                   peUserConsent.JSON__c = JSON.serialize(JSONMap);
                                   platformEventList.add(peUserConsent);
                               }
                           }
                       }
        
        if (platformEventList.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(platformEventList);
        }
        
    }
    
    /************************************************************************ MIGRATION SCRIPTS START ******************************************************************************/
    public static void syncConsentFromUser(List<User> newRecords, Map<Id, User> oldRecords) {
        List<User> users = new List<User>();
        List<REIDP_User_Consent__c> consentsToUpdate = new List<REIDP_User_Consent__c>();
        List<REIDP_User_Consent__c> consentsToCreate = new List<REIDP_User_Consent__c>();
        List<REIDP_Application__c> apps = new List<REIDP_Application__c>();
        
        // contains a list of user Ids and User Consent objs
        Map<Id, List<REIDP_User_Consent__c>> usersAndConsents = new Map<Id, List<REIDP_User_Consent__c>>();
        
        // contains user id and map of consents related to that user
        Map<Id, Map<String, List<REIDP_User_Consent__c>>> finalUC = new Map<Id, Map<String, List<REIDP_User_Consent__c>>>();
        
        // contains type name and consents of that type
        Map<String, List<REIDP_User_Consent__c>> subUC = new Map <String, List<REIDP_User_Consent__c>>();
        
        List<String> pickListValuesList = new List<String>();
        
        // picklist values of User Consent Type field
        Schema.DescribeFieldResult fieldResult = REIDP_User_Consent__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        // check if user is Portal
        for(User u : newRecords) {
            if (u.ContactId != null && u.IsPortalEnabled) {
                users.add(u);
            }
        }
        
        //If no Portal User found => return
        if(users.size() == 0 || isUserConsentExecuted)
            return;
        else
            isUserConsentExecuted = true;
        
        // all BPMe apps
        for(REIDP_Application__c app : [SELECT Id, Name, Short_Name__c,
                                        Latest_Privacy_Policy_Version__c, 
                                        Latest_Terms_Conditions_Version__c
                                        FROM REIDP_Application__c
                                        WHERE Short_Name__c LIKE 'bpme%']) {
                                            apps.add(app);
                                        }
        
        // set for each user the list of consents it has
        for(User u : [SELECT Id, Name, 
                      (SELECT Id, Accepted__c, Application__c, Application_Short_Name__c, Channel__c, Contact__c, Type__c, Version__c 
                       FROM User_Consents__r) 
                      FROM User
                      WHERE Id in :users]) {
                          usersAndConsents.put(u.Id, u.User_Consents__r);
                      }
        
        // a map for each user with a map of consents by Type
        for (User u : users) {
            for (String cType : pickListValuesList) {
                List<REIDP_User_Consent__c> tempCons = new List<REIDP_User_Consent__c>();
                for (REIDP_User_Consent__c uc : usersAndConsents.get(u.Id)) {
                    if (cType.equals(uc.Type__c))
                        tempCons.add(uc);
                }
                subUC.put(cType, tempCons);
            }
            finalUC.put(u.Id, subUC);
        }
        
        for(User u : users) {
            
            if(Trigger.isUpdate && u.REIDP_Drive_Carbon_Neutral__c != oldRecords.get(u.Id).REIDP_Drive_Carbon_Neutral__c) {
                // Don't be scared by looking at:
                // finalUC.get(u.Id).get('Drive Carbon Neutral')
                // it gets a LIST of consents of current USER u by TYPE of consent
                if (finalUC.get(u.Id).get('Drive Carbon Neutral').isEmpty()) {
                    
                    for (REIDP_Application__c app : apps) {
                        if(app.Short_Name__c.toLowerCase() == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                           Accepted__c = u.REIDP_Drive_Carbon_Neutral__c, 
                                                                           User__c = u.Id,
                                                                           Type__c = 'Drive Carbon Neutral',
                                                                           Contact__c = u.ContactId));
                        }
                    }
                } else {
                    for (REIDP_User_Consent__c uc : finalUC.get(u.Id).get('Drive Carbon Neutral')) {
                        if(uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase())
                            consentsToUpdate.add(changeUC(uc, u.REIDP_Drive_Carbon_Neutral__c));
                    }
                }
            }
            
            if((Trigger.isInsert && u.REIDP_General_Marketing_Info__c) || (Trigger.isUpdate && u.REIDP_General_Marketing_Info__c != oldRecords.get(u.Id).REIDP_General_Marketing_Info__c)) {
                if (finalUC.get(u.Id).get('General Marketing').isEmpty()) {
                    for (REIDP_Application__c app : apps) {
                        if(app.Short_Name__c.toLowerCase() == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                           Accepted__c = u.REIDP_General_Marketing_Info__c, 
                                                                           Channel__c = 'Email',
                                                                           User__c = u.Id,
                                                                           Type__c = 'General Marketing',
                                                                           Contact__c = u.ContactId));
                        }
                    }
                } else  if (!finalUC.get(u.Id).get('General Marketing').isEmpty()) {
                    for (REIDP_User_Consent__c uc : finalUC.get(u.Id).get('General Marketing')) {
                        // if Channel is not null and contains 'Email' in it and app is proper
                        if (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            // if General Marketing is set to true (when there is already an 'Email' in channel) -- set Accepted to true
                            if (u.REIDP_General_Marketing_Info__c) {
                                uc.Accepted__c = true;
                                if (uc.Channel__c != null && !uc.Channel__c.contains('Email') ) {
                                    uc.Channel__c = 'Email;' + uc.Channel__c;
                                } else {
                                    uc.Channel__c = 'Email';
                                }
                                consentsToUpdate.add(uc);
                            } else {
                                uc.Accepted__c = false;
                                // if General Marketing is set to false -- remove from Channel 'Email'
                                // if Consent became null after removal set Accepted to false
                                if (!String.isEmpty(uc.Channel__c) && uc.Channel__c.contains('Email')) {
                                    uc.Channel__c.remove('Email');
                                }
                                consentsToUpdate.add(uc);
                            }
                        }
                    }
                }
            }
            
            if((Trigger.isInsert && u.REIDP_Personal_Marketing_Info__c) || (Trigger.isUpdate && u.REIDP_Personal_Marketing_Info__c  != oldRecords.get(u.Id).REIDP_Personal_Marketing_Info__c)) {
                if (finalUC.get(u.Id).get('Personal Marketing').isEmpty()) {
                    for (REIDP_Application__c app : apps) {
                        if(app.Short_Name__c.toLowerCase() == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                           Accepted__c = u.REIDP_Personal_Marketing_Info__c, 
                                                                           User__c = u.Id,
                                                                           Type__c = 'Personal Marketing',
                                                                           Contact__c = u.ContactId));
                        }
                    }	
                } else if (!finalUC.get(u.Id).get('Personal Marketing').isEmpty()) {
                    for (REIDP_User_Consent__c uc : finalUC.get(u.Id).get('Personal Marketing')) {
                        if (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase())
                            consentsToUpdate.add(changeUC(uc, u.REIDP_Personal_Marketing_Info__c));
                    }
                }
            }
            
            if((Trigger.isInsert && u.REIDP_Privacy_Accepted__c != null) || (Trigger.isUpdate && u.REIDP_Privacy_Accepted__c != oldRecords.get(u.Id).REIDP_Privacy_Accepted__c)) {
                if (finalUC.get(u.Id).get('Privacy Policy').isEmpty()) {
                    for (REIDP_Application__c app : apps) {
                        if(app.Short_Name__c.toLowerCase() == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            if(u.REIDP_Privacy_Accepted__c != null) {
                                consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                               Accepted__c = true,
                                                                               Accepted_Time__c = System.now(),
                                                                               User__c = u.Id,
                                                                               Type__c = 'Privacy Policy',
                                                                               Contact__c = u.ContactId,
                                                                               Version__c = app.Latest_Privacy_Policy_Version__c));
                            } else if (u.REIDP_Privacy_Accepted__c == null) {
                                consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                               Accepted__c = false,
                                                                               Accepted_Time__c = null,
                                                                               User__c = u.Id,
                                                                               Type__c = 'Privacy Policy',
                                                                               Contact__c = u.ContactId));
                            }
                        }
                    }	
                }
                else if (!finalUC.get(u.Id).get('Privacy Policy').isEmpty()) { 
                    for (REIDP_User_Consent__c uc : finalUC.get(u.Id).get('Privacy Policy')) {
                        if (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            if(u.REIDP_Privacy_Accepted__c != null)
                                consentsToUpdate.add(changeUC(uc, true));
                            if(u.REIDP_Privacy_Accepted__c == null)
                                consentsToUpdate.add(changeUC(uc, false));
                        }
                    }
                }
            }
            
            if((Trigger.isInsert && u.REIDP_T_C_Accepted__c != null) || (Trigger.isUpdate && u.REIDP_T_C_Accepted__c != oldRecords.get(u.Id).REIDP_T_C_Accepted__c)) {
                if (finalUC.get(u.Id).get('Terms and Conditions').isEmpty()) {
                    for (REIDP_Application__c app : apps) {
                        if(app.Short_Name__c.toLowerCase() == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            if(u.REIDP_T_C_Accepted__c != null) {
                                consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                               Accepted__c = true,
                                                                               Accepted_Time__c = System.now(),
                                                                               User__c = u.Id,
                                                                               Type__c = 'Terms and Conditions',
                                                                               Contact__c = u.ContactId,
                                                                               Version__c = app.Latest_Terms_Conditions_Version__c));
                            } else if (u.REIDP_T_C_Accepted__c == null) {
                                consentsToCreate.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                                                               Accepted__c = false,
                                                                               Accepted_Time__c = null,
                                                                               User__c = u.Id,
                                                                               Type__c = 'Terms and Conditions',
                                                                               Contact__c = u.ContactId));
                            }
                        }
                    }
                } else if (!finalUC.get(u.Id).get('Terms and Conditions').isEmpty()) {
                    for (REIDP_User_Consent__c uc : finalUC.get(u.Id).get('Terms and Conditions')) {
                        if (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                            if(u.REIDP_T_C_Accepted__c != null) 
                                consentsToUpdate.add(changeUC(uc, true));
                            if(u.REIDP_T_C_Accepted__c == null)
                                consentsToUpdate.add(changeUC(uc, false));
                        }
                    }
                }
            }
        }
        
        if (consentsToUpdate.size() > 0) {
            update consentsToUpdate;
        }
        
        if (consentsToCreate.size() > 0) {
            insert consentsToCreate;
        }
    }
    
    public static void syncConsentToUser(List<REIDP_User_Consent__c> newRecords, Map<Id, REIDP_User_Consent__c> oldRecords) {
        Set<Id> consentsId = new Set<Id>();
        Set<Id> usersId = new Set<Id>();
        Map<String, User> usersMap = new Map<String, User>();
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        
        // map of user and all of his consents
        Map<Id, List<REIDP_User_Consent__c>> usersAndConsents = new Map<Id, List<REIDP_User_Consent__c>>();
        
        // check if user is Portal
        for(REIDP_User_Consent__c uc : newRecords) {
            usersId.add(uc.User__c);
            consentsId.add(uc.Id);
        }
        
        for(User u : [SELECT Id, Name, 
                      REIDP_Country_of_App__c,
                      REIDP_General_Marketing_Info__c, 
                      REIDP_Drive_Carbon_Neutral__c, 
                      REIDP_Personal_Marketing_Info__c, 
                      REIDP_Opt_Out_of_Profiling__c,
                      REIDP_Privacy_Accepted__c, 
                      REIDP_T_C_Accepted__c, 
                      (SELECT Id, Accepted__c, Application__c, Application_Short_Name__c, Channel__c, Contact__c, Type__c, Version__c, User__c 
                       FROM User_Consents__r
                       WHERE Id in: consentsId) 
                      FROM User
                      WHERE Id in :usersId
                      AND ContactId != NULL
                      AND IsPortalEnabled = TRUE]) {
                          usersMap.put(u.Id, u);
                          usersAndConsents.put(u.Id, u.User_Consents__r);
                      }
        
        for (List<REIDP_User_Consent__c> collection : usersAndConsents.values())
            consentList.addAll(collection);
        
        if (consentList.size() == 0 || isUserConsentExecuted)
            return;
        else
            isUserConsentExecuted = true;
        
        for(REIDP_User_Consent__c uc : consentList) {
            if((Trigger.isInsert && uc.Accepted__c != null) || (Trigger.isUpdate && (uc.Accepted__c != oldRecords.get(uc.Id).Accepted__c || uc.Channel__c != oldRecords.get(uc.Id).Channel__c))) {
                for (User u : usersMap.values()) {
                    if (uc.Type__c.equals('General Marketing') && uc.User__c == u.Id && uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) {
                        if (uc.Channel__c != null && uc.Accepted__c && uc.Channel__c.contains('Email')) {
                            // if consent of GENERAL MARKENTING type does have Email in channel and is Accepted -- set consent to TRUE
                            u.REIDP_General_Marketing_Info__c = true;
                        } else {
                            // if consent of GENERAL MARKENTING type doesn't have Email in channel and is not Accepted -- set consent to FALSE
                            u.REIDP_General_Marketing_Info__c = false;
                        }
                    }
                    
                    if((uc.Type__c.equals('Drive Carbon Neutral'))  && (uc.User__c == u.Id) && (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) ) {
                        u.REIDP_Drive_Carbon_Neutral__c = uc.Accepted__c;
                        u.REIDP_Drive_Carbon_Neutral_Timestamp__c = System.now();
                    }
                    
                    if((uc.Type__c.equals('Personal Marketing')) && (uc.User__c == u.Id) && (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) ) { 
                        u.REIDP_Personal_Marketing_Info__c = uc.Accepted__c;
                        u.REIDP_Personal_Marketing_TimeStamp__c  = System.now();
                    }
                    
                    if((uc.Type__c.equals('Privacy Policy')) && (uc.User__c == u.Id) && (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) ) {
                        if(uc.Accepted__c)
                            u.REIDP_Privacy_Accepted__c = System.now();
                        else
                            u.REIDP_Privacy_Accepted__c = null;
                    }
                    
                    if((uc.Type__c.equals('Terms and Conditions')) && (uc.User__c == u.Id) && (uc.Application_Short_Name__c == ('bpme' + u.REIDP_Country_of_App__c).toLowerCase()) ) {
                        if(uc.Accepted__c)
                            u.REIDP_T_C_Accepted__c = System.now();
                        else
                            u.REIDP_T_C_Accepted__c = null;
                        
                    }
                }
            }
        }
        
        if (usersMap.size() > 0) {
            update usersMap.values();
        }
    }
    
    private static REIDP_User_Consent__c changeUC(REIDP_User_Consent__c uc, Boolean isAccepted) {
        uc.Accepted__c = isAccepted;
        if (isAccepted)
            uc.Accepted_Time__c = System.now();
        return uc;
    }
    /************************************************************************ MIGRATION SCRIPTS END ******************************************************************************/
    
    private static String getConsentName(REIDP_User_Consent__c consent) {
        return getRegionSafePrefix(consent) + consent.Type__c.toLowerCase().replace(' ', '-');
    }
    
    private static void stripJSON(Map<String,Object> jsonObj)  {
        for(String key : jsonObj.keySet()) {
            if(key == 'attributes') {
                jsonObj.remove(key);
            } else {
                if(jsonObj.get(key) instanceof Map<String,Object>) {
                    if(key == 'User_Consents__r') {
                        Map<String,Object> relationship = (Map<String,Object>)jsonObj.get(key);
                        if(relationship.get('records') instanceof List<Object>) {
                            List<Object> l = (List<Object>) relationship.get('records');
                            jsonObj.remove('User_Consents__r');
                            jsonObj.put('consents', l);
                            if(jsonObj.get('consents') instanceof List<Object>) {
                                for(Object listItem : (List<Object>)jsonObj.get('consents')) {
                                    if(listItem instanceof Map<String,Object>)  {
                                        Map<String,Object> m = (Map<String,Object>) listItem;
                                        if(m.containsKey('User__c')) {
                                            m.remove('User__c');
                                        }
                                        stripJSON((Map<String,Object>)listItem);
                                    }
                                }
                            }
                            continue;
                        }
                    }
                    stripJSON((Map<String,Object>)jsonObj.get(key));
                }
                if(jsonObj.get(key) instanceof List<Object>) {
                    for(Object listItem : (List<Object>)jsonObj.get(key)) {
                        if(listItem instanceof Map<String,Object>)  {
                            stripJSON((Map<String,Object>)listItem);
                        }
                    }
                }
            }
        }  
    }
    
    
    private static String getRegionSafePrefix(REIDP_User_Consent__c consent) {
        return (consent.Application__r.Is_Multi_Region__c) ? consent.Application__r.Short_Name__c + '-' : '';
    }
    
    private static String getChannelList(String channel) {
        return (channel == null) ? '' : ':' + channel;
    }
    
    public class UserConsentException extends Exception {}
}