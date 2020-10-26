/***************************************************************************************************
* Description : Unit Tests for CALCF_Create_New_Survey_Request_From_Case Process Builder and
*				Create New Survey Request flow
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-JAN-30   1.0                 Maros Zilka     	Initial version
* 2020-May-04   2.0                 Narsimha Datla    	Added all test scenarios
***************************************************************************************************/

@isTest
private class CALCF_CreateNewSurveyRequestFromCaseTest {
    
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    private static Account testAccount;
    private static Contact testContact;
    private static User testUser;

    @testSetup
    static void setup() {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
        
        system.runAs(accountIntegrationUserToInsert) 
        {
            Account testAccount = new Account();
            Contact testContact = new Contact();
            
            testAccount.Name = 'Test Account';
            testAccount.Business_Unit__c = 'Lubricants - Automotive';
            testAccount.Sales_Organisation__c = 'UK01';
            
            insert testAccount;
            
            testContact.FirstName = 'First';
            testContact.LastName = 'Last';
            testContact.Email = 'example@example.com';
            testContact.Home_Location__c = 'United Kingdom';
            testContact.Preferred_Language__c = 'English-British';
            testContact.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
            testContact.Last_Surveyed_Date__c = date.today();
            testContact.AccountId = testAccount.Id;
            insert testContact;
        }
    }
    
    @isTest
    static void createNewSurveyRequestFromCaseTest() 
    {
        populateData();
        
        Case testCase = new Case();
        testCase.AccountId = testAccount.Id;
        testCase.ContactId = testContact.Id;
        testCase.Complaint__c = true; 
        testCase.Siebel_Last_Updated_Date__c = Date.today();  
        testCase.CASFOLCF_SiebelClosedDate__c = Date.today();
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        insert testCase;
        
        testCase.Status = 'Closed';
        
        Test.startTest();
        update testCase;
        Test.stopTest();        
        
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c FROM Case LIMIT 1];
        
