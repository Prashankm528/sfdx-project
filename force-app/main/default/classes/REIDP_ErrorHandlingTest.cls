/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 6/2017
*
*/
@isTest
public class REIDP_ErrorHandlingTest {
	@isTest
    static void testInfoLogs() {
        Test.startTest();
        REIDP_ErrorHandling.addInfoErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.addInfoErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.addInfoErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.processLogs();
        REIDP_ErrorHandling.logInfoErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.logInfoErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.logInfoErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        List<REIDP_Error_Log__c> logs = [SELECT Id FROM REIDP_Error_Log__c WHERE REIDP_Type__c = :REIDP_ErrorHandling.INFO_ERROR_TYPE];
        System.assertEquals(6, logs.size());
        Test.stopTest();
    }
    
    @isTest
    static void testWarningLogs() {
        Test.startTest();
        REIDP_ErrorHandling.addWarningErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.addWarningErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.addWarningErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.processLogs();
        REIDP_ErrorHandling.logWarningErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.logWarningErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.logWarningErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        List<REIDP_Error_Log__c> logs = [SELECT Id FROM REIDP_Error_Log__c WHERE REIDP_Type__c = :REIDP_ErrorHandling.WARNING_ERROR_TYPE];
        System.assertEquals(6, logs.size());
        Test.stopTest();
    }
    
    @isTest
    static void testCriticalLogs() {
        Test.startTest();
        REIDP_ErrorHandling.addCriticalErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.addCriticalErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.addCriticalErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.processLogs();
        REIDP_ErrorHandling.logCriticalErrorLog(REIDP_ErrorHandlingTest.class, new REIDP_ErrorHandlingTestException('test'));
        REIDP_ErrorHandling.logCriticalErrorLog(REIDP_ErrorHandlingTest.class, 'test');
        REIDP_ErrorHandling.logCriticalErrorLog(REIDP_ErrorHandlingTest.class, 'test', new REIDP_ErrorHandlingTestException('test'));
        List<REIDP_Error_Log__c> logs = [SELECT Id FROM REIDP_Error_Log__c WHERE REIDP_Type__c = :REIDP_ErrorHandling.CRITICAL_ERROR_TYPE];
        System.assertEquals(6, logs.size());
        Test.stopTest();
    }
    
    public class REIDP_ErrorHandlingTestException extends Exception {}
}