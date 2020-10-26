/**
* @author     Karishma Gurjar
* @date       06/05/2020
* @description    Test class for ICRM_getSuperUserController 
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_getSuperUserControllerTest {
    /**Setup Data for Test **/
    @testSetup 
    static void testdataSetup(){
        Account acc = new Account();        
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = accRecTypeId;
        acc.Name = 'ISTProspect Acc';
        insert acc;
        set<String> uniqueNameSet= new set<String>();
        String sTime= String.valueOf(System.currentTimeMillis());
        String [] uSname = new String[]{'ICRM_getSuperUserControllerabc@test.com.customer.','ICRM_getSuperUserControllerdef@test.com.customer.'};
            Map<integer,Id > profileMap = new Map<integer, Id>();
        integer j=0;
        for(Profile p1: [SELECT Id,name FROM Profile WHERE Name in ('ICRM Base','System Administrator') ORDER BY name asc]){
            profileMap.put(j,p1.id);
            j=j+1;
        }
        
        List<User> userList= new List<User>();
        for(integer i=0; i<=1; i++){
            User auser = new User();
            auser.lastname = 'Testing'+i;
            auser.Username = uSname[i]+sTime;
            uniqueNameSet.add(uSname[i]+sTime);
            auser.Email = 'standarduser'+i+'@testorg.com'; 
            auser.Alias = 'standt'+i;
            auser.EmailEncodingKey='UTF-8'; 
            auser.LanguageLocaleKey='en_US'; 
            auser.LocaleSidKey='en_US'; 
            auser.TimeZoneSidKey='America/Chicago'; 
            auser.ProfileId = profileMap.get(i);
            auser.IsActive = true;  
            userList.add(auser);
        }
        insert userList;
        User[] testUsers = new User[3];
        j =0;
        for(User u1: [SELECT Id,Username FROM User WHERE Username in: uniqueNameSet ORDER BY Username asc]){
            j=j+1;
            testUsers[j]= u1;
        }
        
        System.runAs (testUsers[2]){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ICRM_M_O_Super_User'];
            insert new PermissionSetAssignment(AssigneeId = testUsers[1].id, PermissionSetId = ps.Id);
            Group g1 = [SELECT Id FROM Group where name='IST Global'];
            GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = testUsers[1].id;
            grpMem2.GroupId = g1.Id;
            Insert grpMem2;
        }
        
    }
    /*  Test method for testing  */
    @istest
    public static void testSuperUserClass(){
        
        User bUser = [SELECT Id, Username,UserType FROM User WHERE Username like 'ICRM_getSuperUserControllerabc@test%' LIMIT 1];
        Account acct = [SELECT Id, Name from Account where Name = 'ISTProspect Acc'];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Id> OpportunityIds = new List<Id>();
        string recTypeid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST Global Opportunity').getRecordTypeId();
        for(Integer i = 0;i<5;i++){
            
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = recTypeid;
            opp.AccountId = acct.Id;
            opp.Name = 'Test Opportunity '+i;
            opp.ICRM_BP_Confidential__c = false;   
            if(i == 0){
                
                opp.ICRM_RBU__c = 'LNG';  
                opp.ICRM_Phy_Fin__c = 'Physical'; 
            }
            else
                if(i == 1){
                    opp.ICRM_Client_Order__c = true;   
                    opp.ICRM_RBU__c = 'LNG';  
                    opp.ICRM_Phy_Fin__c = 'Financial'; 
                } else
                    if(i == 2){
                        opp.ICRM_RBU__c = 'SPA';  
                        opp.ICRM_Phy_Fin__c = 'Financial'; 
                    } else
                        if(i == 3){ 
                            opp.ICRM_RBU__c = 'GOE';  
                            opp.ICRM_Phy_Fin__c = 'Physical'; 
                        }
            Opp.ownerid = bUser.id; 
            opp.StageName = 'Closed - Won';
            opp.CloseDate = Date.today() + 1;
            oppList.add(opp);
        }
        insert oppList;
        for(Opportunity oppty : oppList){
            OpportunityIds.add(oppty.id);      
        } 
        Test.startTest();
        List<User> userList = new List<User>();
        userList = ICRM_getSuperUserController.getSuperUserList(OpportunityIds);
        System.assertNotEquals(userList.size(), 0); 
        Test.stopTest();
    }  
}