/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 02/2019
*
**/

@isTest
public class REIDP_AppLauncherControllerTest {
    
    @isTest
    public static void testGetAppList() {
        User usr = REIDP_TestFactory.createCommunityUser(REIDP_AppLauncherControllerTest.class);
        PermissionSet ps;
        
        System.runAs(REIDP_TestFactory.createUserWithRole()) {
            ps = new PermissionSet(Name = 'Test_PermissionSet_' + System.now().getTime(),
                                   Label = 'Test PermissionSet');
            insert ps;
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id );
        }
        
        
        REIDP_Application__c apptc = new REIDP_Application__c(Name = 'testappTC', 
                                                              Short_Name__c = 'tc',
                                                              Community__c = 'BP',
                                                              Is_Active__c = TRUE, 
                                                              Add_to_App_Launcher__c = 'If user accepted T&C');
        insert apptc;
        
        REIDP_Application__c apptcps = new REIDP_Application__c(Name = 'testappTCPS', 
                                                                Short_Name__c = 'tcps',
                                                                Community__c = 'BP',
                                                                Is_Active__c = TRUE, 
                                                                Add_to_App_Launcher__c = 'If user accepted T&C',
                                                                Permission_Set__c = ps.Id);
        insert apptcps;
        
        REIDP_Application__c appps = new REIDP_Application__c(Name = 'testappPS', 
                                                              Short_Name__c = 'ps',
                                                              Community__c = 'BP',
                                                              Is_Active__c = TRUE, 
                                                              Add_to_App_Launcher__c = 'If user has permission',
                                                              Permission_Set__c = ps.Id);
        insert appps;
        
        REIDP_User_Consent__c con = new REIDP_User_Consent__c(Application__c = apptc.Id, 
                                                              Accepted__c = TRUE, 
                                                              User__c = usr.Id, 
                                                              Type__c = 'Terms and Conditions',
                                                              Contact__c = usr.ContactId);
        
        insert con;
        
        REIDP_User_Consent__c conTCPS = new REIDP_User_Consent__c(Application__c = apptcps.Id, 
                                                                  Accepted__c = TRUE, 
                                                                  User__c = usr.Id, 
                                                                  Type__c = 'Terms and Conditions',
                                                                  Contact__c = usr.ContactId);
        
        insert conTCPS;
        
        
        List<REIDP_Application__c> appList = new List<REIDP_Application__c>();
        
        Test.startTest();
        System.runAs(usr) {
            appList = REIDP_AppLauncherController.getAppList();
        }
        Test.stopTest();
        
        System.assertEquals(2, appList.size());
    }
}