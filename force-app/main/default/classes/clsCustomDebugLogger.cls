/************************************************************************************************************
*Description :  Logger for custom debug logs. 
*				All logs created by any method form this class will create record in custom object
*				named Custom_Debug_Log__c.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JULY-20  1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
public class clsCustomDebugLogger {
	
	/***********************************************************************************
	* Log API Error
	*--------------
	* This method should be used in situation when exception is raised inside of API.	
	* Method will log exception details and other important information such as API request.
    ***********************************************************************************/
	public static void logApiError(Exception ex, String message, String className, String apiRequest){
		
		Custom_Debug_Log__c errorLog = new Custom_Debug_Log__c();
		errorLog.Exception_Message__c = ex.getMessage();
		errorLog.Exception_Type__c = ex.getTypeName();
		errorLog.Stack_Trace__c = ex.getStackTraceString();
		errorLog.Message__c = message;
		errorLog.Apex_Class__c = className;
		errorLog.Api_Request__c = apiRequest;
		errorLog.Type__c = 'Error';
		
		// Insert Custom Debug Log 
		createCustomDebugLog(errorLog);			
	}
	
	public static void logApiError(String message, String className, String apiRequest){
		
		Custom_Debug_Log__c errorLog = new Custom_Debug_Log__c();
		errorLog.Message__c = message;
		errorLog.Apex_Class__c = className;
		errorLog.Api_Request__c = apiRequest;
		errorLog.Type__c = 'Error';
		
		// Insert Custom Debug Log 
		createCustomDebugLog(errorLog);			
	}
		     
    /***********************************************************************************
	* Log Error
	*--------------
	* This method should be used in situation when exception is raised.	
	* Method will log exception details and other important information.
	* Three overload are available, one for logging with class name one without class name 
	* and last one for logging only exception data.
    ***********************************************************************************/
	public static void logError(Exception ex, String message, String className){
		
		Custom_Debug_Log__c errorLog = new Custom_Debug_Log__c();
		errorLog.Exception_Message__c = ex.getMessage();
		errorLog.Exception_Type__c = ex.getTypeName();
		errorLog.Stack_Trace__c = ex.getStackTraceString();
		errorLog.Message__c = message;
		errorLog.Apex_Class__c = className;
		errorLog.Type__c = 'Error';
		
		// Insert Custom Debug Log
		createCustomDebugLog(errorLog);			
	}
	
	public static void logError(Exception ex, String message){
		
		Custom_Debug_Log__c errorLog = new Custom_Debug_Log__c();
		errorLog.Exception_Message__c = ex.getMessage();
		errorLog.Exception_Type__c = ex.getTypeName();
		errorLog.Stack_Trace__c = ex.getStackTraceString();
		errorLog.Message__c = message;
		errorLog.Type__c = 'Error';
		
		// Insert Custom Debug Log
		createCustomDebugLog(errorLog);		
	}
	
	public static void logError(Exception ex){
		
		Custom_Debug_Log__c errorLog = new Custom_Debug_Log__c();
		errorLog.Exception_Message__c = ex.getMessage();
		errorLog.Exception_Type__c = ex.getTypeName();
		errorLog.Stack_Trace__c = ex.getStackTraceString();
		errorLog.Type__c = 'Error';
		
		// Insert Custom Debug Log
		createCustomDebugLog(errorLog);		
	}
	
	
	/***********************************************************************************
	* Log API Warning
	*--------------
	* This method should be used in situation when no exception is raised inside of API.	
	* Method will log exception details and other important information such as API request.
    ***********************************************************************************/
	public static void logApiWarning(String message, String className, String apiRequest){
		
		Custom_Debug_Log__c warningLog = new Custom_Debug_Log__c();
		warningLog.Message__c = message;
		warningLog.Apex_Class__c = className;
		warningLog.Api_Request__c = apiRequest;
		warningLog.Type__c = 'Warning';
		
		// Insert Custom Debug Log
		createCustomDebugLog(warningLog);		
	}
	
	/***********************************************************************************
	* Log Warning
	*--------------
	* This method should be used in situation when no exception is raised.
	* Two overload are available, one for logging with class name the other without class name.
    ***********************************************************************************/
	public static void logWarning(String message, String className){
		
		Custom_Debug_Log__c warningLog = new Custom_Debug_Log__c();
		warningLog.Message__c = message;
		warningLog.Apex_Class__c = className;
		warningLog.Type__c = 'Warning';
		
		// Insert Custom Debug Log
		createCustomDebugLog(warningLog);	
	}
	
	public static void logWarning(String message){
		
		Custom_Debug_Log__c warningLog = new Custom_Debug_Log__c();
		warningLog.Message__c = message;
		warningLog.Type__c = 'Warning';
		
		// Insert Custom Debug Log
		createCustomDebugLog(warningLog);		
	}
	
	
	/***********************************************************************************
	* Log Api Message
	*--------------
	* This method should be used in situation when no exception is raised inside of API.	
	* Method will log important information such as API request in situation of expected behaviour which will not result in exception.
    ***********************************************************************************/
	public static void logApiMessage(String message, String className, String apiRequest){
		
		Custom_Debug_Log__c messageLog = new Custom_Debug_Log__c();
		messageLog.Message__c = message;
		messageLog.Apex_Class__c = className;
		messageLog.Api_Request__c = apiRequest;
		messageLog.Type__c = 'Message';
		
		// Insert Custom Debug Log
		createCustomDebugLog(messageLog);		
	}
	
	/***********************************************************************************
	* Log Message
	*--------------
	* This method should be used in situation when no exception is raised.
	* Method will log important information in situation of expected behaviour which will not result in exception.
	* Two overload are available, one for logging with class name the other without class name.
    ***********************************************************************************/
	public static void logMessage(String message, String className){
		
		Custom_Debug_Log__c messageLog = new Custom_Debug_Log__c();
		messageLog.Message__c = message;
		messageLog.Apex_Class__c = className;
		messageLog.Type__c = 'Message';
		
		// Insert Custom Debug Log
		createCustomDebugLog(messageLog);	
	}
	
	public static void logMessage(String message){
		
		Custom_Debug_Log__c messageLog = new Custom_Debug_Log__c();
		messageLog.Message__c = message;
		messageLog.Type__c = 'Message';
		
		// Insert Custom Debug Log
		createCustomDebugLog(messageLog);		
	}
	
	/***********************************************************************************
	* Private Methods
    ***********************************************************************************/
    
    // Insert Custom Debug Log along with timestamp.
    private static void createCustomDebugLog(Custom_Debug_Log__c debugLog){
    			
		debugLog.Created_Date__c = system.now();
		insert debugLog;		
	}
}