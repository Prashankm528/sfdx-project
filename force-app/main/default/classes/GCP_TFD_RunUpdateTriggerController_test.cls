/**
* @author                         : Sid
* @date           				  :	11/11/2019
* @description    				  :	Test class for GCP_TFD_UPDATE_DATA_LINKAGE Component
* Covered Scenarios (Positive)    : Calling different methods of controller class and verifying the output.
* Covered Scenarios (Negative)    : Trying to cover catch block and handling error.
*/
@istest
public with sharing class GCP_TFD_RunUpdateTriggerController_test
{
	//testing data setup for all methods in this class
    @testSetup
    static void DataForThisTestClass()
    {
        //Create User with profile as System Admin...
        Profile prof = [select id from profile where Name = 'System Administrator' LIMIT 1];
        User Contextuser = new User(alias = 'TestUser', email= 'test@test.com',
                            emailencodingkey= 'UTF-8', lastname = 'Test User',
                            timezonesidkey='America/Los_Angeles',
                            languagelocalekey='en_US',
                            localesidkey='en_US', profileid = prof.Id,
                            UserRoleId= NULL,
                            username= 'TestUser' + System.currentTimeMillis() + '@testorg.com');
        insert Contextuser;
    }
    @istest
    static void method1()
    {
        User Contextuser = [select Name from User where lastname = 'Test User'];
        system.runAs(Contextuser)
        {
            GCP_TFD_OpenCredit__c OC = GCP_TFD_TestDataFactory.createOC('12','123','1','UTest','GCRUDE');
            system.assertEquals(FALSE,[select GCP_TFD_Run_Update_Trigger__c from
                                      GCP_TFD_OpenCredit__c where id = :OC.id].GCP_TFD_Run_Update_Trigger__c);
            system.test.startTest();
            GCP_TFD_RunUpdateTriggerController.updaterunupdatetrigger(oc.id);
            system.test.stopTest();
            system.assertEquals(FALSE,[select GCP_TFD_Run_Update_Trigger__c from
                                      GCP_TFD_OpenCredit__c where id = :OC.id].GCP_TFD_Run_Update_Trigger__c);
        }
    }
    @istest
    static void method2()
    {
        User Contextuser = [select Name from User where lastname = 'Test User'];
        system.runAs(Contextuser)
        {
            GCP_TFD_Letter_of_Credit__c LC = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
            system.assertEquals(FALSE,[select GCP_TFD_Run_Update_Trigger__c from
                                      GCP_TFD_Letter_of_Credit__c where id = :LC.id].GCP_TFD_Run_Update_Trigger__c);
            system.test.startTest();
            GCP_TFD_RunUpdateTriggerController.updaterunupdatetriggerlc(lc.id);
            system.test.stopTest();
            system.assertNotEquals(0,[select count() from GCP_TFD_Letter_of_Credit__c where id = :LC.id]);
        }
    }
}