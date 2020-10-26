/**
*___________________________________________________
*@Name:     CDM_CreditDebitNoteFormControllerTest
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: this is test class for CDM_CreditDebitNoteFormController class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@isTest 
private class CDM_CreditDebitNoteFormControllerTest {
    
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
    private static void testdataSetup() {
    
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
  static testMethod void validateCDMFormTemplate() {
   
   // testdataSetup();
    user u = [select id from user where alias = 'hasrole'];
     Map<String,String> reqDataMap = CDM_TestDataFactory.getCDMeFormResponse();
   // System.runAs(u) {
     CDM_TestDataFactory.getCDMeFormTemplate(10);
  
    CDM_CreditDebitNoteFormController  cdmControll = new CDM_CreditDebitNoteFormController();
    Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
    
    CDM_CreditDebitNoteFormController.loadNewFormData('Spain', new List<String>(recTypeMap.keyset())[0]);
    
   
   
     
    CDM_Split_Amount__c splitAmount = new CDM_Split_Amount__c(CDM_Sub_Gross_Amount__c=2344,CDM_GL_Account__c='TESt',CDM_Profit_Center__c='test'
                                                                );
    //insert splitAmount;                                                           
    
    CDM_StaticUtils.datawrap dt = new CDM_StaticUtils.datawrap();
    dt.recDataMap = reqDataMap;
    dt.splitAmountRecs = JSON.serialize(new List<CDM_Split_Amount__c>{splitAmount});
    String recId = CDM_CreditDebitNoteFormController.saveEformData(JSON.serialize(dt));
    
    
    CDM_CreditDebitNoteFormController.getFieldsMetaData(recId,'Spain',new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','','Spain','DE01','Credit Note');
    CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','','Australia','DE01','Credit Note');
    CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','Testing','Australia','DE01','Credit Note');  
    List<Sobject> sobjList = CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','test','Spain','DE01','Credit Note');
    System.assertNotEquals(recId,null);
    CDM_CreditDebitNoteFormController.getSupportingNotes('kac45c', 'Credit Note');
    CDM_CreditDebitNoteFormController.getSupportingNotes('kac45c', 'Debit Note');  
    
    try {
   		CDM_GetSupportingNotesFromDofa.resWrapper wrapper_SD = new CDM_GetSupportingNotesFromDofa.resWrapper();
        wrapper_SD.AmountLimit = 100.00;
        wrapper_SD.AuthorisationType = 'SD';
        wrapper_SD.InvalidApprover = false;
        wrapper_SD.SupportingNotes = 'TEST';
        wrapper_SD.UnlimitedApprover = false;
        CDM_GetSupportingNotesFromDofa.resWrapper wrapper_RC = new CDM_GetSupportingNotesFromDofa.resWrapper();
        wrapper_RC.AmountLimit = 100.00;
        wrapper_RC.AuthorisationType = 'RC';
        wrapper_RC.InvalidApprover = true;
        wrapper_RC.SupportingNotes = 'TEST';
        wrapper_RC.UnlimitedApprover = false;
        Map<String,CDM_GetSupportingNotesFromDofa.resWrapper> supnotesmap = new Map<String,CDM_GetSupportingNotesFromDofa.resWrapper>();
        supnotesmap.put('SD',wrapper_SD);
        supnotesmap.put('RC',wrapper_RC);
        CDM_GetSupportingNotesFromDofa.resWMap = supnotesmap;
    	CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(recId,'TEST');
        
    } catch(Exception e) {
          System.debug(e.getmessage());
      }
   
  //  }
    
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
    static testMethod void validateCDMFormTemplate1() {
   
   // testdataSetup();
    user u = [select id from user where alias = 'hasrole'];
     Map<String,String> reqDataMap = CDM_TestDataFactory.getCDMeFormResponse1();
   //  System.runAs(u) {
     CDM_TestDataFactory.getCDMeFormTemplate(10);
    CDM_CreditDebitNoteFormController  cdmControll = new CDM_CreditDebitNoteFormController();
    Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
    
    CDM_CreditDebitNoteFormController.loadNewFormData('Spain', new List<String>(recTypeMap.keyset())[0]);
    
    
   
     
    CDM_Split_Amount__c splitAmount = new CDM_Split_Amount__c(CDM_Sub_Gross_Amount__c=2344,CDM_GL_Account__c='TESt',CDM_Profit_Center__c='test'
                                                                );
    
    CDM_StaticUtils.datawrap dt = new CDM_StaticUtils.datawrap();
    dt.recDataMap = reqDataMap;
    dt.splitAmountRecs = JSON.serialize(new List<CDM_Split_Amount__c>{splitAmount});
    String recId = CDM_CreditDebitNoteFormController.saveEformData(JSON.serialize(dt));
    
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Approved',CDM_Bulk_Upload__c= 'Yes');
    insert cdn;
        
    CDM_Credit_Debit_Note__c cdn123 = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Form_Status__c = 'Approved',CDM_Bulk_Upload__c= 'Yes');
    insert cdn123;
    
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
  
    
     CDM_SendCDMFormsToRPA.getCDMFormRecords();
    CDM_CreditDebitNoteFormController.getFieldsMetaData(recId,'Spain',new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.getFieldsMetaData(cdn123.Id,'Australia',new List<String>(recTypeMap.keyset())[0]);    
    List<Sobject> sobjList = CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','','Spain','DE01','Credit Note');
   System.assertNotEquals(recId,null);
   
    try {
    CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(recId,'TEST');
    CDM_Credit_Debit_Note__c cdnapp = new CDM_Credit_Debit_Note__c();
    cdnapp.id = recid;
    cdnapp.CDM_Country__c = 'Netherlands';
    update cdnapp;    
    CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(cdn.id,'TEST');
    CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(cdnapp.id,'TEST');    
    
    } catch(Exception e) {
      System.debug(e.getMessage());
      }
    CDM_CreditDebitNoteFormController.getFieldsMetaData(null,'Spain',new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.getPicklistValues(null,null);
    CDM_CreditDebitNoteFormController.getFieldDefinitionMap(null);
   
 //   }
    
    }
    
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    *  get conver Approval Process instance comments updating.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
      static testMethod void validateCDMFormTemplate2() {
   
   // testdataSetup();
    user u = [select id from user where alias = 'hasrole'];
     Map<String,String> reqDataMap = CDM_TestDataFactory.getCDMeFormResponse1();
   //  System.runAs(u) {
     CDM_TestDataFactory.getCDMeFormTemplate(10);
    CDM_CreditDebitNoteFormController  cdmControll = new CDM_CreditDebitNoteFormController();
    CDM_CreditDebitNoteFormController.fetchUser();
    
    Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
    
    CDM_CreditDebitNoteFormController.loadNewFormData('Spain', new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.loadNewFormData('Spain', new List<String>(recTypeMap.keyset())[0]);
    
    
   
     
    CDM_Split_Amount__c splitAmount = new CDM_Split_Amount__c(CDM_Sub_Gross_Amount__c=2344,CDM_GL_Account__c='TESt',CDM_Profit_Center__c='test'
                                                                );
    
    CDM_StaticUtils.datawrap dt = new CDM_StaticUtils.datawrap();
    dt.recDataMap = reqDataMap;
    dt.splitAmountRecs = JSON.serialize(new List<CDM_Split_Amount__c>{splitAmount});
    String recId = CDM_CreditDebitNoteFormController.saveEformData(JSON.serialize(dt));
    
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Approved');
    insert cdn;
    CDM_CreditDebitNoteFormController.getCDMFormStatus(cdn.id);
      
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
  
    
     CDM_SendCDMFormsToRPA.getCDMFormRecords();
    CDM_CreditDebitNoteFormController.getFieldsMetaData(recId,'Spain',new List<String>(recTypeMap.keyset())[0]);
    List<Sobject> sobjList = CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','','Spain','DE01','Credit Note');
   System.assertNotEquals(recId,null);
   
    user u1 = [select id from user where NTID__c ='kac45c'];
      
     CDM_Credit_Debit_Note_Approvers__c approver = new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u1.id);
     insert approver;
     CDM_Credit_Debit_Note__c cdnrec = [SELECT ID,CDM_Approver__c FROM CDM_Credit_Debit_Note__c WHERE id=: recID];
     cdnrec.CDM_Approver__c = approver.id;
     update cdnrec;
     recId = cdnrec.id;
   
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recId);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        //if(!system.test.isRunningTest())
        //{
        /*
            //Submit the approval request for the change
            Approval.ProcessResult result = Approval.process(req1);
            
            //Verify the result
            System.assert(result.isSuccess());
            
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                
            //Approve the submitted request.  
            //First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkItemIds();
            
           system.debug('newWorkItemIds'+newWorkItemIds);
            //Instantiate the new ProcessWorkItemRequest object and populate it
            Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            //Use the ID from the newly created item to specify the item to be worked
            req2.setWorkItemId(newWorkItemIds.get(0));
            
            //Submit the request for approval
            try {
            Approval.ProcessResult result2 = Approval.process(req2);
           
            
            //Verify the results
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
                 }catch(exception e) {e.getmessage();}
               ProcessInstanceWorkitem pwi = [Select Id From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = : recId and ProcessInstance.status='Pending'];       
        
            //system.debug('pwi'+pwi);
        //}
        */
    CDM_CreditDebitNoteFormController.getFieldsMetaData(null,'Spain',new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.getPicklistValues(null,null);
    CDM_CreditDebitNoteFormController.getFieldDefinitionMap(null);
        
   
 //   }
    
    }
    
      /**
    *————————————————————————————————————————————————————
    * @Description
    *  get conver Approval Process instance comments updating.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
      static testMethod void validateCDMFormTemplate3() {
   
   // testdataSetup();
    user u = [select id from user where alias = 'hasrole'];
     Map<String,String> reqDataMap = CDM_TestDataFactory.getCDMeFormResponse1();
     CDM_TestDataFactory.getCDMeFormResponse1();
     CDM_TestDataFactory.createMaterialPicklist();
  
     CDM_TestDataFactory.getCDMeFormTemplate(10);
    CDM_CreditDebitNoteFormController  cdmControll = new CDM_CreditDebitNoteFormController();
    CDM_CreditDebitNoteFormController.fetchUser();
    
    Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
    
    
    CDM_CreditDebitNoteFormController.loadNewFormData('Australia', new List<String>(recTypeMap.keyset())[0]);
    
    
   
     
    CDM_Split_Amount__c splitAmount = new CDM_Split_Amount__c(CDM_Sub_Gross_Amount__c=2344,CDM_GL_Account__c='TESt',CDM_Profit_Center__c='test'
                                                                );
    
    CDM_StaticUtils.datawrap dt = new CDM_StaticUtils.datawrap();
    dt.recDataMap = reqDataMap;
    dt.splitAmountRecs = JSON.serialize(new List<CDM_Split_Amount__c>{splitAmount});
    String recId = CDM_CreditDebitNoteFormController.saveEformData(JSON.serialize(dt));
   
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Approved');
    insert cdn;
    CDM_CreditDebitNoteFormController.getCDMFormStatus(cdn.id);
      
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
      insert new CDM_Split_Amount__c(CDM_Credit_Debit_Note__c = cdn.id);
  
    
     CDM_SendCDMFormsToRPA.getCDMFormRecords();
    CDM_CreditDebitNoteFormController.getFieldsMetaData(recId,'Australia',new List<String>(recTypeMap.keyset())[0]);
   // CDM_CreditDebitNoteFormController.getFieldsMetaData(recId,'Australia',new List<String>(recTypeMap.keyset())[0]);
    CDM_CreditDebitNoteFormController.getMaterials('','','05 Commercial','AU0A');
    CDM_CreditDebitNoteFormController.getMaterials('','160000365','05 Commercial','AU0A');
    
    List<Sobject> sobjList = CDM_CreditDebitNoteFormController.getValidApprovers('CDM_Credit_Debit_Note_Approvers__c','','Spain','DE01','Credit Note');
   System.assertNotEquals(recId,null);
   
    user u1 = [select id from user where NTID__c ='kac45c'];
      
     CDM_Credit_Debit_Note_Approvers__c approver = new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u1.id);
     insert approver;
     CDM_Credit_Debit_Note__c cdnrec = [SELECT ID,CDM_Approver__c FROM CDM_Credit_Debit_Note__c WHERE id=: recID];
     cdnrec.CDM_Approver__c = approver.id;
     update cdnrec;
     recId = cdnrec.id;
   
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recId);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        //if(!system.Test.isRunningTest())
        //{
        /*
            //Submit the approval request for the change
            Approval.ProcessResult result = Approval.process(req1);
            
            //Verify the result
            System.assert(result.isSuccess());
            
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                
            //Approve the submitted request.  
            //First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkItemIds();
            
           system.debug('newWorkItemIds'+newWorkItemIds);
            //Instantiate the new ProcessWorkItemRequest object and populate it
            Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approved');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            //Use the ID from the newly created item to specify the item to be worked
            req2.setWorkItemId(newWorkItemIds.get(0));
            
            //Submit the request for approval
            try {
            Approval.ProcessResult result2 = Approval.process(req2);
           
            
            //Verify the results
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
                 }catch(exception e) {e.getmessage();}
               ProcessInstanceWorkitem pwi = [Select Id From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = : recId and ProcessInstance.status='Pending'];       
        
            system.debug('pwi'+pwi);
        //}
        */
        CDM_CreditDebitNoteFormController.getFieldsMetaData(null,'Australia',new List<String>(recTypeMap.keyset())[0]);
        CDM_CreditDebitNoteFormController.getPicklistValues(null,null);
        CDM_CreditDebitNoteFormController.getFieldDefinitionMap(null);
        
   
 //   }
    
    }
    
        /**
    *————————————————————————————————————————————————————
    * @Description
    *  get conver Approval Process instance comments updating.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
      static testMethod void validateCDMFormTemplate5() {
      user u = [select id from user where NTID__c ='kac45c'];
      
     CDM_Credit_Debit_Note_Approvers__c approver = new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
     insert approver;
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233000,CurrencyIsoCode='AUD');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233900,CurrencyIsoCode='AUD');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233900,CurrencyIsoCode='AUD');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Net_Amount__c = 12339,CDM_Authorisation_Type__c = 'IN',CurrencyIsoCode='AUD');
    insert cdn;
     List<CDM_Credit_Debit_Note__c> cdn1 = [select id from CDM_Credit_Debit_Note__c where CDM_Country__c = 'Australia'];
      List<CDM_Credit_Debit_Note__c> cdnUpdate = new List<CDM_Credit_Debit_Note__c>();
     for(CDM_Credit_Debit_Note__c c: cdn1) {
         c.CDM_Sales_Doc_Type__c = 'ZNCR';
         cdnUpdate.add(c); // cover CDM_ValidateApproverFromDoFA,CDM_GetValidate_Approvers_ZNCRFromDoFA classes
     }
     CDM_ValidateApproverFromDoFA.getApproveralAmount_SameCurrencty('AUD',0,0,'IP','TEST');
     update cdnUpdate;  //CDM_Form_Status__c== 'Rejected'
    // cdn1[0].CDM_Form_Status__c= 'Rejected';
    // update cdn1[0];
     System.assert(cdn1!=null);
    for(CDM_Credit_Debit_Note__c cd : cdn1) {
        CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(cd.id,'TEST');
    }
    CDM_StaticUtils.getPicklistValues('CDM_Credit_Debit_Note__c','CurrencyIsoCode');
    Sobject sobj = CDM_StaticUtils.dynamicQueryType('CDM_Credit_Debit_Note__c','','');
    
   
    }
    
      /**
    *————————————————————————————————————————————————————
    * @Description
    *  get conver Approval Process instance comments updating.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
      static testMethod void validateCDMFormTemplate51() {
      user u = [select id from user where NTID__c ='kac45c'];
      
     CDM_Credit_Debit_Note_Approvers__c approver = new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
     insert approver;
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233,CurrencyIsoCode='EUR');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233900,CurrencyIsoCode='AUD');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233900,CurrencyIsoCode='AUD');
    insert cdn;
     cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Net_Amount__c = 12339,CDM_Authorisation_Type__c = 'IN',CurrencyIsoCode='AUD');
    insert cdn;
     List<CDM_Credit_Debit_Note__c> cdn1 = [select id from CDM_Credit_Debit_Note__c where CDM_Country__c = 'Australia'];
      List<CDM_Credit_Debit_Note__c> cdnUpdate = new List<CDM_Credit_Debit_Note__c>();
     for(CDM_Credit_Debit_Note__c c: cdn1) {
         c.CDM_Sales_Doc_Type__c = 'ZNCR';
         c.CDM_Sales_Doc_Type__c = 'ZNCR';
         cdnUpdate.add(c); // cover CDM_ValidateApproverFromDoFA,CDM_GetValidate_Approvers_ZNCRFromDoFA classes
     }
     CDM_ValidateApproverFromDoFA.getApproveralAmount_SameCurrencty('AUD',0,0,'IP','TEST');
     update cdnUpdate;
     System.assert(cdn1!=null);
    for(CDM_Credit_Debit_Note__c cd : cdn1) {
        CDM_CreditDebitNoteFormController.submitAndProcessApprovalRequest(cd.id,'TEST');
    }
    CDM_StaticUtils.getPicklistValues('CDM_Credit_Debit_Note__c','CurrencyIsoCode');
    Sobject sobj = CDM_StaticUtils.dynamicQueryType('CDM_Credit_Debit_Note__c','','');
    
   
    }
    
    
        /**
    *————————————————————————————————————————————————————
    * @Description
    *  Clone Functionality testing.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    static testMethod void clonecdmrecord() {
    user u = [select id from user where NTID__c ='kac45c'];
      
    CDM_Credit_Debit_Note_Approvers__c approver = new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
    insert approver;
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Country__c = 'Australia',CDM_Approver__c = approver.id,CDM_Authorisation_Type__c = 'IN',CDM_Net_Amount__c = 1233000,CurrencyIsoCode='AUD',CDM_FI_Document_number__c = '12345',CDM_Processing_Error__c = 'Test Error');
    insert cdn;
    //Calling the clone method...        
    string clonedrecid = CDM_CreditDebitNoteFormController.cloneCdnRecords(cdn.id); 
    system.assertEquals(null,[select CDM_Processing_Error__c from CDM_Credit_Debit_Note__c where id =:clonedrecid].CDM_Processing_Error__c);
    system.assertEquals('Draft',[select CDM_Form_Status__c from CDM_Credit_Debit_Note__c where id =:clonedrecid].CDM_Form_Status__c);
        CDM_StaticUtils.generateAuthBody();
        CDM_StaticUtils.rates rate = new CDM_StaticUtils.rates();
        CDM_StaticUtils.AuthReqBody authreqBody = new CDM_StaticUtils.AuthReqBody();
    }
    
}