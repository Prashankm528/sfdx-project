/**
*___________________________________________________
*@Name:     CDM_EformsBulkUpload
*@Author:   Chandra Kanchi
*@Created:  OCT 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get upload bulk CDM Eform from parent CDM form.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_EformsBulkUpload {
    
    /**
*————————————————————————————————————————————————————
* @Description
* createChildEformsData method save child cdn records and cdn lines records.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    public static Map<String,String> fieldsApiMap = new Map<String,String>();
    public static set<String> parentFieldsApiMap = new set<String>(); 
  
   // @InvocableMethod(label='Create child CDMs' description='Create Child CDM Eforms from parent CDM csv file')
    public static void createChildEformsData(List<Id> cdmLst) {
        
        String csvFileBody;
        String recId = cdmLst[0];
        
        
        Map<String,CDM_Credit_Debit_Note__c> childCDMMap = new Map<String,CDM_Credit_Debit_Note__c >();
        Map<String,List<CDM_Split_Amount__c>> childCDMLinesMap = new Map<String,List<CDM_Split_Amount__c>>();
        List<CDM_Split_Amount__c> newCDMLines = new List<CDM_Split_Amount__c>();
        String[] csvFileLines; 
        set<Id> setDocumentIds = new set<Id>();
        List<String> accIdList = new List<String>();
        String s = 'LinkedEntityId';
        accIdList.add('\''+recId+'\'');
        
        String queryStr = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE '+s+ ' IN  '+accIdList;
     
       
        CDM_Credit_Debit_Note__c cdm = [SELECT id, (SELECT id FROM CDM_Split_Amounts__r) FROM CDM_Credit_Debit_Note__c WHERE id=: recId Limit 1]; 

      
            List<CDM_Split_Amount__c> cdmchild = new List<CDM_Split_Amount__c>();
             cdmchild = cdm.CDM_Split_Amounts__r;
        
        if(recId!=null && cdmchild.isEmpty()) {
            for(ContentDocumentLink fileLink: database.query(queryStr)){
                setDocumentIds.add(fileLink.ContentDocumentId);
            }
            ContentVersion cv = [select Id, title, ContentDocumentId,VersionData from ContentVersion where ContentDocumentId in: setDocumentIds limit 1];
                      
            csvFileBody= cv.VersionData.toString();
           // csvFileBody= cv.VersionData.;
            csvFileBody= cv.VersionData.toString();
            
            system.debug(csvFileBody);
          //  csvFileBody= blobToString(cv.VersionData,'');
            
            csvFileLines = csvFileBody.split('\n'); 
           
            Map<integer,String> fieldsMap = new Map<integer,String>();
            
            List<String> csvFieldHeaders = csvFileLines[0].split(',');
            for(integer k=0;k< csvFieldHeaders.size(); k++) {
                fieldsMap.put(k,csvFieldHeaders[k]);
            }  
           
            for(CDM_Eform_Bulk_Upload_Template__mdt ut: (List<CDM_Eform_Bulk_Upload_Template__mdt>)CDM_StaticUtils.dynamicQueryListType('CDM_Eform_Bulk_Upload_Template__mdt',null,null)) {
                fieldsApiMap.put(ut.Template_Name__c,ut.Field_Api_Name__c);
            }
            
            for(CDM_Eform_Bulk_Upload_Parent__mdt ut: (List<CDM_Eform_Bulk_Upload_Parent__mdt>)CDM_StaticUtils.dynamicQueryListType('CDM_Eform_Bulk_Upload_Parent__mdt',null,null)) {
                parentFieldsApiMap.add(ut.Parent_Field__c);
            }
            
            CDM_Credit_Debit_Note__c parentRec = (CDM_Credit_Debit_Note__c)CDM_StaticUtils.dynamicQuery(recId, ' WHERE id=:recId LIMIT 1');
            String objType='CDM_Credit_Debit_Note__c';
            Map<String, Schema.SObjectType> schemaMap = CDM_StaticUtils.cdmSchema;
            Schema.SObjectType cdmSchema = schemaMap.get(objType);
            Map<String, Schema.SObjectField> fieldMap = cdmSchema.getDescribe().fields.getMap();
           
            List<SObject> childCDMs = new List<SObject>();
            
            CDM_Credit_Debit_Note__c  cdmRec;
            for(Integer i=1;i<csvFileLines.size();i++) {
            
                csvFileLines[i] = removeComma(csvFileLines[i]);
               
                List<String> csvFieldsData = csvFileLines[i].split(',');
                cdmRec = new CDM_Credit_Debit_Note__c();
                for(integer j=0;j< csvFieldsData.size(); j++) {
                   
                    if(fieldsMap.containsKey(j)) {
                        if(fieldsApiMap.containsKey(fieldsMap.get(j))) {
                          
                            system.debug(fieldsApiMap.get(fieldsMap.get(j)));
                            system.debug(csvFieldsData[j].remove('%').remove('#N/A'));
                            csvFieldsData[j] = csvFieldsData[j].remove('#N/A');
                            String dType = String.valueOf(fieldMap.get(fieldsApiMap.get(fieldsMap.get(j))).getDescribe().getType());
                             system.debug(dType);
                            if(dType == 'PERCENT' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME' || dType == 'BOOLEAN' || dType == 'DOUBLE') {
                            if(dType == 'PERCENT' || dType == 'CURRENCY' || dType == 'DOUBLE')
                                if(csvFieldsData[j]!=null && csvFieldsData[j] != '') {
                                system.debug(csvFieldsData[j].remove('%').remove('€').trim());
                                cdmRec.put(fieldsApiMap.get(fieldsMap.get(j)),Decimal.valueOf(csvFieldsData[j].remove('%').remove('€').trim()));
                                
                               }
                            /* if(dType == 'CURRENCY' || dType == 'DOUBLE')
                                 if(csvFieldsData[j]!=null)
                                 cdmRec.put(fieldsApiMap.get(fieldsMap.get(j)),Decimal.valueOf(csvFieldsData[j]));
                                */ 
                            if(dType == 'DATE' || dType == 'DATETIME')
                                if(csvFieldsData[j]!=null && csvFieldsData[j]!='')
                                cdmRec.put(fieldsApiMap.get(fieldsMap.get(j)),Date.Today()+Integer.valueOf(csvFieldsData[j]));  
                            
                            if(dType == 'BOOLEAN')
                                if(csvFieldsData[j]!=null && csvFieldsData[j] != '')
                                cdmRec.put(fieldsApiMap.get(fieldsMap.get(j)),Boolean.valueOf(csvFieldsData[j]));    
                                
                                
                            } else {
                                if(csvFieldsData[j]!=null && csvFieldsData[j] != '')
                                cdmRec.put(fieldsApiMap.get(fieldsMap.get(j)), csvFieldsData[j]);
                            } 
                        }    
                    }   
                
                } 
                system.debug(cdmRec);
                setAdditionalFields(cdmRec,parentRec);
                String cNumber = cdmRec.CDM_Customer_Number__c;
                cdmRec.CDM_Split_Required__c = 'No';
                cdmRec.CDM_Invoice_Date__c = date.today();
                cdmRec.CDM_Bline_Date__c = cdmRec.CDM_Due_Date__c;
                cdmRec.ownerId = parentRec.ownerId;
                cdmRec.CDM_Bulk_Upload__c = 'No';
                
                if(childCDMMap.containsKey(cNumber)) {
                   cdmRec.CDM_Tax_Code__c = '';
                   summariseSplitRecors(cdmRec,cNumber,childCDMMap,childCDMLinesMap);
                } else
                      childCDMMap.put(cNumber,cdmRec);
            } 
            if(!childCDMMap.isEmpty()) {
                savepoint sp = database.setSavepoint();
                List<CDM_Credit_Debit_Note__c> newcdmrecords = childCDMMap.values();
                system.debug(newcdmrecords); 
                insert newcdmrecords; 
                boolean correctLineItems = createCDMLinesRecords(newcdmrecords,childCDMLinesMap,newCDMLines);
                if(correctLineItems){
                	insert newCDMLines;    
                }
                else{
                    database.rollback(sp);
                    //Send Email to requester...
                    //Querying Template Id...
                    EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'CDM_Notify Requester On CDN Netherlands LineItems'];
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id,parentRec.createdbyId, parentRec.Id); 
                    email.setTargetObjectId(parentRec.createdbyId);
                    email.saveAsActivity = false;
					email.setTemplateID(emailTemplate.Id);
                    email.setSenderDisplayName('CDM Reviewer'); 
       				email.setReplyTo('no-reply@company.com');
                    string toemailaddress = [select email from user where id = :parentRec.CreatedById].email;
					email.toAddresses = new String[] {toemailaddress};
                    //Sending email...
                    if(!Test.isRunningTest()) {
                        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }
                    //Update Parent Record...
                    parentrec.CDM_Form_Status__c = 'Rejected';
                    parentrec.CDM_Processing_Error__c = 'One or more of the individual invoice/credits in this request include more than 10 line items thus not supported by CDN. Please group line items into requests with up to 10 line items each and resubmit.';
                    update parentrec;					
                }
            } 
         
        }
      
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
    private static boolean createCDMLinesRecords(List<CDM_Credit_Debit_Note__c> newCDMLst,Map<String,List<CDM_Split_Amount__c>> childCDMLinesMap,List<CDM_Split_Amount__c> newCDMLines) {
        Map<id,list<CDM_Split_Amount__c>> cdmidtosplitmap = new Map<id,list<CDM_Split_Amount__c>>();        
        for(CDM_Credit_Debit_Note__c cdm: [SELECT id,CDM_Customer_Number__c FROM CDM_Credit_Debit_Note__c WHERE id=:newCDMLst])
           
            if(childCDMLinesMap.containsKey(cdm.CDM_Customer_Number__c))
                for(CDM_Split_Amount__c s: childCDMLinesMap.get(cdm.CDM_Customer_Number__c)) {
                    s.CDM_Credit_Debit_Note__c = cdm.id;
                    newCDMLines.add(s); 
                    if(cdmidtosplitmap.containsKey(cdm.Id)){
                        cdmidtosplitmap.get(cdm.Id).add(s);
                    }
                    else{
                        cdmidtosplitmap.put(cdm.id,new List<CDM_Split_Amount__c> {s});
                    }
         }
       
     //Looping over each record in map and checking if any line items are more than 10...
        for(string s:childCDMLinesMap.keyset())
        {
            if(s != null && childCDMLinesMap.get(s).size() > 10)
            return false;
        } 
        return true;
    }
  
    
    public static void setAdditionalFields(CDM_Credit_Debit_Note__c cdmRec, CDM_Credit_Debit_Note__c  parentRec) {
       // system.debug(parentRec);
         for(String s: parentFieldsApiMap) 
             cdmRec.put(s, parentRec.get(s));
         system.debug(parentRec.recordTypeId);    
         cdmRec.recordTypeId =  parentRec.recordTypeId;  
         cdmRec.CDM_Payment_Method__c =  'T-Domestic banktransfers'; 
         cdmRec.CDM_Form_Status__c = 'Approved';
         cdmRec.CDM_Tax_Code__c =  getTaxCode(cdmRec.CDM_Tax_Rate__c); 
         cdmRec.CDM_Credit_Debit_Note_Parent__c =  parentRec.Id; 
         if(cdmRec.CDM_Net_Amount__c == null)
            cdmRec.CDM_Net_Amount__c = 0;
         if(cdmRec.CDM_Tax_Rate__c == null)
            cdmRec.CDM_Tax_Rate__c = 0;
         if(cdmRec.CDM_Net_Amount__c != 0 && cdmRec.CDM_Tax_Rate__c!= 0) 
         cdmRec.CDM_Tax_Amount__c = ((cdmRec.CDM_Net_Amount__c * cdmRec.CDM_Tax_Rate__c)/100).setScale(2);
         if(cdmRec.CDM_Tax_Amount__c == null)
            cdmRec.CDM_Tax_Amount__c = 0;
         cdmRec.CDM_Gross_Amount__c =  cdmRec.CDM_Net_Amount__c + cdmRec.CDM_Tax_Amount__c;
          cdmRec.CDM_Cost_Center__c = getAppendZeros(cdmRec.CDM_Cost_Center__c);
           }
    
   public static String getTaxCode(Decimal tRate) {
       if(tRate == 21)
       
           return 'OA-NL21-O - Standard Sale';
       else {
           if(tRate == 0)
               return 'N3-NL0-O - Out of Scope';
           else
               return 'error in master template';    
     
     }
               
   } 
    private Static void summariseSplitRecors(CDM_Credit_Debit_Note__c cdmRec,String cNumber,Map<String,CDM_Credit_Debit_Note__c> childCDMMap,Map<String,List<CDM_Split_Amount__c>> childCDMLinesMap) {
        CDM_Credit_Debit_Note__c cdmExsRec = childCDMMap.get(cNumber);
        cdmExsRec.CDM_Split_Required__c = 'Yes';
       // CDM line item records
       
        if(cdmExsRec.CDM_Net_Amount__c == null)
            cdmExsRec.CDM_Net_Amount__c = 0;
        if(cdmExsRec.CDM_Tax_Rate__c == null)
            cdmExsRec.CDM_Tax_Rate__c = 0;
        if(cdmExsRec.CDM_Net_Amount__c != 0 &&  cdmExsRec.CDM_Tax_Rate__c != 0)    
        cdmExsRec.CDM_Tax_Amount__c = ((cdmExsRec.CDM_Net_Amount__c * cdmExsRec.CDM_Tax_Rate__c)/100).setScale(2);//cdmExsRec.CDM_Tax_Amount__c + cdmRec.CDM_Tax_Amount__c;
        if(cdmExsRec.CDM_Tax_Amount__c == null)
            cdmExsRec.CDM_Tax_Amount__c = 0;
        cdmExsRec.CDM_Gross_Amount__c =  cdmExsRec.CDM_Net_Amount__c + cdmExsRec.CDM_Tax_Amount__c;
        cdmRec.CDM_Tax_Amount__c = (cdmRec.CDM_Net_Amount__c * cdmRec.CDM_Tax_Rate__c)/100;//cdmExsRec.CDM_Tax_Amount__c + cdmRec.CDM_Tax_Amount__c;
        cdmRec.CDM_Gross_Amount__c =  cdmRec.CDM_Net_Amount__c + cdmRec.CDM_Tax_Amount__c;
       
       
        if(childCDMLinesMap.containsKey(cNumber))
             childCDMLinesMap.get(cNumber).add(new CDM_Split_Amount__c(CDM_GL_Account__c = cdmRec.CDM_GL_Account__c,
                                                                       CDM_Profit_Center__c = cdmRec.CDM_Profit_Center__c,
                                                                       CDM_Cost_Center__c = getAppendZeros(cdmRec.CDM_Cost_Center__c),
                                                                       CDM_Sub_Tax_Amount__c = cdmRec.CDM_Tax_Amount__c,
                                                                       CDM_Sub_Gross_Amount__c = cdmRec.CDM_Gross_Amount__c,
                                                                       CDM_Sub_Item_Text__c = cdmRec.CDM_Item_Text__c,
                                                                       CDM_Sub_Net_Amount__c = cdmRec.CDM_Net_Amount__c,
                                                                       CDM_Sub_Tax_Code__c = getTaxCode(cdmRec.CDM_Tax_Rate__c),
                                                                       CDM_Sub_Tax_Rate__c = cdmRec.CDM_Tax_Rate__c
                                                                         ));
        else {
             childCDMLinesMap.put(cNumber , new List<CDM_Split_Amount__c>{ new CDM_Split_Amount__c(CDM_GL_Account__c = cdmRec.CDM_GL_Account__c,
                                                                       CDM_Profit_Center__c = cdmRec.CDM_Profit_Center__c,
                                                                       CDM_Cost_Center__c = getAppendZeros(cdmRec.CDM_Cost_Center__c),
                                                                       CDM_Sub_Tax_Amount__c = cdmRec.CDM_Tax_Amount__c,
                                                                       CDM_Sub_Gross_Amount__c = cdmRec.CDM_Gross_Amount__c,
                                                                       CDM_Sub_Item_Text__c = cdmRec.CDM_Item_Text__c,
                                                                       CDM_Sub_Net_Amount__c = cdmRec.CDM_Net_Amount__c,
                                                                       CDM_Sub_Tax_Code__c = getTaxCode(cdmRec.CDM_Tax_Rate__c),
                                                                       CDM_Sub_Tax_Rate__c = cdmRec.CDM_Tax_Rate__c
                                                                         )});
            childCDMLinesMap.get(cNumber).add(new CDM_Split_Amount__c(CDM_GL_Account__c = cdmExsRec.CDM_GL_Account__c,
                                                                       CDM_Profit_Center__c = cdmExsRec.CDM_Profit_Center__c,
                                                                       CDM_Cost_Center__c = getAppendZeros(cdmRec.CDM_Cost_Center__c),
                                                                       CDM_Sub_Tax_Amount__c = cdmExsRec.CDM_Tax_Amount__c,
                                                                       CDM_Sub_Gross_Amount__c = cdmExsRec.CDM_Gross_Amount__c,
                                                                       CDM_Sub_Item_Text__c = cdmExsRec.CDM_Item_Text__c,
                                                                       CDM_Sub_Net_Amount__c = cdmExsRec.CDM_Net_Amount__c,
                                                                       CDM_Sub_Tax_Code__c = getTaxCode(cdmExsRec.CDM_Tax_Rate__c),
                                                                       CDM_Sub_Tax_Rate__c = cdmExsRec.CDM_Tax_Rate__c
                                                                         ));
        
        }                                                                 
                                      
       
       // cummuliative CDM form amounts
        cdmExsRec.CDM_Net_Amount__c = cdmExsRec.CDM_Net_Amount__c + cdmRec.CDM_Net_Amount__c;
        //cdmExsRec.CDM_Tax_Rate__c = cdmExsRec.CDM_Tax_Rate__c + cdmRec.CDM_Tax_Rate__c;
        cdmExsRec.CDM_Tax_Amount__c = ((cdmExsRec.CDM_Net_Amount__c * cdmExsRec.CDM_Tax_Rate__c)/100).setScale(2);//cdmExsRec.CDM_Tax_Amount__c + cdmRec.CDM_Tax_Amount__c;
        cdmExsRec.CDM_Gross_Amount__c =  cdmExsRec.CDM_Net_Amount__c + cdmExsRec.CDM_Tax_Amount__c;
      
        cdmExsRec.put('CDM_Split_Required__c','Yes');
        childCDMMap.put(cNumber,cdmExsRec);
        
                                          
    
     }
     
     public static string getAppendZeros(String str) {
         if(str!=null)
             return str.rightPad(10,'0');
         else
             return str;   
     
     }
     
  
}