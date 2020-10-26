/************************************************************************************************************
* Description : Test class for private class clsCustomDebugLogger
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-JULY-21  1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
@isTest
private class clsCustomDebugLoggerTest {
	
	
	/***********************************************************************************
	* Test Method
	*--------------
	* logApiError method on Exception
    ***********************************************************************************/
    static testmethod void logApiErrorTest(){
    	
    // Test start.  
    Test.startTest();
    
    try{
    	
    	throw new testException('Don\'t be a silly user.');
    	   	
    }catch(Exception ex){
    	
    	    clsCustomDebugLogger.logApiError(ex, 'My Message', 'myClassName', 'http://restCall?id:123');
    }
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('Don\'t be a silly user.', result[0].Exception_Message__c);
    System.assertEquals('clsCustomDebugLoggerTest.testException', result[0].Exception_Type__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('http://restCall?id:123', result[0].Api_Request__c);
    System.assertEquals('Error', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logApiError method without Exception
    ***********************************************************************************/
    static testmethod void logApiErrorTestNoException(){
    	
    // Test start.  
    Test.startTest();
      	
   	clsCustomDebugLogger.logApiError('My Message', 'myClassName', 'http://restCall?id:123');
 
   
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];  
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('http://restCall?id:123', result[0].Api_Request__c);
    System.assertEquals('Error', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logError method on Exception
    ***********************************************************************************/
    static testmethod void logErrorTest(){
    	
    // Test start.  
    Test.startTest();
    
    try{
    	
    	throw new testException('Don\'t be a silly user.');
    	   	
    }catch(Exception ex){
    	
    	    clsCustomDebugLogger.logError(ex, 'My Message', 'myClassName');
    }
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('Don\'t be a silly user.', result[0].Exception_Message__c);
    System.assertEquals('clsCustomDebugLoggerTest.testException', result[0].Exception_Type__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('Error', result[0].Type__c);
    
    } 
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logError method on Exception no Class name.
    ***********************************************************************************/
    static testmethod void logErrorTestNoClassName(){
    	
    // Test start.  
    Test.startTest();
    
    try{
    	
    	throw new testException('Don\'t be a silly user.');
    	   	
    }catch(Exception ex){
    	
    	    clsCustomDebugLogger.logError(ex, 'My Message');
    }
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('Don\'t be a silly user.', result[0].Exception_Message__c);
    System.assertEquals('clsCustomDebugLoggerTest.testException', result[0].Exception_Type__c);
    System.assertEquals('Error', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logError method on Exception no Class name and Message, Exception Only.
    ***********************************************************************************/
    static testmethod void logErrorTestExceptionOnly(){
    	
    // Test start.  
    Test.startTest();
    
    try{
    	
    	throw new testException('Don\'t be a silly user.');
    	   	
    }catch(Exception ex){
    	
    	    clsCustomDebugLogger.logError(ex);
    }
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('Don\'t be a silly user.', result[0].Exception_Message__c);
    System.assertEquals('clsCustomDebugLoggerTest.testException', result[0].Exception_Type__c);
    System.assertEquals('Error', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logApiWarning will log warning for API 
    ***********************************************************************************/
    static testmethod void logApiWarningTest(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logApiWarning('My Message', 'myClassName', 'http://restCall?id:123');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('http://restCall?id:123', result[0].Api_Request__c);
    System.assertEquals('Warning', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logWarning will log a warning. 
    ***********************************************************************************/
    static testmethod void logWarningTest(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logWarning('My Message', 'myClassName');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('Warning', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logWarning will log a warning with only a message.
    ***********************************************************************************/
    static testmethod void logWarningTestMessageOnly(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logWarning('My Message');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('Warning', result[0].Type__c);
    
    }  
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logApiMessage will log a message for API code.
    ***********************************************************************************/
    static testmethod void logApiMessage(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logApiMessage('My Message', 'myClassName', 'http://restCall?id:123');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('http://restCall?id:123', result[0].Api_Request__c);
    System.assertEquals('Message', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logMessage will log a message.
    ***********************************************************************************/
    static testmethod void logMessage(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logMessage('My Message', 'myClassName');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('myClassName', result[0].Apex_Class__c);
    System.assertEquals('Message', result[0].Type__c);
    
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* logMessage will log a message with only message.
    ***********************************************************************************/
    static testmethod void logMessageMessageOnly(){
    	
    // Test start.  
    Test.startTest();
    
    clsCustomDebugLogger.logMessage('My Message');
    
    list<Custom_Debug_Log__c> result = [SELECT Message__c, Exception_Message__c, Exception_Type__c,
    									Apex_Class__c, Api_Request__c, Type__c 
    									FROM Custom_Debug_Log__c];
    
    // Test end.
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('My Message', result[0].Message__c);
    System.assertEquals('Message', result[0].Type__c);
    
    }   
  
    
    private class testException extends Exception {
	// USE IN UNIT TESTS ONLY !
	}
 
}