/**
* @author Ksenia Potapovich
* @company Bluewolf, an IBM Company
* @date 11/2017
*
*/
@isTest
private class CAIDP_LightningSelfRegisterTest {
    
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        System.assert(CAIDP_LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(CAIDP_LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(CAIDP_LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(CAIDP_LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }
    
    @IsTest
    static void testSiteAsContainerEnabled() {
        System.assertNotEquals(null, CAIDP_LightningSelfRegisterController.siteAsContainerEnabled('http://ciddev-bpcustomer.cs83.force.com/Castrol'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.lastname_is_required, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.Site.email_is_required, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.Site.email_is_required, CAIDP_LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', 'USA', 'en_US', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.site.passwords_dont_match, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertNotEquals(null, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
    }
    
    
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials() {
        Map < String, String > paramsMap = initializeParams();
        System.assertEquals(null, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    }
    
    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount() {
        Account acc = new Account(name = 'test acc');
        insert acc;
        List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map < String, String > paramsMap = initializeParams();
        System.assertEquals(null, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
    }
    
    @IsTest
    static void testGetNullExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), CAIDP_LightningSelfRegisterController.getExtraFields(null));
    }
    
    @IsTest
    static void testGetNonEmptyExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), CAIDP_LightningSelfRegisterController.getExtraFields('field1'));
    }
    
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, CAIDP_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
    }
    
    @IsTest
    static void CAIDP_LightningSelfRegisterControllerInstantiation() {
        CAIDP_LightningSelfRegisterController controller = new CAIDP_LightningSelfRegisterController();
        System.assertNotEquals(controller, null);
    }
    
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    
    @isTest
    static void testDuplicateEmail() {
        
        User u = REIDP_TestFactory.createCommunityUser(CAIDP_LightningSelfRegisterTest.class);
        
        Test.startTest();
        String errorLabel = CAIDP_LightningSelfRegisterController.selfRegister('TestFirstName2', 'TestLastName2', u.Email, 'USA', 'en_US', null, null, null, null, null, null, null);
        Test.stopTest();
        
        System.assertEquals(Label.CastrolDuplicateEmail, errorLabel);
    }
    
    @isTest
    static void testGetCountriesPicklist() {
        Test.startTest();
        List<String> result = CAIDP_LightningSelfRegisterController.getCountriesPicklist();
        Test.stopTest();
        System.assert(result.size() > 0);
    }
    
    @isTest
    static void testSelfRegisterPhone() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.System.assertNotEquals(null, CAIDP_LightningSelfRegisterController.selfRegisterPhone(paramsMap.get('firstName'), paramsMap.get('lastName'), '11 111 1111', '111', 'USA', 'en_US', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
    }
}