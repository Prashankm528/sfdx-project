/*****************************************************************************************
*	    Date:		    09DEC2019
*       Author:         Rahma Belghouti - Infosys
*       Description:    Test class for SFO_CustomMetadataUtility
*       Modifications:  
****************************************************************************************/
@IsTest
public with sharing class SFO_CustomMetadataUtilityTest {
    
    @IsTest
    static void testGetConfigSettingBooleanVal(){
        
        Test.startTest();        
        Map<String, Boolean> resultedMap = SFO_CustomMetadataUtility.getConfigSettingBooleanVal('testing');
        System.assertEquals(2, resultedMap.size());
        System.assertEquals(true, resultedMap.get('setting1'));
        System.assertEquals(false, resultedMap.get('setting2'));
        Test.stopTest();
        
    }
    @IsTest
    static void testGetConfigSettingStringVal(){
        
        Test.startTest();
        List<String> resultedList = SFO_CustomMetadataUtility.getConfigSettingStringVal('testing');
        System.assertEquals(2, resultedList.size());
        System.assert(resultedList.contains('US01'));
        System.assert(resultedList.contains('ZA0A'));
        Test.stopTest();
        
    }
    @IsTest
    static void testGetConfigSettingNumberVal(){
        
        Test.startTest();  
        Map<String, Decimal> resultedMap = SFO_CustomMetadataUtility.getConfigSettingNumberVal('testing');
        System.assertEquals(2, resultedMap.size());
        System.assertEquals(15, resultedMap.get('setting1'));
        System.assertEquals(20, resultedMap.get('setting2'));
        Test.stopTest();
        
    }
    
}