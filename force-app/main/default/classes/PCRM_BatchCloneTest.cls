/*****************************************************************************************
*   Date:     08/28/2020
*   Author:   Pooja Deokar (TCS)  
*   Description:   Test Class for Class PCRM_BatchCloneOpportunity
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_BatchCloneTest
{  
    
    //Test method for opportunity  clonning
    static testMethod void testPCRM_BatchCloneOpportunity() 
    {        
        PCRM_Utility testUtil = new PCRM_Utility();
        String cronexpression = testUtil.getCronExpession();
        test.startTest();        
        testUtil.testPCRM_BatchCloneOpportunitydata('Monthly');
        PCRM_CloneOpportunityHierarchyMonthly MonthlyOppty = new PCRM_CloneOpportunityHierarchyMonthly();        
        System.schedule('PCRM Testing Job11', cronexpression, MonthlyOppty);

        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOpportunityHierarchyMonthly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        test.stopTest();
	}
    //Test method for Montly Opportunity Clone
    static testMethod void TestPCRM_CloneOpportunityHierarchyMonthly() 
    {       
        PCRM_Utility testUtil = new PCRM_Utility();
        String cronexpression = testUtil.getCronExpession();
        testUtil.setupBatchclassdataFrequency('Monthly');
        test.startTest();
        PCRM_CloneOpportunityHierarchyMonthly MonthlyOppty = new PCRM_CloneOpportunityHierarchyMonthly();        
        System.schedule('PCRM Testing Job1', cronexpression, MonthlyOppty);
        PCRM_BatchCloneUtil.getQuarter();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOpportunityHierarchyMonthly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        test.stopTest();
	}
    
     //Test method for Montly Opportunity Hierarchy Clone
    static testMethod void TestPCRM_PCRM_CloneOppAcctHierarchyMonthly() 
    {
        PCRM_Utility testUtil = new PCRM_Utility();    
        String cronexpression = testUtil.getCronExpession();
        testUtil.setupBatchclassdataFrequency('Monthly');
        
        test.startTest();       
        PCRM_CloneOppAcctHierarchyMonthly MonthlyOppty = new PCRM_CloneOppAcctHierarchyMonthly();        
        System.schedule('PCRM Testing Job2', cronexpression, MonthlyOppty);
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOppAcctHierarchyMonthly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        
        test.stopTest();
	}
    
    //Test method for Quaterly Opportunity Clone
    static testMethod void TestPCRM_CloneOpportunityHierarchyQuarterly() 
    {
      
        PCRM_Utility testUtil = new PCRM_Utility();
        String cronexpression = testUtil.getCronExpession();
        testUtil.setupBatchclassdataFrequency('Quarterly');
        test.startTest();   
        PCRM_CloneOpportunityHierarchyQuarterly MonthlyOppty = new PCRM_CloneOpportunityHierarchyQuarterly();        
        System.schedule('PCRM Testing Job3', cronexpression, MonthlyOppty);
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOpportunityHierarchyQuarterly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        
        test.stopTest();
	}
    
    //Test method for Quaterly Opportunity Hierarchy Clone
    static testMethod void TestPCRM_CloneOppAcctHierarchyQuarterly() 
    {       
        PCRM_Utility testUtil = new PCRM_Utility();
        String cronexpression = testUtil.getCronExpession();
        testUtil.setupBatchclassdataFrequency('Quarterly');
        test.startTest();
       
        PCRM_CloneOppAcctHierarchyQuarterly MonthlyOppty = new PCRM_CloneOppAcctHierarchyQuarterly();        
        System.schedule('PCRM Testing Job4', cronexpression, MonthlyOppty);
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('PCRM_CloneOppAcctHierarchyQuarterly', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        
        test.stopTest();
	}
    
    //Test method for opportunity contact role clonning
    static testMethod void TestPCRM_BatchCloneContactRoles() 
    {
        PCRM_Utility testUtil1 = new PCRM_Utility();       
        testUtil1.setupBatchclassdataFrequency('Quarterly');
       
        test.startTest();
       
        map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs =  testUtil1.getMapOldNewOppID();        
        PCRM_BatchCloneContactRoles objCloneContactRoles = new PCRM_BatchCloneContactRoles(mapOldOpportunityIDsWithNewOpportunityIDs);
        system.enqueueJob(objCloneContactRoles);
        system.assertEquals(2, mapOldOpportunityIDsWithNewOpportunityIDs.size());
        test.stopTest();
	}
   
    //Test method for Quotes clonning
    static testMethod void TestPCRM_BatchCloneQuotes() 
    {
        PCRM_Utility testUtil = new PCRM_Utility();        
        testUtil.setupBatchclassdataFrequency('Quarterly');        
        test.startTest();       
        
        map<Id, Id> mapOldOpportunityIDsWithNewOpportunityIDs1 = testUtil.getMapOldNewOppID();  
      
        PCRM_BatchCloneQuotes objBatchCloneQuotes = new PCRM_BatchCloneQuotes(mapOldOpportunityIDsWithNewOpportunityIDs1);
        system.enqueueJob(objBatchCloneQuotes);
        system.assertEquals(2, mapOldOpportunityIDsWithNewOpportunityIDs1.size());
        test.stopTest();
	}
	 //Test method for Quotes clonning
    static testMethod void TestPCRM_BatchCloneQLI() 
    {  
        PCRM_Utility testUtil = new PCRM_Utility();       
        testUtil.setupBatchclassdataFrequency('Monthly');
        test.startTest();
        
        List<Quote> lstQuote = [Select id,PCRM_Quote_Cloned_From__c,Status
                              From Quote 
                              Where Status ='Draft' ]; 
       
        List<Product2> lstProducts = new PCRM_Utility().createProducts1(1);
		insert lstProducts;
	 
		//Create pricebook
		List<PricebookEntry> listPricebookEntry = new PCRM_Utility().createStandardPricebookEntry(lstProducts);
		insert listPricebookEntry;        
   	 	List<Quote> lstQuote1 = [Select id,PCRM_Quote_Cloned_From__c,Status
                              From Quote 
                              Where Status ='Presented' ];
        //Create quotelineitem
		List <QuoteLineItem> ListOfQuotesLines = new PCRM_Utility().createQuoteLines(lstQuote1,lstProducts); 		
		INSERT ListOfQuotesLines;
        
        PCRM_BatchCloneQuoteLineItems objBatchCloneQLI = new PCRM_BatchCloneQuoteLineItems(lstQuote);
        system.enqueueJob(objBatchCloneQLI);        
        system.assertEquals(1, lstQuote.size());
        test.stopTest();
	}
}