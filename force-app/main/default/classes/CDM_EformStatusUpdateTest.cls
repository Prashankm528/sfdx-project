/**
*___________________________________________________
*@Name:     CDM_EformStatusUpdateTest
*@Author:   Chandra Kanchi
*@Created:  July 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get cover test code coverage for CDM_EformStatusUpdate class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/


@isTest

private with sharing class CDM_EformStatusUpdateTest {

 /**
    *————————————————————————————————————————————————————
    * @Description
    * test method.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 

static testMethod void CDM_EformStatusUpdateFromRPATest() {
    // prepare test-data

    //As Per Best Practice it is important to instantiate the Rest Context
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/Something'; //Request URL
    req.httpMethod = 'POST';

    RestContext.request = req;
    RestContext.response= res;
    
    List<CDM_StaticUtils.CDMEformsStatusUpdate> resData = new List<CDM_StaticUtils.CDMEformsStatusUpdate>();
    
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Draft');
    insert cdn;
    
    CDM_StaticUtils.CDMEformsStatusUpdate reswrap = new CDM_StaticUtils.CDMEformsStatusUpdate();
    reswrap.FIDocumentDate = '2019-01-01';
    reswrap.FIDocumentNumber = 'FI3455';
    reswrap.ProcessingError = 'Fail';
    reswrap.RecordId = cdn.id;
    
    resData.add(reswrap);
    
      
        String myJSON = JSON.serialize(resData);
        

        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/upsertaccount';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
    
    
    
    
    
    Test.startTest();
        String actual = CDM_EformStatusUpdate.cdmStatusUpdate();//HttpClass.updateCustomObject();
    Test.stopTest();

    System.assertEquals('Success', actual);
}



}