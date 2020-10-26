public abstract class REIDP_TwilioVerificationResource extends REIDP_TwilioResource {
	
    protected final String VERIFICATION_API_PATH = '/protected/json/phones/verification/';
    protected final String VERIFICATION_START_PATH = 'start';
    protected final String VERIFICATION_CHECK_PATH = 'check';
    
    protected final String verificationMethod;
    protected Integer codeLength;
    
    abstract String getSMSCredentialNameSandbox();
    abstract String getSMSCredentialNameProduction();
    
    private String credentialName {
        private get {
            return REIDP_Constants.isSandbox ? getSMSCredentialNameSandbox() : getSMSCredentialNameProduction();
        }
        private set;
    }
    
    public REIDP_TwilioVerificationResource(String twilioSettingsName) {
        REIDP_Twilio_Setting__mdt twilioSettings;
        try {
            twilioSettings = [SELECT Base_URL__c,
                              		 Code_Length__c,
                              		 Via__c 
                              FROM REIDP_Twilio_Setting__mdt 
                              WHERE DeveloperName = :(twilioSettingsName == null ? DEFAULT_PROFILE_NAME : twilioSettingsName)
                              LIMIT 1];
        }
        catch(Exception ex) {
            REIDP_ErrorHandling.logCriticalErrorLog(REIDP_TwilioPhoneVerification.class, 'Invalid Twilio profile name', ex);
        }
        verificationMethod = twilioSettings.Via__c;
        codeLength = Integer.valueOf(twilioSettings.Code_Length__c);
        this.setEndpoint(twilioSettings.Base_URL__c, credentialName);
    }
    
    public REIDP_TwilioVerificationResource() {
        this(null);
    }
    
    public abstract class Response {
        public Boolean success;
        public String message;
        public Boolean is_ported;
        public Boolean is_cellphone;
        public String carrier;
    }
}