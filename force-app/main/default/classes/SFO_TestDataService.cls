/*****************************************************************************************
*	    Date:		    20APR2020
*       Author:         
*       Description:    Data factory class for SFO
*       Modifications:  22APR2020 Rahma Belghouti - Add create ContentNote method
****************************************************************************************/
public with sharing class SFO_TestDataService {
    private static Integer userCount = 0;
    private static final String MULTIPLE_NTID_TEST_USER_MAIN_NTID = 'apextest1';
    public static final String MULTIPLE_NTID_TEST_USER_SECOND_NTID = 'apextest2';
    
    /*
* Returns an account record type map
*/
    public static Map<String,RecordTypeInfo> AccountRecordTypeMap {
        get {
            if (AccountRecordTypeMap == null) {
                AccountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            
            return AccountRecordTypeMap;
        }
        
        private set;
    }
    
    /*
* Returns an opportunity record type map
*/
    public static Map<String,RecordTypeInfo> OpportunityRecordTypeMap {
        get {
            if (OpportunityRecordTypeMap == null) {
                OpportunityRecordTypeMap = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            
            return OpportunityRecordTypeMap;
        }
        
        private set;
    }
    
    /*
* Returns a contact record type map
*/
    public static Map<String,RecordTypeInfo> ContactRecordTypeMap {
        get {
            if (ContactRecordTypeMap == null) {
                ContactRecordTypeMap = Contact.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            
            return ContactRecordTypeMap;
        }
        
        private set;
    }
    
    /*
* Returns an Castrol sales user profile
*/
    public static Profile CastrolSalesUserProfile {
        get {
            if (CastrolSalesUserProfile == null) {
                CastrolSalesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
            }
            
            return CastrolSalesUserProfile;
        }
        
        private set;
    }
    
    /*
* Returns System Admin profile
*/
    public static Profile systemAdminProfile {
        get {
            if (systemAdminProfile == null) {
                systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            }
            
            return systemAdminProfile;
        }
        
        private set;
    }
    
    /*
* Returns a Castrol - Alpine FWS Sales role user
*/
    public static UserRole CastrolSalesAlpineFwsSalesRole {
        get {
            if (CastrolSalesAlpineFwsSalesRole == null) {
                CastrolSalesAlpineFwsSalesRole = [SELECT Id FROM UserRole WHERE Name = 'Castrol - Alpine FWS Sales'];
            }
            
            return CastrolSalesAlpineFwsSalesRole;
        }
        
        private set;
    }
    
    /*
* Returns a Castrol Sales User
*/
    public static User createCastrolSalesUser(Id profileId, Id userRoleId) {
        userCount++;
        String username = 'TestUserBxx_SFO_TestDataService' + userCount + '@example.castrol.com';
        
        //Setup Sales User
        User u = new User(
            Alias = 'TestUser',
            Email = username,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = username,
            Business_Unit__c = 'Lubricants - Automotive',
            Sales_Organisation__c = 'AT01',
            UserRoleId = userRoleId
        );
        
        return u;
    }
    
    
    /*
* Returns Castrol Products
*/
    public static List<Product2> createCastrolTestProducts(Integer batchSize) {
        List<Product2> products = new List<Product2>();
        
        for (Integer i = 0; i < batchSize; i++) {
            products.add(
                new Product2(
                    Name = 'Test Product ' + i,
                    IsActive = true,
                    Family = 'Lubricants - Automotive',
                    CASFO_Product_Sales_Organisation__c = 'AT01'
                )
            );
        }
        
        return products;
    }
    
    /*
* Returns customer account
*/
    public static Account createCustomerAccount() {
        Account acc = new Account(
            Name = 'Test acc',
            RecordTypeId = AccountRecordTypeMap.get('Customer').getRecordTypeId(),
            AccountNumber = '123456'
        );
        
        return acc;
    }
    
    /*
* Returns multiple sObjects
*/
    public static List<Account> createCustomerAccounts(Integer batchSize) {
        List<Account> accountList = new List<Account>();
        for(Integer count = 0; count < batchSize; count++)
        {
            Account testAccount = createCustomerAccount();
            testAccount.Name = 'Test acc'+ count;
            testAccount.AccountNumber = '123456'+ count;
            accountList.add(testAccount);
        }
        return accountList;
    }
    /*
* Returns a contact
*/
    public static Contact createContact(Id accId) {
        Contact con = new Contact(
            FirstName ='Test',
            LastName = 'User',
            AccountId = accId,
            RecordTypeId = ContactRecordTypeMap.get('General_Contact').getRecordTypeId()
        );
        
        return con;
    }
    
    /*
* Returns an opportunity
*/
    public static Opportunity createCastrolOpportunity(Id accId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Test Trigger Oppty',
            CloseDate = Date.today().addDays(33),
            StageName = 'Lead',
            AccountId = accId,
            Sales_Method__c = 'Spot',
            CurrencyIsoCode = 'USD',
            Supply_Start_Date__c = Date.today().addDays(33),
            RecordTypeId = OpportunityRecordTypeMap.get('General').getRecordTypeId()
        );
        
        return opportunity;
    }
    
    /*
* Returns an opportunity contact role
*/
    public static CASFO_Opportunity_Contact__c createOpportunityContactRole(Id oppId, Id conId) {
        CASFO_Opportunity_Contact__c oppContact = new CASFO_Opportunity_Contact__c(
            CASFO_Opportunity__c = oppId,
            CASFO_Contact__c = conId,
            CASFO_Role__c = 'Decision Maker'
        );
        
        return oppContact;
    }
    
    /*
* Returns an opportunity revenue
*/
    public static Revenue__c createOpportunityRevenue(Id oppId, Id productId) {
        Revenue__c oppRevenue = new Revenue__c(
            Opportunity__c = oppId,
            Product__c = productId,
            Type__c = 'New',
            CurrencyIsoCode = 'USD',
            Revenue__c = 1000,
            Margin__c = 1000,
            Volume__c = 1,
            OEM__c = 'Ford'
        );
        
        return oppRevenue;
    }
    
    /*
* return SFO_Opportunity_Offer__c
*/
    
    public static SFO_Opportunity_Offer__c createOpportunityOffer(Id oppId,Id offerId)
    {
        SFO_Opportunity_Offer__c opportunityOffer = new SFO_Opportunity_Offer__c(
            SFO_Opportunity__c = oppId,
            SFO_Offer__c =offerId
        );
        return opportunityOffer;
    }
    
    public static SFO_Offer__c createOffer(Id oppId)
    {
        SFO_Offer__c newOffer = new SFO_Offer__c(
            Name = 'Castrol i-Learning',
            CurrencyIsoCode ='USD'
        );
        return newOffer;
    }
    
    /*
* Returns a target
*/
    public static SFO_Target__c createTarget(Account account, string year, string quarter)
    {
        SFO_Target__c target = new SFO_Target__c();
        
        target.SFO_Account__c = account.Id;
        target.SFO_Year__c = year;
        target.SFO_Quarter__c = quarter;
        target.SFO_Margin__c = 1000;
        target.SFO_Revenue__c = 10000;
        target.SFO_Volume__c = 10000;
        
        return target;
    }
    /*
* Returns an event
*/
    public static Event createEvent(Id recordTypeId) {
        Event newEvent= new Event(
            RecordTypeId = recordTypeId,
            Subject = 'Call',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().AddDays(2)
        );
        return newEvent;
    }
    
    /*
* Returns a content
*/
    public static ContentVersion createContent(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Document',
            PathOnClient = 'Document.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        return contentVersion;
    }
    
    /*
* Returns a content note
*/
    public static ContentNote createContentNote(String title, String body){
        String bodyText = body;
        ContentNote contentNote = new ContentNote(
            Title = title,
            Content = Blob.valueOf(bodyText.escapeHTML4())       
        );
        return contentNote;
    }
    
    /*
* Returns a document link
*/
    public static ContentDocumentLink createDocumentLink(Id contentDocumentId, Id linkedEntityId){
        ContentDocumentLink documentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId,
            ShareType = 'V'
        );
        return documentLink;
    }
    
    /*
* Returns a user with that like username
*/
    public static User getUserLike(String username){
        String searchedUsername = username + '%';
        User result = [SELECT Id, isActive FROM User WHERE UserName LIKE: searchedUsername AND isActive = true LIMIT 1];
        return result;
    }
    
    /*
* Returns a user with that username
*/
    public static List<User> getUsers(String username){
        return  [SELECT Id, isActive FROM User WHERE UserName =: username AND isActive = true];
    }
    
    /*
* Create the test user with more than one NTID
*/
    public static User createMultipleNTIDTestUser(){
        User result = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.systemAdminProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        result.NTID__c = MULTIPLE_NTID_TEST_USER_MAIN_NTID;
        return result;
    }
    
    /*
* Returns Sandbox Username Suffix for the usernames
* If it is sfodev sandbox, then return '.sfodev'.
* If it is production, returns ''
*/
    public static String SandboxUsernameSuffix{
        get {
            if(SandboxUsernameSuffix  == null) {
                if (IsSandbox) {
                    SandboxUsernameSuffix = '.' + UserInfo.getUserName().substringAfterLast('.');
                } else {
                    SandboxUsernameSuffix = '';
                }
            }
            return SandboxUsernameSuffix;
        }
        
        private set;
    }
    
    /*
* Returns true if it is sandbox. Return false if it is production
*/
    public static Boolean IsSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            
            return isSandbox;
        }
        
        private set;
    }
}