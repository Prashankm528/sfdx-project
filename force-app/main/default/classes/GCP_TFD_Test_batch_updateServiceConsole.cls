/**
* @author      Avinash Jain
* @date      20/08/2019
* @description    test class for the batch class GCP_TFD_UpdateServiceConsole
*/
@isTest(seeAlldata=false)
public with sharing class GCP_TFD_Test_batch_updateServiceConsole {
    static testMethod void testMethod1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :System.Label.GCP_TFD_Standard_user_pofile_id];
        List<user> userlist = GCP_TFD_TestDataFactory.CreateUser(5,p);
        List<string> permissionSetsName =  System.Label.GCP_TFD_PermissionSets.split(',');
        String PSN = permissionSetsName[0];
        id ps =[SELECT Id FROM PermissionSet WHERE Name =:PSN].id;
        List<permissionSetassignment> psalist = GCP_TFD_TestDataFactory.CreatePSA(userlist,ps);
        system.test.startTest();
        GCP_TFD_UpdateServiceConsole USC = new GCP_TFD_UpdateServiceConsole();
        database.executeBatch(USC);        
        system.Test.stopTest();
        System.assertEquals(True,[Select id,assigneeId,PermissionSet.Name,Assignee.UserPermissionsSupportUser from PermissionSetAssignment where PermissionSet.Name =:PSN limit 1].Assignee.UserPermissionsSupportUser);
    }
    
}