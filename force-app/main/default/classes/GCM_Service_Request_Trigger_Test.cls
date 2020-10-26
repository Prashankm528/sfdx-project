/****************************************************************************************************
 *  Date          : 03-JAN-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Service_Request_Trigger
 *  Modifications :
 *  03-JAN-2020	  : SYAP - Initial
 *  24-FEB-2020   : SYAP Added Test Method for bulk case conversion
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Service_Request_Trigger_Test {
/****************************************************************************************************
 Test post record creation logic.
 ****************************************************************************************************/
	public static testMethod void postCreateTest() {    
		// Create Test Record
		GCM_Service_Request__c request = new GCM_Service_Request__c();
		request.GCM_Sales_Organization__c = 'UK01';
		request.GCM_Business_Unit__C = 'Fuels - Cards';
		request.GCM_Case_Record_Type__c = 'GCM_Fuels_Cards';
        insert request;

		List<GCM_Service_Request__c> result = [select Id, GCM_Case_Record_Type_Id__c, OwnerId from GCM_Service_Request__c where Id = :request.Id];
		System.assert(result.size() > 0, 'Test Record Created');
		System.assert(result[0].GCM_Case_Record_Type_Id__c != null, 'Record Type Id Set');
		System.assert(String.valueOf(result[0].OwnerId).startsWith('00G'), 'Queue Assignment');
	}

/****************************************************************************************************
 Test bulk record creation logic.
 ****************************************************************************************************/
	public static testMethod void bulkConvertCaseTest() {    
    	// Create Test Record
    	List<GCM_Service_Request__c> requests = new List<GCM_Service_Request__c>();
		for (Integer count = 0; count <= 5; count++) {
	    	GCM_Service_Request__c request = new GCM_Service_Request__c();
            request.GCM_Sales_Organization__c = 'UK01';
    		request.GCM_Business_Unit__C = 'Fuels - Cards';
    		request.GCM_Case_Record_Type__c = 'GCM_Fuels_Cards';
    		request.GCM_Type__c = 'Test_' + count;
            request.GCM_Detailed_Description__c = 'Test';
        	requests.add(request);
            
    	}
    	insert requests;
        
        
        
        // Mass Update Requests
		requests = [select Id, GCM_Trigger_Automation__c from GCM_Service_Request__c where GCM_Type__c like 'Test%'];
        for (GCM_Service_Request__c request : requests) {            
            request.GCM_Trigger_Automation__c = Datetime.now().addHours(1);
        }
		update requests;
        
		// Assert Results 
		requests = [select Id, GCM_Related_Case_Id__c, GCM_Related_Case_Number__c from GCM_Service_Request__c where GCM_Type__c like 'Test%'];
        for (GCM_Service_Request__c request : requests) {
            System.assert(request.GCM_Related_Case_Id__c != null, 'Case Created');
        }
	}
}