/**
*___________________________________________________
*@Name:     CDM_EformsCsvUpload
*@Author:   Chandra Kanchi
*@Created:  OCT 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get upload bulk CDM Eform from parent CDM form.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_EformsCsvUpload {
    
    /**
*————————————————————————————————————————————————————
* @Description
* createChildEformsData method save child cdn records and cdn lines records.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
   // public static set<String> parentFieldsApiMap = new set<String>(); 
    public static Map<String,String> CDNLineFieldsApiMap = new Map<String,String>(); 
    public static List<CDM_Split_Amount__c> newCDMLines = new List<CDM_Split_Amount__c>();
 
    @auraEnabled
    public static void createChildEformsData(Id recId,Id cId) {
        
        String csvFileBody;
       // String recId = cdmLst[0];
        Map<String, Schema.SObjectField> fieldMap = CDM_StaticUtils.cdmSchema.get('CDM_Credit_Debit_Note__c').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> childfieldMap = CDM_StaticUtils.cdmSchema.get('CDM_Split_Amount__c').getDescribe().fields.getMap();
        Map<String,List<CDM_Split_Amount__c>> childCDMLinesMap = new Map<String,List<CDM_Split_Amount__c>>();
        Map<String,String> fieldsApiMap = new Map<String,String>();  // this map have fields which is having with out split case fields
        Map<String,String> fieldsApiCdnLinesMap = new Map<String,String>(); // this map have fields which is having with split case fields
        
        List<CDM_Split_Amount__c> newCDMLines = new List<CDM_Split_Amount__c>();
        
        String[] csvFileLines; 
        set<Id> setDocumentIds = new set<Id>();
        List<String> recIdList = new List<String>();
        String s = 'Id';
        recIdList.add('\''+cId+'\'');
        
        String queryStr = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE '+s+ ' IN  '+recIdList;
        
        
        if(recId!=null) {
            for(ContentDocumentLink fileLink: database.query(queryStr)){
                setDocumentIds.add(fileLink.ContentDocumentId);
            }
            system.debug('setDocumentIds :'+setDocumentIds);
            ContentVersion cv = [select Id, title, ContentDocumentId,VersionData from ContentVersion where ContentDocumentId in: setDocumentIds limit 1];
            
            csvFileBody= cv.VersionData.toString();
            
            csvFileBody= cv.VersionData.toString();
            
            system.debug(csvFileBody);
            if(csvFileBody != null)
                csvFileLines = csvFileBody.split('\n'); 
            
            Map<integer,String> fieldsMap = new Map<integer,String>();
            
            List<String> csvFieldHeaders = csvFileLines[0].split(',');
            for(integer k=0;k< csvFieldHeaders.size(); k++) {
                if(csvFieldHeaders[k] != null)
                fieldsMap.put(k,csvFieldHeaders[k].trim());
            }  
            
            for(CDM_Eform_CSV_Template__mdt ut: (List<CDM_Eform_CSV_Template__mdt>)CDM_StaticUtils.dynamicQueryListType('CDM_Eform_CSV_Template__mdt',null,null)) {
                fieldsApiMap.put(ut.Template_Name__c,ut.Field_Api_Name__c);
            }
            
         /*   for(CDM_Eform_Bulk_Upload_Parent__mdt ut: (List<CDM_Eform_Bulk_Upload_Parent__mdt>)CDM_StaticUtils.dynamicQueryListType('CDM_Eform_Bulk_Upload_Parent__mdt',null,null)) {
                parentFieldsApiMap.add(ut.Parent_Field__c);
            } */
            
            for(CDM_Eform_CSV_CDN_Lines__mdt ut: (List<CDM_Eform_CSV_CDN_Lines__mdt>)CDM_StaticUtils.dynamicQueryListType('CDM_Eform_CSV_CDN_Lines__mdt',null,null)) {
                CDNLineFieldsApiMap.put(ut.CDM_Template_Name__c,ut.CDM_Field_Api_Name__c);
            }
            
          
            CDM_Credit_Debit_Note__c parentRec;
            
            
            List<SObject> childCDMs = new List<SObject>();
            String cNumber;
            parentRec = new CDM_Credit_Debit_Note__c();
            CDM_Split_Amount__c cdnLine = new CDM_Split_Amount__c();
            system.debug(csvFileLines.size());
           
            for(Integer i=1;i<csvFileLines.size();i++) {
                cdnLine = new CDM_Split_Amount__c();
                csvFileLines[i] = removeComma(csvFileLines[i].trim());
                
                List<String> csvFieldsData = csvFileLines[i].split(',');
                
                for(integer j=0;j< csvFieldsData.size(); j++) {
                    if(fieldsMap.containsKey(j)) {
                        if(cNumber == null) {
                            
                            parentRec = (CDM_Credit_Debit_Note__c)getFieldMapping(fieldsApiMap,fieldsMap,j,csvFieldsData,parentRec,fieldMap); 
                            if(csvFileLines.size() > 2) {
                                cdnLine = (CDM_Split_Amount__c)getFieldMapping(CDNLineFieldsApiMap,fieldsMap,j,csvFieldsData,cdnLine,childfieldMap); 
                                //newCDMLines.add(cdnLine);
                            }
                            
                        } else {
                            if(csvFileLines.size() > 2) {
                                cdnLine = (CDM_Split_Amount__c)getFieldMapping(CDNLineFieldsApiMap,fieldsMap,j,csvFieldsData,cdnLine,childfieldMap); 
                               // newCDMLines.add(cdnLine);
                            }
                        }      
                        
                    }   
                } 
                if(cdnLine.cdm_sub_Net_Amount__c != null)
                    newCDMLines.add(cdnLine);
                
                if(cNumber == null)
                    cNumber = parentRec.CDM_Customer_Number__c;
                
            } 
            getUpdateNetAmount(parentRec,newCDMLines,recId);
            parentRec.CDM_CH_Csv_Upload__c = false;
            parentRec.CDM_Bline_Date__c = parentRec.CDM_Due_Date__c != null? parentRec.CDM_Due_Date__c : parentRec.CDM_Bline_Date__c != null? parentRec.CDM_Bline_Date__c : date.today();
           // parentRec.CDM_CH_Csv_Upload__c = false;
            parentRec.CDM_Bulk_Upload__c = '';
            if(parentRec.CDM_Payment_Term__c == null || parentRec.CDM_Payment_Term__c == '')
                parentRec.CDM_Payment_Term__c = 'C158';
                parentRec.Id = recId;
            
            system.debug(parentRec);
            system.debug(newCDMLines);
            savepoint sp = database.setSavepoint();
            Update parentRec;
            insert newCDMLines;
            boolean incorrectProfitCenter = false;
            //Checking if Profit Center and Cost center are as per requirement...
       		for(CDM_Split_Amount__c cdmsp : newCDMLines)
       		{
           		if((cdmsp.CDM_Profit_Center__c != NULL && cdmsp.CDM_Profit_Center__c.length() != 7)
                   || (cdmsp.CDM_Cost_Center__c != NULL && cdmsp.CDM_Cost_Center__c.length() != 10))
           		{
                    incorrectProfitCenter = true;
                }
            }
            if(incorrectProfitCenter)
            {
            	database.rollback(sp);
                //Send Email to requester...
                //Querying Template Id...
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'CDM_Notify Requester on SWISS Failed Form'];
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id,parentRec.createdbyId, parentRec.Id); 
                email.setTargetObjectId(parentRec.createdbyId);
                system.debug('parentRec.createdbyId :'+parentRec.createdbyId);
                system.debug('parentRec.Id :'+parentRec.Id);
                email.saveAsActivity = false;
                email.setTemplateID(emailTemplate.Id);
                email.setSenderDisplayName('CDM Reviewer'); 
                email.setReplyTo('no-reply@company.com');
                Id userId = [select createdbyId from CDM_Credit_debit_Note__c where id = :parentRec.Id].createdbyId;                
                string toemailaddress = [select email from user where id = :userId].email;
                email.toAddresses = new String[] {toemailaddress};
                //Sending email...
                if(!Test.isRunningTest()) {
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                }
				parentrec.CDM_Form_Status__c = 'Failed';
                parentrec.CDM_Processing_Error__c = 'Form failed due to csv file showing an invalid profit/cost centre number. Please update data in file and initiate new form. Alternatively please make adjustments in failed form and resubmit.';
                update parentrec;
            }               		           		            
        }
        
    }
    
    // update net amount value from cdn line items
      public static void getUpdateNetAmount(CDM_Credit_Debit_Note__c  parentRec,List<CDM_Split_Amount__c> cdnLine,String recId) {
       Decimal netAmount = 0;
       Decimal subGrossAmount = 0;
       if(!cdnLine.isEmpty()) { 
           for(CDM_Split_Amount__c sline: cdnLine) {
               netAmount += sline.CDM_Sub_Net_Amount__c;
              // subGrossAmount += sline.CDM_Sub_Gross_Amount__c;
               sline.CDM_Credit_Debit_Note__c = recId;
               }
       parentRec.CDM_Net_Amount__c = netAmount;    
       //parentRec.CDM_Gross_Amount__c = subGrossAmount;    
       parentRec.CDM_Split_Required__c = 'Yes';    
       } 
           
      
    }
  
  // set parent fields empty when split case is yes 
   public static void setParentFieldsEmpty(CDM_Credit_Debit_Note__c  parentRec) {
       parentRec.CDM_GL_Account__c = '';
       parentRec.CDM_Tax_Rate__c = null;            
       parentRec.CDM_Tax_Code__c = '';                        
       parentRec.CDM_Tax_Amount__c = null;                        
       parentRec.CDM_Profit_Center__c = '';                        
       parentRec.CDM_Gross_Amount__c = null;                        
       parentRec.CDM_Item_Text__c = '';    
       
   
   }
    
    // get field mapping
    private static SObject getFieldMapping(Map<String,String> fieldsApiMap,Map<integer,String> fieldsMap,integer j,List<String> csvFieldsData,SObject Rec,Map<String, Schema.SObjectField> fieldMap) {
        
        system.debug(csvFieldsData[j]);
      
        if(fieldsApiMap.containsKey(fieldsMap.get(j))) {
            
           system.debug(fieldsMap.get(j));
           system.debug(fieldsApiMap.get(fieldsMap.get(j)));
           system.debug(fieldMap.get(fieldsApiMap.get(fieldsMap.get(j))));
            
            String dType = String.valueOf(fieldMap.get(fieldsApiMap.get(fieldsMap.get(j))).getDescribe().getType());
            system.debug(dType);
            system.debug('fieldsApiMap.get(fieldsMap.get(j)) :'+fieldsApiMap.get(fieldsMap.get(j)));
            if(dType == 'PERCENT' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME' || 
               dType == 'BOOLEAN' || dType == 'DOUBLE') {
                   if(dType == 'PERCENT' || dType == 'CURRENCY' || dType == 'DOUBLE')
                       if(csvFieldsData[j]!=null && csvFieldsData[j] !=''){                           
                           Rec.put(fieldsApiMap.get(fieldsMap.get(j)),Decimal.valueOf(csvFieldsData[j].remove('%').remove('€').trim()));
                       }
                  
                   if(dType == 'DATE' || dType == 'DATETIME')
                       if(csvFieldsData[j]!=null && csvFieldsData[j]!='')
                       Rec.put(fieldsApiMap.get(fieldsMap.get(j)),getdateFormat(csvFieldsData[j]));  
                   
                   if(dType == 'BOOLEAN')
                       Rec.put(fieldsApiMap.get(fieldsMap.get(j)),Boolean.valueOf(csvFieldsData[j]));    
                   
                   
               } else {
                   if(fieldsApiMap.get(fieldsMap.get(j)) == 'CDM_Profit_Center__c' ||
                      fieldsApiMap.get(fieldsMap.get(j)) == 'CDM_Cost_Center__c'){
                          
                          if(csvFieldsData[j].length() == 7){
                              Rec.put('CDM_Profit_Center__c', csvFieldsData[j]);
                          }
                          else if(csvFieldsData[j].length() == 10){
                              Rec.put('CDM_Cost_Center__c', csvFieldsData[j]);
                          }
                          else{
                              Rec.put('CDM_Profit_Center__c', csvFieldsData[j]);
                          }
                      }
                   else
                   Rec.put(fieldsApiMap.get(fieldsMap.get(j)), csvFieldsData[j]);
               } 
        } 
        return Rec;              
        
    }  
    // get data formate for date
    private static date getdateFormat(String str) {
        List<String> dates = str.split('/');
        
        if(dates.size() == 3) {
            string year = dates[2];
            string month = dates[1];
            string day = dates[0];
            
            string stringDate = year + '-' + month
                + '-' + day;
            return date.valueOf(stringDate);
        } else
            return null;
       
        
    }  
    // remove additional comma's in in each line
    private static String removeComma(String csvRec) {
        
        String s2 = csvRec.substringBetween('"','"');
        if(s2!=null)
            csvRec = csvRec.replace('"'+s2+'"', s2.remove(','));
        s2 = csvRec.substringBetween('"','"');
        
        if(s2!=null)
            if(s2.contains(','))
            csvRec = removeComma(csvRec);
        return csvRec;                
    }
    
    @auraEnabled
    public static void updateParentNetAmountNL(Id recId,Id cId) {
        system.debug('Coming here');
        String csvFileBody;
        String[] csvFileLines; 
        set<Id> setDocumentIds = new set<Id>();
        List<String> recIdList = new List<String>();
        String s = 'Id';
        recIdList.add('\''+cId+'\'');
        
        String queryStr = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE '+s+ ' IN  '+recIdList;
        
        
        if(recId!=null) {
            for(ContentDocumentLink fileLink: database.query(queryStr)){
                setDocumentIds.add(fileLink.ContentDocumentId);
            }
            system.debug('setDocumentIds :'+setDocumentIds);
            ContentVersion cv = [select Id, title, ContentDocumentId,VersionData from ContentVersion where ContentDocumentId in: setDocumentIds limit 1];
            
            csvFileBody= cv.VersionData.toString();
            Map <String, Integer> fieldNumberMap = new Map <String,Integer>();
            system.debug(csvFileBody);
            if(csvFileBody != null)
                csvFileLines = csvFileBody.split('\n'); 
            List<String> lstFieldNames = new list<string>();
            Map<integer,String> fieldsMap = new Map<integer,String>();
            String fieldValue;
            Integer fieldNumber;
            //contactDataLines = contactDataAsString.split('\n');
        	string[] csvFieldNames = csvFileLines[0].split(',');
        	for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
            	lstFieldNames.add(csvFieldNames[i].trim());
        	}
        	for (Integer i = 1; i < 2; i++) {
            	//conObj = new Contact();
            	csvFileLines[i] = removeComma(csvFileLines[i]);
            	String[] inputvalues = new String[]{};
                inputvalues = csvFileLines[i].split(',');
                if(!system.Test.isRunningTest()){
                    fieldValue = inputvalues[17];
                    system.debug('fieldValue :'+fieldValue);             
                    fieldValue = fieldValue.remove('€');
                    fieldValue = fieldValue.remove('"');
                    fieldValue = fieldValue.remove(' ');
                    fieldValue = fieldValue.remove(',');
                }
                /*
            	string[] csvRecordData = csvFileLines[i].split(',');
            	for (String fieldName: csvFieldNames) {
                    if(fieldName == 'Total net'){
             			system.debug('fieldValue :'+fieldValue);             
                     	fieldNumber = fieldNumberMap.get(fieldName);
                		fieldValue = csvRecordData[fieldNumber].remove('€');                           
                        fieldValue = fieldValue.remove(',');
                    }                	
                }
				*/
            }
            //Updating fieldValue as net amount...
            system.debug('fieldValue :'+fieldValue);             
            cdm_credit_debit_note__c cdm = new cdm_credit_debit_note__c();
            cdm.id = recId;
            if(!system.Test.isRunningTest())
            cdm.CDM_Net_Amount__c = double.valueof(fieldValue);
            update cdm;
        }        
    }      
}