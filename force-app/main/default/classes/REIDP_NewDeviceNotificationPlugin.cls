/**
* @author Ragim Ragimov
* @company Bluewolf, an IBM Company
* @date 7/2017
*
* A Flow Plugin used to detect New Devices user uses to log in to Community
*/
global class REIDP_NewDeviceNotificationPlugin implements Process.Plugin {    
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
            new Process.PluginDescribeResult.InputParameter('LoginFlow_UserAgent', Process.PluginDescribeResult.ParameterType.STRING, false),
                new Process.PluginDescribeResult.InputParameter('LoginFlow_Platform', Process.PluginDescribeResult.ParameterType.STRING, false),
                new Process.PluginDescribeResult.inputParameter('Email_Address', Process.PluginDescribeResult.ParameterType.STRING, false),
                new Process.PluginDescribeResult.inputParameter('Email_Template', Process.PluginDescribeResult.ParameterType.STRING, false)
                };
                    result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
                        new Process.PluginDescribeResult.OutputParameter('NewDevice',
                                                                         Process.PluginDescribeResult.ParameterType.Boolean)
                            };
                                return result;
    }
    
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Boolean firstDevice = false;
        Boolean knownDevice = false;
        
        String deviceUAFull = (String) request.inputParameters.get('LoginFlow_UserAgent');
        String devicePlatform = (String) request.inputParameters.get('LoginFlow_Platform');
        String emailFrom = (String) request.inputParameters.get('Email_Address');
        String emailTemplate = (String) request.inputParameters.get('Email_Template');
        String deviceUA = deviceUAFull;
        
        Pattern uaPlatform = Pattern.compile('\\(([^(]*)\\)');
        Matcher uaPlatformMatcher = uaPlatform.matcher(deviceUAFull);
        if(uaPlatformMatcher.find())
            deviceUA = uaPlatformMatcher.group(1);
        
        //Get additional login parameters
        LoginHistory loginInfo;
        try {
            loginInfo = [SELECT Id, Application, Browser, CountryIso, LoginTime, LoginType, Platform, SourceIp, Status
                         FROM LoginHistory 
                         WHERE UserId = :UserInfo.getUserId() ORDER BY LoginTime DESC LIMIT 1];
        } catch(Exception ex) {
            loginInfo = new LoginHistory();
        }
        
        String deviceId = devicePlatform + '!' + deviceUA + '!' + ((loginInfo.Application == 'Browser') ? loginInfo.Browser : loginInfo.Application);
        Map<String, Object> result = new Map<String, Object>();
        
        String userId = UserInfo.getUserId();
        User user = [select Id, Name, REIDP_Default_Community__c, Username, REIDP_Devices__c, Email from User where Id = :userId];
        
        Map<String, DateTime> deviceDateMap = null;
        if (user.REIDP_Devices__c == null || user.REIDP_Devices__c == '') {
            deviceDateMap = new Map<String, DateTime>();   
            firstDevice = true;
        }
        else {
            try {
                deviceDateMap = (Map<String, DateTime>) JSON.deserialize(user.REIDP_Devices__c, Map<String, DateTime>.class);
            }
            catch(Exception ex) {
                //In case someone manually edited the field and deserialization failed
                deviceDateMap = new Map<String, DateTime>();
                firstDevice = true;
            }
        }
        
        Set<String> devices = deviceDateMap.keySet();
        
        if (devices.contains(deviceId)) {
            result.put('NewDevice', false);
            deviceDateMap.put(deviceId, DateTime.now());
            knownDevice = true;
        } 
        else {
            result.put('NewDevice', true);
            
            //Delete device that wasn't used
            if(devices.size() >= 150) {
                List<DateTime> dates = deviceDateMap.values();
                dates.sort();
                for (String d: devices) {
                    if (deviceDateMap.get(d) == dates[0]) {
                        deviceDateMap.remove(d);
                    }
                }
            }            
            
            
            if(!firstDevice) {
                //Did user ever login from this Country?
                Boolean knownCountry = false;
                for(LoginHistory lh : [SELECT CountryIso, Status FROM LoginHistory 
                                       WHERE LoginTime = LAST_N_DAYS:365 AND CountryIso = :loginInfo.CountryIso AND Id != :loginInfo.Id ORDER BY LoginTime LIMIT 100]){
                                           if(lh.Status == 'Success') {
                                               knownCountry = true;
                                               break;
                                           }
                                       }
                
                //Did user login using this Platform? (iPhone, Android, etc)
                Boolean knownPlatform = false;
                if(knownCountry) {
                    for(String str : devices) {
                        if(str.startsWithIgnoreCase(devicePlatform)) {
                            knownPlatform = true;
                            break;
                        }
                    }
                }
                
                //Did user login from this IP address during last 3 days? Maybe it is just a different browser?
                if(knownCountry && knownPlatform) {
                    for(LoginHistory lh : [SELECT SourceIp, Status FROM LoginHistory 
                                           WHERE LoginTime = LAST_N_DAYS:3 AND Id != :loginInfo.Id ORDER BY LoginTime LIMIT 100]){
                                               if(lh.Status == 'Success' && lh.SourceIp == loginInfo.SourceIp) {
                                                   knownDevice = true;
                                                   break;
                                               }    
                                           }
                }
            }
            
            deviceDateMap.put(deviceId, DateTime.now());
            user.REIDP_Devices__c = JSON.serialize(deviceDateMap);
        }
        try {
            update user;
            
            // check if user is PhoneNumber or Email
            if(!firstDevice && !knownDevice) {
                if (user.Username.endsWith(REIDP_Constants.MOBILE_USERS_SUFFIX))
                    sendSMS(user);
                else
                    sendEmail(emailFrom, emailTemplate);
            }
            
        }
        catch(Exception ex) {
            //Try catch, to allow login during Salesforce Read Only mode.
            try {
                REIDP_ErrorHandling.logWarningErrorLog(REIDP_NewDeviceNotificationPlugin.class, 'Error adding New Device to user', ex);
            } catch(Exception exc) {}
            
        }
        return new Process.PluginResult(result);
    }
    
    private static void sendEmail(String addressFrom, String emailTemplate) {
        List <OrgWideEmailAddress> owas = [SELECT id FROM OrgWideEmailAddress WHERE Address = :addressFrom LIMIT 1];
        EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = :emailTemplate];
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(templateId.Id);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false); 
        if(owas.size() > 0)
            mail.setOrgWideEmailAddressId(owas[0].id);
        allmsg.add(mail);
        try {
            Messaging.sendEmail(allmsg, true);
        } catch (Exception e) {
            REIDP_ErrorHandling.logWarningErrorLog(REIDP_NewDeviceNotificationPlugin.class, 'Error sending New Device Notification Email', e);   
        }
    }
    
    private static void sendSMS(User users) {
        List<User> usersToProcess = new List<User>();
        usersToProcess.add(users);
        if(usersToProcess.size() > 0) {
            REIDP_NotifyMobileUserNewDevice sendSMSNewDevice = new REIDP_NotifyMobileUserNewDevice(usersToProcess);
            ID jobID = System.enqueueJob(sendSMSNewDevice);
        }
    }
}