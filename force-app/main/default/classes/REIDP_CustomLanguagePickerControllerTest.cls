/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 10/2018
*
**/

@isTest
public class REIDP_CustomLanguagePickerControllerTest {
    
    @isTest
    public static void testGetCommunityLanguages() {
        List<REIDP_CustomLanguagePickerController.SelectOption> listLangs = new List<REIDP_CustomLanguagePickerController.SelectOption>();
        
        Test.startTest();
        System.runAs(REIDP_TestFactory.createCommunityUser(REIDP_CustomLanguagePickerControllerTest.class)) {
            listLangs = REIDP_CustomLanguagePickerController.getCommunityLanguages();
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testCheckLanguageUrlFail() {
        String anyURL = 'testUrl';
        
        Test.startTest();
        String result = REIDP_CustomLanguagePickerController.checkLanguageUrl(anyURL);
        Test.stopTest();
        System.assertEquals(null, result);
    }
    
    @isTest
    public static void testChangeLanguageUrlLogin() {
        String language = 'ru';
        String startUrl = '123';
        String urlPath = 'someUrl';
        
        Test.startTest();
        REIDP_CustomLanguagePickerController.changeLanguageUrlLogin(language, startUrl, urlPath);
        Test.stopTest();
    } 
    
    @isTest
    public static void testChangeLanguageUrlSelfRegister() {
        String language = 'ru';
        String startUrl = '123';
        String urlPath = 'someUrl';
        
        Test.startTest();
        REIDP_CustomLanguagePickerController.changeLanguageUrlSelfRegister(language, startUrl, urlPath);
        Test.stopTest();
    }
    
    @isTest
    public static void testChangeLanguageUrlForgotPassword() {
        String language = 'ru';
        String startUrl = '123';
        String urlPath = 'someUrl';
        
        Test.startTest();
        REIDP_CustomLanguagePickerController.changeLanguageUrlForgotPassword(language, startUrl, urlPath);
        Test.stopTest();
    }
}