/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 04/2018
 * 
 */
public with sharing class REIDP_Constants {
    
    //GENERAL

    public static final Boolean isSandbox {
        get {
            if(isSandbox == null) {
                isSandbox = [SELECT Id, IsSandbox FROM Organization].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }
    
    public static final Organization ORG_DEFAULTS {
        get {
            if(ORG_DEFAULTS == null)
                ORG_DEFAULTS = [SELECT Id, DefaultLocaleSidKey, LanguageLocaleKey, TimeZoneSidKey FROM Organization LIMIT 1];
            return ORG_DEFAULTS;
        }
        set;
    }
    
    public static final String DEFAULT_NETWORK_URL_PATH_PREFIX = 'BP';
    
    public static final String GENERAL_IDP_PROFILE_NAME = 'RE IDP External Identity';
    
    public static final String PERSON_ACCOUNT_RECORD_TYPE_NAME = 'RE IDP Person Account';
    
    public static final String PERSON_ACCOUNT_RECORD_TYPE_ID {
        get {
            if(PERSON_ACCOUNT_RECORD_TYPE_ID == null)
                PERSON_ACCOUNT_RECORD_TYPE_ID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('REIDP_PersonAccount').getRecordTypeId();
            return PERSON_ACCOUNT_RECORD_TYPE_ID;
        }
        private set;
    }
    
    public static final Set<String> SET_OF_WELCOME_PROFILE_NAMES = new Set<String>{
        GENERAL_IDP_PROFILE_NAME + ' BP',
		GENERAL_IDP_PROFILE_NAME + ' Castrol',
		GENERAL_IDP_PROFILE_NAME + ' AMPM'
    };
    
    //Enum values for login option based on Exp ID
    
    public enum AvailableLoginOption {EMAIL_AND_PHONE, EMAIL_ONLY, PHONE_ONLY, PHONE_AND_EMAIL}
        
    
    
    public static final String MOBILE_USERS_SUFFIX = '@idp.bp.com';
    
    //BP Related
    
    public static final String BP_COMMUNITY_NAME = 'BP';
    
    public static final String FROM_EMAIL_ADDRESS = 'accounts_team@bp.com';
    
    //Castrol Related
    
    public static final String CASTROL_COMMUNITY_NAME = 'Castrol';
    
    //AMPM Related
    
    public static final String AMPM_COMMUNITY_NAME = 'AMPM';
    
    // AUTH PROVIDERS
    public static final String FACEBOOK_PROVIDER = 'Facebook';
    public static final String GOOGLE_PROVIDER = 'Google';
    
    // map UrlPathPrefix to community name
    public static final Map<String, String> COMMUNITY_NAMES = new Map<String, String>{
        'AMPM' => 'ampm',
        'BP'   => 'BP'
    };
    
    public static final Set<String> SET_OF_AUTH_PROVIDER_NAMES = new Set<String>{
        FACEBOOK_PROVIDER + '_' + BP_COMMUNITY_NAME,
        GOOGLE_PROVIDER + '_' + BP_COMMUNITY_NAME,

        FACEBOOK_PROVIDER + '_' + CASTROL_COMMUNITY_NAME,
        GOOGLE_PROVIDER + '_' + CASTROL_COMMUNITY_NAME
    };
}