/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
**/
@isTest
public class REIDP_PAIntegrationTest {
    public static String accountId;
    public static String wrongAccountId = 'wrong-account-id'; 
    static String customerUri = 'test_customerUri';
    static String issuingPartnerUri = 'test_issuingPartnerUri';
    static String partnerUri = 'test_partnerUri';
    
    @testSetup static void setup() {
        REIDP_PATestFactory.newTestUser();
    }
    
    @isTest static void consumerLookUpInfoTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            System.assertNotEquals(null, REIDP_PAConsumerDetailsController.getConsumerDetails(getAccountId(u)));
        }
        Test.stopTest();
    }
    
    
    
    @isTest static void consumerLookUpInfoBadArgTest() {
        //User u = REIDP_PATestFactory.newTestUser();
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
                REIDP_PAConsumerDetailsController.getConsumerDetails('bad-suser');
                System.assert(false);
            } catch (Exception e) {
                System.assert(true);       
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void activateWalletTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            REIDP_PAConsumerDetailsController.activateUserWallet(getAccountId(u));
            System.assert(true);
        }
        Test.stopTest();
    } 
    
    @isTest static void activateWalletBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
                REIDP_PAConsumerDetailsController.activateUserWallet('bad-account-id');
                System.assert(false);
            } catch (Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void deactivateWalletTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            REIDP_PAConsumerDetailsController.deactivateUserWallet(getAccountId(u));
            System.assert(true);
        }
        Test.stopTest();
    } 
    
    @isTest static void deactivateWalletBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
                REIDP_PAConsumerDetailsController.deactivateUserWallet('bad-account-id');
                System.assert(false);
            } catch (Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void getConsumerCardsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            REIDP_PAConsumerDetailsController.getConsumerCards(getAccountId(u));
            System.assert(true);
        }
        Test.stopTest();
    } 
    
    
    @isTest static void deleteConsumerCardTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            REIDP_PAConsumerDetailsController.deleteConsumerCard(getAccountId(u), 'some-card-uri');
            System.assert(true);
        }
        Test.stopTest();
    } 
    
    @isTest static void deleteConsumerCardBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.deleteConsumerCard(getAccountId(u), null);
            System.assert(false);
            } catch (Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void deleteUserWalletTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            REIDP_PAConsumerDetailsController.deleteUserWallet(getAccountId(u));
            System.assert(true);
        }
        Test.stopTest();
    } 
    
     @isTest static void deleteUserWalletBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.deleteUserWallet('bad-accound-id');
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    
    @isTest static void getAvailableSecurityQuestionsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
             System.assertNotEquals(null, 
                                    REIDP_PAConsumerDetailsController.getAvailableSecurityQuestions(getAccountId(u)));
        }
        Test.stopTest();
    } 
    
     @isTest static void getAvailableSecurityQuestionsBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.getAvailableSecurityQuestions(null);
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void getUserSecurityQuestionsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
             System.assertNotEquals(null, 
                                    REIDP_PAConsumerDetailsController.getUserSecurityQuestions(getAccountId(u)));
        }
        Test.stopTest();
    } 
    
     @isTest static void getUserSecurityQuestionsBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.getUserSecurityQuestions(null);
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void getConsumerTransactionsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
             System.assertNotEquals(null, 
                                    REIDP_PAConsumerDetailsController.getConsumerTransactions(getAccountId(u), null, null, null, null));
        }
        Test.stopTest();
    } 
    
     @isTest static void getConsumerTransactionsBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.getConsumerTransactions(null, null, null, null, null);
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    
    @isTest static void submitNewSecurityQuestionsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            String questions = '[{"question" : "test-question", "answer" : "test-answer"}]';
            System.assertEquals(true, REIDP_PAConsumerDetailsController.submitNewSecurityQuestions(getAccountId(u), questions));
        }
        Test.stopTest();
    } 
    
     @isTest static void submitNewSecurityQuestionsBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.submitNewSecurityQuestions('bad-accound-id', null);
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    @isTest static void authenticateSecurityQuestionsTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            String questions = '[{"question" : "test-question", "answer" : "test-answer"}]';

            REIDP_PAConsumerDetailsController.authenticateSecurityQuestions(getAccountId(u), questions);
            System.assert(true);
        }
        Test.stopTest();
    } 
    
     @isTest static void authenticateSecurityQuestionsBadArgTest() {
        User u = getUser();
        HttpCalloutMock mock = new REIDP_PAIntegrationTestMock();
        REIDP_PAIntegrationTestMock mock2 = (REIDP_PAIntegrationTestMock) mock;
        mock2.setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(u) {
            try {
            REIDP_PAConsumerDetailsController.authenticateSecurityQuestions('bad-accound-id', null);
            System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.stopTest();
    } 
    
    
    private static User getUser() {
        List<User> uList = [SELECT ContactId FROM User WHERE Email = 'integrationtest@test.com'];
        User u = uList.get(0);
        return u;
    }
    private static String getAccountId(User u) {
        Contact c = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId];
        return '' + c.AccountId;
    }
}