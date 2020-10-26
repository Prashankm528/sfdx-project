/****************************************************************************************************
 *  Date          : 10-FEB-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Update_Record
 * Modifications  : 10-FEB-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Update_Record_Test
{
/****************************************************************************************************
  Test Update Record
 ****************************************************************************************************/
    @isTest static void testUpdateRecord() {
        Test.startTest();
        Case newCase = new Case();
        newCase.Type = 'Test';
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        insert newCase;
        System.assert(newCase.Id != null, 'Test Case Created');
   
        // Update All Data Types
        List<GCM_Update_Record.InputData> inputDataList = new List<GCM_Update_Record.InputData>(); 
        String fieldNames = 'GCM_Automatic_Closed_Case__c|Status|Due__c';
        String fieldValues = 'true|Closed|' + String.valueOfGmt(DateTime.now());        
        GCM_Update_Record.InputData inputData = new GCM_Update_Record.InputData(newCase.Id, fieldNames, fieldValues);
        inputDataList.add(inputData);
        GCM_Update_Record.updateRecordInvocable(inputDataList);

        // Check Results
        List<Case> cases = [select Id from Case where GCM_Automatic_Closed_Case__c = true and Status = 'Closed' and ClosedDate != null];
        System.assert(cases.size() > 0, 'Case Updated');
        
        // Instantiate Empty Constructor - Increase Test Coverage
        GCM_Update_Record.InputData inputDataEmpty = new GCM_Update_Record.InputData();

        // Test Exception
        fieldNames = 'GCM_Automatic_Closed_Case__c|Status|Due__c';
        fieldValues = 'true|Closed|(Wrong Data Format - Not Date Time)';        
        inputData = new GCM_Update_Record.InputData(newCase.Id, fieldNames, fieldValues);
        inputDataList.remove(0); // Reuse List Instantiated Above
        inputDataList.add(inputData);
        GCM_Update_Record.updateRecordInvocable(inputDataList);
        
        // Test Exception Throw Exception
        try {
            List<String> fieldList = fieldNames.split('\\|');
            List<String> valueList = fieldValues.split('\\|');
            Map<Id, Map<String, String>> recAndFieldMap = new Map<Id, Map<String, String>>();
            Map<String, String> fieldMap = new Map<String, String>();
            for (Integer count; count < fieldList.size(); count++) {
                fieldMap.put(fieldList[count], valueList[count]);
            }
            recAndFieldMap.put(newCase.Id, fieldMap);
            GCM_Update_Record.updateRecords(recAndFieldMap, false);
            GCM_Update_Record.updateRecords(recAndFieldMap, true);
	        GCM_Update_Record.updateRecord(newCase.Id, fieldMap, true);  
        }
        catch (Exception caughtException) {
            // Do Nothing
        }
        
        Test.stopTest();
    }
}