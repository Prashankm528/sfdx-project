@isTest
private class CAIDP_LightningProfileControllerTest {
    
    @isTest 
    static void saveUserTest() {

        User newUser = REIDP_TestFactory.createUserWithRole();
        
        String newEmail = REIDP_TestFactory.generateUniqueUserEmail(CAIDP_LightningProfileControllerTest.class);

        Test.startTest();
            newUser.Email = newEmail;
            CAIDP_LightningProfileController.saveUser(newUser, 'USA');
        Test.stopTest();

        User savedUser = [
            SELECT Email, Country
            FROM User
            WHERE Id = :newUser.Id
        ];

        System.assertEquals(newEmail, savedUser.Email);
        System.assertEquals('USA', savedUser.Country);
    }
    
    @isTest 
    static void getUserTest() {
        Test.startTest();
            User currUser = CAIDP_LightningProfileController.getUser();
        Test.stopTest();

        System.assertNotEquals(currUser, null);
    }

}