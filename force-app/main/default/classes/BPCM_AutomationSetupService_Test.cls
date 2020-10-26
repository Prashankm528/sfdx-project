/**
* @author: Gabriela Matos
* @date: 25/06/2020
* @group: BPCM
* @description: Test cover for BPCM_AutomationSetupService.cls
* @name BPCM_AutomationSetupService_Test.cls
*/

@isTest
public with sharing class BPCM_AutomationSetupService_Test {
    
    /*
    * Test method. System should insert a new BPCM_Automation_Setup__c without errors
    */
    static testMethod void shouldInsertNewRecord(){

        Test.startTest();
        BPCM_Automation_Setup__c autoSetupNew = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
        'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');
        Test.stopTest();

        List<BPCM_Automation_Setup__c> newASList = [SELECT Id FROM BPCM_Automation_Setup__c WHERE Id = :autoSetupNew.Id];
        System.assert(!newASList.isEmpty(), 'Automation Setup has not been created!');
    }

    /*
    * Test method. System should NOT insert a new BPCM_Automation_Setup__c record as it's a duplicate one
    */
    static testMethod void shouldNotInsertNewRecord(){

        Test.startTest();
        BPCM_Automation_Setup__c autoSetOne = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
        'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');

        Try {
            BPCM_Automation_Setup__c autoSetTwo = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
            'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');
        } Catch(Exception e){
            System.assertEquals(System.Label.BPCM_Duplicate_Msg_Automation_Setup, BPCM_TestDataFactory.parseErrorMessage(e.getMessage()));
        }
        Test.stopTest();
    }

    /*
    * Test method. System should update an existing BPCM_Automation_Setup__c record
    */
    static testMethod void shouldUpdateExistingRecord(){

        Test.startTest();
        BPCM_Automation_Setup__c autoSetOne = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
        'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');

        BPCM_Automation_Setup__c autoSetTwo = BPCM_TestDataFactory.createAutomationSetup(true, 2, 'Active', 
        'BPCM_Keyword', 'Damage', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');

        autoSetTwo.BPCM_Process_Order__c = 3;
        update autoSetTwo;
        Test.stopTest();

        List<BPCM_Automation_Setup__c> newASList = [SELECT BPCM_Process_Order__c FROM BPCM_Automation_Setup__c WHERE Id = :autoSetTwo.Id];
        System.assert(!newASList.isEmpty(), 'Automation Setup has not been created!');
        System.assertEquals(3, newASList[0].BPCM_Process_Order__c);

    }

    /*
    * Test method. System should NOT update an existing BPCM_Automation_Setup__c record with an existing unique key
    */
    static testMethod void shouldNotUpdateExistingRecord(){

        Test.startTest();
        BPCM_Automation_Setup__c autoSetOne = BPCM_TestDataFactory.createAutomationSetup(true, 1, 'Active', 
        'BPCM_Keyword', 'Red Light, Fire', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');

        BPCM_Automation_Setup__c autoSetTwo = BPCM_TestDataFactory.createAutomationSetup(true, 2, 'Active', 
            'BPCM_Keyword', 'Damage', 'BPCM_Technical', 'Home Charge', 'Unit not working', 'Constant Red Light', '1-ASAP');

        Try {
            autoSetTwo.BPCM_Process_Order__c = 2;
            update autoSetTwo;

        } Catch(Exception e){
            System.assertEquals(System.Label.BPCM_Duplicate_Msg_Automation_Setup, BPCM_TestDataFactory.parseErrorMessage(e.getMessage()));
        }
        Test.stopTest();
    }
}