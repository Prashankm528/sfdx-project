/*****************************************************************************************
*   Date:           27JULY20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Test class for GEFUE_MassUploadCtrl controller class
*   Modifications:  
****************************************************************************************/
@isTest
public with sharing class GEFUE_MassUploadCtrlTest {
    /*
    * test method to cover code in GEFUE_MassUploadCtrl and GEFUE_CreateOpportunitiesQueueable class 
    */
    @isTest static void testMassUpload() {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf('Package,Sold to,Jobber Name,Site Street,Site City,Site State,DCA/NTI,Stage,Close Date,Terminal,Terminal Number,Estimated Gas,Estimated Diesel,Image Amount,CPG,IRR\n,9123021,Orion Oil LLC,13 Avenue Street,Chicago,IL,DCA,Lead,2020-07-31,DETROIT,6123,1500,1500,45000,0.03,20\nCoen Markets Package,90041866,Coen Markets,1363 Route 66,Templeton,PA,DCA,Lead,2020-07-31,CHICAGO,6412,,2000,45000,0.45,30\nCoen Markets Package,90041866,Coen Markets,1513 Lincoln Way,White Oak,PA,DCA,Lead,2020-08-06,CHICAGO,6412,3500,2300,45000,0.43,45'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        Test.startTest();
        Account acc1 = new Account(Name='Coen Test', AccountNumber='90041866',Business_Unit__c = 'Fuels North America');
        Account acc2 = new Account(Name='Orio Oil LLC Test', AccountNumber='9123021',Business_Unit__c = 'Fuels North America');
        List<Account> lstAcc = new List<Account>{acc1, acc2};
		insert lstAcc;
        
        GEFUE_Terminal__c chicago = new GEFUE_Terminal__c(Name='Chicago', GEFUE_Terminal_Number__c='6412');
        GEFUE_Terminal__c detroit = new GEFUE_Terminal__c(Name='Detroit', GEFUE_Terminal_Number__c='6123');
        List<GEFUE_Terminal__c> lstTerminal = new List<GEFUE_Terminal__c>{chicago, detroit};
        insert lstTerminal;
        
        Id productRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('GEFUE_Product').getRecordTypeId();
        Product2 prod1 = new Product2(Name = 'Gas',isActive = true, CASFO_Product_Sales_Organisation__c='0052',RecordTypeId=productRTId);
        Product2 prod2 = new Product2(Name = 'Diesel',isActive = true, CASFO_Product_Sales_Organisation__c='0052',RecordTypeId=productRTId);
        List<Product2> lstProduct = new List<Product2>{prod1, prod2};
        insert lstProduct;
        
        PriceBook2 pricebookIdSTD = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
        update pricebookIdSTD;
        
        Pricebook2 pricebookIdCST = new Pricebook2 (Name='Fuels NA Price Book',Description='Test Pricebook Entry 1', isActive=true);
        insert pricebookIdCST;   
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
        List<GEFUE_Opportunity_Staging__c> lstInitialOppStaging = GEFUE_MassUploadCtrl.fetchFiles(contentVersionSelect.ContentDocumentId);
        List<GEFUE_Opportunity_Staging__c> validatedOppStaging = GEFUE_MassUploadCtrl.validateRows(lstInitialOppStaging);
        
        List<GEFUE_Opportunity_Staging__c> lstFetchInlineEdit = GEFUE_MassUploadCtrl.inlineEditSave(lstInitialOppStaging, validatedOppStaging);
        String jobId = GEFUE_MassUploadCtrl.finalSubmitQueueable(validatedOppStaging);
        List<String> lstOppStageId = new List<String>();
        for (GEFUE_Opportunity_Staging__c oppStage : lstFetchInlineEdit) {
            lstOppStageId.add(oppStage.Id);
        }
        String status = GEFUE_MassUploadCtrl.checkJobStatus(jobId);
        String packId = GEFUE_MassUploadCtrl.retrievePackageId(lstOppStageId);
        System.assert(status != NULL, 'Status is not fetched');
        Test.stopTest();
    }

    /*
    * test method to cover validation code in GEFUE_MassUploadCtrl and GEFUE_CreateOpportunitiesQueueable class
    */
    @isTest static void testMassUploadRequiredFields() {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf('Package,Sold to,Jobber Name,Site Street,Site City,Site State,DCA/NTI,Stage,Close Date,Terminal,Terminal Number,Estimated Gas,Estimated Diesel,Image Amount,CPG,IRR\n,9123021,Orion Oil LLC,13 Avenue Street,,IL,DCA,Lead,2020-07-31,DETROIT,,1500,1500,45000,0.03,20\nCoen Markets Package,90041866,Coen Markets,1363 Route 66,Templeton,PA,DCA,Lead,2020-07-31,CHICAGO,6412,,2000,45000,0.45,30\nCoen Markets Package,90041866,Coen Markets,1513 Lincoln Way,White Oak,PA,DCA,Lea,2020-08-06,CHICAGO,6412,3500,2300,45000,0.43,45'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
        List<GEFUE_Opportunity_Staging__c> lstInitialOppStaging = GEFUE_MassUploadCtrl.fetchFiles(contentVersionSelect.ContentDocumentId);
        List<GEFUE_Opportunity_Staging__c> validatedOppStaging = GEFUE_MassUploadCtrl.validateRows(lstInitialOppStaging);
        System.assert(validatedOppStaging.size() > 0, 'Records not validated');
    }
}