/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 1/2019
 *
 * Test class for REIDP_UserConsentPlugin
 * 
 */
@isTest
public class REIDP_UserConsentPluginTest {

    @isTest
    public static void testUserConsentCustomAttributes() {
        
        User usr = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentPluginTest.class);
        
        User usrrole = REIDP_TestFactory.createUserWithRole();
        
        System.runAs(usrrole) {
            
            REIDP_Application__c apptc = new REIDP_Application__c(Name = 'TestApp', 
                                                                  Short_Name__c = 'testApp',
                                                                  Connected_App__c = 'TestApp',
                                                                  Is_Active__c = TRUE, 
                                                                  Add_to_App_Launcher__c = 'If user accepted T&C');
            insert apptc;
            
            List<REIDP_User_Consent__c> consents = new List<REIDP_User_Consent__c>();
            
            consents.add(new REIDP_User_Consent__c(Application__c = apptc.Id,
                                                   Accepted__c = TRUE, 
                                                   User__c = usr.Id, 
                                                   Type__c = 'Terms and Conditions',
                                                   Contact__c = usr.ContactId));
            
            consents.add(new REIDP_User_Consent__c(Application__c = apptc.Id,
                                                   Accepted__c = TRUE, 
                                                   User__c = usr.Id, 
                                                   Type__c = 'Privacy Policy',
                                                   Contact__c = usr.ContactId));
            
            consents.add(new REIDP_User_Consent__c(Application__c = apptc.Id,
                                                   Accepted__c = TRUE, 
                                                   User__c = usr.Id, 
                                                   Type__c = 'General Marketing',
                                                   Contact__c = usr.ContactId));
            
            consents.add(new REIDP_User_Consent__c(Application__c = apptc.Id,
                                                   Accepted__c = TRUE, 
                                                   User__c = usr.Id, 
                                                   Type__c = 'Profiling',
                                                   Contact__c = usr.ContactId));
            
            
            consents.add(new REIDP_User_Consent__c(Application__c = apptc.Id,
                                                   Accepted__c = TRUE, 
                                                   User__c = usr.Id, 
                                                   Type__c = '3rd Party Sharing',
                                                   Contact__c = usr.ContactId));
            
            insert consents;
        }
        
        Test.startTest();
        System.runAs(usr) {
            REIDP_UserConsentPlugin ucon = new REIDP_UserConsentPlugin();
            Map<String, String> caMap = ucon.customAttributes(UserInfo.getUserId(), null, new Map<String, String>(), null);
            System.assertEquals('true', caMap.get('tc'));
            System.assertEquals('true', caMap.get('pp'));
            System.assertEquals('true', caMap.get('general-marketing'));
            System.assertEquals('true', caMap.get('profiling'));
            System.assertEquals('true', caMap.get('3rd-party-sharing'));
        }
        Test.stopTest();
    }
}