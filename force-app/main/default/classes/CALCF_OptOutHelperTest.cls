/************************************************************************************************************
*Description : Tests to clsOptOutHelper class
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-MAR-01   1.0                 Frantisek Kolacny   Initial version 
* 2017-Mar-22   1.1                 Frantisek Kolacny   Comments added 
* 2017-Aug-14   1.2                 Frantisek Kolacny   Survey_Opt_Out__c included in tests
* 2017-Aug-22   1.3                 Grant Whitfield     Updated for CASSFO-1955
*************************************************************************************************************/
@isTest
private class CALCF_OptOutHelperTest {
    
        /***********************************************************************************
        * Data Preparation Method 
        * ---------------------------- 
        * Method to create custom settings, account and contact prior to running tests. 
        ***********************************************************************************/
        @testSetup static void createData(){
        
        // Opted out perion will be 30 days.
        lcf_settings__c settings = new lcf_settings__c();
        settings.Opt_Out_Period__c = '30';
        
        insert settings;
       
        Id customerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' AND SobjectType = 'Account'  LIMIT 1].Id;  

        Account acc = new Account();
        acc.Name = 'David Gilmour';
        acc.Integration_Id__c = '12345020UK010203';
        acc.RecordTypeId = customerRecordTypeId;
        
        insert acc;
            
        Contact con = new Contact();
        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.AccountId = acc.Id;
        con.Email = 'david@ibm.com';
        con.Home_Location__c = 'United Kingdom';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        con.Last_Surveyed_Date__c = datetime.now().addDays(-1).date();
        
        insert con; 

    }
    
        
    /***********************************************************************************
    * Test Method
    *--------------
    * This method will test the situation when opt out is requested.
    * It will be requested by setting Survey_Opt_Out_Requested__c = true 
    * and calling clsOptOutNewRequestWrapper. As a result it will check Next_Surveyable_Date__c
    * on contact. 
    ***********************************************************************************/
    static testmethod void optOutRequested(){
        
        Test.startTest();
        
        Contact con = [SELECT Id, Survey_Opt_Out_Requested__c FROM Contact];
        // Opt out contact.
        con.Survey_Opt_Out_Requested__c = true;
        list<string> inParam = new list<string>();
        inParam.add(string.valueOf(con.Id));
        clsOptOutNewRequestWrapper.invokeOptOut(inParam);

        Test.stopTest();
        
        Contact updatedCon = [SELECT Id, Next_Surveyable_Date__c, Survey_Opt_Out_Requested__c FROM Contact];
        // Check Next_Surveyable_Date__c which indicate how long will be contact opred out. 
        System.assertEquals(datetime.now().addDays(30).date(), updatedCon.Next_Surveyable_Date__c);
        System.assertEquals(false, updatedCon.Survey_Opt_Out_Requested__c);
    }
    
