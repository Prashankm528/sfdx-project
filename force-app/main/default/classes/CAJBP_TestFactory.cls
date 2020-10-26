/**
 * @author Jan Majling
 * @date 21/08/2018
 * @description     Test Factory for CAJBP project
 * 16/01/2019   Venkatesh Muniyasamy    Updated for JBP Validation
 * 28/01/2020   Venkatesh Muniyasamy    Updated for Objective Currency as JBPs
 * 27/04/2020   Venkatesh Muniyasamy    Updated for YTD JBP Creation
 * 03/09/2020   Abhinit Kohar           Added method to create Admin Users
 */
@isTest
public class CAJBP_TestFactory {
    private static final BPG_TestDataService.SObjectCreator RecordCreator = new BPG_TestDataService.SObjectCreator();
	public static final String CURRENCY_ISO_CODE = 'USD';
	public static final String STANDARD_USER_PERMISSION_SET = 'CAJBP Standard User';
	public static final String ADMIN_USER_PERMISSION_SET = 'CAJBP Admin User';
	public static final String ADMIN_BUSINESS_GOALS_PERMISSION_SET = 'CAJBP Business Strategic Goals Admin';

    /*
    * Generates a set of test users.
    */
    public static List<User> createUsers(Integer count, Integer offset) {
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
        ];
        List<User> users = new List<User>();
        Integer max = count + offset;
        for(Integer i = offset; i < max; i++) {
            Long currentTime = DateTime.now().getTime();
            String username = ('cajbp.user@test.com#' + i + '#' + currentTime);

            User user = new User(
                ProfileId = profile.Id,
                Username = username.left(80),
                LastName = 'JBP User',
                Email = 'jbp_user' + i +'@test.com.bp.customer.uk',
                Alias = ('jbp' + i + currentTime).left(8),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                CommunityNickname = username.left(40)
            );
            users.add(user);
        }
        insert users;
        return users;
    }

    /*
    * Generates a set of Admin test users.
    */
    public static List<User> createAdminUsers(Integer count, Integer offset) {
        Profile profile = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
        ];
        List<User> users = new List<User>();
        Integer max = count + offset;
        for(Integer i = offset; i < max; i++) {
            Long currentTime = DateTime.now().getTime();
            String username = ('cajbp.user@test.com#' + i + '#' + currentTime);

            User user = new User(
                    ProfileId = profile.Id,
                    Username = username.left(80),
                    LastName = 'JBP User',
                    Email = 'jbp_user' + i +'@test.com.bp.customer.uk',
                    Alias = ('jbp' + i + currentTime).left(8),
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    CommunityNickname = username.left(40)
            );
            users.add(user);
        }
        insert users;
        return users;
    }

    public static void createPermissionSetAssignment(ID userId, String name) {
        Database.upsert(new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Label = :name LIMIT 1].Id,
            AssigneeId = userId
        ));
    }

    public static CAJBP_Business_Strategic_Goal__c createBusinessGoal(String channel, String title, String year, String clt) {
        CAJBP_Business_Strategic_Goal__c record = new CAJBP_Business_Strategic_Goal__c(
            Name = title,
            CAJBP_Year__c = year,
            CAJBP_CLT__c = clt,
            CAJBP_Channel__c = channel
        );
        return record;
    }

    /*
    * Generates a new customer account.
    */
    public static Account createAccount() {
        Id recordTypeCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account account = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeCustomerId,
            Type = 'ZMHI'
        );
        insert account;
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Last', accountId = account.Id);
        insert contact;

        return account;
    }

    public static Contact createContact(ID accId) {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Last', accountId = accId);
        return contact;
    }

    /*
    * Generates a new customer account and joint business plan.
    */
    public static CAJBP_Joint_Business_Plan__c createJointBusinessPlan() {
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = '2080',
            CAJBP_State__c = 'Draft',
            CurrencyIsoCode = 'EUR',
            CAJBP_JBP_End_Date__c = Date.today().addDays(5),
            CAJBP_Account_Locale__c = 'en_GB'
        );
        insert jbp;
        return jbp;
    }
    /*
    * Generates a new customer account and joint business planbased on input.
    */
    public static CAJBP_Joint_Business_Plan__c createJointBusinessPlan(String year, String state) {
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = year,
            CAJBP_State__c = state,
            CurrencyIsoCode = 'EUR',
            CAJBP_JBP_End_Date__c = Date.today().addDays(5),
            CAJBP_Account_Locale__c = 'en_GB'
        );
        insert jbp;
        return jbp;
    }

    /*
    * Generates a new customer account and joint business planbased on input.
    */
    public static CAJBP_Joint_Business_Plan__c createJointBusinessPlan(String year, String state, string clt, string recordTypeId) {
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Account__c = CAJBP_TestFactory.createAccount().Id,
            CAJBP_Year__c = year,
            CAJBP_State__c = state,
            CurrencyIsoCode = 'EUR',
            CAJBP_CLT__C = clt,
            RecordTypeId = recordTypeId,
            CAJBP_JBP_End_Date__c = Date.today().addDays(5),
            CAJBP_Account_Locale__c = 'en_GB'
        );
        insert jbp;
        return jbp;
    }

    /*
    * Generates a new jbp team member for sharing.
    */
     public static CAJBP_JBP_Team_Member__c createJBPTeamMember(Id userId, Id jbpId, String access, String role) {
        CAJBP_JBP_Team_Member__c teamMember = new CAJBP_JBP_Team_Member__c(
            CAJBP_User__c = userId,
            CAJBP_Joint_Business_Plan__c = jbpId,
            CAJBP_Access__c = access,
            CAJBP_Role__c = role
        );
        insert teamMember;
        return teamMember;
    }

    public static CAJBP_Objective__c createObjective(Id jbpId) {
        CAJBP_Objective__c objective = new CAJBP_Objective__c(
            CAJBP_Joint_Business_Plan__c = jbpId,
            Name = 'Test Objective',
            CAJBP_Description__c = 'Test Objective Description',
            CurrencyIsoCode = 'USD'
        );
        insert objective;
        return objective;
    }

    public static CAJBP_JBP_Activity__c createJbpActivity(Id objectiveId) {
        CAJBP_JBP_Activity__c jbpActivity = new CAJBP_JBP_Activity__c(
            Name = 'Test JBP Activity',
            CAJBP_Activity_Type__c = 'Promotion',
            CAJBP_Status__c = 'In Progress',
            CAJBP_Paid_for_by__c= 'Castrol',
            CAJBP_Objective__c = objectiveId,
            CurrencyIsoCode = CURRENCY_ISO_CODE,
            CAJBP_Start_Date__c = Date.today(),
            CAJBP_End_Date__c = Date.today().addDays(1),
            CAJBP_Castrol_Estimated_Cost__c = 1000,
            CAJBP_Partner_Estimated_Cost__c = 900
        );
        insert jbpActivity;
        return jbpActivity;
    }

    public static CAJBP_Risk__c createRisk(ID jbpId, String status, Decimal volume, decimal value, Date impactDate) {
        CAJBP_Risk__c record = new CAJBP_Risk__c();
        record.CAJBP_Joint_Business_Plan__c = jbpId;
        record.CAJBP_Volume__c = volume;
        record.CAJBP_Value__c = value;
        record.CAJBP_Status__c = status;
        record.CAJBP_Impact_Date__c = impactDate;
        return record;
    }

    public static CAJBP_Customer_Contact__c createCustomerContact(CAJBP_Joint_Business_Plan__c jbp) {
        Contact contact = new Contact(FirstName = 'Customer', LastName = 'Contact', accountId = jbp.CAJBP_Account__c);
        insert contact;
        CAJBP_Customer_Contact__c record = new CAJBP_Customer_Contact__c();
        record.CAJBP_Joint_Business_Plan__c = jbp.Id;
        record.CAJBP_Partnership_Mindset__c = 'M';
        record.CAJBP_Relationship__c = 'Good';
        record.CAJBP_Customer__c = contact.Id;
        insert record;
        return record;
    }

    public static List<CAJBP_Product_Mix_Target__c> createProductMixTarget(CAJBP_Joint_Business_Plan__c jbp, Integer dataSize)
    {
        List<CAJBP_Product_Mix_Target__c> productMixTarget = new List<CAJBP_Product_Mix_Target__c>();
        Id scoreCardId = [SELECT id FROM CAJBP_Scorecard__c WHERE CAJBP_Joint_Business_Plan__c =:jbp.Id LIMIT 1].Id;
        string productMixTargetRecordType = [SELECT id,name FROM recordtype WHERE sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;

        for(integer i = 1; i<=dataSize; i++)
        {
            productMixTarget.add(new CAJBP_Product_Mix_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,
            CAJBP_Product_Mix_Target_Name__c = 'EDGE' + dataSize, CAJBP_Price_Per_Litre_Rebate__c=100.00,
            CAJBP_Volume_Target__c=10000,recordtypeid = productMixTargetRecordType,
            CurrencyIsoCode='USD',CAJBP_Scorecard__c = scoreCardId));
        }
        insert productMixTarget;
        return productMixTarget;
    }

    public static void createProductMixTargetItem(CAJBP_Product_Mix_Target__c pmt)
    {
        CAJBP_Product_Mix_Target_Item__c pmtItem = new CAJBP_Product_Mix_Target_Item__c(CAJBP_Product_Brand__c='EDGE',
                                                        CAJBP_Product_Mix_Target__c = pmt.Id);
        insert pmtItem;
    }

    public static CAJBP_Ways_of_Working_Target__c createWaysOfWorkingTarget(ID jbpId) {
        CAJBP_Ways_of_Working_Target__c record = new CAJBP_Ways_of_Working_Target__c();
        record.CAJBP_Joint_Business_Plan__c = jbpId;
        record.Name = 'Ways';
        record.CAJBP_Description__c = 'Ways Description';
        record.CAJBP_Due_Date__c = Date.Today().addDays(5);
        record.CurrencyIsoCode = 'EUR';
        return record;
    }

    public static CAJBP_Distributor_Joint_Activity_Fund__c createJaf(ID jbpId) {
        CAJBP_Distributor_Joint_Activity_Fund__c record = new CAJBP_Distributor_Joint_Activity_Fund__c();
        record.CAJBP_Joint_Business_Plan__c = jbpId;
        record.CAJBP_Castrol_Contribution_Amount__c = 100;
        record.CAJBP_Partner_Contribution_Amount__c = 100;
        return record;
    }

    public static Map<string, List<CAJBP_SWOT__c>> createJbpSwot(Id jbpId) {
        Map<string, List<CAJBP_SWOT__c>> swotMap = new Map<string, List<CAJBP_SWOT__C>>();
        CAJBP_SWOT__c swot = new CAJBP_SWOT__c (
            Name='Strength Created',
            CAJBP_Joint_Business_Plan__c = jbpId,
            Type__c = 'Strength',
            CAJBP_Description__c = 'Description of Strength');
        swotMap.put(swot.Type__c, new List<CAJBP_SWOT__c>{swot});
        return swotMap;
    }

    public static Map<string, List<CAJBP_SWOT__c>> createJbpSwot(Id jbpId, String type) {
        Map<string, List<CAJBP_SWOT__c>> swotMap = new Map<string, List<CAJBP_SWOT__C>>();
        CAJBP_SWOT__c swot = new CAJBP_SWOT__c (
            Name= type + ' Created',
            CAJBP_Joint_Business_Plan__c = jbpId,
            Type__c = type,
            CAJBP_Active__c = true,
            CAJBP_Description__c = 'Description of ' + type);
        swotMap.put(swot.Type__c, new List<CAJBP_SWOT__c>{swot});
        return swotMap;
    }

    public static Map<string, List<CAJBP_SwotController.Swot>> createJbpRelatedSwot(Id jbpId, String type) {
        Map<string, List<CAJBP_SwotController.Swot>> swotMap = new Map<string, List<CAJBP_SwotController.Swot>>();
        CAJBP_SwotController.Swot swot = new CAJBP_SwotController.Swot(new CAJBP_SWOT__c (
            Name= type + ' Created',
            CAJBP_Joint_Business_Plan__c = jbpId,
            Type__c = type,
            CAJBP_Active__c = true,
            CAJBP_Description__c = 'Description of ' + type));

        swotMap.put(swot.type, new List<CAJBP_SwotController.Swot>{swot});
        return swotMap;
    }

    public static Account createCustomerMock() {
        return (Account)RecordCreator.createInstance(
            Schema.Account.SObjectType,
            new Map<String, Object>{
               'RecordTypeId' => Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
               'Name' => 'Test Customer Account',
               'Type' => 'ZMHI'
            },
            true
        );
    }

    public static CAJBP_Joint_Business_Plan__c createJointBusinessPlanMock(Account customer) {
        return (CAJBP_Joint_Business_Plan__c)RecordCreator.createInstance(
            Schema.CAJBP_Joint_Business_Plan__c.SObjectType,
            new Map<String, Object>{
               'CAJBP_Year__c' => '2080',
               'CAJBP_State__c' => 'Draft',
               'CAJBP_Account__r' => customer,
               'CAJBP_Account__c' => customer.Id
            },
            true,
            true
        );
    }

    public static CAJBP_Objective__c createObjectiveMock(CAJBP_Joint_Business_Plan__c jbp) {
        return (CAJBP_Objective__c)RecordCreator.createInstance(
            Schema.CAJBP_Objective__c.SObjectType,
            new Map<String, Object>{
               'RecordTypeId' => Schema.SObjectType.CAJBP_Objective__c.getRecordTypeInfosByName().get('Objective').getRecordTypeId(),
               'Name' => 'Test Objective',
               'CAJBP_Description__c' => 'Test Description',
               'CAJBP_Joint_Business_Plan__r' => jbp,
               'CAJBP_Joint_Business_Plan__c' => jbp.Id
            },
            true,
            true
        );
    }

    public static CAJBP_SWOT__c createSwotMock(CAJBP_Joint_Business_Plan__c jbp, String type) {
        return (CAJBP_SWOT__c)RecordCreator.createInstance(
            Schema.CAJBP_SWOT__c.SObjectType,
            new Map<String, Object>{
               'Name' => 'Test Swot',
               'CAJBP_Description__c' => 'Test Description',
               'Type__c' => type,
               'CAJBP_Active__c' => true,
               'CAJBP_Joint_Business_Plan__r' => jbp,
               'CAJBP_Joint_Business_Plan__c' => jbp.Id
            },
            true,
            true
        );
    }

    public static CAJBP_Objective_SWOT__c createObjectiveSwotMock(CAJBP_SWOT__c swot, CAJBP_Objective__c objective) {
        return (CAJBP_Objective_SWOT__c)RecordCreator.createInstance(
            Schema.CAJBP_Objective_SWOT__c.SObjectType,
            new Map<String, Object>{
               'CAJBP_SWOT__r' => swot,
               'CAJBP_SWOT__c' => swot.Id,
               'CAJBP_Objective__r' => objective,
               'CAJBP_Objective__c' => objective.Id
            },
            true,
            true
        );
    }

    public static CAJBP_Valid_Delete_State__mdt createJBPDeleteStateMock() {
        return (CAJBP_Valid_Delete_State__mdt)RecordCreator.createInstance(
            Schema.CAJBP_Valid_Delete_State__mdt.SObjectType,
            new Map<String, Object>{
               'DeveloperName' => 'Draft',
               'Label' => 'Draft'
            },
            true
        );
    }

    public static Map<String, Object> createSingleUserPermission(String username) {
        Map<String, Object> bundle = new Map<String, Object>();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        bundle.put('profile', p);

        User u = new User(
            Alias = 'standt',
            Email = 'standarduser_jbp@testorg.com.bp.customer',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = username
        );

        insert u;
        bundle.put('user', u);

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label = :STANDARD_USER_PERMISSION_SET];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        bundle.put('psa', psa);
        return bundle;
    }
}