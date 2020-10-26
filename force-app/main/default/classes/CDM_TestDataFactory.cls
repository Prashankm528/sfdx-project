/**
*___________________________________________________
*@Name:     CDM_TestDataFactory
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for set test data for test classes.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@isTest
public with sharing class CDM_TestDataFactory {
    /** Create eform Template Data  **/
    @testVisible
    private static List<CDM_C_D_Note_Eform_Template__c> getCDMeFormTemplate(Integer numOfRec) {
        
        List<CDM_C_D_Note_Eform_Template__c> cdmTemplateList = new List<CDM_C_D_Note_Eform_Template__c>();
    CDM_C_D_Note_Eform_Template__c cdmEform;
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Tax Code',CDM_DataType__c='Text',CDM_DefaultValue__c='TEST',
                                                    CDM_Required_Countrys__c='Spain,Austria',CDM_Target_Field__c='CDM_Tax_Code__c',
                                                    CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Country',CDM_DataType__c='PICKLIST',CDM_DefaultValue__c='',
                                                    CDM_Required_Countrys__c='Spain',CDM_Target_Field__c='CDM_Country__c',
                                                    CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Approver',CDM_DataType__c='LookUp',CDM_DefaultValue__c='TEST',
                                                    CDM_Required_Countrys__c='Spain',CDM_Target_Field__c='CDM_Tax_Code__c',
                                                    CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Bline Date',CDM_DataType__c='Date',CDM_DefaultValue__c=null,
                                                    CDM_Required_Countrys__c='Spain,Austria',CDM_Target_Field__c='CDM_Bline_Date__c',
                                                    CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Quantity',CDM_DataType__c='Number',CDM_DefaultValue__c=null,
                                                    CDM_Required_Countrys__c='Spain',CDM_Target_Field__c='CDM_Quantity__c',
                                                    CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Gross Amount',CDM_DataType__c='Currency',CDM_DefaultValue__c=null,
                                                    CDM_Required_Countrys__c='Spain',CDM_Target_Field__c='CDM_Gross_Amount__c',
                                                    CDM_Optional_Countrys__c='Spain',CDM_Target_Object__c='CDM_CDM_Credit_Debit_Note__c');  //Approver
    cdmTemplateList.add(cdmEform);
    cdmEform = new CDM_C_D_Note_Eform_Template__c(Name='Approver',CDM_DataType__c='LookUp',CDM_DefaultValue__c='TEST',
                                                    CDM_Required_Countrys__c='Spain',CDM_Optional_Countrys__c='Spain,Austria',
                                                    CDM_Target_Field__c='CDM_Approver__c',CDM_Target_Object__c='CDM_Credit_Debit_Note__c');
    cdmTemplateList.add(cdmEform);
   insert cdmTemplateList; 
        System.Assert(cdmTemplateList.size()>0);
        return cdmTemplateList;
    }
  
   /** Create eform Template request Data  **/
    @testVisible
    private static Map<String,String> getCDMeFormResponse() {
        Map<String,String> reqDataMap = new Map<String,String>();
        Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
        User u = [select id from user where profile.name = 'BP Base' and isactive= true limit 1];
        Insert new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
    
        CDM_Credit_Debit_Note_Approvers__c approver = [SELECT Id from CDM_Credit_Debit_Note_Approvers__c LIMIT 1 ];
          reqDataMap.put('CDM_Country__c','{"FieldName":"Country","Fieldvalue":"Spain","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Country__c","MaxVal":255,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('RecordTypeId','{"FieldName":"Type of Request","Fieldvalue":"'+new List<String>(recTypeMap.keyset())[0]+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"RecordTypeId","MaxVal":18,"Required":true,"ReadOnly":true,"Show":true,"LookValId":"'+new List<String>(recTypeMap.keyset())[0]+'","LookVal":"Credit Note"}');
        reqDataMap.put('CDM_Quantity__c','{"FieldName":"Quantity","Fieldvalue":"12","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DOUBLE","FieldId":"","TargetField":"CDM_Quantity__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Unit_Price__c','{"FieldName":"Unit Price","Fieldvalue":"2323","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"CURRENCY","FieldId":"","TargetField":"CDM_Unit_Price__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Amount__c','{"FieldName":"Amount","Fieldvalue":"2323.00","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"CURRENCY","FieldId":"","TargetField":"CDM_Amount__c","MinVal":"1","MaxVal":0,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
        reqDataMap.put('CDM_Approver__c','{"FieldName":"Approver","Fieldvalue":"'+ approver.id+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"CDM_Approver__c","MaxVal":18,"Required":false,"ReadOnly":false,"Show":true,"LookValId":" '+  approver.id +'","LookVal":"Approver7 ","LookUpFilter":"Max_Amount__c >=","LookUpFilterFields":"Amount__c"}');
        reqDataMap.put('CDM_Bline_Date__c','{"FieldName":"Bline Date","Fieldvalue":"2019-05-24","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DATE","FieldId":"","TargetField":"CDM_Bline_Date__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_What_Code__c','{"FieldName":"What Code","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_What_Code__c","MaxVal":250,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Split_Required__c','{"FieldName":"Split Required","Fieldvalue":"Yes","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Split_Required__c","MaxVal":255,"Required":false,"ReadOnly":false,"Show":true,"LookValId":""}');
        return reqDataMap;
    
    
    }
    
     /** Create eform Template request Data  **/
    @testVisible
    private static Map<String,String> getCDMeFormResponse1() {
        Map<String,String> reqDataMap = new Map<String,String>();
        Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
         User u = [select id from user where profile.Name = 'BP Base' and isactive= true limit 1];
         Insert new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
    
        CDM_Credit_Debit_Note_Approvers__c approver = [SELECT Id from CDM_Credit_Debit_Note_Approvers__c LIMIT 1 ];
        reqDataMap.put('CDM_Country__c','{"FieldName":"Country","Fieldvalue":"Spain","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Country__c","MaxVal":255,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Company_Code__c','{"FieldName":"Company Code","Fieldvalue":"DE01","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"Dependent","FieldId":"","TargetField":"CDM_Company_Code__c","MaxVal":255,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_RecordTypeId','{"FieldName":"Type of Request","Fieldvalue":"'+new List<String>(recTypeMap.keyset())[0]+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"RecordTypeId","MaxVal":18,"Required":true,"ReadOnly":true,"Show":true,"LookValId":"'+new List<String>(recTypeMap.keyset())[0]+'","LookVal":"Credit Note"}');
        reqDataMap.put('CDM_Quantity__c','{"FieldName":"Quantity","Fieldvalue":"12","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DOUBLE","FieldId":"","TargetField":"CDM_Quantity__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Unit_Price__c','{"FieldName":"Unit Price","Fieldvalue":"2323","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"NUMBER","FieldId":"","TargetField":"CDM_Unit_Price__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Amount__c','{"FieldName":"Amount","Fieldvalue":"2323.00","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"CURRENCY","FieldId":"","TargetField":"CDM_Amount__c","MinVal":"1","MaxVal":0,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
        reqDataMap.put('CDM_Approver__c','{"FieldName":"Approver","Fieldvalue":"'+ approver.id+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"CDM_Approver__c","MaxVal":18,"Required":false,"ReadOnly":false,"Show":true,"LookValId":" '+  approver.id +'","LookVal":"Approver7 ","LookUpFilter":"Max_Amount__c >=","LookUpFilterFields":"Amount__c"}');
        reqDataMap.put('CDM_Split_Required__c','{"FieldName":"Split Required","Fieldvalue":"Yes","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Split_Required__c","MaxVal":255,"Required":false,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Bline_Date__c','{"FieldName":"Bline Date","Fieldvalue":"2019-05-24","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DATE","FieldId":"","TargetField":"CDM_Bline_Date__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
       // reqDataMap.put('CDM_Document_Date__c','{"FieldName":"Document Date","Fieldvalue":"2019-05-24 00:00:00","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DATETIME","FieldId":"","TargetField":"CDM_Document_Date__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_What_Code__c','{"FieldName":"What Code","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_What_Code__c","MaxVal":250,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
         
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        return reqDataMap;
    
    
    }
    
    /** Create eform Template request Data  **/
    @testVisible
    private static Map<String,String> getCDMeFormResponse2() {
        Map<String,String> reqDataMap = new Map<String,String>();
        Map<String,String> recTypeMap = CDM_CreditDebitNoteFormController.getRecordTypesMap();
         User u = [select id from user where profile.Name = 'BP Base' and isactive= true limit 1];
         Insert new CDM_Credit_Debit_Note_Approvers__c(Name='TSET',CDM_Approver_User__c = u.id);
    
        CDM_Credit_Debit_Note_Approvers__c approver = [SELECT Id from CDM_Credit_Debit_Note_Approvers__c LIMIT 1 ];
        reqDataMap.put('CDM_Country__c','{"FieldName":"Country","Fieldvalue":"Australia","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Country__c","MaxVal":255,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Company_Code__c','{"FieldName":"Company Code","Fieldvalue":"DE01","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"Dependent","FieldId":"","TargetField":"CDM_Company_Code__c","MaxVal":255,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_RecordTypeId','{"FieldName":"Type of Request","Fieldvalue":"'+new List<String>(recTypeMap.keyset())[0]+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"RecordTypeId","MaxVal":18,"Required":true,"ReadOnly":true,"Show":true,"LookValId":"'+new List<String>(recTypeMap.keyset())[0]+'","LookVal":"Credit Note"}');
        reqDataMap.put('CDM_Quantity__c','{"FieldName":"Quantity","Fieldvalue":"12","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DOUBLE","FieldId":"","TargetField":"CDM_Quantity__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Unit_Price__c','{"FieldName":"Unit Price","Fieldvalue":"2323","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"NUMBER","FieldId":"","TargetField":"CDM_Unit_Price__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Amount__c','{"FieldName":"Amount","Fieldvalue":"2323.00","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"CURRENCY","FieldId":"","TargetField":"CDM_Amount__c","MinVal":"1","MaxVal":0,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
        reqDataMap.put('CDM_Approver__c','{"FieldName":"Approver","Fieldvalue":"'+ approver.id+'","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"REFERENCE","FieldId":"","TargetField":"CDM_Approver__c","MaxVal":18,"Required":false,"ReadOnly":false,"Show":true,"LookValId":" '+  approver.id +'","LookVal":"Approver7 ","LookUpFilter":"Max_Amount__c >=","LookUpFilterFields":"Amount__c"}');
        reqDataMap.put('CDM_Split_Required__c','{"FieldName":"Split Required","Fieldvalue":"Yes","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"PICKLIST","FieldId":"","TargetField":"CDM_Split_Required__c","MaxVal":255,"Required":false,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_Bline_Date__c','{"FieldName":"Bline Date","Fieldvalue":"2019-05-24","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DATE","FieldId":"","TargetField":"CDM_Bline_Date__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
       // reqDataMap.put('CDM_Document_Date__c','{"FieldName":"Document Date","Fieldvalue":"2019-05-24 00:00:00","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"DATETIME","FieldId":"","TargetField":"CDM_Document_Date__c","MaxVal":0,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        reqDataMap.put('CDM_What_Code__c','{"FieldName":"What Code","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_What_Code__c","MaxVal":250,"Required":false,"ReadOnly":false,"Show":false,"LookValId":""}');
         
        reqDataMap.put('CDM_Customer_Number__c','{"FieldName":"Customer Number","Fieldvalue":"testet","TargetObject":"CDM_Credit_Debit_Note__c","DataType":"STRING","FieldId":"","TargetField":"CDM_Customer_Number__c","MaxVal":100,"Required":true,"ReadOnly":false,"Show":true,"LookValId":""}');
        return reqDataMap;
    
    
    } 
    
    /** create user test record  **/
  public static User createUserWithRole() {
       

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        List<permissionset> ps = [select id from permissionset where name= 'CDM_Eforms' limit 1];
        
        String userEmail = generateUniqueUserEmail(CDM_TestDataFactory.class);
        
        User userWithRole = new User(alias = 'hasrole', email=userEmail,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username=userEmail,
                                     NTID__c ='kac45c');
        insert userWithRole;
        if(ps!=null) 
            if(ps.size()>0) {
            permissionsetAssignment psa = new permissionsetAssignment(PermissionSetId = ps[0].id,AssigneeId = userWithRole.id);
            insert psa;
        
        }
        return userWithRole;
    }
    
    /** create user record with role  **/
    public static User ApproverUserWithRole() {
        UserRole r = [select id from userrole where name = 'CDM Approver User'];
       // Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        List<permissionset> ps = [select id from permissionset where name= 'CDM_Eforms' limit 1];
        
        String userEmail = generateUniqueUserEmail(CDM_TestDataFactory.class);
        
        User userWithRole = new User(alias = 'hasrole', email=userEmail,userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username=userEmail,
                                     NTID__c ='kac4c');
        insert userWithRole;
        if(ps!=null) 
            if(ps.size()>0) {
            permissionsetAssignment psa = new permissionsetAssignment(PermissionSetId = ps[0].id,AssigneeId = userWithRole.id);
            insert psa;
        
        }
        return userWithRole;
    }
    
    /** generate unique email address **/
     public static String generateUniqueUserEmail(System.Type classType) {
        return (classType.getName() + System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
    }
    
     /** create materials picklist data **/
     public static void createMaterialPicklist() {
       CDM_Material__c m = new CDM_Material__c(Name='160000365',CDM_Description__c='Sundry Clearing Account',CDM_Type2__c='Non-Oily');
       insert m;
       CDM_Configuration_Material__c cm = new CDM_Configuration_Material__c(CDM_Channel_Code__c='AU0A',CDM_Sales_Org__c='05 Commercial');
       insert cm;
       CDM_Material_Picklist__c mp = new CDM_Material_Picklist__c(CDM_Configuration_Material__c=cm.id,CDM_Material__c=m.id);
       insert mp;
    }
    
    }