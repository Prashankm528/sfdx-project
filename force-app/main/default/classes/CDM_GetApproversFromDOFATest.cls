/**
*___________________________________________________
*@Name:     CDM_GetApproversFromDOFATest
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for cover test code coverage for CDM_GetApproversFromDOFA class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/


@isTest 
private with sharing class CDM_GetApproversFromDOFATest {
  static testMethod void GetApproversFromDOFA() {
      List<User> uList = [SELECT id,NTID__c,Name FROM user WHERE NTID__c!=null LIMIT 10];
      
      insert new CDM_Credit_Debit_Note_Approvers__c(CDM_Requester_NTID__c = uList[0].NTID__c, CDM_Approver_NTID__c = uList[1].NTID__c);
      insert new CDM_Credit_Debit_Note_Approvers__c(CDM_Requester_NTID__c = uList[2].NTID__c, CDM_Approver_NTID__c = uList[3].NTID__c);
      
        
      String csvfileString = 'Requestor Name,Requestor NTID,Approver Name,Approver NTID,Supporting Notes\n' + uList[0].Name+','+ uList[0].NTID__c +','+uList[1].Name+',' +  uList[1].NTID__c + ',supporting\n' + uList[2].Name+','+ uList[2].NTID__c +','+uList[3].Name+',' +  uList[3].NTID__c + ',supporting\n' + uList[4].Name+','+ uList[4].NTID__c +','+uList[5].Name+',' +  uList[5].NTID__c + ',supporting\n' + uList[6].Name+','+ uList[6].NTID__c +','+uList[7].Name+',' +  uList[7].NTID__c + ',supporting';
      String csvAsString = EncodingUtil.base64Encode(Blob.valueOf(csvfileString));
      List<Sobject> records =  CDM_GetApproversFromDOFA.saveApproversData(csvAsString); 
       System.assertNotEquals(records , null);
  }
  }