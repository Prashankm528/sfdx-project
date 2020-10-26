/****************************************************************************************************
 *  Date          : 27-AUG-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Update_Record
 * Modifications  : 27-AUG-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Create_Record_Test
{
/****************************************************************************************************
  Test Update Record
 ****************************************************************************************************/
    @isTest static void testCreateRecord() {
        Test.startTest();
   
        
        // Update All Data Types
        Map<String, String> fieldMap = new Map<String, String>();
        fieldMap.put('GCM_Automatic_Closed_Case__c', 'true');
        fieldMap.put('Status', 'In Progress');
        fieldMap.put('Due__c', String.valueOfGmt(Datetime.now()));
        
        GCM_Create_Record.ResponseWrapper response = GCM_Create_Record.CreateRecord('Case', fieldMap, true);

        // Check Results
        System.assert(response.recId != null, 'Record Created');
        List<Case> cases = [select Id from Case where GCM_Automatic_Closed_Case__c = true and Status = 'In Progress' and Id = :response.recId];
        System.assert(cases.size() > 0, 'Case Created Correctly');
        
        // Test Exception
        // Set String Into Date Field
        fieldMap.put('GCM_Received_Date__c', 'test');
        GCM_Create_Record.ResponseWrapper responseError = new GCM_Create_Record.ResponseWrapper();
        try {
            // Test Aura Exception
        	responseError = GCM_Create_Record.CreateRecord('Case', fieldMap, true);
        }
        catch (Exception exceptionObject) {
        	System.assert(responseError.recId == null, 'Aura Exception: Record Not Created');    
        }
        // Test Normal (Gracefully Handled) Exception
		responseError = GCM_Create_Record.CreateRecord('Case', fieldMap, false);
		System.assert(responseError.recId == null, 'Normal Exception: Record Not Created');    
        
        Test.stopTest();
    }
}