/***********************************************************************************************
 * @author           Xc
 * @date             2020/04/01
 * @group            CHCRM
 * @description      Test class for CHCRM_LookupController

 * history
 * 2020/04/01  Xc  Created 
 ************************************************************************************************/
@isTest
private with sharing class CHCRM_LookupControllerTest {
    @testSetup
    static void testSetup(){
        Account workshop = CHCRM_TestSetup.createWorkshopAccount('Test Workshop');
        insert workshop;
    }

    static testMethod void testInsertAndDeleteHandler() {
        Account workshop = [SELECT Name FROM Account LIMIT 1];
        List<Account> result = (List<Account>) CHCRM_LookupController.query(workshop.Name.left(1),'Account');
        System.assertEquals('Test Workshop', result[0].Name);
    }
}