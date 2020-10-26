/*****************************************************************************************
*       Date:           01JUL19
*       Author:         Quentin Lebastard - IBM
*       Description:    Unit tests for TKT Case Trigger functionality
*       Modifications:  09JUL19 Michal Vavra - IBM: Refactoring and adding bulk tests
*****************************************************************************************/
@IsTest
public class TKT_CaseAssignmentHandlerTest {
    public static Id prospectRecordTypeId = Account.SObjectType.getDescribe()
        .getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
    
    private static Exception capturedException;
    
    @IsTest
    private static void testTriggerAssignmentRulesPositive() {
        Account account = createAccount();
        insert account;
        Contact contact = createContact(account);
        insert contact;
        Case testCase = createTicketingCase(contact);
        
        Database.DMLOptions noAssignmentRulesOptions = new Database.DMLOptions();
        noAssignmentRulesOptions.assignmentRuleHeader.useDefaultRule = false;
        noAssignmentRulesOptions.assignmentRuleHeader.assignmentRuleId = null;
        testCase.setOptions(noAssignmentRulesOptions);
        
        Test.startTest();
            try {
            	insert testCase;
            } catch (Exception e) {
                capturedException = e;
            }
        Test.stopTest();
        
        List<Case> resultCases = [SELECT Id, OwnerId FROM Case];
        
        System.assertEquals(null, capturedException, 'No exception should be thrown when');
        System.assertNotEquals(Userinfo.getUserId(), resultCases[0].OwnerId, 'The trigger should have forced assignment rules if none were used at the insert');
    }
    
    @IsTest
    private static void testTriggerAssignmentRulesNegativeNotTKTCase() {
        final String GENERAL_CASE_RECORD_TYPE_DEV_NAME = 'General_Case';
        final Id nonTKTCaseRecordTypeId = Case.SObjectType.getDescribe()
        	.getRecordTypeInfosByDeveloperName().get(GENERAL_CASE_RECORD_TYPE_DEV_NAME).getRecordTypeId();
        
        Account account = createAccount();
        insert account;
        Contact contact = createContact(account);
        insert contact;
        Case testCase = createCase(contact, nonTKTCaseRecordTypeId);
        
        Database.DMLOptions noAssignmentRulesOptions = new Database.DMLOptions();
        noAssignmentRulesOptions.assignmentRuleHeader.useDefaultRule = false;
        noAssignmentRulesOptions.assignmentRuleHeader.assignmentRuleId = null;
        testCase.setOptions(noAssignmentRulesOptions);
        
        Test.startTest();
            try {
            	insert testCase;
            } catch (Exception e) {
                capturedException = e;
            }
        Test.stopTest();
        
        List<Case> resultCases = [SELECT Id, OwnerId FROM Case];
        
        System.assertEquals(null, capturedException, 'No exception should be thrown when');
        System.assertEquals(Userinfo.getUserId(), resultCases[0].OwnerId, 'The trigger should not run assignment rules when Case is not of TKT Record Type');
    }
    
    @IsTest
    private static void testTriggerAssignmentRulesNegativeNoAssignmentRuleFound() {
        String nonExistingAssignmentRuleName = 'Non Existing Assignment Rule Name';

        Account account = createAccount();
        insert account;
        Contact contact = createContact(account);
        insert contact;
        Case testCase = createTicketingCase(contact);
        
        TKT_CaseAssignmentHandler.ticketingAssignmentRuleName = nonExistingAssignmentRuleName;
        
        Test.startTest();
            try {
            	insert testCase;
            } catch (Exception e) {
                capturedException = e;
            }
        Test.stopTest();
        
        System.assert(
            capturedException != null,
            'Exception should be thrown when Assignment Rule for Case Ticketing does not exist'
        );
        System.assertEquals(
            DmlException.class.getName(),
            capturedException.getTypeName(),
            'DmlException should be thrown when Assignment Rule for Case Ticketing does not exist'
        );
        System.assert(
            capturedException.getMessage().contains(nonExistingAssignmentRuleName),
            'Exception message should contain Assignment Rule Name when it does not exist'
        );
    }
    
    private static Account createAccount() {
        return new Account(
            Name = 'Acme',
            RecordTypeId = prospectRecordTypeId
        );
    }
    
    private static Contact createContact(Account parentAccount) {
        return new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'doe@example.com',
            Survey_Opt_Out_Requested__c = false,
            AccountId = parentAccount.Id
        );
    }
    
    private static Case createTicketingCase(Contact relatedContact) {
        return createCase(relatedContact, TKT_CaseAssignmentHandler.ticketingCaseRecordTypeId);
    }
    
    private static Case createCase(Contact relatedContact, Id recordTypeId) {
        return new Case(
            ContactId = relatedContact.Id,
            RecordTypeId = recordTypeId,
            SuppliedEmail = 'test@testcase.com',
            Origin = 'New Customer Form',
            TKT_First_Name__c = 'John',
            TKT_Last_Name__c = 'Doe',
            TKT_How_can_we_help_you_NEW_FORM__c = 'New User Access',
            TKT_Describe_how_we_can_help__c  = 'Please, I need an access',
            TKT_Primary_Commodity_Business_with_BP__c = 'Natural Gas',
            TKT_Ticket_Form_Email__c = 'test@testcase.com'
        );
    }
}