/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 1/2019
 *
 * This web service that is used by External Applications to manage User Consents
 * 
 */
@RestResource(urlMapping='/UserConsent/*')
global with sharing class REIDP_UserConsentResource {
    
    global class UserConsentCreateRequest {
        public String consentId;
        public String appName;
        public String version;
        public Boolean accepted;
        public String consentType;
        public List<String> channel;
    }
    
    global class UserConsentResponse {
        public List<REIDP_User_Consent__c> userConsents = new List<REIDP_User_Consent__c>();
        public Boolean success = true;
        public String message;
    }
    
    @HttpGet
    global static UserConsentResponse getUserConsent() {	
        UserConsentResponse ucr = new UserConsentResponse();
        try {
            String appShortName = RestContext.request.params.get('appName');
            
            String userId = UserInfo.getUserId();
            String appName = getApplicationName();
            
            String query = 'SELECT Id, ' +
                'Type__c, ' +
                'Channel__c, ' +
                'Version__c, ' +
                'Accepted_Time__c, ' +
                'Accepted__c ' +
                'FROM REIDP_User_Consent__c ' +
                'WHERE User__c = :userId ' +
                'AND Application__r.Connected_App__c = :appName ' +
                (!String.isBlank(appShortName) ? 'AND Application__r.Short_Name__c = :appShortName' : '');
            
            List<REIDP_User_Consent__c> userConsentData = (List<REIDP_User_Consent__c>) Database.query(query);
            
            ucr.userConsents = userConsentData;
        } catch (Exception e) {
            ucr.success = false;
            ucr.message = 'Bad Request';
        }    
        return ucr;
    }
    
    @HttpPost
    global static UserConsentResponse updateUserConsent(List<UserConsentCreateRequest> reqData) {
        if(!isValidUpdateRequest(reqData))
            throw new JSONException('Bad Request');
        
        UserConsentResponse ucResponse = new UserConsentResponse();
        List<REIDP_User_Consent__c> consentsToUpdate = new List<REIDP_User_Consent__c>();
        Set<Id> reqIds = new Set<Id>();
        
        
        for (UserConsentCreateRequest ucr : reqData) { 
            reqIds.add(ucr.consentId);
        }
        
        Map<Id, REIDP_User_Consent__c> consent = new Map<Id, REIDP_User_Consent__c> ([SELECT Id,
                                                                                      Accepted__c,
                                                                                      Accepted_Time__c,
                                                                                      Type__c,
                                                                                      Channel__c,
                                                                                      Version__c
                                                                                      FROM REIDP_User_Consent__c
                                                                                      WHERE User__c = :UserInfo.getUserId() 
                                                                                      AND Id in: reqIds
                                                                                      AND Application__r.Connected_App__c = :getApplicationName()]);
        
        try {
            for (UserConsentCreateRequest ucr : reqData) {
                
                consent.get(ucr.consentId).Accepted__c = ucr.accepted;
                consent.get(ucr.consentId).Accepted_Time__c = System.now();
                consent.get(ucr.consentId).Channel__c = (ucr.channel != null) ? String.join(ucr.channel, ';') 
                    : null;
                consent.get(ucr.consentId).Version__c = ucr.version;
                
                consentsToUpdate.add(consent.get(ucr.consentId));
                
            }
            update consentsToUpdate;     
            ucResponse.userConsents = consentsToUpdate;
        } catch (Exception e) {
            ucResponse.success = false;
            ucResponse.message = 'Bad Request';
        }
        
        return ucResponse;
    }
    
    @HttpPut
    global static UserConsentResponse addUserConsent(List<UserConsentCreateRequest> reqData) {
        if(!isValidCreateRequest(reqData))
            throw new JSONException('Bad Request');
        
        UserConsentResponse ucResponse = new UserConsentResponse();
        String appName = getApplicationName();
        
        try {
            ucResponse.userConsents = REIDP_UserConsentHelper.createUserConsent(reqData, appName, UserInfo.getUserId());
        } catch (Exception e){
            ucResponse.success = false;
            ucResponse.message = 'Bad Request';
        }
        
        return ucResponse;
        
    }
    
    private static Boolean isValidCreateRequest(List<UserConsentCreateRequest> reqData) {
        Boolean result = true;
        for(UserConsentCreateRequest ucr : reqData) {
            if (ucr.consentType == null || ucr.accepted == null) {
                result = false;
            }
        }
        return result;
    }
    
    private static Boolean isValidUpdateRequest(List<UserConsentCreateRequest> reqData) {
        Boolean result = true;
        for(UserConsentCreateRequest ucr : reqData) {
            if (ucr.consentId == null || 
                ucr.consentType == null ||
                ucr.accepted == null)  {
                    result = false;
                }
        }
        return result;
    }
    
    private static String getApplicationName() {
        if(!Test.isRunningTest()) {
            String loginHistoryId = Auth.SessionManagement.getCurrentSession().get('LoginHistoryId');
            return [SELECT Id, Application FROM LoginHistory WHERE Id = :loginHistoryId].Application;
        } 
        else return 'testApp';
    }
}