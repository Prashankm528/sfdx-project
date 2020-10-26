/**
* @author     Santosh Verma
* @date       31/07/2019
* @description    Test class for projecttrigger and helper class  
* 
* History
*  
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_ProjectTriggerTest {
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        
        String sTime= String.valueOf(System.currentTimeMillis());
        set<String> uniqueNameSet= new set<String>();
        String [] uSname = new String[]{'ICRM_ProjectTriggerabc@test.com.customer.','ICRM_ProjectTriggerdef@test.com.customer.','ICRM_ProjectTriggerghi@test.com.customer.'};    
            Map<String,Id > profileMap = new Map<String, Id>();
        for(Profile p1: [SELECT Id,name FROM Profile WHERE Name in ('ICRM Base','System Administrator')]){
            profileMap.put(p1.name,p1.id);
        }
        List<User> userList= new List<User>();
        for(integer i=0; i<=2; i++){
            User auser = new User();
            auser.lastname = 'Testing'+i;
            auser.Email = 'standarduser'+i+'@testorg.com'; 
            auser.Alias = 'standt'+i;
            auser.EmailEncodingKey='UTF-8'; 
            auser.LanguageLocaleKey='en_US'; 
            auser.LocaleSidKey='en_US'; 
            auser.TimeZoneSidKey='America/Chicago'; 
            auser.Username = uSname[i]+sTime;
            uniqueNameSet.add(uSname[i]+sTime);
            auser.IsActive = true;  
            if(i < 2){  
                auser.ProfileId = profileMap.get('ICRM Base');   
            }
            else{   
                auser.ProfileId = profileMap.get('System Administrator');
            }
            userList.add(auser);
        }
        insert userList;
        User[] testUsers = new User[3];
        Integer j =0;
        for(User u1: [SELECT Id,Username FROM User WHERE Username in: uniqueNameSet ORDER BY Username asc]){
            
            testUsers[j]= u1;      
            j=j+1;
        }
        ICRM_Project__c  PrjObj1 = new ICRM_Project__c();     
        prjobj1.name = 'Project-001-Test'; 
        prjobj1.ICRM_Project_Types__c = 'AMA';
        Date myDate = Date.newInstance(2019, 2, 17);
        prjobj1.ICRM_Start_Date__c= myDate;
        prjobj1.ICRM_End_Date__c = myDate+7; 
        prjobj1.ICRM_Inception_Date__c = myDate;
        prjobj1.ICRM_Stage__c = 'Select';
        prjobj1.ICRM_Priority__c='High';
        prjobj1.ownerid=testUsers[1].id;
        prjobj1.ICRM_BP_Confidential__c = True;
        prjobj1.ICRM_Confidentiality_Comments__c='Test';
        prjobj1.ICRM_Reason_for_Confidentiality__c='ITK';
        BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
        insert prjobj1;
        System.runAs (testUsers[2]){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ICRM_M_O'];
            insert new PermissionSetAssignment(AssigneeId = testUsers[0].id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = testUsers[1].id, PermissionSetId = ps.Id);
        }
        ICRM_Project_Team__c pt= new ICRM_Project_Team__c(ICRM_User__c=testUsers[1].id, ICRM_Project__c=prjobj1.id);
        insert pt;
    }
    
    /**
* @description - test method
*/
    @istest
    public static void testTrigger(){
        
        Test.startTest();
        list<ICRM_Project__c>  PrjObj = new list<ICRM_Project__c>(); 
        
        PrjObj =  [Select ID,name,ICRM_Start_Date__c,ICRM_End_Date__c,ICRM_Project_Types__c, ICRM_Project_Name_Text__c,ICRM_Project_Types_Text__c,ICRM_Start_Date_Text__c,ICRM_End_Date_Text__c from ICRM_Project__c where ICRM_Project_Name_Text__c = 'Project-001-Test' ];       
        Test.stopTest();
        System.assertEquals(prjobj.get(0).name, prjobj.get(0).ICRM_Project_Name_Text__c,'The test class is not pass');
        System.assertEquals(prjobj.get(0).ICRM_Project_Types__c, prjobj.get(0).ICRM_Project_Types_Text__c,'The test class is not pass');
        System.assertEquals(string.valueof(prjobj.get(0).ICRM_Start_Date__c), prjobj.get(0).ICRM_Start_Date_Text__c,'The test class is not pass');
        System.assertEquals(string.valueof(prjobj.get(0).ICRM_End_Date__c), prjobj.get(0).ICRM_End_Date_Text__c,'The test class is not pass');    
    }
    /** Method to check Project Header record got created whenever new Confidential Project got created **/
    @istest
    public static void testProjectHeaderInsert(){
        ICRM_Project__c PrjObj =  [Select id,Name,ICRM_Inception_Date__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c from ICRM_Project__c where name = 'Project-001-Test'];  
        ICRM_Confidential_Project__c PrjHead= [Select id,Name,ICRM_Inception_Date__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c FROM ICRM_Confidential_Project__c where ICRM_Project_ID__c = : PrjObj.ICRM_Project_ID__c];
        System.assertEquals(PrjHead.Name,PrjObj.name,
                            'Project Header got created with correct Name');    
        System.assertEquals(PrjHead.ICRM_Inception_Date__c,PrjObj.ICRM_Inception_Date__c,
                            'Project Header got created with correct Inception Date');
        System.assertEquals(PrjHead.ICRM_Stage__c,PrjObj.ICRM_Stage__c,
                            'Project Header got created with correct Stage Name');  
        System.assertEquals(PrjHead.ICRM_Priority__c,PrjObj.ICRM_Priority__c,
                            'Project Header got created with correct Priority');                                
    }
    /** Method to check Project Header record got updated whenever existing Confidential Project got updated **/
    @istest
    public static void testProjectHeaderUpdate(){
        
        ICRM_Project__c PrjObj =  [Select id,Name,ICRM_Inception_Date__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c from ICRM_Project__c where name = 'Project-001-Test'];  
        PrjObj.ICRM_Stage__c='Operate';
        Test.startTest(); 
        update PrjObj;
        ICRM_Confidential_Project__c PrjHead= [Select id,ICRM_Stage__c,ICRM_Project_ID__c FROM ICRM_Confidential_Project__c where ICRM_Project_ID__c = : PrjObj.ICRM_Project_ID__c];
        System.assertEquals(PrjHead.ICRM_Stage__c,PrjObj.ICRM_Stage__c,
                            'Project Header got updated with correct Stage Name');
        Test.stopTest();
    }
    /** Method to check Project Header record got deleted whenever existing Confidential Project got deleted **/
    @istest
    public static void testProjectHeaderDelete(){
        
        List<ICRM_Confidential_Project__c> headerList = new List<ICRM_Confidential_Project__c>();
        ICRM_Project__c PrjObj =  [Select id,ICRM_Project_ID__c from ICRM_Project__c where name = 'Project-001-Test'];  
        Test.startTest();
        delete PrjObj;
        headerList = [SELECT id, name FROM ICRM_Confidential_Project__c WHERE name = 'Project-001-Test'];
        System.assertEquals(headerList.size(), 0 ,'The Header record is deleted');
        Test.stopTest();
    }
    /** Method to check Project Header record got deleted whenever existing Confidential Project got deleted **/
    @istest
    public static void testProjectTeamShareRevise(){
        
        ICRM_Project__c PrjObj =  [Select id,Name,ICRM_Inception_Date__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c from ICRM_Project__c where name = 'Project-001-Test'];  
        User useri2= [SELECT Id  FROM User WHERE Username like 'ICRM_ProjectTriggerabc@test%' LIMIT 1];
        PrjObj.ownerid=useri2.id;
        Test.startTest(); 
        update PrjObj;
        List<ICRM_Project_Team__c> pteam= [Select id,ICRM_User__c from ICRM_Project_Team__c where ICRM_Project__c =: PrjObj.id];
        System.assertNotEquals(pteam.size(), 0);
        Test.stopTest();
    }
    /** Method to check Edit access to Structurer SPA and Commercial SPA Users to the project **/
    @istest
    public static void testProjectShareToSPAUsers(){
        
        User useri1= [SELECT Id  FROM User WHERE Username like 'ICRM_ProjectTriggerdef@test%' LIMIT 1];    
        User useri2= [SELECT Id  FROM User WHERE Username like 'ICRM_ProjectTriggerabc@test%' LIMIT 1];
        ICRM_Project__c  PrjObj1 = new ICRM_Project__c();     
        prjobj1.name = 'ProjectTest1';  
        prjobj1.ICRM_Commercial_SPA__c=useri1.id;
        prjobj1.ICRM_Structurer_SPA__c=useri2.id;
        Test.startTest(); 
        insert prjobj1;
        List<ICRM_Project_Team__c> pteam= [Select id,ICRM_User__c from ICRM_Project_Team__c where ICRM_Project__c =: prjobj1.id];
        System.assertNotEquals(pteam.size(), 0);
        Test.stopTest();
    }
    /** Method to check NPV and Stage Sych from Project to Opportunity **/
    @istest
    public static void stageNPVSyncTest(){
        
        User useri1= [SELECT Id  FROM User WHERE Username like 'ICRM_ProjectTriggerdef@test%' LIMIT 1];
        ICRM_Project__c PrjObj =  [Select id,Name,ICRM_Inception_Date__c,ICRM_Stage__c,ICRM_Priority__c,ICRM_Project_ID__c from ICRM_Project__c where name = 'Project-001-Test'];  
        string accRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        string oppRecTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('IST New Opportunity').getRecordTypeId();
        System.runAs (useri1){
            Account acc = new Account();        
            acc.RecordTypeId = accRecTypeId;
            acc.Name = 'IST Account for Oppty';
            insert acc;
            Opportunity opp1 = new Opportunity();
            opp1.RecordTypeId = oppRecTypeId;
            opp1.CloseDate=system.today();
            opp1.StageName='Active Discussions';
            opp1.AccountId = acc.Id;
            opp1.ownerid = useri1.id;
            opp1.Name = 'Opportunity for Project';
            opp1.ICRM_RBU__c='SPEH';
            opp1.ICRM_Project__c = PrjObj.id;
            string values= 'NPV Update;Stage Change;Team Member';
            opp1.ICRM_Send_Email__c=values;
            Insert opp1;
            Test.startTest(); 
            PrjObj.ICRM_NPV__c=3421;
            PrjObj.ICRM_Stage__c='Execute';
            BPG_Trigger_Handler_Utilities.resetRecursionCheckSet();
            update PrjObj;
            System.assertEquals(2, Limits.getEmailInvocations());
            Test.stopTest();
        }
    }
}