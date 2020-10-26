/**
*___________________________________________________
*@Name:     CDM_SendCDMSupportingNotesToRPA 
*@Author:   Chandra Kanchi
*@Created:  Feb 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for send supporting notes to RPA
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@RestResource(urlMapping='/CDMSupportingNotes/*')
global with sharing class CDM_SendCDMSupportingNotesToRPA {

    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * get cdm eform records send to RPA.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    @HttpGet
  static global CDM_StaticUtils.CDMSupportingNotes getCDMFormRecords() {
      CDM_StaticUtils.CDMSupportingNotes sNotes = new CDM_StaticUtils.CDMSupportingNotes();
      List<CDM_StaticUtils.CDMSuportingNote> sNote = new List<CDM_StaticUtils.CDMSuportingNote>();
        RestRequest req = RestContext.request;
       RestResponse res = RestContext.response;
       String cdmId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
       
       /* List<id> pInstanceTargetIds = new List<id>();
           for(ProcessInstance pi : [SELECT Id, TargetObjectId, (SELECT Id, StepStatus, Comments FROM StepsAndWorkitems where StepStatus='Pending')
                FROM ProcessInstance]) {
                if(pi.StepsAndWorkitems != null)
                    if(pi.StepsAndWorkitems.isEmpty())
                       pInstanceTargetIds.add(pi.TargetObjectId);
            }
        */
       
       List<CDM_Credit_Debit_Note__c> cdmRec  = [SELECT id,CDM_Supporting_Notes_SG__c , recordtype.Name,
                                               CDM_Supporting_Notes_SD__c ,CDM_Supporting_Notes_RC__c,CDM_Country__c,Name,CDM_Amount_Limit__c  FROM CDM_Credit_Debit_Note__c
                                               WHERE CDM_Form_Status__c = 'Review' and createddate = last_n_days:30 ORDER BY createddate DESC limit 15];
      if(cdmRec!=null) {
         for(CDM_Credit_Debit_Note__c cdm : cdmRec) {
              CDM_StaticUtils.CDMSuportingNote csNote = new CDM_StaticUtils.CDMSuportingNote();
              csNote.SupportingNotes_RC = replaceSemicolon(cdm.CDM_Supporting_Notes_RC__c);
              csNote.SupportingNotes_SD = replaceSemicolon(cdm.CDM_Supporting_Notes_SD__c);
              csNote.SupportingNotes_SG = replaceSemicolon(cdm.CDM_Supporting_Notes_SG__c);
              csNote.RecordName = cdm.Name;
              csNote.AmountLimit = cdm.CDM_Amount_Limit__c;
              csNote.RequestType = cdm.recordtype.Name;
              csNote.RecordId = cdm.Id;
              sNote.add(csNote);
              sNotes.CDMSuportingNote = sNote;
             
          }
        } 
         return sNotes;
        
                
      }
      
      public static String replaceSemicolon(String str) {
          return String.isNotBlank(str)? str.replace(',',';') : str;
      
      }
   
}