    /***********************************************************************************
    * Test Method
    *--------------
    * This method will test situation when new contact i added into the system. 
    * this contact have email address of contact which already exist in the system and 
    * it is opred out.
    * As a result new contact will be opted out too. 
    ***********************************************************************************/
    static testmethod void newRecordCreated(){
        
        Profile profile = [Select Id From Profile where Name = 'System Administrator' limit 1];
        //all other required field.
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com.ibm223',
                           ProfileId = profile.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.runAs(usr){
            
            Id customerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' AND SobjectType = 'Account'  LIMIT 1].Id;  

            Account acc3                  = new Account();
            acc3.Name                     = 'David Gilmour3';
            acc3.Integration_Id__c        = '12345020UK0102031113';
            acc3.recordtypeid             = customerRecordTypeId;
            
            insert acc3;

            // New contact with the same email address. 
            Contact con                   = new Contact();
            
            con.FirstName                 = 'Roger';
            con.LastName                  = 'Waters';
            con.Email                     = 'david@ibm.com';
            con.Survey_Opt_Out__c         = true;
            con.AccountId                 = acc3.id;

            
            //This should trigger the process builder and sync the next and last survey dates between all contacts
            //with the same email... We have two of them
            insert con;

            
            Test.startTest();
            
            List<String> inParam = new List<String>();
            inParam.add(String.valueOf(con.Id));
            
            
            Contact updatedCon = [SELECT Id, FirstName, Contact_Deduplication_Id__c, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                    FROM Contact 
                                    WHERE FirstName = 'David'
                                    LIMIT 1];
                                    
            updatedCon.Next_Surveyable_Date__c   = datetime.now().addDays(10).date();
            updatedCon.Last_Surveyed_Date__c     = datetime.now().addDays(-2).date();
            update updatedCon;
            
            Test.stopTest();
            Contact firstCon = [SELECT Id, FirstName, Contact_Deduplication_Id__c, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                    FROM Contact 
                                    WHERE FirstName = 'Roger'
                                    LIMIT 1];
                                    
            Contact conAfterUpdate = [SELECT Id, FirstName, Contact_Deduplication_Id__c, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                    FROM Contact 
                                    WHERE FirstName = 'David'
                                    LIMIT 1];
            
            // Next_Surveyable_Date__c on both contact needs to be the same (same email address).
            System.assertEquals(firstCon.Next_Surveyable_Date__c, conAfterUpdate.Next_Surveyable_Date__c);
    
            // Last_Surveyed_Date__c on both contact needs to be the same (same email address).
            System.assertEquals(firstCon.Last_Surveyed_Date__c, conAfterUpdate.Last_Surveyed_Date__c);
            
            // Contacts should be opted out
            System.assertEquals(true, conAfterUpdate.Survey_Opt_Out__c);
            System.assertEquals(true, firstCon.Survey_Opt_Out__c);


        }  
    }
    
    /***********************************************************************************
    * Test Method
    *--------------
    * This method will test situation when contact is updated and it s email address is 
    * changed into address which already exist in system. 
    * As a result Next_Surveyable_Date__c of both of contacts must be the same.
    ***********************************************************************************/
    static testmethod void emailChaged(){
        
        Test.startTest();

        Id customerRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' AND SobjectType = 'Account'  LIMIT 1].Id;  


        Account acc2 = new Account();
        acc2.Name = 'David Gilmour2';
        acc2.Integration_Id__c = '12345020UK010203111';
        acc2.RecordTypeId = customerRecordTypeId;
        
        insert acc2;
        
        // New contact created.
        Contact con = new Contact();
        con.FirstName = 'David2';
        con.LastName = 'Gilmour2';
        con.Accountid = acc2.id;
        con.Email = 'david@ibm2.com';
        con.Home_Location__c = 'United Kingdom2';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Contact_Deduplication_Id__c = ' DAVID2GILMOUR2DAVID@IBM.COM';
        con.Next_Surveyable_Date__c = datetime.now().addDays(10).date();
        insert con;
        
        list<string> inParam = new list<string>();
        inParam.add(string.valueOf(con.Id)); 
        //clsOptOutNewRecordWrapper.invokeOptOut(inParam);
    
        Contact updatedCon = [SELECT Id, Next_Surveyable_Date__c FROM Contact WHERE FirstName = 'David'];
        System.assertEquals(null, updatedCon.Next_Surveyable_Date__c);
        
        // Email address is updated.
        Contact david2contact = [SELECT Id, Email FROM Contact WHERE FirstName = 'David2'];
        david2contact.Email = 'david@ibm.com';
        update david2contact;
        
        list<string> inParamEmailChange = new list<string>();
        inParamEmailChange.add(string.valueOf(david2contact.Id)); 
        clsOptOutAddressChangedWrapper.invokeOptOut(inParamEmailChange);
        
        Test.stopTest();
        
        Contact updatedCon2 = [SELECT Id, Next_Surveyable_Date__c FROM Contact WHERE FirstName = 'David'];
        // Next_Surveyable_Date__c on both contact needs to be the same (same email address).
        System.assertEquals(con.Next_Surveyable_Date__c, updatedCon2.Next_Surveyable_Date__c);
    }
    
}