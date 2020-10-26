@isTest
private class CAPL_ChangePasswordControllerTest {
	
	@isTest 
	static void fetchUserIdTest() {
		Test.startTest();
		   String userId = CAPL_ChangePasswordController.fetchUserId();
		Test.stopTest();

		System.assertNotEquals(userId, null);
	}
	
	@isTest static void changePasswordTest() {
		Test.startTest();
		   String pageUrl = CAPL_ChangePasswordController.changePassword('qwerty123', 'qwerty1', 'qwerty1');
		Test.stopTest();

		System.assertEquals(pageUrl, null);
	}
	
}