/*****************************************************************************************
*       Date:        10FEB2020
*       Author:      Arron Kukadia
*       Description: test class for DUP_DownloadButtonController
*****************************************************************************************/
@isTest
public class DUP_DownloadButtonCtrlTests {
    /**
    * @description 	creates data which is used it the other tests
    * @param
    * @return
    */
    @testSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> newUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert newUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DUP_Super_User_Access'];
        Id testUserId = newUser[0].Id;
        DUP_DataFactory.assignPermissionSet(testUserId, ps.Id);
    }
    
    /**
    * @description 	checkPermission Test - checks the user has the custom permission
    * @param
    * @return
    */
    @isTest static void checkPermissionTest(){
        Test.startTest();
        List<User> u2 = [select id from user where email = 'positive@controllertest.com' limit 1];
        if(!u2.isEmpty()){
            System.runAs(u2[0]) {
                Boolean hasPermission = DUP_DownloadButtonController.checkPermission('DUP_SuperUser');
                System.assertEquals(true, hasPermission);
            }
        }
        Test.stopTest();
    }
    
}