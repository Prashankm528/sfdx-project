/**
*___________________________________________________
*@Name:     CDM_SendCDMSupportingNotesToRPA_test
*@Author:   Sid
*@Created:  28 July 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: this is test class for CDM_SendCDMSupportingNotesToRPA class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest 
public with sharing class CDM_SendCDMSupportingNotesToRPA_test {
	  /**
    *————————————————————————————————————————————————————
    * @Description
    * get test setup data.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
   @TestSetup
    private static void testdataSetup() 
    {    
   		User u= CDM_TestDataFactory.createUserWithRole();
    }
    /**
    *————————————————————————————————————————————————————
    * @Description
    * get convering the validate eform template.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    static testMethod void TestCdmSupportingNotes_RPA() 
    {
    	user u = [select id from user where alias = 'hasrole'];            
    	CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Review',
                                                                    CDM_Bulk_Upload__c = 'Yes');
    	insert cdn;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/abc/xyz/';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CDM_StaticUtils.CDMSupportingNotes  results = CDM_SendCDMSupportingNotesToRPA.getCDMFormRecords();
        system.assertNotEquals(NULL,results,'Assertion Passed');
        Test.stopTest();
    }
    
}