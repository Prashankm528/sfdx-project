/*****************************************************************************************
*       Date:           01JUL19
*       Author:         Quentin Lebastard - IBM
*       Description:    Unit tests for TKT Create New Case Controller functionality


@ ------------ Changed by ---
*  @author            Karishma Gurjar
*  @date              26th March, 2020
*  @description       1075261 : Update Test Classes for Ticketing Platform
*****************************************************************************************/
@IsTest
public with sharing class TKT_createNewCaseControllerTEST {
    
    @isTest static void getHelpOptions_test() {
        /** Test Method to cover method getHelpOptions**/
        List<String> picklistValues = TKT_createNewCaseController.getHelpOptions('TKT_How_can_we_help_you_NEW_FORM__c');
        System.assertNotEquals(picklistValues.size(), null, 'No values for help option picklist');
    }
    @isTest static void getHelpOptions_testNegative() {
        /** Test Method to cover method getHelpOptions**/
        Test.startTest();
        try
        {
            List<String> picklistValues = TKT_createNewCaseController.getHelpOptions('TKT_Approved__c');
        }
        catch(Exception e) 
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('Script-thrown exception') ? true : false;
            system.assertEquals(expectedExceptionThrown,true);
        }
        
    }
    @isTest static void getCommodityTeam_test() {
        /** Test Method to cover method getCommodityTeam**/
        List<String> picklistValues = TKT_createNewCaseController.getCommodityTeam();
        System.assertNotEquals(picklistValues.size(), null, 'No values for Commodity/Team picklist');
    }
    @isTest static void getHelpOptionsExternal_test() {
        /** Test Method to cover method getHelpOptionsExternal**/
        List<String> picklistValues = TKT_createNewCaseController.getHelpOptions('TKT_How_can_we_help_you_EXTERNAL_FORM__c');
        System.assertNotEquals(picklistValues.size(), null, 'No values for help option picklist');
    }
    @isTest static void getHelpOptionsInternal_test() {
        /** Test Method to cover method getHelpOptionsInternal**/
        List<String> picklistValues = TKT_createNewCaseController.getHelpOptions('TKT_How_can_we_help_you_INTERNAL_FORM__c');
        System.assertNotEquals(picklistValues.size(), null, 'No values for help option picklist');
    }
    @isTest static void getDomain_test() {
        /** Test Method to cover method getDomain**/
        String currentDomain = TKT_createNewCaseController.getDomain();
        System.assertNotEquals(currentDomain, null, 'No values for domain');
    }
    
    @isTest static void getDomain_test_Negative() {
        /** Test Method to cover method getDomain**/
        String currentDomain = TKT_createNewCaseController.getDomain();
        System.assertNotEquals(currentDomain, null, 'No values for domain');
    }
    @isTest static void getBusinessOptions_test() {
        /** Test Method to cover method getBusinessOptions**/
        List<String> picklistValues = TKT_createNewCaseController.getBusinessOptions();
        System.assertNotEquals(picklistValues.size(), null, 'No values for business option picklist');
    }
    
    @isTest static void saveCase_test() {
        /** Test Method to cover method saveCase**/
        Case newCase = new Case(Status = 'New', SuppliedEmail = 'test@test.com');
        
        // Set options to ignore assignment
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.assignmentRuleId= null;
        newCase.setOptions(dmo);
        
        Test.startTest();
        TKT_createNewCaseController.saveCase(newCase);
        Test.stopTest();
        System.assertNotEquals(newCase.Id, null, 'Case not inserted properly');
    }
    @isTest static void saveCase_test_Negative() {
        /** Test Method to cover method saveCase**/
        Case cc =new Case();
        string recTypeCaseid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Ticketing').getRecordTypeId();
        cc.RecordTypeId = recTypeCaseid;
        cc.SuppliedEmail = 'test@testcase.com';
        Test.startTest();
        try
        {
            Case c1= TKT_createNewCaseController.saveCase(cc);
        }
        catch(Exception e) 
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('Script-thrown exception') ? true : false;
            system.assertEquals(expectedExceptionThrown,true);
        }
        Test.stopTest();
        
    }
}