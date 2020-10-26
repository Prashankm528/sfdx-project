/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 2/2019
* 
*/

@isTest
public class REIDP_UserConsentHelperTest {
    
    @testSetup static void setup() {
        List<REIDP_User_Consent__c> cList = new List<REIDP_User_Consent__c>();
        
        //Needed to reset SOQL count after user creation
        Test.startTest();
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class);
        User testUser2 = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class);
        
        testUser.REIDP_Country_of_App__c = 'au';
        testUser2.REIDP_Country_of_App__c = 'uk';
        
        update testUser;
        update testUser2;
        Test.stopTest();
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            List<REIDP_Application__c> apps = new List<REIDP_Application__c>();
            apps.add(new REIDP_Application__c(Name = 'bp me uk',
                                              Permission_Set__c = 'test',
                                              Short_Name__c = 'bpmeuk',
                                              Connected_App__c = 'testApp',
                                              Generate_Platform_Events__c = True
                                              ));
            
            apps.add(new REIDP_Application__c(Name = 'bp me au',
                                              Permission_Set__c = 'test',
                                              Short_Name__c = 'bpmeau',
                                              Connected_App__c = 'testApp',
                                              Generate_Platform_Events__c = True
                                              ));
            
            insert apps;
            
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, // UK
                                                Accepted__c = FALSE, 
                                                User__c = testUser.Id, // AU
                                                Type__c = 'Drive Carbon Neutral',
                                                Contact__c = testUser.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, // UK
                                                Accepted__c = TRUE, 
                                                User__c = testUser2.Id, // UK
                                                Type__c = 'Drive Carbon Neutral',
                                                Contact__c = testUser2.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(1).Id, // AU
                                                Accepted__c = FALSE, 
                                                User__c = testUser.Id, // AU
                                                Type__c = 'General Marketing',
                                                Channel__c = 'Email;SMS',
                                                Contact__c = testUser.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(1).Id, // AU
                                                Accepted__c = TRUE, 
                                                User__c = testUser2.Id, //UK
                                                Type__c = 'General Marketing',
                                                Channel__c = 'SMS',
                                                Contact__c = testUser2.ContactId));
            
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, //UK
                                                Accepted__c = FALSE, 
                                                User__c = testUser2.Id, //UK
                                                Type__c = 'Personal Marketing',
                                                Channel__c = 'Email;SMS',
                                                Contact__c = testUser2.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, //UK
                                                Accepted__c = TRUE, 
                                                User__c = testUser.Id, //AU
                                                Type__c = 'Personal Marketing',
                                                Channel__c = '',
                                                Contact__c = testUser.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, // UK
                                                Accepted__c = FALSE, 
                                                User__c = testUser.Id, // AU
                                                Type__c = 'Privacy Policy',
                                                Contact__c = testUser.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(0).Id, //UK
                                                Accepted__c = TRUE, 
                                                User__c = testUser2.Id, //UK
                                                Type__c = 'Privacy Policy',
                                                Contact__c = testUser2.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(1).Id, //AU
                                                Accepted__c = FALSE, 
                                                User__c = testUser2.Id, // UK
                                                Type__c = 'Terms and Conditions',
                                                Contact__c = testUser2.ContactId));
            
            cList.add(new REIDP_User_Consent__c(Application__c = apps.get(1).Id, // AU
                                                Accepted__c = TRUE, 
                                                User__c = testUser.Id, // AU
                                                Type__c = 'Terms and Conditions',
                                                Contact__c = testUser.ContactId));
            
            insert cList;
        }
        
    }
    
    
    /*
* DRIVE CARBON NEUTRAL TESTS
* EDIT ON CONSENT (TRIGGER)
* 
*/
    @isTest
    static void testEditConsentDCN_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c, User__r.REIDP_Drive_Carbon_Neutral__c
                                    FROM REIDP_User_Consent__c WHERE Type__c = 'Drive Carbon Neutral' AND Accepted__c = FALSE];
        User testUser = uc.User__r;
        
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = TRUE;
            update uc;
            Test.stopTest();
        }
        
        
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c, User__c, User__r.REIDP_Drive_Carbon_Neutral__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = updatedUc.User__r;
        
        System.assertEquals(false, updatedTestUser.REIDP_Drive_Carbon_Neutral__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditConsentDCN_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c, User__r.REIDP_Drive_Carbon_Neutral__c
                                    FROM REIDP_User_Consent__c WHERE Type__c = 'Drive Carbon Neutral' AND Accepted__c = TRUE]; 
        User testUser = uc.User__r;
        
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = FALSE;
            update uc;
            Test.stopTest();
        }
        
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c, User__c, User__r.REIDP_Drive_Carbon_Neutral__c
                                           FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = updatedUc.User__r;
        
        System.assertEquals(false, updatedTestUser.REIDP_Drive_Carbon_Neutral__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    /*
* GENERAL MARKETING TESTS
* EDIT ON CONSENT (TRIGGER)
* 
*/
    
    @isTest
    static void testEditConsentGM_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__r.REIDP_General_Marketing_Info__c 
                                    FROM REIDP_User_Consent__c WHERE Type__c = 'General Marketing' AND Accepted__c = FALSE];
        User testUser = uc.User__r;
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = TRUE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c, User__r.REIDP_General_Marketing_Info__c  FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = updatedUc.User__r;
        
        System.assertEquals(true, updatedTestUser.REIDP_General_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditConsentGM_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c, User__r.REIDP_General_Marketing_Info__c FROM REIDP_User_Consent__c WHERE Type__c = 'General Marketing' AND Accepted__c = TRUE];
        User testUser = uc.User__r;
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = FALSE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c, User__r.REIDP_General_Marketing_Info__c  FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = updatedUc.User__r;
        
        System.assertEquals(false, updatedTestUser.REIDP_General_Marketing_Info__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    /*
* PERSONAL MARKETING TESTS
* EDIT ON CONSENT (TRIGGER)
* 
*/
    
    @isTest
    static void testEditConsentPM_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Personal Marketing' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = TRUE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(true, updatedTestUser.REIDP_Personal_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditConsentPM_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Personal Marketing' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            UC.Version__c = '2.0';
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(false, updatedTestUser.REIDP_Personal_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    /*
* PRIVACY POLICY TESTS
* EDIT ON CONSENT (TRIGGER)
* 
*/
    
    @isTest
    static void testEditConsentPP_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Privacy Policy' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();	
            uc.Accepted__c = TRUE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(null, updatedTestUser.REIDP_Privacy_Accepted__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditConsentPP_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Privacy Policy' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = FALSE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(null, updatedTestUser.REIDP_Privacy_Accepted__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    /*
* TERMS & CONDITIONS TESTS
* EDIT ON CONSENT (TRIGGER)
* 
*/
    
    @isTest
    static void testEditConsentTT_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Terms and Conditions' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = TRUE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(null, updatedTestUser.REIDP_T_C_Accepted__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditConsentTT_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Terms and Conditions' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            uc.Accepted__c = FALSE;
            update uc;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(null, updatedTestUser.REIDP_T_C_Accepted__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    /****************************************************************************************************************************************************/ 
    
    /*
* DRIVE CARBON NEUTRAL TESTS
* EDIT ON USER (TRIGGER)
* 
*/
    @isTest
    static void testEditUserDCN_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Drive Carbon Neutral' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Drive_Carbon_Neutral__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Drive_Carbon_Neutral__c = TRUE;
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Drive_Carbon_Neutral__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(true, updatedTestUser.REIDP_Drive_Carbon_Neutral__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    /*
* GENERAL MARKETING TESTS
* EDIT ON USER (TRIGGER)
* 
*/
    
    @isTest
    static void testEditUserGM_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'General Marketing' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_General_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_General_Marketing_Info__c = TRUE;
            update testUser;
            Test.stopTest();
        }
        
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_General_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(true, updatedTestUser.REIDP_General_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditUserGM_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'General Marketing' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_General_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_General_Marketing_Info__c = FALSE;
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_General_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(false, updatedTestUser.REIDP_General_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    /*
* PERSONAL MARKETING TESTS
* EDIT ON USER (TRIGGER)
* 
*/
    
    @isTest
    static void testEditUserPM_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Personal Marketing' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Personal_Marketing_Info__c = TRUE;
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(true, updatedTestUser.REIDP_Personal_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditUserPM_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Personal Marketing' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Personal_Marketing_Info__c = FALSE;
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Personal_Marketing_Info__c FROM User WHERE Id =: testUser.Id];
        
        System.assertEquals(false, updatedTestUser.REIDP_Personal_Marketing_Info__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditUserPP_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Privacy Policy' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Privacy_Accepted__c = System.now();
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertNotEquals(null, updatedTestUser.REIDP_Privacy_Accepted__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditUserPP_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Privacy Policy' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Privacy_Accepted__c = System.now();
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_Privacy_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertNotEquals(null, updatedTestUser.REIDP_Privacy_Accepted__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    /*
* TERMS & CONDITIONS TESTS
* EDIT ON USER (TRIGGER)
* 
*/
    @isTest
    static void testEditUserTT_UserFail() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Terms and Conditions' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_T_C_Accepted__c = System.now();
            update testUser;
            Test.stopTest();
        }
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertNotEquals(null, updatedTestUser.REIDP_T_C_Accepted__c);
        System.assertEquals(false, updatedUc.Accepted__c);
    }
    
    @isTest
    static void testEditUserTT_UserSuccess() {
        REIDP_User_Consent__c uc = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Terms and Conditions' AND Accepted__c = TRUE];
        User testUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: uc.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_T_C_Accepted__c = System.now();
            update testUser;
            Test.stopTest();
        }
        
        REIDP_User_Consent__c updatedUc = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: uc.Id];
        User updatedTestUser = [SELECT Id, REIDP_T_C_Accepted__c FROM User WHERE Id =: testUser.Id];
        
        System.assertNotEquals(null, updatedTestUser.REIDP_T_C_Accepted__c);
        System.assertEquals(true, updatedUc.Accepted__c);
    }
    
    
    @isTest
    static void testUpdateSeveralConsents_Success() {
        REIDP_User_Consent__c ucPP = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Privacy Policy' AND Accepted__c = FALSE];
        REIDP_User_Consent__c ucDCN = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Drive Carbon Neutral' AND Accepted__c = FALSE]; 
        
        List<REIDP_User_Consent__c> consList = new List<REIDP_User_Consent__c>();
        
        User testUser = [SELECT Id, REIDP_Privacy_Accepted__c, REIDP_Drive_Carbon_Neutral__c, REIDP_Opt_Out_of_Profiling__c FROM User WHERE Id =: ucPP.User__c];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            ucPP.Accepted__c = TRUE;
            ucDCN.Accepted__c = TRUE;
            consList.add(ucDCN);
            consList.add(ucPP);
            
            update consList;
            Test.stopTest();
        }
        
        
        REIDP_User_Consent__c updatedUcPP = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: ucPP.Id];
        REIDP_User_Consent__c updatedUcDCN = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Id =: ucDCN.Id];
        User updatedTestUser = [SELECT Id, REIDP_Privacy_Accepted__c, REIDP_Drive_Carbon_Neutral__c, REIDP_Opt_Out_of_Profiling__c FROM User WHERE Id =: testUser.Id];
        
        // PRIVACY POLICY
        System.assertEquals(null, updatedTestUser.REIDP_Privacy_Accepted__c);
        System.assertEquals(true, updatedUcPP.Accepted__c);
        
        // DRIVE CARBON NEUTRAL
        System.assertEquals(false, updatedTestUser.REIDP_Drive_Carbon_Neutral__c);
        System.assertEquals(true, updatedUcDCN.Accepted__c);
    }
    
    /****************************************************************************************************************************************************/ 
    
    /*
* ALL FIELD TESTS ON CREATE
* EDIT ON USER (TRIGGER)
* 
*/
    @isTest
    static void testEditUser_Success() {
        REIDP_User_Consent__c uc1 = [SELECT Id, Accepted__c, User__c FROM REIDP_User_Consent__c WHERE Type__c = 'Drive Carbon Neutral' AND Accepted__c = FALSE];
        User testUser = [SELECT Id, REIDP_Drive_Carbon_Neutral__c FROM User WHERE Id =: uc1.User__c AND REIDP_Country_of_App__c = 'au' LIMIT 1];
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            testUser.REIDP_Privacy_Accepted__c = System.now();
            testUser.REIDP_T_C_Accepted__c = System.now();
            testUser.REIDP_Drive_Carbon_Neutral__c = true;
            testUser.REIDP_General_Marketing_Info__c = true;
            testUser.REIDP_Personal_Marketing_Info__c = true;
            testUser.REIDP_Opt_Out_of_Profiling__c = true;
            update testUser;
            Test.stopTest();
        }
        
        List<REIDP_User_Consent__c> newConsents = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE User__c =: testUser.Id];
        
        System.assertEquals(5, newConsents.size());
    }
    
    
    @isTest
    static void testCreateWithTCandPPUser_Success() {
        
        Test.startTest();
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class, 
                                                              new Map<String, Object>{'REIDP_Country_of_App__c' => 'UK',
                                                                  'REIDP_Privacy_Accepted__c' => System.now(),
                                                                  'REIDP_T_C_Accepted__c' => System.now()});
        Test.stopTest();
        
        List<REIDP_User_Consent__c> newConsents = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE User__c =: testUser.Id];
        
        System.assertEquals(2, newConsents.size());
    }
    
    
    @isTest
    static void testGetConsentPlatformUpdateEvent() {
        REIDP_Application__c app = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeuk' LIMIT 1];
        REIDP_User_Consent__c uc = [SELECT Id, User__c, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id LIMIT 1];
        User testUser = [SELECT Id, ContactId FROM User WHERE Id = :uc.User__c];
        List<REIDP_User_Consent__c> ucList = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser.Id LIMIT 3];
        
        for (REIDP_User_Consent__c consent : ucList) {
            consent.Accepted__c = !consent.Accepted__c;
        }
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            update ucList;
            Test.stopTest();
        }
        
        Set<REIDP_Platform_Event__e> eventResults = new Set<REIDP_Platform_Event__e>();
        List<REIDP_User_Consent__c> ucUpdatedList = [SELECT Id, Accepted__c, Type__c, Contact__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser.Id LIMIT 3];
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(e.JSON__c);
            Map<String, Object> userconsRecords = (Map<String, Object>)m.get('User_Consents__r');
            List<Object> usercons = (List<Object>)m.get('consents');
            
            if(e.Event_Type__c == 'Consent' && e.Audience__c.equals('bpmeuk') && e.User__c.equals(testUser.Id) ) {
                for (REIDP_User_Consent__c uccons : ucUpdatedList) {
                    for (Object o : usercons) {
                        Map<String,Object> data = (Map<String,Object>)o;
                        if (data.get('Id') == uccons.Id && data.get('Accepted__c') == uccons.Accepted__c 
                            && data.get('Type__c').equals(uccons.Type__c)) {
                                consentList.add(uccons);
                            }
                    }
                }
                eventResults.add(e);
            }
        }
        
        System.assert(eventResults.size() == 1); 
        System.assert(consentList.size() == 3);
    }
    
    @isTest
    static void testGetConsentPlatformUpdateEventChannelUpdate() {
        REIDP_Application__c app = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeuk' LIMIT 1];
        REIDP_User_Consent__c uc = [SELECT Id, User__c, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id LIMIT 1];
        User testUser = [SELECT Id, ContactId FROM User WHERE Id = :uc.User__c];
        List<REIDP_User_Consent__c> ucList = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser.Id LIMIT 3];
        
        for (REIDP_User_Consent__c consent : ucList) {
            consent.Channel__c = 'SMS';
        }
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            update ucList;
            Test.stopTest();
        }
        
        Set<REIDP_Platform_Event__e> eventResults = new Set<REIDP_Platform_Event__e>();
        List<REIDP_User_Consent__c> ucUpdatedList = [SELECT Id, Accepted__c, Type__c, Contact__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser.Id LIMIT 3];
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(e.JSON__c);
            Map<String, Object> userconsRecords = (Map<String, Object>)m.get('User_Consents__r');
            List<Object> usercons = (List<Object>)m.get('consents');
            
            if(e.Event_Type__c == 'Consent' && e.Audience__c.equals('bpmeuk') && e.User__c.equals(testUser.Id) ) {
                for (REIDP_User_Consent__c uccons : ucUpdatedList) {
                    for (Object o : usercons) {
                        Map<String,Object> data = (Map<String,Object>)o;
                        if (data.get('Id') == uccons.Id && data.get('Accepted__c') == uccons.Accepted__c 
                            && data.get('Type__c').equals(uccons.Type__c)) {
                                consentList.add(uccons);
                            }
                    }
                }
                eventResults.add(e);
            }
        }
        
        System.assert(eventResults.size() == 1); 
        System.assert(consentList.size() == 3);
    }
    
    @isTest
    static void testGetConsentPlatformEventInsertSuccess() {
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class);
        REIDP_Application__c app = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeuk' LIMIT 1];
        List<REIDP_User_Consent__c> ucList = new List<REIDP_User_Consent__c>();
        
        ucList.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                             Accepted__c = true, 
                                             User__c = testUser.Id,
                                             Type__c = 'Personal Marketing',
                                             Contact__c = testUser.ContactId));
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            insert ucList;
            Test.stopTest();
        }
        
        Set<REIDP_Platform_Event__e> eventResults = new Set<REIDP_Platform_Event__e>();
        List<REIDP_User_Consent__c> ucUpdatedList = [SELECT Id, Accepted__c, Type__c, Contact__c FROM REIDP_User_Consent__c WHERE Id in : ucList];
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(e.JSON__c);
            Map<String, Object> userconsRecords = (Map<String, Object>)m.get('User_Consents__r');
            List<Object> usercons = (List<Object>)m.get('consents');
            
            if(e.Event_Type__c == 'Consent' && e.Audience__c.equals('bpmeuk') && e.User__c.equals(testUser.Id) ) {
                for (REIDP_User_Consent__c uccons : ucUpdatedList) {
                    for (Object o : usercons) {
                        Map<String,Object> data = (Map<String,Object>)o;
                        if (data.get('Id') == uccons.Id && data.get('Accepted__c') == uccons.Accepted__c 
                            && data.get('Type__c').equals(uccons.Type__c)) {
                                consentList.add(uccons);
                                
                            }
                    }
                }
                eventResults.add(e);
            }
        }
        
        System.assertEquals(1, eventResults.size()); 
        System.assertEquals(1, consentList.size()); 
    }
    
    @isTest
    static void testGetConsentPlatformEventMultipleEventsSuccess() {
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class);
        
        REIDP_Application__c app = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeuk' LIMIT 1];
        REIDP_Application__c app2 = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeau' LIMIT 1];
        
        REIDP_User_Consent__c uc = [SELECT Id, User__c, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app2.Id LIMIT 1];
        User testUser2 = [SELECT Id, ContactId FROM User WHERE Id = :uc.User__c];
        
        List<REIDP_User_Consent__c> ucList2 = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser2.Id LIMIT 4];
        List<REIDP_User_Consent__c> ucList = new List<REIDP_User_Consent__c>();
        
        ucList.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                             Accepted__c = FALSE, 
                                             User__c = testUser.Id,
                                             Type__c = 'General Marketing',
                                             Contact__c = testUser.ContactId));
        
        ucList.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                             Accepted__c = true, 
                                             User__c = testUser.Id,
                                             Type__c = 'Personal Marketing',
                                             Contact__c = testUser.ContactId));
        
        for (REIDP_User_Consent__c consent : ucList2) {
            consent.Accepted__c = !consent.Accepted__c;
        }
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            update ucList2;
            insert ucList;
            Test.stopTest();
        }
        
        Set<REIDP_User_Consent__c> consents = new Set<REIDP_User_Consent__c>();
        consents.addAll(ucList);
        consents.addAll(ucList2);
        
        Set<REIDP_Platform_Event__e> eventResults = new Set<REIDP_Platform_Event__e>();
        List<REIDP_User_Consent__c> ucUpdatedList = [SELECT Id, Accepted__c, Type__c, Contact__c FROM REIDP_User_Consent__c WHERE Id in : consents];
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        system.debug('REIDP_PlatformEventTriggerHandler.gotEvents ' + REIDP_PlatformEventTriggerHandler.gotEvents.size());
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(e.JSON__c);
            Map<String, Object> userconsRecords = (Map<String, Object>)m.get('User_Consents__r');
            List<Object> usercons = (List<Object>)m.get('consents');
            
            if(e.Event_Type__c == 'Consent' && (e.Audience__c.equals('bpmeuk') || e.Audience__c.equals('bpmeau')) && (e.User__c.equals(testUser.Id) || e.User__c.equals(testUser2.Id)) ) {
                system.debug('e ' + e);
                for (REIDP_User_Consent__c uccons : ucUpdatedList) {
                    for (Object o : usercons) {
                        Map<String,Object> data = (Map<String,Object>)o;
                        if (data.get('Id') == uccons.Id && data.get('Accepted__c') == uccons.Accepted__c 
                            && data.get('Type__c').equals(uccons.Type__c)) {
                                consentList.add(uccons);
                                
                            }
                    }
                }
                eventResults.add(e);
            }
        }
        
        System.assertEquals(2, eventResults.size()); 
        System.assertEquals(5, consentList.size()); 
    }

    @isTest
    static void testGetConsentPlatformEventMultipleEventsDisabled() {
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentHelperTest.class);
        
        REIDP_Application__c app = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeuk' LIMIT 1];
        REIDP_Application__c app2 = [SELECT Id FROM REIDP_Application__c WHERE Short_Name__c = :'bpmeau' LIMIT 1];
        
        app.Generate_Platform_Events__c = False;
        update app;

        REIDP_User_Consent__c uc = [SELECT Id, User__c, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app2.Id LIMIT 1];
        User testUser2 = [SELECT Id, ContactId FROM User WHERE Id = :uc.User__c];
        
        List<REIDP_User_Consent__c> ucList2 = [SELECT Id, Accepted__c FROM REIDP_User_Consent__c WHERE Application__c = :app.Id AND User__c = :testUser2.Id LIMIT 4];
        List<REIDP_User_Consent__c> ucList = new List<REIDP_User_Consent__c>();
        
        ucList.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                             Accepted__c = FALSE, 
                                             User__c = testUser.Id,
                                             Type__c = 'General Marketing',
                                             Contact__c = testUser.ContactId));
        
        ucList.add(new REIDP_User_Consent__c(Application__c = app.Id,
                                             Accepted__c = true, 
                                             User__c = testUser.Id,
                                             Type__c = 'Personal Marketing',
                                             Contact__c = testUser.ContactId));
        
        for (REIDP_User_Consent__c consent : ucList2) {
            consent.Accepted__c = !consent.Accepted__c;
        }
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            Test.startTest();
            update ucList2;
            insert ucList;
            Test.stopTest();
        }
        
        Set<REIDP_User_Consent__c> consents = new Set<REIDP_User_Consent__c>();
        consents.addAll(ucList);
        consents.addAll(ucList2);
        
        Set<REIDP_Platform_Event__e> eventResults = new Set<REIDP_Platform_Event__e>();
        List<REIDP_User_Consent__c> ucUpdatedList = [SELECT Id, Accepted__c, Type__c, Contact__c FROM REIDP_User_Consent__c WHERE Id in : consents];
        List<REIDP_User_Consent__c> consentList = new List<REIDP_User_Consent__c>();
        system.debug('REIDP_PlatformEventTriggerHandler.gotEvents ' + REIDP_PlatformEventTriggerHandler.gotEvents.size());
        for(REIDP_Platform_Event__e e: REIDP_PlatformEventTriggerHandler.gotEvents) {
            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(e.JSON__c);
            Map<String, Object> userconsRecords = (Map<String, Object>)m.get('User_Consents__r');
            List<Object> usercons = (List<Object>)m.get('consents');
            
            if(e.Event_Type__c == 'Consent' && (e.Audience__c.equals('bpmeuk') || e.Audience__c.equals('bpmeau')) && (e.User__c.equals(testUser.Id) || e.User__c.equals(testUser2.Id)) ) {
                system.debug('e ' + e);
                for (REIDP_User_Consent__c uccons : ucUpdatedList) {
                    for (Object o : usercons) {
                        Map<String,Object> data = (Map<String,Object>)o;
                        if (data.get('Id') == uccons.Id && data.get('Accepted__c') == uccons.Accepted__c 
                            && data.get('Type__c').equals(uccons.Type__c)) {
                                consentList.add(uccons);
                                
                            }
                    }
                }
                eventResults.add(e);
            }
        }
        // both should be zero since the app is disabled
        System.assertEquals(0, eventResults.size()); 
        System.assertEquals(0, consentList.size()); 
    }
    
}