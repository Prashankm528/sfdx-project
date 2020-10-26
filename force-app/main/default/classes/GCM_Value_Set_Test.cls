/****************************************************************************************************
 *  Date          : 22-SEP-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Value_Set
 * Modifications  : 22-SEP-2020 SYAP - Initial
****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Value_Set_Test {
/****************************************************************************************************
 * Test Get Field Dependencies
 ****************************************************************************************************/  
    static testMethod void testGetFieldDependencies() {
        Test.startTest();
        
        // Field Dependencies
        Map<String, String> fieldMap = new Map<String, String>();
        fieldMap.put('Type', 'Area__c');
        
        List<String> keys = GCM_Value_Set.getFieldDependencies('Case', 'GCM_Lubes', fieldMap);
        
        // Above Method Will Not Return Any Value Sets In Test Mode
        System.assert(keys.size() == 0, 'Value Set Found');
        
        Test.stopTest();
    }
}