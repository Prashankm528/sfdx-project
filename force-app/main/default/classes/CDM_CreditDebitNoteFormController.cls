/**
*___________________________________________________
*@Name:     CDM_CreditDebitNoteFormController
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get eform field template meta data.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

public with sharing class CDM_CreditDebitNoteFormController {
    
    public static String objName = 'CDM_Credit_Debit_Note__c'; 
    public static Map<String, Schema.SObjectType> globalDes = Schema.getGlobalDescribe(); 
    
    
    /**
*————————————————————————————————————————————————————
* @Description
* get valid approvers based on country,countrycode and request type.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @AuraEnabled
    public static List<Sobject> getMaterials(String sobjName , String searchKey,String salesOrg,String dChannel) {
        
        if(searchKey != null && searchKey!= '')  
            return CDM_StaticUtils.dynamicQueryListType(sObjName, ' WHERE (Name LIKE \''+String.escapeSingleQuotes(searchKey)+'%\' OR CDM_Description__c LIKE \''+ String.escapeSingleQuotes(searchKey) + '%\' OR CDM_Description__c LIKE \'%'+ String.escapeSingleQuotes(searchKey) + '%\') AND id in (select CDM_Material__c from CDM_Material_Picklist__c where CDM_Configuration_Material__r.CDM_Sales_Org__c = \''+salesOrg+'\' and CDM_Configuration_Material__r.CDM_Channel_Code__c = \''+dChannel+'\')' ,null);
        else
            return CDM_StaticUtils.dynamicQueryListType(sObjName,' WHERE id in (select CDM_Material__c from CDM_Material_Picklist__c where CDM_Configuration_Material__r.CDM_Sales_Org__c = \''+salesOrg+'\' and CDM_Configuration_Material__r.CDM_Channel_Code__c = \''+dChannel+'\')'  , null);   //Line_of_Business__c 
        
    }
    
      /**
*————————————————————————————————————————————————————
* @Description
* get supporting notes from dofa api.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @AuraEnabled
    public static CDM_StaticUtils.CDMSuportingNote getSupportingNotes(String ntId, String reqType) {
        return CDM_GetSupportingNotesForApprover.getCDM_GetSupportingNotes(ntId, reqType);
    
    }
    
    
    
    
    /**
*————————————————————————————————————————————————————
* @Description
* get valid approvers based on country,countrycode and request type.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @AuraEnabled
    public static List<Sobject> getValidApprovers(String sobjName , String searchKey, String country,String companyCode,String requestType) {
        User u = [SELECT Id,NTID__c FROM User where id=: userinfo.getUserId() LIMIT 1];
        List<CDM_LOB_Mappings__mdt> lobMaping = new List<CDM_LOB_Mappings__mdt>();
        system.debug(companyCode);
        system.debug(country);
        if(companyCode != null)
            lobMaping = [SELECT id,label,Company_Code__c,LOB__c from CDM_LOB_Mappings__mdt WHERE Company_Code__c =: companyCode];
        
        if(country!='Australia' && country!='New Zealand') {
            if(!lobMaping.isEmpty()) {
                if(searchKey != null && searchKey!= '')
                    return CDM_StaticUtils.dynamicQueryListType(sObjName, ' WHERE (Name LIKE \''+String.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+String.escapeSingleQuotes(searchKey)+'\' OR Name LIKE \'%'+String.escapeSingleQuotes(searchKey)+'%\')  AND CDM_country__c = \''+ String.escapeSingleQuotes(country) +'\'' +' AND CDM_Request_Type__c = \'' + requestType +'\'' + ' AND CDM_Line_of_Business__c = \'' + lobMaping[0].LOB__c +'\'' + ' AND CDM_Approver_User__r.isActive = true' , null);
                else
                    return CDM_StaticUtils.dynamicQueryListType(sObjName, ' WHERE CDM_country__c = \''+ String.escapeSingleQuotes(country) + '\''  +' AND CDM_Request_Type__c = \'' + requestType +'\''  +' AND CDM_Line_of_Business__c = \'' + lobMaping[0].LOB__c  +'\'' + ' AND CDM_Approver_User__r.isActive = true', null);   
            }
            
        } else {
            if(searchKey != null && searchKey!= '')
                return CDM_StaticUtils.dynamicQueryListType(sObjName, ' WHERE (Name LIKE \''+String.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+String.escapeSingleQuotes(searchKey)+'\' OR Name LIKE \'%'+String.escapeSingleQuotes(searchKey)+'%\')  AND CDM_country__c = \''+ String.escapeSingleQuotes(country) + '\''  +' AND CDM_Request_Type__c = \'' + requestType + '\'' + ' AND CDM_Approver_User__r.isActive = true', null);   
            else
                return CDM_StaticUtils.dynamicQueryListType(sObjName, ' WHERE CDM_country__c = \''+ String.escapeSingleQuotes(country) + '\''  +' AND CDM_Request_Type__c = \'' + requestType + '\'' + ' AND CDM_Approver_User__r.isActive = true', null);   
          }
        return null;
    }
    
    
      /**
*————————————————————————————————————————————————————
* @Description
* get record type map.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 

    public class approversResponse {
    @AuraEnabled
    public List<Sobject> approversSobj{get;set;}
    @AuraEnabled
    public CDM_StaticUtils.CDMSuportingNote sNotes{get;set;}
   
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* get record type map.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @AuraEnabled
    public static Map<String,String> getRecordTypesMap() {
        
        return getRecordtypeMap(objName);
        
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* save cdm eform record data which is comming from eform component.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    @AuraEnabled
    public static string  saveEformData(String recData) {
        
        System.debug(recData);
        
        // Map<String, Schema.SObjectType> globalDes = Schema.getGlobalDescribe();
        Schema.SObjectType sobjectType = globalDes.get(objName);
        Sobject sobj = sobjectType.newSobject();
        String country;
        CDM_StaticUtils.datawrap  dwrp= new CDM_StaticUtils.datawrap();
        dwrp = (CDM_StaticUtils.datawrap) json.deserialize(recData, CDM_StaticUtils.datawrap.class);
        for(object s:dwrp.recDataMap.values()){
            system.debug('before deserialization '+s);
            CDM_StaticUtils.recDataWrap eformData;// = new CDM_StaticUtils.recDataWrap();
            if(String.valueOf(s).contains('{')) {
                eformData = (CDM_StaticUtils.recDataWrap) json.deserialize(String.valueOf(s), CDM_StaticUtils.recDataWrap.class);
                if(eformData!=null)
                    // if(eformData.ReadOnly != null)
                    // if(!eformData.ReadOnly) {
                    if(eformData.DataType == 'NUMBER' || eformData.DataType == 'CURRENCY' ||
                       eformData.DataType == 'REFERENCE' || eformData.DataType == 'DATETIME' || 
                       eformData.DataType == 'DATE' || eformData.DepDataType == 'CURRENCY' ||
                       eformData.DataType == 'Dependent' || eformData.DataType == 'DOUBLE' ||
                       eformData.DataType == 'BOOLEAN'||
                       eformData.DataType == 'PERCENT') {
                           
                           if(eformData.DataType == 'NUMBER') 
                               if(eformData.Fieldvalue!=null)
                               sobj.put(eformData.TargetField,integer.valueOf(eformData.Fieldvalue));
                           
                           if(eformData.DataType  == 'CURRENCY' || eformData.DataType == 'DOUBLE') 
                               if(eformData.Fieldvalue  !=null)
                               sobj.put(eformData.TargetField,decimal.valueOf(eformData.Fieldvalue)); 
                           
                           
                           if(eformData.DataType  == 'REFERENCE') {
                               if(eformData.Fieldvalue !=null)
                                   sobj.put(eformData.TargetField,eformData.LookValId);
                               system.debug(eformData.TargetField);
                               system.debug(eformData.Fieldvalue);
                           }      
                           
                           if(eformData.DataType  == 'Dependent'){ 
                               if(eformData.Fieldvalue !=null) {
                                   if(eformData.DepDataType == 'CURRENCY'
                                      || eformData.DepDataType == 'DOUBLE')
                                       sobj.put(eformData.TargetField,decimal.valueOf(eformData.Fieldvalue));
                                   
                                   if(eformData.DepDataType == 'NUMBER')
                                       sobj.put(eformData.TargetField,integer.valueOf(eformData.Fieldvalue));     
                                   if(eformData.DepDataType == 'STRING')
                                       sobj.put(eformData.TargetField,eformData.Fieldvalue);    
                                    if(eformData.DepDataType == 'BOOLEAN')
                                       sobj.put(eformData.TargetField,eformData.Fieldvalue!=null? Boolean.valueOf(eformData.Fieldvalue) : false);    
                                   if(eformData.DepDataType == 'DATETIME')
                                       sobj.put(eformData.TargetField,DateTime.valueOf(eformData.Fieldvalue));         
                                   if(eformData.DepDataType == 'DATE')
                                       sobj.put(eformData.TargetField,Date.valueOf(eformData.Fieldvalue));      
                                   
                               }
                               if(eformData.Fieldvalue ==null && eformData.DepDataType == 'DATE'){
                                   sobj.put(eformData.TargetField,null);      
                               }
                           }
                           
                           if(eformData.DataType  == 'DATETIME') 
                               if(eformData.Fieldvalue!=null)
                               sobj.put(eformData.TargetField,DateTime.valueOf(eformData.Fieldvalue)); 
                           
                           if(eformData.DataType  == 'DATE') 
                               if(eformData.Fieldvalue!=null){
                               sobj.put(eformData.TargetField,Date.valueOf(eformData.Fieldvalue));  
                               system.debug(eformData.TargetField + ':' +eformData.Fieldvalue);    
                               }
                           
                           if(eformData.DataType  == 'DOUBLE') 
                               if(eformData.Fieldvalue!=null)
                               sobj.put(eformData.TargetField,Decimal.valueOf(eformData.Fieldvalue));  
                           
                           if(eformData.DataType  == 'BOOLEAN') 
                               if(eformData.Fieldvalue!=null)
                               sobj.put(eformData.TargetField,Boolean.valueOf(eformData.Fieldvalue));  
                           if(eformData.DataType  == 'PERCENT') 
                               if(eformData.Fieldvalue!=null && eformData.Fieldvalue!='')   
                               sobj.put(eformData.TargetField,Decimal.valueOf(eformData.Fieldvalue));     
                           
                           
                       } else
                       {    
                         
                           if(eformData.TargetField == 'CDM_Country__c')
                               country = eformData.Fieldvalue;
                              if(eformData.Fieldvalue!=null && eformData.TargetField !=null) {
                               sobj.put(eformData.TargetField,eformData.Fieldvalue); 
                              } else {
                                   if(eformData.TargetField !=null)
                                       sobj.put(eformData.TargetField,''); 
                                    }   
                       }  
                
            }
            
        } 
        System.debug(sobj);
        
        
        if(dwrp.recordId !=null)
            sobj.id = dwrp.recordId;
        upsert sobj;
        if(sobj.id != null)
            shareApprovers(sobj.id);
        
        if(sobj.get('CDM_Split_Required__c') == 'Yes') {       
            List<CDM_Split_Amount__c> childRecords = (List<CDM_Split_Amount__c>) json.deserialize(String.valueOf(dwrp.splitAmountRecs), List<CDM_Split_Amount__c>.class); 
            List<CDM_Split_Amount__c> existinRecords = [SELECT id from CDM_Split_Amount__c where CDM_Credit_Debit_Note__c =: sobj.id];
            List<CDM_Split_Amount__c> delLineRecords = new List<CDM_Split_Amount__c>();
            set<String> childRecMap = new set<String>();
            
            system.debug(childRecords);
            decimal amount = 0;
            for(CDM_Split_Amount__c sm : childRecords) 
                childRecMap.add(sm.id);
            
            for(CDM_Split_Amount__c csa : existinRecords) 
                if(!childRecMap.contains(csa.id))
                delLineRecords.add(csa);
            
            for(CDM_Split_Amount__c sm : childRecords)  {                                 
                if(sm.id == null)
                    sm.CDM_Credit_Debit_Note__c = sobj.id;
                amount =+ sm.CDM_Sub_Gross_Amount__c;    
                //amount1 =+ sm.CDM_Sub_Net_Amount__c;
                
            }  
            sobj.put('CDM_Gross_Amount__c',amount);   
            upsert childRecords;
            delete delLineRecords;
        } 
        return sobj.id;
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* share cdm eform record for approver.

*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    public static void shareApprovers(String recId) {
        List<CDM_Credit_Debit_Note__c> cdmRec = [SELECT id,CDM_Approver__r.CDM_Approver_User__c,OwnerId FROM CDM_Credit_Debit_Note__c WHERE id =: recId AND 
                                                 CDM_Approver__r.CDM_Approver_User__r.isActive = true LIMIT 1];
        List<CDM_Credit_Debit_Note__Share> cdmShare = new List<CDM_Credit_Debit_Note__Share>();
        System.debug(cdmRec);
        
        if(cdmRec != null && !cdmRec.isEmpty()) {
            if(cdmRec[0].CDM_Approver__r.CDM_Approver_User__c != null) {
                cdmShare = [SELECT id from CDM_Credit_Debit_Note__Share WHERE parentId =: recId AND (AccessLevel = 'Edit' OR AccessLevel = 'Read' OR AccessLevel = 'All') AND UserOrGroupId =: cdmRec[0].CDM_Approver__r.CDM_Approver_User__c];
                User u = [select id from user where id=: cdmRec[0].CDM_Approver__r.CDM_Approver_User__c];
                if(cdmShare.isEmpty()) {
                    system.debug(cdmRec[0].CDM_Approver__r.CDM_Approver_User__c);
                    
                    CDM_Credit_Debit_Note__Share cdmShr = new CDM_Credit_Debit_Note__Share(parentId = recId,AccessLevel = 'Edit',UserOrGroupId = cdmRec[0].CDM_Approver__r.CDM_Approver_User__c);
                    system.debug(cdmShr);
                    Insert cdmShr;
                }
                
            }else {
                cdmShare = [SELECT id from CDM_Credit_Debit_Note__Share WHERE parentId =: recId AND (AccessLevel = 'Edit' OR AccessLevel = 'Read') AND UserOrGroupId !=: cdmRec[0].OwnerId];
                delete cdmShare;
                
            } 
        }    
        
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* load cdm eform records metadata.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    
    @AuraEnabled
    public static CDM_StaticUtils.fieldsMetaData  getFieldsMetaData(String recId,String country,String recTypeId) {
        if(recId!=null)
            return loadExistingFormData(recId,country);
        else
            return loadNewFormData(country,recTypeId);    
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* loading existing cdm eform record data.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/  
    
    @Testvisible
    private static CDM_StaticUtils.fieldsMetaData loadExistingFormData(String recId,String country) {
        Map<string,Map<string,List<String>>> depPicklistMap = new Map<string,Map<string,List<String>>>();
        map<String,Boolean> requiredFields = new Map<string,Boolean>();
        List<CDM_C_D_Note_Eform_Template__c> cdnFormTemplate = new List<CDM_C_D_Note_Eform_Template__c>();
      
        Map<String,List<string>> recMaps = new Map<String,List<string>>(); 
        Sobject sobjRec;
        sobjRec =  CDM_StaticUtils.dynamicQuery(recId, ' WHERE id=:recId LIMIT 1');
        System.debug('sobjRec'+sobjRec);
        String requestTypeName = '';
        CDM_StaticUtils.fieldsMetaData fmd = new CDM_StaticUtils.fieldsMetaData();  
        fmd.recordTypeMap = getRecordtypeMap(objName);
        map <String, map <String, Schema.SObjectField>> targetObjFieldDefMap = new map <String, map <String, Schema.SObjectField>> ();
        targetObjFieldDefMap.put(objName, getFieldDefinitionMap(objName));
        map <String, SObject> sObjMap = new map <String, SObject> ();
        sObjMap.put(String.valueOf(sobjRec.getSObjectType()), sobjRec);
        String uRecId = userinfo.getUserId();
        country = String.valueOf(sobjRec.get('CDM_Country__c'));    
        System.debug('country'+country);
        SObject sObj;
        string postingPeriodval;
        Map <String, Schema.SObjectField> fieldMap = globalDes.get(objName).getDescribe().fields.getMap();
        
        
        List<CDM_C_D_Note_Eform_Template__c> cdmList = (List<CDM_C_D_Note_Eform_Template__c>)CDM_StaticUtils.dynamicQueryListType('CDM_C_D_Note_Eform_Template__c',null,' ORDER BY CDM_Order__c ASC'); 
        for(CDM_C_D_Note_Eform_Template__c c : cdmList) {
            set<String> reqContrySet = new set<string>();
            set<String> optContrySet = new set<string>();
            System.debug(c.CDM_Required_Countrys__c);
            c.CDM_show__c = false;            
            if(country!=null) {
                if(c.CDM_Required_Countrys__c!=null) {
                    if(c.CDM_Required_Countrys__c.contains(','))
                        reqContrySet.addAll(c.CDM_Required_Countrys__c.split(','));
                    else
                        reqContrySet.add(c.CDM_Required_Countrys__c);
                    if(reqContrySet!=null && country!=null)
                        if(reqContrySet.contains(country)) {
                            c.CDM_required__c = true;
                            c.CDM_show__c = true;
                        }    
                }
                
                if(c.CDM_Optional_Countrys__c!=null) {
                    if(c.CDM_Optional_Countrys__c.contains(','))
                        optContrySet.addAll(c.CDM_Optional_Countrys__c.split(','));
                    else
                        optContrySet.add(c.CDM_Optional_Countrys__c);
                    if(optContrySet!=null && country!=null)
                        if(optContrySet.contains(country))
                        c.CDM_show__c = true;
                } 
                
            }  
            
            if(c.CDM_Target_Field__c!=null) {
                if(c.CDM_DataType__c == 'Dependent')      
                    c.CDM_Dependent_Field_DataType__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getType()); 
                else
                    c.CDM_DataType__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getType());
                
                c.CDM_DefaultValue__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getDefaultValue()); 
                c.CDM_Help_Text__c = fieldMap.get(c.CDM_Target_Field__c).getDescribe().getInlineHelpText(); 
                c.CDM_Max_Length__c = fieldMap.get(c.CDM_Target_Field__c).getDescribe().getLength();
                // c.Required__c = reqContrySet.contains(c.Target_Field__c); 
                if(c.CDM_Controlling_Field__c!=null && c.CDM_Controlling_Field__c!='') { // dependent picklist
                    depPicklistMap.put(c.CDM_Target_Field__c,CDM_DepedentPicklist.getDependentMap(globalDes.get(objName) ,c.CDM_Controlling_Field__c,c.CDM_Target_Field__c));
                    System.debug(depPicklistMap);
                }   
                
                
                
                if(c.CDM_DataType__c == 'REFERENCE') { 
                    for(Schema.SObjectType reference : fieldMap.get(c.CDM_Target_Field__c).getDescribe().getReferenceTo()) {
                        c.CDM_Look_Up_Object_Name__c = reference.getDescribe().getName();
                        break;
                    } 
                    if(fieldMap.get(c.CDM_Target_Field__c).getDescribe().isCustom())  { 
                        sObj = sObjMap.get(c.CDM_Target_Object__c).getSObject(String.valueOf(c.CDM_Target_Field__c).replace('__c', '__r'));
                        System.debug('sobject'+sObj);
                        if(sObj!=null) {
                            c.CDM_Look_Up_Field_Value__c = sObj.get('Name') + ' ';
                            if(c.CDM_Target_Field__c == 'CDM_Material__c') {
                                sObj = CDM_StaticUtils.dynamicQuery(String.valueOf(sObj.get('Id')), ' WHERE id= \''+sObj.get('Id')+'\' LIMIT 1');
                                fmd.material = sObj;
                                c.CDM_Look_Up_Field_Value__c = sObj.get('CDM_Material__c')+ ' ';//sObj.get('CDM_Material__c') + ' '; 
                            }
                            
                            if(c.CDM_Target_Field__c == 'CDM_Approver__c') {  
                                sObj = CDM_StaticUtils.dynamicQuery(String.valueOf(sObj.get('Id')), ' WHERE id= \''+sObj.get('Id')+'\' LIMIT 1');
                                c.CDM_Supporting_Notes_Credit__c = sObj.get('CDM_Supporting_Notes_Credit__c') + ' ';
                                c.CDM_Supporting_Notes_Debit__c = sObj.get('CDM_Supporting_Notes_Debit__c') + ' ';
                                
                            }
                            c.CDM_DefaultValue__c = String.valueOf(sObjMap.get(c.CDM_Target_Object__c).get(c.CDM_Target_Field__c));
                        }
                        
                    }  else {
                        
                        c.CDM_DefaultValue__c = String.valueOf(sobjRec.get(c.CDM_Target_Field__c));    
                        c.CDM_Look_Up_Field_Value__c = fmd.recordTypeMap !=null ? c.CDM_DefaultValue__c !=null ? fmd.recordTypeMap.containsKey(c.CDM_DefaultValue__c) ? fmd.recordTypeMap.get(c.CDM_DefaultValue__c) : '' : '' : '';
                        requestTypeName = fmd.recordTypeMap !=null ? c.CDM_DefaultValue__c !=null ? fmd.recordTypeMap.containsKey(c.CDM_DefaultValue__c) ? fmd.recordTypeMap.get(c.CDM_DefaultValue__c) : '' : '' : '';
                    }
                    
                }
                
                
                if(sobjRec!=null)
                    c.CDM_DefaultValue__c = String.valueOf(sobjRec.get(c.CDM_Target_Field__c));
                
                if(c.CDM_DataType__c == 'PICKLIST') {
                    recMaps.put(c.CDM_Target_Field__c,getPicklistValues(c.CDM_Target_Object__c,c.CDM_Target_Field__c));
                }  
               /// if((country == 'Australia' || country == 'New Zealand') && c.Name == 'Invoice/Reference Number' && requestTypeName == 'Debit Note') 
               //     c.CDM_show__c  = false;
            }
            ///Logic to make invoice date and operation date as disable if posting period is previous..
            if(c.CDM_Target_Field__c == 'CDM_Posting_Period__c')
            {                
                postingPeriodval = c.CDM_DefaultValue__c;
                system.debug(postingPeriodval);
            }
            if(c.CDM_Target_Field__c == 'CDM_Posting_Period__c' || 
               c.CDM_Target_Field__c == 'CDM_Invoice_Date__c' ||
               c.CDM_Target_Field__c == 'CDM_Operation_Date__c' ||
               c.CDM_Target_Field__c == 'CDM_Tax_Report_Date__c' ||
               c.CDM_Target_Field__c == 'CDM_Posting_Date__c')
            {
                if(postingPeriodval == 'Previous')
                {                    
                    if(c.CDM_Target_Field__c == 'CDM_Invoice_Date__c' || c.CDM_Target_Field__c == 'CDM_Operation_Date__c')
                    {                        
                        c.CDM_Read_Only__c = true;                        
                    }                  
                    if(c.CDM_Target_Field__c == 'CDM_Tax_Report_Date__c' || c.CDM_Target_Field__c == 'CDM_Posting_Date__c')
                    {                        
                        c.CDM_Read_Only__c = true;   
                        c.CDM_Show__c = true;
                    }			
                }
            }
            //Logic ends here
            cdnFormTemplate.add(c);     
        }
        
        
        fmd.cdnFormTemplate = cdnFormTemplate;
        fmd.recPicklistMap = recMaps;
        fmd.fieldRule = eFormFieldRules();
        fmd.depPicklistMap = depPicklistMap;
        if(country == 'Australia' || country == 'New Zealand') {
            List<SObject> cdnTaxEndUse = new List<SObject>();
            Map<String,List<String>> cdnFormTaxEndUse = new Map<String,List<String>>();
            if(country == 'Australia')
                cdnTaxEndUse = CDM_StaticUtils.dynamicQueryListType('CDM_Tax_End_Use__mdt',' WHERE country__c=\''+String.escapeSingleQuotes('AU0A')+'\'',' ORDER BY CDM_Order__c ASC');
            if(country == 'New Zealand')
                cdnTaxEndUse = CDM_StaticUtils.dynamicQueryListType('CDM_Tax_End_Use__mdt',' WHERE country__c=\''+String.escapeSingleQuotes('NZ0A')+'\'',' ORDER BY CDM_Order__c ASC');
            if(cdnTaxEndUse !=null)
                for(SObject s: cdnTaxEndUse) {
                    String k = String.valueOf(s.get('ChannelCode__c'));
                    String v = String.valueOf(s.get('PicklistValue__c'));
                    if(cdnFormTaxEndUse.containsKey(k))
                        cdnFormTaxEndUse.get(k).add(v);
                    else
                        cdnFormTaxEndUse.put(k,new List<String>{v});
                }
            fmd.cdnFormTaxEndUse = cdnFormTaxEndUse;
            fmd.cdnFormSalesDocType = CDM_StaticUtils.dynamicQueryListType('CDM_Sales_Doc_Type__mdt',null,null);     
        }
        Map<String,List<String>> taxCodes = getCodes('CDM_Tax_Codes__mdt',' WHERE country__c=\''+String.escapeSingleQuotes(country)+'\'');
        Map<String,List<String>> payMethods = getCodes('CDM_Payment_Methods__mdt',' WHERE country__c=\''+String.escapeSingleQuotes(country)+'\'');
        if(taxCodes.containsKey(country))
            fmd.recPicklistMap.put('CDM_Tax_Code__c',taxCodes.get(country)); 
        if(payMethods.containsKey(country))
            fmd.recPicklistMap.put('CDM_Payment_Method__c',payMethods.get(country));   
        //recordEditAccess 
        if(String.isNotBlank(recId)) 
            fmd.recordEditAccess  = [SELECT  RecordId ,HasEditAccess FROM UserRecordAccess WHERE RecordId = :recId AND UserId =: uRecId].HasEditAccess;
        fmd.payMethods = getCodes('CDM_Payment_Methods__mdt',' WHERE country__c=\''+String.escapeSingleQuotes(country)+'\'');
        fmd.splitAmountRecs = CDM_StaticUtils.dynamicQueryListType('CDM_Split_Amount__c', ' WHERE CDM_Credit_Debit_Note__c =\''+String.escapeSingleQuotes(recId)+'\'', '');
        return fmd; 
        
    }
    
    
    
    
    
    
    /**
*————————————————————————————————————————————————————
* @Description
* get record types for cdm efom object.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    public static Map<String,String> getRecordtypeMap(String objName) {
        Map<String,String> rtMap = new Map<String,String>();
        for(RecordType rt : [SELECT Id,Name FROM RecordType WHERE SobjectType=: objName])
            rtMap.put(rt.Id,rt.Name);
        return rtMap;
    }
    // getting Tax and payment codes
    private static Map<String,List<String>>  getCodes(String objN,String qFilter)  {
        Map<String,List<String>> pValuesMap = new Map<String,List<String>>();
        LIst<SObject> sobjlst = CDM_StaticUtils.dynamicQueryListType(objN ,qFilter,' ORDER BY Picklist_Value__c');
        if(sobjlst != null)
            for(SObject sobj : sobjlst) {
                String country = String.valueOf(sobj.get('Country__c'));
                String pVal = String.valueOf(sobj.get('Picklist_Value__c'));
                if(pValuesMap.containsKey(country))
                    pValuesMap.get(country).add(pVal);
                else
                    pValuesMap.put(country , new List<String>{pVal});    
                
            }
        return pValuesMap;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* load new cdm eform records metadata.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @Testvisible
    private static CDM_StaticUtils.fieldsMetaData loadNewFormData(String country,String recTypeId) {
        String  requestTypeName ='';
        map<String,Boolean> requiredFields = new Map<string,Boolean>();
        List<CDM_C_D_Note_Eform_Template__c> cdnFormTemplate = new List<CDM_C_D_Note_Eform_Template__c>();
        Map<string,Map<string,List<String>>> depPicklistMap = new Map<string,Map<string,List<String>>>();
        //Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,List<string>> recMaps = new Map<String,List<string>>(); //
        SObject sObj;
        Sobject sobjRec;
        
        CDM_StaticUtils.fieldsMetaData fmd = new CDM_StaticUtils.fieldsMetaData();  
        fmd.recordTypeMap = getRecordtypeMap(objName);
        Map <String, Schema.SObjectField> fieldMap = globalDes.get(objName).getDescribe().fields.getMap();
        
        List<CDM_C_D_Note_Eform_Template__c> cdmTemlst = (List<CDM_C_D_Note_Eform_Template__c>)CDM_StaticUtils.dynamicQueryListType('CDM_C_D_Note_Eform_Template__c',null,' ORDER BY CDM_Order__c ASC');
        
        for(CDM_C_D_Note_Eform_Template__c c : cdmTemlst) {
            set<String> reqContrySet = new set<string>();
            set<String> optContrySet = new set<string>();
            System.debug(c.CDM_Required_Countrys__c);
            if(country!=null)
                c.CDM_show__c = false;
            else
                c.CDM_show__c = true;
            if(country!=null) {
                if(c.CDM_Required_Countrys__c!=null) {
                    if(c.CDM_Required_Countrys__c.contains(','))
                        reqContrySet.addAll(c.CDM_Required_Countrys__c.split(','));
                    else
                        reqContrySet.add(c.CDM_Required_Countrys__c);
                    if(reqContrySet!=null && String.valueOf(country)!=null)
                        if(reqContrySet.contains(String.valueOf(country))) {
                            c.CDM_required__c = true;
                            c.CDM_show__c = true;
                        }    
                }
                
                if(c.CDM_Optional_Countrys__c!=null) {
                    if(c.CDM_Optional_Countrys__c.contains(','))
                        optContrySet.addAll(c.CDM_Optional_Countrys__c.split(','));
                    else
                        optContrySet.add(c.CDM_Optional_Countrys__c);
                    if(optContrySet!=null && String.valueOf(country)!=null)
                        if(optContrySet.contains(String.valueOf(country)))
                        c.CDM_show__c = true;
                } 
                
            }  
            
            system.debug(c.CDM_Target_Field__c);
            if(c.CDM_Target_Field__c!=null) {
                if(c.CDM_DataType__c == 'Dependent')      
                    c.CDM_Dependent_Field_DataType__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getType()); 
                else 
                    c.CDM_DataType__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getType());
                
                if(c.Name == 'Requester Name') 
                    c.CDM_DefaultValue__c = String.valueOf(CDM_StaticUtils.dynamicQuery(userinfo.getUserId(), ' WHERE id=\''+userinfo.getUserId()+'\' LIMIT 1').get('Name'));
                else 
                    c.CDM_DefaultValue__c = String.valueOf(fieldMap.get(c.CDM_Target_Field__c).getDescribe().getDefaultValue());
                
                if(c.CDM_Target_Field__c == 'CDM_Country__c' && country!=null)
                    c.CDM_DefaultValue__c =  country;//getCountryName(country); 
                
                c.CDM_Help_Text__c = fieldMap.get(c.CDM_Target_Field__c).getDescribe().getInlineHelpText(); 
                c.CDM_Max_Length__c = fieldMap.get(c.CDM_Target_Field__c).getDescribe().getLength();
                if(c.CDM_Controlling_Field__c!=null && c.CDM_Controlling_Field__c!='') { // dependent picklist
                    depPicklistMap.put(c.CDM_Target_Field__c,CDM_DepedentPicklist.getDependentMap(globalDes.get(objName) ,c.CDM_Controlling_Field__c,c.CDM_Target_Field__c));
                    System.debug(depPicklistMap);
                }    
                system.debug(c.CDM_datatype__c); 
                if(c.CDM_DataType__c == 'REFERENCE') {
                    for(Schema.SObjectType reference : fieldMap.get(c.CDM_Target_Field__c).getDescribe().getReferenceTo()) {
                        c.CDM_Look_Up_Object_Name__c = reference.getDescribe().getName();
                        break;
                    }
                    if(c.CDM_Target_Field__c == 'RecordTypeId' && recTypeId!=null) {
                        c.CDM_DefaultValue__c = recTypeId; 
                        c.CDM_Look_Up_Field_Value__c = fmd.recordTypeMap !=null ? c.CDM_DefaultValue__c !=null ? fmd.recordTypeMap.containsKey(c.CDM_DefaultValue__c) ? fmd.recordTypeMap.get(c.CDM_DefaultValue__c) : '' : '' : '';
                        requestTypeName = fmd.recordTypeMap !=null ? c.CDM_DefaultValue__c !=null ? fmd.recordTypeMap.containsKey(c.CDM_DefaultValue__c) ? fmd.recordTypeMap.get(c.CDM_DefaultValue__c) : '' : '' : '';
                        
                    }
                    
                }       
                
                if(c.CDM_DataType__c == 'PICKLIST') {
                    recMaps.put(c.CDM_Target_Field__c,getPicklistValues(c.CDM_Target_Object__c,c.CDM_Target_Field__c));
                }
                
             //   if((country == 'Australia' || country == 'New Zealand') && c.Name == 'Invoice/Reference Number' && requestTypeName == 'Debit Note') 
             //       c.CDM_show__c = false;
            }
            
            cdnFormTemplate.add(c); 
        }
        
        // fieldsMetaData fmd = new fieldsMetaData();
        fmd.cdnFormTemplate = cdnFormTemplate;
        fmd.recPicklistMap = recMaps;
        fmd.fieldRule = eFormFieldRules();
        fmd.depPicklistMap = depPicklistMap;
        
        if(country!=null) {
            if(country == 'Australia' || country == 'New Zealand') {
                List<SObject> cdnTaxEndUse = new List<SObject>();
                Map<String,List<String>> cdnFormTaxEndUse = new Map<String,List<String>>();
                if(country == 'Australia')
                    cdnTaxEndUse = CDM_StaticUtils.dynamicQueryListType('CDM_Tax_End_Use__mdt',' WHERE SalesOrg__c =\''+String.escapeSingleQuotes('AU0A')+'\'',' ORDER BY Order__c ASC');
                if(country == 'New Zealand')
                    cdnTaxEndUse = CDM_StaticUtils.dynamicQueryListType('CDM_Tax_End_Use__mdt',' WHERE SalesOrg__c =\''+String.escapeSingleQuotes('NZ0A')+'\'',' ORDER BY Order__c ASC');
                if(cdnTaxEndUse!=null)
                    for(SObject s: cdnTaxEndUse) {
                        String k = String.valueOf(s.get('Channel__c'));//String.valueOf(s.get('ChannelCode__c'));
                        String v = String.valueOf(s.get('PicklistValue__c'));
                        if(cdnFormTaxEndUse.containsKey(k))
                            cdnFormTaxEndUse.get(k).add(v);
                        else
                            cdnFormTaxEndUse.put(k,new List<String>{v});
                    }
                fmd.cdnFormTaxEndUse = cdnFormTaxEndUse;
                fmd.cdnFormSalesDocType = CDM_StaticUtils.dynamicQueryListType('CDM_Sales_Doc_Type__mdt',null,null);     
            }
            Map<String,List<String>> taxCodes = getCodes('CDM_Tax_Codes__mdt',' WHERE country__c=\''+String.escapeSingleQuotes(country)+'\'');
            Map<String,List<String>> payMethods = getCodes('CDM_Payment_Methods__mdt',' WHERE country__c=\''+String.escapeSingleQuotes(country)+'\'');
            List<SObject> taxEndUse = CDM_StaticUtils.dynamicQueryListType('CDM_Tax_End_Use__mdt',null,null);//getCodes('CDM_Tax_End_Use__mdt',null);
            if(taxCodes.containsKey(country))
                fmd.recPicklistMap.put('CDM_Tax_Code__c',taxCodes.get(country)); 
            if(payMethods.containsKey(country))
                fmd.recPicklistMap.put('CDM_Payment_Method__c',payMethods.get(country));
        }   
        
        fmd.recordTypeMap = getRecordtypeMap(objName);
        return fmd; 
        
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* get eform feild rule for show or hidden fields.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    @Testvisible
    private static map <String, list <CDM_C_D_Note_Eform_FieldRule__c>> eFormFieldRules () {
        
        map <String, list <CDM_C_D_Note_Eform_FieldRule__c>> mapField = new map <String, list <CDM_C_D_Note_Eform_FieldRule__c>>();
        
        list <String> tempList;
        for(CDM_C_D_Note_Eform_FieldRule__c  fieldRule : [SELECT ID, Name, CDM_Parent_Field__r.CDM_Target_Field__c, 
                                                          CDM_Parent_Field_Value__c, 
                                                          CDM_Show_Field__r.CDM_Target_Field__c
                                                          from CDM_C_D_Note_Eform_FieldRule__c
                                                          limit 49999]) {
                                                              if(mapField.containsKey(fieldRule.CDM_Parent_Field__r.CDM_Target_Field__c)) 
                                                                  mapField.get(fieldRule.CDM_Parent_Field__r.CDM_Target_Field__c).add(fieldRule);
                                                              else
                                                                  mapField.put(fieldRule.CDM_Parent_Field__r.CDM_Target_Field__c , new List<CDM_C_D_Note_Eform_FieldRule__c>{fieldRule});    
                                                          }
        return mapField;       
        
    }  
    
    /**
*————————————————————————————————————————————————————
* @Description
* get all picklist meta data values for cdm efom object.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    public static List<String> getPicklistValues(String ObjectApiName, String FieldName) {
        try {
            List<String> lstPickVals = new List<String>();
            Schema.SObjectType targetType = globalDes.get(ObjectApiName);                                //From the Object Api name retrieving the SObject
            Sobject objectName = targetType.newSObject();
            Schema.sObjectType sobjectType = objectName.getSObjectType();                                                //grab the sobject that was passed
            Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();                                   //describe the sobject
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();                               //get a map of fields for the passed sobject
            List<Schema.PickListEntry> pickListValLst = fieldMap.get(FieldName).getDescribe().getPickListValues();    //grab the List of pickList values for the passed field on the sobject
            for (Schema.PickListEntry a : pickListValLst) {                                                           //for all values in the pickList List
                lstPickVals.add(a.getValue());                                                                       //add the value  to our final List
            }
            
            return lstPickVals;
        }
        catch(Exception ex) {
            return new List<String>();
        }
    }    
    
    
    /**
*————————————————————————————————————————————————————
* @Name: getFieldDefinitionMap
* @Description :  This method will be used for fetching getFieldDefinitionMap for all the fields definition in dynamicaly.
* Returns : map <String, Schema.SObjectField>
*  

*————————————————————————————————————————————————————
**/
    public static map <String, Schema.SObjectField> getFieldDefinitionMap(String eformObjname) {
        try {
            Map <String, Schema.SObjectField> fieldMap = globalDes.get(eformObjname).getDescribe().fields.getMap();
            return fieldMap;
        } catch(Exception exp) { System.debug(exp.getMessage()); return null; }  
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Submit for approval.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    
    @AuraEnabled
    public static CDM_StaticUtils.responsewrp submitAndProcessApprovalRequest(String recId,String comments) {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
       //CDM_Credit_Debit_Note__c cdc_DebitNt = (CDM_Credit_Debit_Note__c)CDM_StaticUtils.dynamicQuery('CDM_Credit_Debit_Note__c', ' WHERE id= \''+ recId + '\'LIMIT 1');
        CDM_Credit_Debit_Note__c cdc_DebitNt = [Select id,CDM_Amount__c,CDM_Bulk_Upload__c,CDM_Net_Amount__c,CDM_Approver__c,CDM_Credit_Approval_Amount__c,CDM_Gross_Amount__c ,
                                                CDM_Approver__r.CDM_Approver_User__r.Id, CDM_Approver__r.CDM_Approver_User__r.ntId__c, CDM_Approver__r.Name,  CurrencyIsoCode,CDM_Country__c,CDM_Authorisation_Type__c,
                                                CDM_Supporting_Notes_SD__c , CDM_Supporting_Notes_RC__c, CDM_Supporting_Notes_SG__c,CDM_Total_Sub_Gross_Amount__c,CDM_Split_Required__c ,CDM_ApproverName__c,
                                                CDM_Approval_Status__c,CDM_Request_Type__c,CDM_Form_Status__c,CDM_Requester_Comments__c ,CDM_Amount_Limit__c from CDM_Credit_Debit_Note__c 
                                                where Id=: recId limit 1]; 
        CDM_StaticUtils.responsewrp wrp = new CDM_StaticUtils.responsewrp(); 
        
        if(cdc_DebitNt.CDM_Bulk_Upload__c == 'Yes') {
            CDM_BulkUploadEformTemplate bulkTem = new CDM_BulkUploadEformTemplate();
            bulkTem.recId = cdc_DebitNt.id;
            if(bulkTem.emailBody == null || bulkTem.emailBody== '') {
                wrp.error = 'Please verify if the attached file in in CSV UTIF-8 format and all the data provided in the file is in proper format';
                return wrp;
            }
            
        }  
                                         
        if(cdc_DebitNt.CDM_Approver__c!=null) {
        
            cdc_DebitNt.CDM_Requester_Comments__c = comments;
             if(cdc_DebitNt.CDM_Country__c == 'Australia' || cdc_DebitNt.CDM_Country__c == 'New Zealand') {
                 if(cdc_DebitNt.CDM_Net_Amount__c == null)  {
                    wrp.error = 'Enter Net Amount Value';
                   
                    return wrp;
                 }               
                    CDM_StaticUtils.ValidApproverRes validateRes = CDM_ValidateApproverFromDoFA.getValidateApprover(cdc_DebitNt.CDM_Authorisation_Type__c,cdc_DebitNt.CDM_Net_Amount__c,cdc_DebitNt.CDM_Approver__r.CDM_Approver_User__r.ntId__c,cdc_DebitNt.CurrencyIsoCode);
                    if(validateRes.status) {
                        wrp.success = validateRes.statusres;
                        update cdc_DebitNt;
                        req1.setComments(comments);
                        req1.setObjectId(recId);
                        req1.setNextApproverIds(new String[]{cdc_DebitNt.CDM_Approver__r.CDM_Approver_User__r.Id});
                        Approval.ProcessResult result1 = Approval.process(req1);
                        
                    }else { wrp.error = validateRes.statusres;   }
                  
                    return wrp; 
                 
            }  
            else {
                /*
                if(cdc_DebitNt.CDM_Country__c == 'Netherlands' && cdc_DebitNt.CDM_Bulk_Upload__c == 'Yes') {
                   
                        system.debug('Bulk upload netherlands>>>>>>'+cdc_DebitNt.CDM_Bulk_Upload__c);
                        update cdc_DebitNt;
                        req1.setComments(comments);
                        req1.setObjectId(recId);
                        req1.setNextApproverIds(new String[]{cdc_DebitNt.CDM_Approver__r.CDM_Approver_User__r.Id});
                        Approval.ProcessResult result1 = Approval.process(req1);
                        wrp.success = 'Request was successfully submitted'; 
                        return wrp;
                      } 
                  else {
				  */
                       CDM_StaticUtils.ValidApproverRes validateRes = CDM_GetSupportingNotesFromDofa.getCDM_GetSupportingNotes(cdc_DebitNt,comments);
                       system.debug('Supporting notes:>>>>>>>>>>>>>'+validateRes);
                       if(validateRes.status) {
                           system.debug('validateRes.statusres>>>>>>'+validateRes.statusres);
                           wrp.success = validateRes.statusres;
                           //update cdc_DebitNt;
                           database.update(cdc_DebitNt,false);
                       }
                	   else {
                           wrp.error = validateRes.statusres;
                       }
                    //}
             }   
             
        } else 
            wrp.error = 'Select valid approver.';
        
        return wrp;
        
    }
    /**
*————————————————————————————————————————————————————
* @Description
* fetch current user role.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    @AuraEnabled 
    public static String fetchUser(){
        system.debug('Calling fetchUser');
        return [select id,UserRole.DeveloperName from User where id =: userInfo.getUserId()].UserRole.DeveloperName;
        
    }

    /**
*————————————————————————————————————————————————————
* @Description
* Check if user is assigned to Admin Permission Set
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    @AuraEnabled 
    public static Boolean fetchadminPermSet(){
        system.debug('Calling fetchadminPermSet');
        List<PermissionSetAssignment> i = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()
                                          AND PermissionSet.Name = 'CDM_Eform_Admin'];
        if(i.size() == 1)
            return True; 
        else
            return false;
    }
    
    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * clone cdn and cdn line items.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    
    @AuraEnabled 
    public static String cloneCdnRecords(String recId) {
       Sobject sobjRec;
       sobjRec =  CDM_StaticUtils.dynamicQuery(recId, ' WHERE id=:recId LIMIT 1');
       //Cloning the above Account Record ac
       Sobject sobjRec1 = sobjRec.clone(false, false, false, false);
       sobjRec1.put('CDM_Form_Status__c', 'Draft');
       sobjRec1.put('CDM_Approval_Unlimited_Amount__c', false);
       sobjRec1.put('CDM_Amount_Limit__c', null);
       sobjRec1.put('CDM_Luis_Failed__c', false); 
       sobjRec1.put('CDM_Posting_Period__c','Current');
       sobjRec1.put('CDM_Tax_Report_Date__c', null);
       sobjRec1.put('CDM_Posting_Date__c', null);
       //Getting the fields to be set as NULL from custom label
       List<string> nullfields = system.label.CDM_CLONE_BLANK_FIELDS.split(',');
       for(string s:nullfields)
       {
           sobjRec1.put(s, null);
       }
       insert sobjRec1;
        
       List<CDM_Split_Amount__c> cdnLineItems = new List<CDM_Split_Amount__c>();
       for(CDM_Split_Amount__c s: [SELECT id,CDM_Credit_Debit_Note__c,CDM_D_C__c,CDM_GL_Account__c,CDM_Profit_Center__c,CDM_Sub_Item_Text__c ,
                                   CDM_Sub_Gross_Amount__c,CDM_Sub_Net_Amount__c,CDM_Sub_Tax_Code__c,CDM_Sub_Tax_Amount__c,CDM_Cost_Center__c,CDM_Sub_Tax_Rate__c
                                   FROM CDM_Split_Amount__c WHERE CDM_Credit_Debit_Note__c =: recId])
       if(s.CDM_Credit_Debit_Note__c != null) {
           
                CDM_Split_Amount__c cLine = s.clone(false, false, false, false);
                cLine.CDM_Credit_Debit_Note__c = sobjRec1.id;
               
                
                cdnLineItems.add(cLine); 
             
            }
        database.insert(cdnLineItems);
      return sobjRec1.Id;  
    }
    
/**
*————————————————————————————————————————————————————
* @Description
* fetch current user role.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    
    @AuraEnabled 
    public static statusResponse getCDMFormStatus(String recId) {
        statusResponse sres =  new statusResponse();
        sres.cdmRecord = [select id,CDM_Form_Status__c,Name,CDM_Country__c,
                          CDM_Gross_Amount__c,CDM_Net_Amount__c
                          from CDM_Credit_Debit_Note__c
                          where id =: recId];
           if(String.isNotBlank(recId)) 
            sres.HasEditAccess  = [SELECT  RecordId ,HasEditAccess FROM UserRecordAccess WHERE RecordId = :recId AND UserId =: Userinfo.getUserId()].HasEditAccess; 
       return sres; 
    }
     /**
*————————————————————————————————————————————————————
* @Description
* fetch current user role.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 

    public class statusResponse {
        @AuraEnabled
        public CDM_Credit_Debit_Note__c cdmRecord;
        @AuraEnabled
        public boolean HasEditAccess;
    
    
    }  
    
      /**
*————————————————————————————————————————————————————
* @Description
* Submit for approval.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    

}