        system.assertEquals('Survey Error 12', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c);
    }

    @isTest
    static void isNotSurveyableCaseTest() 
    {
        populateData();

        Case testCase = new Case();
        testCase.AccountId = testAccount.Id;
        testCase.ContactId = testContact.Id;
        testCase.Complaint__c = true; 
        testCase.Siebel_Last_Updated_Date__c = Date.today();  
        testCase.CASFOLCF_SiebelClosedDate__c = Date.today();
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testCase.RecordTypeId = returnRecordTypeId('IST General');
        testcase.Contact_Type__c = 'Consumer';

        Test.startTest();
        insert testCase;
        Test.stopTest();
        
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c FROM Case LIMIT 1];
        
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c);
    }
    
    @isTest
    static void isNotGETEAndComplaint() 
    {
        populateData();
        
        Case testCase = new Case();
        testCase.Complaint__c = false; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        insert testCase;

        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();

        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(!testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be false');
    }

    @isTest
    static void isNoContact() 
    {
        populateData();
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = null;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 04', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }
  
    @isTest
    static void isNoEmailcontact() 
    {
        populateData();
        testcontact.Email = '';
        update testContact;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 10', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }
    
    @isTest
    static void isNoAccount() 
    {
        populateData();
		testContact.AccountId =  null;
        update testContact;
		        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testCase.Siebel_Last_Updated_Date__c = Date.today();  
        testCase.CASFOLCF_SiebelClosedDate__c = Date.today();
        testCase.closeddate = Date.Today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 01', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }
    
    @isTest
    static void isAccountSalesOrgNotSupported() 
    {
        populateData();
        testAccount.Sales_Organisation__c = 'ZK10';
        update testAccount;
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(!testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be false');
    }

    @isTest
    static void isAccountHavingWrongBusinessUnit() 
    {
        populateData();
        testAccount.business_Unit__c = 'PL01';
        update testAccount;
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(!testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be false');
    }  
    
    @isTest
    static void isContactTestModeNotEqualToTestMode() 
    {
        populateData();
		lcf_Settings__c lcfs = new lcf_Settings__c();
        lcfs.Test_Mode__c = true;
        insert lcfs;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 08', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    } 
    
    @isTest
    static void isCaseIsAlreadySurveyed() 
    {
        populateData();
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        testcase.LCF_Surveyed__c = true;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(!testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be false');
    }  

    @isTest
    static void isContactOptedOut() 
    {
        populateData();
        testContact.Survey_Opt_Out__c  = true;
        update testContact;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 05', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }  

    @isTest
    static void isContactTempOptedOut() 
    {
        populateData();
        testContact.Next_Surveyable_Date__c = date.today();
        update testContact;
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.accountId = testAccount.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }  
    
    @isTest
    static void isClosedDateOlderThanTwoDays() 
    {
        populateData();
	        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 02', testCase.CALCF_Not_Surveyed_Reason__c);
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c,'Not Surveyed should be true');
    }

    @isTest
    static void isSurveyCreated() 
    {
        populateData();
	    
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'castrol';
        testTemplate.Sales_Organization__c = 'UK01';
        testTemplate.lcf_Channel__c =  'Complaints';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);

        Surveytaker__c testSurveytaker = [Select Id,Case__c from Surveytaker__c LIMIT 1];
        system.assertEquals(testCase.Id, testSurveytaker.case__c);
    }
    
    @isTest
    static void isSurveyCreatedGROrg() 
    {
        populateData();
	    testAccount.Sales_Organisation__c = 'GR01';
        update testAccount;
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'bpcastrol';
        testTemplate.Sales_Organization__c = 'GR01';
        testTemplate.lcf_Channel__c =  'Complaints';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);

        Surveytaker__c testSurveytaker = [Select Id,Case__c from Surveytaker__c LIMIT 1];
        system.assertEquals(testCase.Id, testSurveytaker.case__c);
    }
    
 @isTest
    static void isSurveyCreatedDEOrg() 
    {
        populateData();
	    testAccount.Sales_Organisation__c = 'DE01';
        update testAccount;
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'bp';
        testTemplate.Sales_Organization__c = 'DE01';
        testTemplate.lcf_Channel__c =  'Complaints';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
    }

 @isTest
    static void isSurveyTemplateNotFound() 
    {
        populateData();
	    testAccount.Sales_Organisation__c = 'GR01';
        update testAccount;
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'bpcastrol';
        testTemplate.Sales_Organization__c = 'DE01';
        testTemplate.lcf_Channel__c =  'Complaints';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = true; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 12', testCase.CALCF_Not_Surveyed_Reason__c);
    }
    
    @isTest
    static void isNonComplaintSurveyCreated() 
    {
        populateData();
	    testAccount.Sales_Organisation__c = 'GR01';
        update testAccount;
        
        testContact.Last_Surveyed_Date__c = date.today().addDays(-40);
        testContact.Preferred_Language__c ='English-British';
		update testContact;
        
        Enquiries_Settings__c eq = new Enquiries_Settings__c();
        eq.Enquiry_Type__c = 'General Enquiries';
        eq.SR_Area__c = 'Order Inquiry';
        eq.SR_Sub_Area__c = 'Stock';
        eq.SR_Type__c = 'Order Management';
        eq.Name = '02';
		insert eq;
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'bpcastrol';
        testTemplate.Sales_Organization__c = 'GR01';
        testTemplate.lcf_Channel__c =  'General Enquiries';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = false; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testCase.Area__c = 'Order Inquiry'; 
        testCase.Sub_Area__c = 'Stock'; 
        testCase.Type = 'Order Management'; 
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        Surveytaker__c testSurveytaker = [Select Id,Case__c from Surveytaker__c LIMIT 1];
        system.assertEquals(testCase.Id, testSurveytaker.case__c);
    }

    @isTest
    static void isNonComplaintSurveyCreated2() 
    {
        populateData();
	    testAccount.Sales_Organisation__c = 'GR01';
        update testAccount;
        
        testContact.Last_Surveyed_Date__c = date.today().addDays(-40);
        testContact.Preferred_Language__c ='English-British';
		update testContact;
        
        Enquiries_Settings__c eq = new Enquiries_Settings__c();
        eq.Enquiry_Type__c = 'General Enquiries';
        eq.SR_Area__c = 'Delivery Details';
        eq.SR_Sub_Area__c = 'Status / Info';
        eq.SR_Type__c = 'Order Management';
        eq.Name = '02';
		insert eq;
        
        Survey__c testTemplate = new Survey__c();
        testTemplate.name = 'testtest';
        testTemplate.Language_Code__c = 'EN';
        testTemplate.CALCF_Brand__c = 'bpcastrol';
        testTemplate.Sales_Organization__c = 'GR01';
        testTemplate.lcf_Channel__c =  'General Enquiries';
        testTemplate.Active__c = true;
        insert testTemplate;

        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = testTemplate.Id;
        question.OrderNumber__c = 15;
        question.Question__c = 'test Question';
        question.CALCF_Question_Short_Name__c = 'NPS';
        insert question;
        
        Case testCase = new Case();
        testCase.Complaint__c = false; 
        testCase.CALCF_LCF_Not_Surveyed__c = true;
        testCase.Area__c = eq.SR_Area__c; 
        testCase.Sub_Area__c = eq.SR_Sub_Area__c; 
        testCase.Type = eq.SR_Type__c; 
        testcase.Contact_Type__c = 'Consumer';
        testCase.RecordTypeId = returnRecordTypeId('General Case');
        testcase.contactId = testContact.Id;
        testcase.CASFOLCF_SiebelClosedDate__c = date.today();
		testcase.Siebel_Last_Updated_Date__c = date.today();
        insert testCase;
        
        Test.startTest();
        testCase.Status = 'Closed';
		update testCase;
        Test.stopTest();
        testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c,subject,Complaint__c FROM Case LIMIT 1];
        system.assertEquals('Survey Error 00', testCase.CALCF_Not_Surveyed_Reason__c);
        Surveytaker__c testSurveytaker = [Select Id,Case__c from Surveytaker__c LIMIT 1];
        system.assertEquals(testCase.Id, testSurveytaker.case__c);
    }    
    
    private static void populateData()
    {
        testAccount = [Select Id From Account limit 1];
        testContact = [Select Id From Contact limit 1];
		testUser  = SFO_TestDataService.getUserLike(TEST_USER_USERNAME);
    }
    
    private static ID returnRecordTypeId(String RTName){
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
    
}