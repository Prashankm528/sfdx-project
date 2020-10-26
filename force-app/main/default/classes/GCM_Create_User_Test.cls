/****************************************************************************************************
 * Date          : 14-AUG-2020
 * Author        : Sunny Yap
 * Description   : Test class for GCM_Create_User
 * Modifications : 12-MAR-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Create_User_Test
{
/****************************************************************************************************
 * Test Create User
 ****************************************************************************************************/
    @isTest static void testCreateUser() {
        Test.startTest();
        String json = '';
        json += '[';
        json += '{';
        json += '"Alias" : "gcmtest",';
        json += '"Username" : "gcmtestuserunique@bp.com",';
        json += '"Email" : "gcmtestuserunique@bp.com",';
        json += '"SenderEmail" : "",';
        json += '"FirstName" : "Tester",';
        json += '"LastName" : "GCM",';
        json += '"TimeZoneSidKey" : "GMT",';
        json += '"NTID__c" : "",';
        json += '"Sales_Organisation__c" : "UK01",';
        json += '"Business_Unit__c" : "Fuels - Cards",';
        json += '"GCM_User_Team__c" : "",';
        json += '"GCM_Business_Hours__c" : "",';
        json += '"Profile" : "GCM_Cards_CSR_GSYS",';
        json += '"Role" : "GCM_Europe_Centre_Operations",';
        json += '"CallCenter" : "SoftphoneCTI",';
        json += '"Group" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Fuels_Cards_UK01"';
        json += '}';
        json += '],';
        json += '"Queue" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Fuels_Cards_UK01"';
        json += '}';
        json += '],';
        json += '"PermissionSet" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Application_Administrator"';
        json += '}';        
        json += '],';
        json += '"CollaborationGroup" : [';
        json += '{';
        json += '"Name" : "GBS TEST CHATTER GROUP"';
        json += '}';
        json += ']';
        json += '}';
        json += ']';
        
        GCM_Create_User.createUser(json);       
        Test.stopTest();
    }  

/****************************************************************************************************
 * Test Update User
 ****************************************************************************************************/
    @isTest static void testUpdateUser() {
        Test.startTest();
        List<User> users = [select Id, Username, Email, Profile.Name, UserRole.DeveloperName from User where Id = :UserInfo.getUserId()];
        if (users.size() != 1) return;
        String json = '';
        json += '[';
        json += '{';
        json += '"Alias" : "gcmtest",';
        json += '"Username" : "' + users[0].Username + '",';
        json += '"Email" : "' + users[0].Email + '",';
        json += '"SenderEmail" : "",';
        json += '"FirstName" : "Tester",';
        json += '"LastName" : "GCM",';
        json += '"TimeZoneSidKey" : "GMT",';
        json += '"NTID__c" : "",';
        json += '"Sales_Organisation__c" : "UK01",';
        json += '"Business_Unit__c" : "Fuels - Cards",';
        json += '"GCM_User_Team__c" : "",';
        json += '"GCM_Business_Hours__c" : "",';
        json += '"Profile" : "' + users[0].Profile.Name + '",';
        json += '"Role" : "' + users[0].UserRole.DeveloperName + '",';
        json += '"CallCenter" : "SoftphoneCTI",';
        json += '"Group" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Fuels_Cards_UK01"';
        json += '}';
        json += '],';
        json += '"Queue" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Fuels_Cards_UK01"';
        json += '}';
        json += '],';
        json += '"PermissionSet" : [';
        json += '{';
        json += '"DeveloperName" : "GCM_Application_Administrator"';
        json += '}';        
        json += '],';
        json += '"CollaborationGroup" : [';
        json += '{';
        json += '"Name" : "GBS TEST CHATTER GROUP"';
        json += '}';
        json += ']';
        json += '}';
        json += ']';
		GCM_Create_User.createUser(json);
        System.assert(users.size() == 1, 'Test Data Found');
        Test.stopTest();
    }  
}