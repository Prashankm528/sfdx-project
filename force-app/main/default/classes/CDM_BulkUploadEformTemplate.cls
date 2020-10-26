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


public with sharing class CDM_BulkUploadEformTemplate{

    public String emailBody{get;set;}
   public String recId {
         get {
         system.debug(recId);
          return recId;}
        set { recId = value;
      
         String csvFileBody;
     
    
      String[] csvFileLines; 
      system.debug(recId);
      system.debug(recordId);
     
      set<Id> setDocumentIds = new set<Id>();
      
      
        String s = 'LinkedEntityId';
        List<String> accIdList = new List<String>();
      
            accIdList.add('\''+recId+'\'');
     
        String queryStr = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE '+s+ ' IN  '+accIdList;
              
      
      
      
      
       if(recId!=null) {
       for(ContentDocumentLink fileLink: database.query(queryStr)){
        setDocumentIds.add(fileLink.ContentDocumentId);
        }
        try {
        ContentVersion cv = [select Id, title, ContentDocumentId,VersionData from ContentVersion where ContentDocumentId in: setDocumentIds limit 1];
  
      emailBody = cv.VersionData.toString().trim();
      }catch(exception e) {system.debug(e.getMessage());}
        } 
      } 
   }
    public String recordId{get;set;}
    
    Public void setrecId(String a) {
       
      }

     
    public void getParameters() {
       
    }
 public CDM_BulkUploadEformTemplate() {
 
 
     
 }
 
   
}