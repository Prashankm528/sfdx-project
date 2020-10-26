/**
*___________________________________________________
*@Name:     CDM_GetApproversFromDOFA
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get valid approvers from dofa, here get data from csv file.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/


public with sharing class CDM_GetApproversFromDOFA {

  /**
    *————————————————————————————————————————————————————
    * @Description
    * save approvers data.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
 @AuraEnabled
     public static List<Sobject> saveApproversData(String csvFileBody) {
      
      List<CDM_Credit_Debit_Note_Approvers__c> cdmApproversList = new List<CDM_Credit_Debit_Note_Approvers__c>();
      Map<String,List<CDM_Credit_Debit_Note_Approvers__c>> cdmApprsList = new Map<String,List<CDM_Credit_Debit_Note_Approvers__c>>();
      Map<String,set<String>> cdmexistingApprsList = new Map<String,set<String>>();
      List<CDM_Credit_Debit_Note_Approvers__c> NTidsList = new List<CDM_Credit_Debit_Note_Approvers__c>();
      Map<String,set<String>> dofaApprovrsMap = new Map<String,set<String>>();
      Map<String,set<String>> cdmApprovrsMap = new Map<String,set<String>>();
      set<String> ntIds = new set<String>();
      //set<String> NtIds = new set<String>();
      String[] csvFileLines;
      csvFileBody = EncodingUtil.urlDecode(csvFileBody, 'UTF-8');
      Blob csvData  = EncodingUtil.base64Decode(csvFileBody);
      csvFileBody = csvData.toString();
      csvFileLines = csvFileBody.split('\n'); 
           for(Integer i=1;i<csvFileLines.size();i++) {
              string[] csvRecordData = csvFileLines[i].split(',');
              if(csvRecordData!=null)
                  if(!csvRecordData.isempty() && csvRecordData.size()>2) {
                      ntIds.add(csvRecordData[1].trim());     
                      ntIds.add(csvRecordData[3].trim());
                  
                  }
               }
               system.debug(ntIds);
        for(CDM_Credit_Debit_Note_Approvers__c cdm : [SELECT id,CDM_Requester_NTID__c,Name,CDM_Approver_NTID__c,//Supporting_Notes__c,
        CDM_Approver_User__c,CDM_Requester_User__c
                                                        from CDM_Credit_Debit_Note_Approvers__c  LIMIT 49999]) {
           if(cdmexistingApprsList.containsKey(cdm.CDM_Requester_NTID__c))
               cdmexistingApprsList.get(cdm.CDM_Requester_NTID__c).add(cdm.CDM_Approver_NTID__c);
           else
               cdmexistingApprsList.put(cdm.CDM_Requester_NTID__c , new set<String> {cdm.CDM_Approver_NTID__c});     
       }    
      
      System.debug(cdmexistingApprsList) ;
        Map<String,String> usersMap = new Map<String,String>();
       for(User u : [SELECT id,NTID__c,Name FROM User WHERE NTID__c!=null AND NTID__c = : ntIds LIMIT 49999]) 
           usersMap.put(u.NTID__c,u.id);
                         
               for(Integer i=1;i<csvFileLines.size();i++) {
                  string[] csvRecordData = csvFileLines[i].split(',');
                  if(csvRecordData!=null)
                      if(!csvRecordData.isempty() && csvRecordData.size()>3 && usersMap.containsKey(csvRecordData[1].trim()) &&  usersMap.containsKey(csvRecordData[3].trim())) {
                         if(cdmexistingApprsList.containsKey(csvRecordData[1].trim())) {
                             if(!cdmexistingApprsList.get(csvRecordData[1].trim()).contains(csvRecordData[3].trim())) { 
                              
                            } else
                                 cdmApproversList.add(new CDM_Credit_Debit_Note_Approvers__c(CDM_Requester_NTID__c = csvRecordData[1].trim(),
                                                                         Name = csvRecordData[2].trim(),CDM_Approver_NTID__c=csvRecordData[3].trim(),
                                                                        // Supporting_Notes__c = csvRecordData[4].trim(),
                                                                         CDM_Approver_User__c = usersMap.get(csvRecordData[3].trim()),
                                                                         CDM_Requester_User__c = usersMap.get(csvRecordData[1].trim())));                                                   
                          } else {
                                 cdmApproversList.add(new CDM_Credit_Debit_Note_Approvers__c(CDM_Requester_NTID__c = csvRecordData[1].trim(),
                                                                         Name = csvRecordData[2].trim(),CDM_Approver_NTID__c=csvRecordData[3].trim(),
                                                                       //  Supporting_Notes__c = csvRecordData[4].trim(),
                                                                         CDM_Approver_User__c = usersMap.get(csvRecordData[3].trim()),
                                                                         CDM_Requester_User__c = usersMap.get(csvRecordData[1].trim())));
                                
                             }  
                          
                                
                   
                      }
                  }    
                                                     
      
      
           upsert cdmApproversList;
         
    return cdmApproversList;
    }
}