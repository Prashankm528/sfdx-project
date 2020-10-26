/*****************************************************************************************
*       Date:        01OCT2019
*       Author:      Alessandro Miele - IBM
*       Description: Controller for registration page
*****************************************************************************************/
public without sharing class DUP_SelfRegistrationController {

    private static final String DUPLICATE_ERROR_MSG = 'A user with this email address already exists. Please verify your input or login as an existing user.';
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        	Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    /**
	* @description:	method to register a user using REIDP service
	* @param: value string to create the user
	* @return: null
	*/    
    @AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String language, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        //Savepoint sp = null;
        //sp = Database.setSavepoint();

       
       try {
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.IDPLastNameRequired;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.IDPEmailRequired;
            } 
           else {
               email = email.toLowerCase();
                List<DUP_Counterparty_Contact__c> cpContacts = [SELECT DUP_Email__c FROM DUP_Counterparty_Contact__c WHERE DUP_Email__c=:email];
                if (cpContacts.isEmpty()){
                    throw new DuplicateException(Label.DUP_Login_Error_Message);
                }
                List<User> existingUsers = [SELECT Email FROM User WHERE Email=:email and IsActive = TRUE];
                if (existingUsers != null && !existingUsers.isEmpty()){
                    throw new DuplicateException(Label.BPDuplicateEmail);
                }
            }
            
            //REIDP_UserResource.UserCreateRequest reqData = new REIDP_UserResource.UserCreateRequest();
            

            //reqData.firstname = (firstname != null && firstname.length() > 0) ? firstname.capitalize() : '';
            //reqData.lastname = lastName.capitalize();
            //reqData.language = language;
            //reqData.email = email;
            //reqData.communityPath = 'BP';
            
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();            

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('reqData');
            gen.writeStartObject();
            gen.writeObjectField('firstname', (firstname != null && firstname.length() > 0) ? firstname.capitalize() : '');
            gen.writeObjectField('lastname', lastName.capitalize());
            gen.writeObjectField('email', email);
            gen.writeObjectField('language', language);
            gen.writeObjectField('communityPath', 'BP');
            gen.writeObjectField('returnApp', 'DUP');
            gen.writeEndObject();
            gen.writeEndObject();
            String jsonString = gen.getAsString();

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(baseUrl + '/BP/services/apexrest/IdPUser');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonString);
            request.setTimeout(120000);

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 201) {
                System.debug('SUCCESSS'+response);
            } else{
                System.debug('ERROR' + response);
            }        
            
            String responseBody = response.getBody();
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);            
            String userId = (String)responseMap.get('userId');

            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            //String userId = Site.createPortalUser(u, accountId, password);
            //REIDP_UserResource.UserCreateResponse response = REIDP_UserResource.noRestSelfRegister(reqData);
            //System.debug('response ' + response);
            
            //String userId = (String)responseMap.get('userId');
          
            // create a fake userId for test.
            
            if (Test.isRunningTest()) {
                userId = UserInfo.getUserId() ;          
            }
            if (userId != null) { 
                //Approval process for permission sets
                List<User> currentUsers = [SELECT ContactId FROM User WHERE Id =: userId LIMIT 1];
                if(currentUsers!=null && !currentUsers.isEmpty())
                User currentUser = currentUsers[0];   
                insertPermissionSet(userId);
                insertShareUser(userId);
				ApexPages.PageReference lgn = new PageReference('');
                if (password != null && password.length() > 1) {
                     lgn = Site.login(email, password, startUrl);                    
                }
                else {
                    lgn = new PageReference(regConfirmUrl);
                    
                }
                if(!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
            }
            return null;
        }
        catch (Exception ex) {
            //Database.rollback(sp);
            String returnString = ex.getMessage(); 

            if(DUPLICATE_ERROR_MSG == ex.getMessage()){
                Id userId = [SELECT Id FROM User WHERE Email =: email].Id;
                insertPermissionSet(userId);
                insertShareUser(userId);
                returnString += ' Permission to the application has been refreshed.';                
            }
            DUP_DocumentRequestUtil.sendEmailOnException('Exception in class "DUP_SelfRegistrationController" in method "selfRegister" while being executed by '+UserInfo.getUserName()+'('+email+') '+
                                                        '. Error in line: '+ex.getLineNumber() +' due to: '+ex.getMessage());
            return returnString;           
        }
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,String>> extraFields = new List<Map<String,String>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        //if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, String> fieldDetail = new Map<String, String>();
                fieldDetail.put('dbRequired', String.valueOf(f.getDBRequired()));
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', String.valueOf(f.getRequired()));
                fieldDetail.put('type', String.valueOf(f.getType()));
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}//}
        return extraFields;
    }

    /**
	* @description:	it inserts a REIDP_Application_Access_Request__c to apply permission sets to the user
	* @param: user Id of the created user
	* @return: void
	*/
    @future
    public static void insertPermissionSet(Id userId){
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'DUP_Counterparty_Access'].Id;
        List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment 
                                        WHERE PermissionSetId = :permissionSetId
                                            AND AssigneeId = :userId ];
        if(permissionSetAssignmentList.isEmpty()){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSetId, AssigneeId = userId);
            try {
                insert psa;
            } catch (DmlException e) {
                System.debug('An Error has occurred while inserting a new PermissionSet Assignment: '+ e.getMessage());
            }
        }      
    }

    /**
	* @description:	it inserts a UserShare to share the user with the DUP Internal Users group
	* @param: user Id of the created user
	* @return: void
	*/
    @future
    public static void insertShareUser(Id userId){
        //Share the User
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'DUP_Internal_Users'].Id;
        UserShare uss = new UserShare(UserId = userId, UserOrGroupId = groupId, UserAccessLevel = 'Read');
        try {
            insert uss;
        } catch (DmlException e) {
            System.debug('An Error has occurred while Sharing the user: '+ e.getMessage());
        }       
    } 
    
    public class DuplicateException extends Exception {}

}