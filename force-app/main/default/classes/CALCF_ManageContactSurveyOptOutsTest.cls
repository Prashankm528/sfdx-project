/***************************************************************************************************
* Description : Unit Tests for CALCF_ManageContactSurveyOptOuts process builder and flow
*               Some of this flow scenaros were already covered in clsOptOutHelperTest Class.
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2020-May-04   1.0                 Narsimha Datla     	Initial version
*
***************************************************************************************************/
@isTest
private class CALCF_ManageContactSurveyOptOutsTest
{
    private static final String TEST_USER_USERNAME = 'SFOTestUser21434@Test12313.com.SFOTest12312' + Label.SFO_UsernameTestSuffix;
    private static Account testAccount;
    private static Contact testContact;
    private static User testUser;
    
    @testSetup
    static void setup() 
    {
        User accountIntegrationUserToInsert = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        accountIntegrationUserToInsert.username = TEST_USER_USERNAME;
        insert accountIntegrationUserToInsert;
        
        system.runAs(accountIntegrationUserToInsert) 
        {
            // Opted out perion will be 30 days.
            lcf_settings__c settings = new lcf_settings__c();
            settings.Opt_Out_Period__c = '30';
            
            insert settings;
            
        }
    }
    
    @isTest
    static void hasOptOutBeenRequestedTest() 
    {
        Account acc = SFO_TestDataService.createCustomerAccount();
        acc.Name = 'Test user';
        acc.Integration_Id__c = '12345020UK010203';
        acc.RecordTypeId = returnAccountRecordTypeId('Customer');
        insert acc;
        
        Contact con = SFO_TestDataService.createContact(acc.Id);
        con.FirstName = 'Test';
        con.LastName = 'User';
        con.AccountId = acc.Id;
        con.recordTypeId = returnContactRecordTypeId('General Contact');
        con.Email = 'dgadasdad@yewerwer.com';
        con.Home_Location__c = 'United Kingdom';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = 'Testerwrw@bperwer.COM';
        con.Last_Surveyed_Date__c = datetime.now().addDays(-1).date();
        con.Survey_Opt_Out_Requested__c = true;

        Test.startTest();
        	insert con;       
        Test.stopTest();
        
        con = [Select Id, Next_Surveyable_Date__c,Survey_Opt_Out_Requested__c From Contact Where Id =:con.Id];
        system.assertEquals(Datetime.now().addDays(30).Date(), con.Next_Surveyable_Date__c, 'Next Surveyabale date should be equal to 30 from Today');
		system.assertEquals(false, con.Survey_Opt_Out_Requested__c,'Survey_Opt_Out_Requested__c value should be false');
    }
  
    private static ID returnAccountRecordTypeId(String RTName)
    {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
    
    private static ID returnContactRecordTypeId(String RTName)
    {
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
    }
}