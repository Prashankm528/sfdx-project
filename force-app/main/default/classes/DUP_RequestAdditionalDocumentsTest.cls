@isTest
public class DUP_RequestAdditionalDocumentsTest {
	@testSetup
    static void testSetup(){
        List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(2);
        insert entityList;
        DUP_Document_Request__c docRequest = New DUP_Document_Request__c();
            docRequest.DUP_CounterParty_Name__c =('ControlerTest');
        	docRequest.DUP_Status_Upload__c     = 'DUP_New_Request';
            docRequest.DUP_Email_Templates__c = 'New / Existing Counterparty Template';
            docRequest.DUP_BP_Entity_Details__c = entityList[0].Id;
            docRequest.DUP_Risk_Status__c = 'Low';
            docRequest.DUP_ICOSId__c = '000000';
            docRequest.DUP_doc_submitted_status__c = 'Document Requested';
            docRequest.DUP_RBU__c = 'BPGWA';
        insert docRequest;
        List<DUP_Document_Request__c> newRequestList = new List<DUP_Document_Request__c>();
        for (Integer i = 0; i < 2; i ++) {
            DUP_Document_Request__c newRequest = New DUP_Document_Request__c();
            newRequest.DUP_CounterParty_Name__c =('ControlerTest' + i);
        	newRequest.DUP_Status_Upload__c     = 'DUP_New_Request';
            newRequest.DUP_Email_Templates__c = 'Additional Info Review Request Template';
            newRequest.DUP_BP_Entity_Details__c = entityList[i].Id;
            newRequest.DUP_Risk_Status__c = 'Low';
            newRequest.DUP_ICOSId__c = '000000' + i;
            newRequest.DUP_doc_submitted_status__c = 'Document Requested';
            newRequest.DUP_RBU__c = 'BPGWA';
            newRequest.DUP_Linked_Document_Request__c = docRequest.Id;
        	newRequestList.add(newRequest);
        }
        insert newRequestList;
    }
    
    /**
    * @description  test method for getStatus method
    **/
    @isTest
    static void getStatusTest(){
        DUP_Document_Request__c newRequestTest = [SELECT Name, Id , DUP_Status_Upload__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest' 
                                                  LIMIT 1];
        test.startTest();
        string status = DUP_RequestAdditionalDocuments.getStatus(newRequestTest.Id);
        test.stopTest();
        system.assertEquals(newRequestTest.DUP_Status_Upload__c, status);
    }
    
    /**
    * @description  test method for createDocumentRequest method
    * condition: (DUP_Linked_Document_Request__c==null) and email template=system.label.DUP_EmailTemplate_NewRequest
    **/
    @isTest
    static void createDocumentRequestTest1(){
        DUP_Document_Request__c newRequestTest = [SELECT Id , DUP_Status_Upload__c,DUP_Email_Templates__c,DUP_Linked_Document_Request__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest' 
                                                  LIMIT 1];
        test.startTest();
        id returnID = DUP_RequestAdditionalDocuments.createDocumentRequest(newRequestTest.id);
        test.stopTest();
        DUP_Document_Request__c returnedRequest = [SELECT Id , DUP_Status_Upload__c,DUP_Email_Templates__c,
                                                   DUP_Linked_Document_Request__c,DUP_doc_submitted_status__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE id=:returnID];
        system.assertEquals('Confirm Details', returnedRequest.DUP_doc_submitted_status__c);
        system.assertEquals('DUP_Confirm_Details', returnedRequest.DUP_Status_Upload__c);
        system.assertEquals('Additional Info Request Template', returnedRequest.DUP_Email_Templates__c);
        system.assertEquals(newRequestTest.Id, returnedRequest.DUP_Linked_Document_Request__c);
    }
    
    /**
    * @description  test method for createDocumentRequest method
    * condition: (DUP_Linked_Document_Request__c!=null) and email template=system.label.DUP_EmailTemplate_NewReviewRequest
    **/
    @isTest
    static void createDocumentRequestTest2(){
        DUP_Document_Request__c newRequestTest = [SELECT Id , DUP_Status_Upload__c,DUP_Email_Templates__c,DUP_Linked_Document_Request__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE DUP_CounterParty_Name__c ='ControlerTest0' 
                                                  LIMIT 1];
        test.startTest();
        id returnID = DUP_RequestAdditionalDocuments.createDocumentRequest(newRequestTest.id);
        test.stopTest();
        DUP_Document_Request__c returnedRequest = [SELECT Id , DUP_Status_Upload__c,DUP_Email_Templates__c,
                                                   DUP_Linked_Document_Request__c,DUP_doc_submitted_status__c
                                                  FROM DUP_Document_Request__c 
                                                  WHERE id=:returnID];
        system.assertEquals('Confirm Details', returnedRequest.DUP_doc_submitted_status__c);
        system.assertEquals('DUP_Confirm_Details', returnedRequest.DUP_Status_Upload__c);
        system.assertEquals('Additional Info Review Request Template', returnedRequest.DUP_Email_Templates__c);
        system.assertEquals(newRequestTest.DUP_Linked_Document_Request__c, returnedRequest.DUP_Linked_Document_Request__c);
    }
    
}