/******************************************************************************************************************
* Description: Unit Tests for the clsRESTOrderPortalSurveyController Apex Class
*
* Date          Version #      Author           Description
* -----------------------------------------------------------------------------------------------------------
*
* 2017-FEB-15   1.0         Frantisek Kolacny   Initial version
* 2017-Mar-22   1.1         Frantisek Kolacny   Comments added
* 2017-Aug      1.2         Grant Whitfield     Changed endpoint
* 2017-Aug      1.3         Grant Whitfield     Changed tests to accomodate Org Consolidation, included CustomerRecordTypeId
* 2018-Sep-04   1.4         Maros Zilka         Fixed styling, and SonarQube errors,
*                                               added test to test business unit on account
* 2020-May-15   1.5         Rahma Belghouti     Fix Summer 20 critical update issue
*******************************************************************************************************************/

@isTest
private class clsRESTOrderPortalSurveyControllerTest {
    
    /***********************************************************************************
    * Data Preparation Method
    * ----------------------------
    * Method to create custom settings, account and contact prior to running tests.
    ***********************************************************************************/

    @testSetup static void setUp() {

        insert new UKMS_DIV_CODE_MAPPING__c(Name = '001', Div_Code_Name__c = 'Lubricants - Automotive', Salesforce_Code__c = '0203',Source_System_Code__c = '1202', Active__c = true);
        insert new UKMS_SALES_ORG_MAPPING__c(Name = '001', Salesforce_Code__c = 'UK01',Source_System_Code__c = 'GB07', Active__c = true);       
        
         // get a customer account record id
        Id CustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
           
        // New account.
        Account acc = new Account();

        acc.Name = 'David Gilmour';
        acc.RecordTypeId = CustomerRecordTypeId;
        acc.Integration_Id__c = '12345020UK010203';
        acc.Business_Unit__c = 'Lubricants - Industrial';
        
        insert acc;
        
        // New contact.    
        Contact con = new Contact();

        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.AccountId = acc.Id;
        con.Email = 'david@ibm.com';
        con.Home_Location__c = 'United Kingdom';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        
        insert con; 
        
        createSettings();
           
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when new contact source is created 
  * but there is no email template in the system.
  * As a result there will be one contact source but no survey.
    ***********************************************************************************/
    static testmethod void newContactSourceCreatedNoTemplateAvailable(){
      
      // Arrage          
    RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
    List<Contact_Source__c> result = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(1, result.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when Api key is not valid.
  * As a result there will be no contact source and no survey created.
    ***********************************************************************************/
    static testmethod void apiKeyNotValid(){
    
    // Arrage
    RestResponse res = new RestResponse();    
    RestRequest req = createRequestInvlaidApiKey();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(0, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when Sales Org is not valid.
  * As a result there will be no contact source and no survey created.
    ***********************************************************************************/
    static testmethod void salesOrgNotSupported(){
      
      // Arrage        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     
      req.params.put('SalesOrg', 'NOT SUPPORTED');

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(0, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when Div. Code is not valid.
  * As a result there will be no contact source and no survey created.
    ***********************************************************************************/
    static testmethod void divCodeNotSupported(){
      
      // Arrage
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     
      req.params.put('DivCode', 'NOT SUPPORTED');

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(0, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when there is not valid Account in the system.
  * As a result there will be no contact source and no survey created.
    ***********************************************************************************/
    static testmethod void invalidAccountInRequest(){
      
      // Arrage
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     
      req.params.put('ExternalAccountId', 'Invalid');

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(0, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when email address is empty
  * in this situation it will be not possible to asembly deduplication key.
  * As a result there will be no contact source and no survey created.
    ***********************************************************************************/
    static testmethod void noEmailForDeDuplicationId(){
      
      // Arrage
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     
      req.params.put('ContactEmailAddress', '');

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(0, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when all requirements to create survey are met.
  * As a result there will contact source and survey created.
    ***********************************************************************************/
     static testmethod void surveyAndNewSourceCreated(){
      
      // Arrage
    createValidTemplate();        
        
    RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(1, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(1, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will check if mapping for new contact source is valid. 
    ***********************************************************************************/
    static testmethod void newSourceMapping(){
      
      // Arrage
    createValidTemplate();        
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
    List<Contact_Source__c> result = [SELECT Id, Contact__c, Review__c, Review_Comments__c, Account_ERP_ID__c, Account_Integration_Id__c, Business_Unit__c, 
                      Account_Name__c, Contact_Deduplication_Id__c, Contact_Email__c,Contact_First_Name__c, Contact_Last_Name__c, External_Contact_Id__c,
                      External_User_Id__c, Sales_Organisation__c, Source_System__c, Reference__c, User_Source__c,  Source_URL__c
                  FROM Contact_Source__c LIMIT 1];
                  
    System.assertEquals('12345', result.get(0).Account_ERP_ID__c);
    System.assertEquals('12345020UK010203', result.get(0).Account_Integration_Id__c);
    System.assertEquals('Lubricants - Automotive', result.get(0).Business_Unit__c);
    System.assertEquals('DAVIDGILMOURDAVID@IBM.COM', result.get(0).Contact_Deduplication_Id__c);
    System.assertEquals('david@ibm.com', result.get(0).Contact_Email__c);
    System.assertEquals('David', result.get(0).Contact_First_Name__c);
    System.assertEquals('Gilmour', result.get(0).Contact_Last_Name__c);
    System.assertEquals('00008171', result.get(0).External_Contact_Id__c);
    System.assertEquals('PD1Id1234', result.get(0).External_User_Id__c);
    System.assertEquals('UK01', result.get(0).Sales_Organisation__c);
    System.assertEquals('Nike%20Customer%20Portal', result.get(0).Source_System__c);
    System.assertEquals('12345', result.get(0).Reference__c);
    System.assertEquals('ExternalAccountName', result.get(0).Account_Name__c);
    System.assertEquals('ExternalUserSource', result.get(0).User_Source__c);
    System.assertEquals('SourceURL', result.get(0).Source_URL__c);
    
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact source is in the system and contains contact Id.
  * As a result there will contact source and survey created. 
    ***********************************************************************************/
    static testmethod void sourceExistSurveyIsCreated(){
      
      // Arrage
    createValidTemplate();     
        
        Contact con = [SELECT Id FROM Contact];
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.User_Source__c = 'ExternalUserSource';
        contactSource.Contact__c = con.Id;
        insert contactSource;
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(1, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(1, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will check if mapping for update contact source is valid. 
    ***********************************************************************************/
    static testmethod void sourceExistNoContactInIt(){
      
      // Arrage
    createValidTemplate();     
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.User_Source__c = 'ExternalUserSource';
        contactSource.Review__c = true;
        insert contactSource;
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
    List<Contact_Source__c> result = [SELECT Id, Contact__c, Review__c, Review_Comments__c, Account_ERP_ID__c, Account_Integration_Id__c, Business_Unit__c, 
                      Account_Name__c, Contact_Deduplication_Id__c, Contact_Email__c,Contact_First_Name__c, Contact_Last_Name__c, External_Contact_Id__c,
                      External_User_Id__c, Sales_Organisation__c, Source_System__c, Reference__c 
                  FROM Contact_Source__c LIMIT 1];
                  
    System.assertEquals('12345', result.get(0).Account_ERP_ID__c);
    System.assertEquals('12345020UK010203', result.get(0).Account_Integration_Id__c);
    System.assertEquals('Lubricants - Automotive', result.get(0).Business_Unit__c);
    System.assertEquals('DAVIDGILMOURDAVID@IBM.COM', result.get(0).Contact_Deduplication_Id__c);
    System.assertEquals('david@ibm.com', result.get(0).Contact_Email__c);
    System.assertEquals('David', result.get(0).Contact_First_Name__c);
    System.assertEquals('Gilmour', result.get(0).Contact_Last_Name__c);
    System.assertEquals('00008171', result.get(0).External_Contact_Id__c);
    System.assertEquals('PD1Id1234', result.get(0).External_User_Id__c);
    System.assertEquals('UK01', result.get(0).Sales_Organisation__c);
    System.assertEquals('Nike%20Customer%20Portal', result.get(0).Source_System__c);
    System.assertEquals('12345', result.get(0).Reference__c);
    System.assertEquals('ExternalAccountName', result.get(0).Account_Name__c);
        
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(1, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact source is in the system but no contact Id is in it.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void sourceExistNoContactInItAndNoContactMatch(){
      
      // Arrage
    createValidTemplate();     
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.Review__c = true;
        insert contactSource;
        
      RestResponse res = new RestResponse();
    RestRequest req = createRequest();     
        req.params.put('ContactEmailAddress', 'not@davidemail.com');
        
    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert        
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact source is in the system but no contact Id is in it.
  * There is multiple contacts in system. This need to run under "Integration" user.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void sourceExistNoContactInItAndMultipleContactsMatch(){
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Castrol_Integration'];
      User u = new User(Alias = 'R3434', Email='RnadomName343@testorg.com', EmailEncodingKey='UTF-8', LastName='RnadomName3434', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='RnadomName43434@testorg.com');
      System.runAs(u) {
      
      
        // get a customer account record id
        Id CustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
      
        // New account.
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.recordtypeid = CustomerRecordTypeId;
        acc1.Integration_Id__c = '09876543210UK010203';
        
        insert acc1;
      
      
      // Arrage
    createValidTemplate();     
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.Review__c = true;
        insert contactSource;
    
        // Second contact
        Contact con = new Contact();
        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.Email = 'david@ibm.com';
        con.Home_Location__c = 'United Kingdom';
        con.accountid = acc1.id;
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = '  DAVIDGILMOURDAVID@IBM.COM';        
        insert con; 
        
      RestResponse res = new RestResponse();
    RestRequest req = createRequest();     
        
    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
      }
      
    // Assert        
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact source is in the system but no contact Id is in it.
  * No email in request so there will be no way how to create deduplication key.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void sourceExistNoContactInItAndNoEmail(){
      
      // Arrage
    createValidTemplate();     
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.Review__c = true;
        insert contactSource;
        
      RestResponse res = new RestResponse();
    RestRequest req = createRequest();     
        req.params.put('ContactEmailAddress', '');
    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert        
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when no contact source is in the system.
  * No email in request so there will be no way how to create deduplication key.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void noContactSourceAndNoContactFound(){
      
      // Arrage
    createValidTemplate();        
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();   
     req.params.put('ContactEmailAddress', 'not@david.com');  

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
      List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
    System.assertEquals(1, source.size());
    
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when no contact source is in the system.
  * There is multiple contacts in system. This need to run under "Integration" user.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void noContactSourceAndMultipleContactsFound(){
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Castrol_Integration'];
      User u = new User(Alias = 'R3434', Email='RnadomName343@testorg.com', EmailEncodingKey='UTF-8', LastName='RnadomName3434', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='RnadomName43434@testorg.com');
      System.runAs(u) {
        
      // Arrage
    createValidTemplate();        
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();   

    RestContext.request = req;
    RestContext.response = res;
    
    account newAcc = new account();
    newAcc.Name = 'Roger';
    insert newAcc;
    
    Contact con = new Contact();
        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.AccountId = newAcc.Id;
        con.Email = 'david@ibm.com';
        con.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        
    Contact con2 = new Contact();
        con2.FirstName = 'David';
        con2.LastName = 'Gilmour';
        con2.AccountId = newAcc.Id;
        con2.Email = 'david@ibm.com';
        con2.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        
        insert con2; 
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
      
    // Assert 
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
            
    }
      
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will check if mapping for SurveyTaker__c is valid. 
    ***********************************************************************************/
    static testmethod void surveyMapping(){
      
      // Arrage
    createValidTemplate();        
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert  
    List<SurveyTaker__c> survey = [SELECT Id, RecordTypeId, Contact__c, Reference_Number__c, Portal_Messages__c, Order_Ship_To__c,
                    Source_System__c, Survey_Status__c, Mode__c, Account__c, Sales_Organisation__c, survey__c 
                    FROM SurveyTaker__c LIMIT 1];
                    
    System.assertEquals(1, survey.size());    
    System.assertEquals('12345', survey.get(0).Reference_Number__c);
    System.assertEquals('Portal%20Message', survey.get(0).Portal_Messages__c);
    System.assertEquals('0987654321', survey.get(0).Order_Ship_To__c);
    System.assertEquals('Nike%20Customer%20Portal', survey.get(0).Source_System__c);
    System.assertEquals('Pending', survey.get(0).Survey_Status__c);
    System.assertEquals('Online', survey.get(0).Mode__c);
    System.assertEquals('UK01', survey.get(0).Sales_Organisation__c);
    
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact is opted out.
  * As a result there will be no survey created. 
    ***********************************************************************************/
    static testmethod void contactIsOptedOutSurveyNotCreated() {
    
        // Arrage
        createValidTemplate();
        
        Contact con = [SELECT Id, Next_Surveyable_Date__c FROM Contact LIMIT 1];
        con.Next_Surveyable_Date__c = datetime.now().addDays(1).date();
        update con;
        
        RestResponse res = new RestResponse();
        RestRequest req = createRequest();

        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        clsRESTOrderPortalSurveyController.doGet();
        Test.stopTest();
        
        // Assert
        List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        System.assertEquals(0, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact is Test Contact and LCF is in TEST mode.
  * As a result there will be survey created for contact.
    ***********************************************************************************/
    static testmethod void contactIsTestContactSurveyIsCreatedInTestMode(){
      
      // Arrage
    createValidTemplate();
        
        Contact con = [SELECT Test_Contact__c FROM Contact LIMIT 1];
        con.Test_Contact__c = true;
        update con;
                
        lcf_settings__c Settings = [Select Test_Mode__c FROM lcf_settings__c LIMIT 1];
        Settings.Test_Mode__c = true;
        update Settings;
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(true, lcf_settings__c.getInstance().Test_Mode__c);
    System.assertEquals(1, survey.size());
    }
    
    /***********************************************************************************
  * Test Method
  *--------------
  * Method will simulate situation when contact is Test Contact and LCF is not in TEST mode.
  * As a result there will be no survey created for contact.
    ***********************************************************************************/
    static testmethod void contactIsTestContactSurveyIsNotCreatedInTestMode(){
      
      // Arrage
    createValidTemplate();     
        
        Contact con = [SELECT Id, Next_Surveyable_Date__c, Test_Contact__c FROM Contact LIMIT 1];
        con.Next_Surveyable_Date__c = datetime.now().addDays(1).date();
        con.Test_Contact__c = true;
        update con;
        
      RestResponse res = new RestResponse();    
    RestRequest req = createRequest();     

    RestContext.request = req;
    RestContext.response = res;
    
    // Act
    Test.startTest();
    clsRESTOrderPortalSurveyController.doGet();
    Test.stopTest();
    
    // Assert
    List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
    System.assertEquals(0, survey.size());
    }
        
    /***********************************************************************************
    * Test Method
    *--------------
    * Method will create a survey for the sales org RO
    ***********************************************************************************/
    static testmethod void createSurveyWithROSalesOrg(){
        // Arrage
        insert new UKMS_SALES_ORG_MAPPING__c(Name = '002', Salesforce_Code__c = 'RO01',Source_System_Code__c = 'C004', Active__c = true); 
        Survey__c template = new Survey__c();
        template.lcf_Channel__c = 'Orders';
        template.Active__c = true;
        template.Language_Code__c = 'en';
        template.Sales_Organization__c = 'RO01';
        template.Integration_Id__c = '001';
        template.CALCF_Brand__c = 'castrol';
        insert template;
        
        Account account = [SELECT Id FROM Account WHERE Name = 'David Gilmour'];
        account.Integration_Id__c = '12345017RO010203ABCD';
        update account;
        
        RestResponse res = new RestResponse();    
        RestRequest req = createRequest();
        req.params.put('SalesOrg', 'C004');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        clsRESTOrderPortalSurveyController.doGet();
        Test.stopTest();
        
        // Assert
        List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
        System.assertEquals(1, source.size());
        
        List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        System.assertEquals(1, survey.size());
    }
    /***********************************************************************************
    * Test Method
    *--------------
    * Method will create a survey for the sales org PL
    ***********************************************************************************/
    static testmethod void createSurveyWithPLSalesOrg(){
        
        // Arrage
        insert new UKMS_SALES_ORG_MAPPING__c(Name = '003', Salesforce_Code__c = 'PL01',Source_System_Code__c = 'PLA4', Active__c = true); 
        Survey__c template = new Survey__c();
        template.lcf_Channel__c = 'Orders';
        template.Active__c = true;
        template.Language_Code__c = 'en';
        template.Sales_Organization__c = 'PL01';
        template.Integration_Id__c = '001';
        template.CALCF_Brand__c = 'castrol';
        insert template;
        
        Account account = [SELECT Id FROM Account WHERE Name = 'David Gilmour'];
        account.Integration_Id__c = '12345033PL010203';
        update account;
        
        RestResponse res = new RestResponse();    
        RestRequest req = createRequest();
        req.params.put('SalesOrg', 'PLA4');
        System.debug('req = '+req);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        clsRESTOrderPortalSurveyController.doGet();
        Test.stopTest();
        
        // Assert
        List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
        System.assertEquals(1, source.size());
        
        List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        System.assertEquals(1, survey.size());
    }
    /***********************************************************************************
    * Test Method
    *--------------
    * Method will test validate method
    ***********************************************************************************/
    static testmethod void testValidateData(){
        
        // Arrage        
        RestResponse res = new RestResponse();
        RestRequest req = createRequest();     
        req.params.put('ExternalContactId', '');
        req.params.put('ExternalUserId', '');
        req.params.put('ContactFirstName', '');
        req.params.put('ContactLastName', '');
        req.params.put('ContactEmailAddress', '');
        req.params.put('ExternalAccountId', '');
        req.params.put('SalesOrg', '');
        req.params.put('DivCode', '');
        req.params.put('DistChannel', '');
        req.params.put('Locale', '');
        req.params.put('LanguageCode', '');
        req.params.put('ExternalUserSource', '');
        req.params.put('Apikey', '');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        clsRESTOrderPortalSurveyController.doGet();
        Test.stopTest();
        
        // Assert        
        List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        System.assertEquals(0, survey.size());
    }
    /***********************************************************************************
    * Test Method
    *--------------
    * Method will simulate situation when contact source does not have a contact
    ***********************************************************************************/
    static testmethod void sourceDoesNotExistSurveyIsCreated(){
        
        // Arrage
        createValidTemplate();             
        
        Contact_Source__c contactSource = new Contact_Source__c();
        contactSource.External_User_Id__c = 'PD1Id1234';
        contactSource.User_Source__c = 'ExternalUserSource';
        contactSource.Contact__c = Null;
        insert contactSource;
        
        RestResponse res = new RestResponse();    
        RestRequest req = createRequest();     
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Act
        Test.startTest();
        clsRESTOrderPortalSurveyController.doGet();
        Test.stopTest();
        
        // Assert
        List<Contact_Source__c> source = [SELECT Id FROM Contact_Source__c LIMIT 1];
        System.assertEquals(1, source.size());
        
        List<SurveyTaker__c> survey = [SELECT Id FROM SurveyTaker__c LIMIT 1];
        System.assertEquals(0, survey.size());
    }
    
    static void createValidTemplate(){
      Survey__c template = new Survey__c();
      template.lcf_Channel__c = 'Orders';
      template.Active__c = true;
      template.Language_Code__c = 'en';
      template.Sales_Organization__c = 'UK01';
      template.Integration_Id__c = '001';
      template.CALCF_Brand__c = 'castrol';
      insert template;
    }
    
    static void createSettings(){
      
      lcf_settings__c NewSettings = new   lcf_settings__c();
        NewSettings.Do_Not_Survey_Period__c = '10';
        NewSettings.Portal_API_Key__c = '1';
        NewSettings.Order_Survey_API_Active__c = true;
        insert NewSettings;            
    }
    
    private static RestRequest createRequest(){
      
      RestRequest req = new RestRequest();   
      req.requestURI  = 'dummyrequestURI';
      req.httpMethod = 'GET';   
      req.params.put('ExternalContactId', '00008171');
      req.params.put('ExternalUserId', 'PD1Id1234');
      req.params.put('ContactFirstName', 'David');
      req.params.put('ContactLastName', 'Gilmour');
      req.params.put('ContactEmailAddress', 'david@ibm.com');
      req.params.put('ExternalAccountId', '12345');
      req.params.put('SalesOrg', 'GB07');
      req.params.put('DivCode', '02');
      req.params.put('DistChannel', '12');
      req.params.put('Brand', 'Castrol');
      req.params.put('Locale', 'en_GB');
      req.params.put('LanguageCode', 'en');
      req.params.put('ReferenceNumber', '12345');
      req.params.put('Source', 'Nike%20Customer%20Portal');
      req.params.put('PortalMessages', 'Portal%20Message');
      req.params.put('ShipTo', '0987654321');
      req.params.put('Apikey', '1');
      req.params.put('ExternalAccountName', 'ExternalAccountName');
      req.params.put('ExternalUserSource', 'ExternalUserSource');
      req.params.put('SourceURL', 'SourceURL');
      
      return req;
    }

    private static RestRequest createRequestInvlaidApiKey(){
        
        RestRequest req = new RestRequest();
        req.requestURI = 'dummyrequestURI';
        req.httpMethod = 'GET';
        req.params.put('ExternalContactId', '00008171');
        req.params.put('ExternalUserId', 'PD1Id1234');
        req.params.put('ContactFirstName', 'David');
        req.params.put('ContactLastName', 'Gilmour');
        req.params.put('ContactEmailAddress', 'david@ibm.com');
        req.params.put('ExternalAccountId', '12345');
        req.params.put('SalesOrg', 'GB07');
        req.params.put('DivCode', '02');
        req.params.put('DistChannel', '12');
        req.params.put('Brand', 'Castrol');
        req.params.put('Locale', 'en_GB');
        req.params.put('LanguageCode', 'en');
        req.params.put('ReferenceNumber', '12345');
        req.params.put('Source', 'Nike%20Customer%20Portal');
        req.params.put('PortalMessages', 'Portal%20Message');
        req.params.put('ShipTo', '0987654321');
        req.params.put('Apikey', 'invalid');
        req.params.put('ExternalAccountName', 'ExternalAccountName');
        req.params.put('ExternalUserSource', 'ExternalUserSource');
        req.params.put('SourceURL', 'SourceURL');
        
        return req;
    }
}