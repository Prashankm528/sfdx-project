/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 8/2017
 *
 * Error handlig class that saves logs into RE IDP Error Logs
 * 
 */
public class REIDP_ErrorHandling {
    @TestVisible
    private static final String CRITICAL_ERROR_TYPE = 'Critical';
    @TestVisible
    private static final String WARNING_ERROR_TYPE = 'Warning';
    @TestVisible
    private static final String INFO_ERROR_TYPE = 'Info';
    
	private static List<REIDP_Error_Log__c> errorLogs = new List<REIDP_Error_Log__c>();
    
    private static void addError(System.Type cls, String msg, Exception ex, String eType) {
        String networkName;
        try {
            Network n = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
            networkName = n.UrlPathPrefix;
        } catch(Exception e){}
			
        REIDP_Error_Log__c errorLog = new REIDP_Error_Log__c(REIDP_Class_Name__c = (cls != null) ? cls.getName() : 'UNKNOWN CLASS',
                                                             REIDP_Message__c = (msg != null && msg.length() > 255) ? 
                                                             					 msg.substring(0, 200) : msg + ' [' + UserInfo.getName() + ']',
                                                             REIDP_Type__c = (eType == null) ? CRITICAL_ERROR_TYPE : eType,
                                                             REIDP_Community__c = networkName);
        if(ex != null) {
        	errorLog.REIDP_Exception_Line_Number__c = ex.getLineNumber();
            errorLog.REIDP_Exception_Message__c = ex.getMessage();
            errorLog.REIDP_Exception_Stack_Trace__c = ex.getStackTraceString();
            errorLog.REIDP_Exception_Type__c = ex.getTypeName();
        }
        errorLogs.add(errorLog);
    }
    
    private static void logError(System.Type cls, String msg, Exception ex, String eType) {
        addError(cls, msg, ex, eType);
        processLogs();
    }
    
    public static void processLogs() {
        if(errorLogs.size() > 0) {
            //[Try/Catch] to prevent MIXED_DML_OPERATION
            try {
                insert errorLogs;
            } catch (Exception ex) {}
            errorLogs = new List<REIDP_Error_Log__c>();
        }
    }
    
    //Critical Error Log
    
    public static void logCriticalErrorLog(System.Type cls, String msg) {
        logError(cls, msg, null, CRITICAL_ERROR_TYPE);
    }
    
    public static void logCriticalErrorLog(System.Type cls, Exception ex) {
        logError(cls, null, ex, CRITICAL_ERROR_TYPE);
    }
    
    public static void logCriticalErrorLog(System.Type cls, String msg, Exception ex) {
        logError(cls, msg, ex, CRITICAL_ERROR_TYPE);
    }
    
    public static void addCriticalErrorLog(System.Type cls, String msg) {
        addError(cls, msg, null, CRITICAL_ERROR_TYPE);
    }
    
    public static void addCriticalErrorLog(System.Type cls, Exception ex) {
        addError(cls, null, ex, CRITICAL_ERROR_TYPE);
    }
    
    public static void addCriticalErrorLog(System.Type cls, String msg, Exception ex) {
        addError(cls, msg, ex, CRITICAL_ERROR_TYPE);
    }
    
    //Warning Error Log
    
    public static void logWarningErrorLog(System.Type cls, String msg) {
        logError(cls, msg, null, WARNING_ERROR_TYPE);
    }
    
    public static void logWarningErrorLog(System.Type cls, Exception ex) {
        logError(cls, null, ex, WARNING_ERROR_TYPE);
    }
    
    public static void logWarningErrorLog(System.Type cls, String msg, Exception ex) {
        logError(cls, msg, ex, WARNING_ERROR_TYPE);
    }
    
    public static void addWarningErrorLog(System.Type cls, String msg) {
        addError(cls, msg, null, WARNING_ERROR_TYPE);
    }
    
    public static void addWarningErrorLog(System.Type cls, Exception ex) {
        addError(cls, null, ex, WARNING_ERROR_TYPE);
    }
    
    public static void addWarningErrorLog(System.Type cls, String msg, Exception ex) {
        addError(cls, msg, ex, WARNING_ERROR_TYPE);
    }
    
    //Info Error Log
    
    public static void logInfoErrorLog(System.Type cls, String msg) {
        logError(cls, msg, null, INFO_ERROR_TYPE);
    }
    
    public static void logInfoErrorLog(System.Type cls, Exception ex) {
        logError(cls, null, ex, INFO_ERROR_TYPE);
    }
    
    public static void logInfoErrorLog(System.Type cls, String msg, Exception ex) {
        logError(cls, msg, ex, INFO_ERROR_TYPE);
    }
    
    public static void addInfoErrorLog(System.Type cls, String msg) {
        addError(cls, msg, null, INFO_ERROR_TYPE);
    }
    
    public static void addInfoErrorLog(System.Type cls, Exception ex) {
        addError(cls, null, ex, INFO_ERROR_TYPE);
    }
    
    public static void addInfoErrorLog(System.Type cls, String msg, Exception ex) {
        addError(cls, msg, ex, INFO_ERROR_TYPE);
    }
}