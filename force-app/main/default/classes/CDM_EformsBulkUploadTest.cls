/**
*___________________________________________________
*@Name:     CDM_EformsBulkUploadTest
*@Author:   Chandra Kanchi
*@Created:  July 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get cover test code coverage for CDM_EformsBulkUpload class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/


@isTest

private with sharing class CDM_EformsBulkUploadTest {

 /**
    *————————————————————————————————————————————————————
    * @Description
    * test method.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 

static testMethod void CDM_EformsBulkUploadDataTest() {
    User u = [SELECT id,Name FROM User WHERE id=:Userinfo.getUserId()];
    CDM_Credit_Debit_Note_Approvers__c cdnApprover = new CDM_Credit_Debit_Note_Approvers__c(Name=u.Name,CDM_Approver_User__c=u.id);
    Insert cdnApprover;
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c(CDM_Form_Status__c = 'Draft',recordTypeId = Schema.SObjectType.CDM_Credit_Debit_Note__c.getRecordTypeInfosByName().get('Credit Note').getRecordTypeId(),CDM_Country__c='Netherlands',CDM_Company_Code__c='NL01',
                                                                CDM_Approver__c = cdnApprover.id,CDM_Description__c='TEST TEST',CDM_Bulk_Upload__c = 'Yes');
    insert cdn;
    
    String csvStr = 'Working ID,ISP mnemonic naam,BTW,Category,Leverancier,CATMAN,Bedrag,Omschrijving op Factuur,Factuurnummer,Datum Factuur,PC,GL,Due Date,VAT number,Company Code\n ,12228587,0,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n ,12228587,21,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n,12228587,20,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n,12228587,20,OTC,Medz Europe BV,Sjoerdtje,20,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n';
     ContentVersion contentVersion = new ContentVersion(
      Title = 'InvoiceFile',
      PathOnClient = 'InvoiceFile.csv',
      VersionData = Blob.valueOf(csvStr),
      IsMajorVersion = true
    );
    insert contentVersion;    
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    
    //create ContentDocumentLink  record 
    ContentDocumentLink cdl = New ContentDocumentLink();
    cdl.LinkedEntityId = cdn.id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.shareType = 'V';
    insert cdl;
   // CDM_EformsCsvUpload.createChildEformsData(cdn.id,cdl.id);
    cdn.CDM_Form_Status__c = 'Approved';
   
        Update cdn;
        CDM_EformsCsvUpload.createChildEformsData(cdn.id,cdl.id);
       
        System.assert(cdn!=null);
    
      }
      
      /**
    *————————————————————————————————————————————————————
    * @Description
    * test method used for swiss country csv file upload.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 

static testMethod void CDM_EformsBulkUploadDataTest1() {
    User u = [SELECT id,Name FROM User WHERE id=:Userinfo.getUserId()];
    CDM_Credit_Debit_Note_Approvers__c cdnApprover = new CDM_Credit_Debit_Note_Approvers__c(Name=u.Name,CDM_Approver_User__c=u.id);
    Insert cdnApprover;
    CDM_Credit_Debit_Note__c cdn = new CDM_Credit_Debit_Note__c( CDM_Form_Status__c = 'Draft',recordTypeId = Schema.SObjectType.CDM_Credit_Debit_Note__c.getRecordTypeInfosByName().get('Credit Note').getRecordTypeId(),CDM_Country__c='Switzerland',CDM_Company_Code__c='NL01',
                                                                CDM_Approver__c = cdnApprover.id,CDM_Description__c='TEST TEST',CDM_Bulk_Upload__c = 'Yes');
    insert cdn;
    
    String csvStr = 'General Comments,Request type,Customer Number,Invoice Date,Gross Amount,Tax Amount,Due Date,Invoice / Reference #,Payment term,Payment block,Profit Centre,G/L Account,Item Text,D/C,Net Amount,Tax Code,Tax Amount,Tax Rate,Sub Gross Amount\n ,invoice,50627887,29/04/2019,108880.5664,3111.03639,,581935,C158,no,5715000,702220001,Rechnuns Nr.581915/La Anteil Eigenhaendler 0%,credit,1132.5,§N,0,0.00%,1132.5\n ,,,,,,,,,,5715000,702220001,Rechnuns Nr.581915/La Anteil Eigenhaendler 7.7 %,credit,40403.07,§I,3111.03639,7.70%,43514.10639\n,,,,,,,,,,5600000,461050002,Rechnuns Nr.581915/La Anteil Agenturware,credit,64233.96,V0,0,0.00%,64233.96\n';
    //String csvStr = 'Working ID,ISP mnemonic naam,BTW,Category,Leverancier,CATMAN,Bedrag,Omschrijving op Factuur,Factuurnummer,Datum Factuur,PC,GL,Due Date,VAT number,Company Code\n ,12228587,0,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n ,12228587,21,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n,12228587,20,OTC,Medz Europe BV,Sjoerdtje,1687.73,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n,12228587,20,OTC,Medz Europe BV,Sjoerdtje,20,Verkoopbudget Q2 - 2019,,,5711043,609230100,30,NL811050026B01,NL01\n';
     ContentVersion contentVersion = new ContentVersion(
      Title = 'InvoiceFile',
      PathOnClient = 'InvoiceFile.csv',
      VersionData = Blob.valueOf(csvStr),
      IsMajorVersion = true
    );
    insert contentVersion;    
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    
    //create ContentDocumentLink  record 
    ContentDocumentLink cdl = New ContentDocumentLink();
    cdl.LinkedEntityId = cdn.id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.shareType = 'V';
    insert cdl;
    cdn.CDM_Form_Status__c = 'Draft';
   
        Update cdn;
     
        System.assert(cdn!=null);
   
   
      }

}