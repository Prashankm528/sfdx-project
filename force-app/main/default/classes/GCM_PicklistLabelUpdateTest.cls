/********************************************************************************
* Date           : 30-JUN-2020
* Author         : Roselin Hephzibah
* Description    : Test class for GCM_PicklistLabelUpdate
* Modifications  : 30-JUN-2020 Roselin - Initial
********************************************************************************/ 
@isTest
public class GCM_PicklistLabelUpdateTest {

/****************************************************************************************************
Testmethod to cover GCM_PicklistLabelUpdate.
****************************************************************************************************/
    static testMethod void picklistLabelUpdateTest() {
        
        //Create Case
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.GCM_BOT_Resolution_Code__c = 'gExceptionNumber22';
        cs.GCM_Additional_Order_Info__c = '10';
        cs.Description = '';
        cs.GCM_ByPassValidation_Timestamp__c = system.now();
        insert cs;
        
        List<GCM_PicklistLabelUpdate.InputData> ipdlist = new List<GCM_PicklistLabelUpdate.InputData>();
        GCM_PicklistLabelUpdate.InputData ipd = new GCM_PicklistLabelUpdate.InputData();
        ipd.recordId = cs.Id;
        ipd.fieldFrom = 'GCM_BOT_Resolution_Code__c|GCM_Additional_Order_Info__c';
        ipd.fieldTo = 'Description';
        ipd.byPassTimeStamp = 'GCM_ByPassValidation_Timestamp__c';
        ipdlist.add(ipd);
        GCM_PicklistLabelUpdate.getPicklistLabel(ipdlist);
        
        List<Case> caseList = [Select Id,Description,GCM_BOT_Resolution_Code__c From Case WHERE Id =: cs.Id];
        System.assert(caseList[0].Description != null, 'Update Failed');
    }
}