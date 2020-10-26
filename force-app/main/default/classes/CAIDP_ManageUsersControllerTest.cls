@isTest
private class CAIDP_ManageUsersControllerTest {
    
    @isTest 
    static void createRowsTest() {
        Test.startTest();
            List<CAIDP_ManageUsersController.CAIDP_MemberWrapper> wrappers = CAIDP_ManageUsersController.createRows(5);
        Test.stopTest();

        System.assertEquals(5, wrappers.size());
    }

    @isTest 
    static void inviteMembersTest() {
        Test.startTest();
            String result = CAIDP_ManageUsersController.inviteMembers('[{"apps":[{"autoAssigned":true,"enabled":true,"label":"Web Builder"},{"autoAssigned":false,"enabled":true,"label":"Web Builder Dev"},{"autoAssigned":false,"enabled":true,"label":"Web Builder Test"},{"autoAssigned":true,"enabled":true,"label":"Professional League"}],"email":"test@gmail.com","language":"en_US"}]', true);
        Test.stopTest();

        System.assertEquals(null, result);
    }
    
}