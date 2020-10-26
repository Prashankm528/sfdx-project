/**
* @author: Gabriela Matos
* @date: 19/06/2020
* @group: BPCM
* @description: Test cover for BPCM_SettingsService.cls
* @name BPCM_SettingsService_Test.cls
*/

@isTest
public with sharing class BPCM_SettingsService_Test {

    private static final String SETTING_DEV_NAME = 'Test_Case_Update';

    static testMethod void shouldNotGetCaseFieldAPINameToCheck(){
        
        List<String> csFieldAPIName = BPCM_SettingsService.getCaseFieldsToCheckUpdate(SETTING_DEV_NAME);
        System.assert(csFieldAPIName.isEmpty(), 'Setting Metadata found');
    }

    static testMethod void shouldGetCaseFieldAPINameToCheck(){
        
        BPCM_TestDataFactory.mockBPCMSettingsMap('Status, OwnerId', SETTING_DEV_NAME);
        List<String> csFieldAPIName = BPCM_SettingsService.getCaseFieldsToCheckUpdate(SETTING_DEV_NAME);
        System.assert(!csFieldAPIName.isEmpty(), 'Setting Metadata not found');
        System.assertEquals(csFieldAPIName[0].trim(), 'Status');
        System.assertEquals(csFieldAPIName[1].trim(), 'OwnerId');
    }
}