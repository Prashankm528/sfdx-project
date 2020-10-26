@isTest
public class REIDP_PhoneVerificationControllerTest {
	
    @isTest
    static void testREIDP_PhoneVerificationControllerPhoneChangeNoPhone() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        pvController.countryCode = '123';
        PageReference pref = pvController.openCodePage();
        System.assertEquals(null, pref);
		System.assertNotEquals(ApexPages.getMessages(), null);
        System.assertEquals(Label.BP_Error + ': ' + Label.BP_Please_enter_valid_phone_number,
                            ApexPages.getMessages().get(0).getDetail());
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_PhoneVerificationControllerPhoneChangeNoCoutryCode() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        PageReference pref = pvController.openCodePage();
        System.assertEquals(null, pref);
		System.assertNotEquals(ApexPages.getMessages(), null);
        System.assertEquals(Label.BP_Error + ': ' + Label.BP_Please_Select_Country,
                            ApexPages.getMessages().get(0).getDetail());
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_PhoneVerificationControllerPhoneChange() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        pvController.phoneNumber = '1234567890';
        pvController.countryCode = '123';
        PageReference pref = pvController.openCodePage();
        System.assertEquals(Page.REIDP_PhoneVerificationPageThree.getUrl(), pref.getUrl());
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_PhoneVerificationControllerVerifiedPhoneChangeNoCode() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('requireVerification', 'true');
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        pvController.phoneNumber = '1234567890';
        pvController.countryCode = '123';
        PageReference pref = pvController.openCodePage();
        System.assertEquals(null, pref);
        pref = pvController.openConfirmedPage();
        System.assertEquals(null, pref);
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_PhoneVerificationControllerVerifiedPhoneChange() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('requireVerification', 'true');
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        pvController.phoneNumber = '1234567890';
        pvController.countryCode = '123';
        PageReference pref = pvController.openCodePage();
        System.assertEquals(null, pref);
        pvController.code = '1234';
        pref = pvController.openConfirmedPage();
        System.assertEquals(null, pref);
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_PhoneVerificationControllerCancel() {
        Test.startTest();
        PageReference pageRef = Page.REIDP_PhoneVerificationPageOne;
        Test.setCurrentPage(pageRef);
        REIDP_PhoneVerificationController pvController = new REIDP_PhoneVerificationController();
        PageReference pref = pvController.cancel();
        System.assertEquals('/', pref.getUrl());
        Test.stopTest();
    }

}