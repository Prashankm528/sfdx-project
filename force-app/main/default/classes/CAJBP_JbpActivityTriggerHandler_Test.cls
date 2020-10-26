/**
* This test class contains unit tests for validating the behavior of
* CAJBP_JbpActivityTriggerHandler.cls class for the CAJBP_JbpActivityTrigger trigger.
*
* @autor Jana Cechova
* Created: 10 September, 2018
* history
* 18/07/2019	Jana Cechova		   Created
* 23/10/2019   Venkatesh Muniyasamy    Updated for JAF Rollup
* 12/12/2019   Venkatesh Muniyasamy    Updated for Objective Validation
* 16/01/2020   Venkatesh Muniyasamy    Updated for Objective Validation
* 30/01/2020   Venkatesh Muniyasamy    Updated for Related JBP Currency Update
* 01/07/2020   Venkatesh Muniyasamy    Updated for Related JBP Total Rollup
*/

@isTest(seeAllData = false)
private class CAJBP_JbpActivityTriggerHandler_Test{

    static integer bulkSize=10;
    static string paidBy;
    static list<CAJBP_Joint_Business_Plan__c> lstJBPs = new list<CAJBP_Joint_Business_Plan__c>();
    static list<CAJBP_Objective__c> lstObjectives = new list<CAJBP_Objective__c>();
    static list<CAJBP_JBP_Activity__c> lstJBPActivities = new list<CAJBP_JBP_Activity__c>();
    static list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFs = new list<CAJBP_Distributor_Joint_Activity_Fund__c>();


    /**
    * The purpose of this method is to create test data used in unit tests.
    * @see
    * @param
    * @return     void
    */
    static void createTestData() {
         Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
         );
        insert account;
        Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
        insert contact;

        for(Integer i=0; i<bulkSize; i++){
           lstJBPs.add(new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(Date.today().year()),
                CAJBP_Account__c = account.id,
                CAJBP_State__c = 'Closed',
                CAJBP_JBP_Start_Date__c = Date.today(),
                CAJBP_JBP_End_Date__c = Date.today().addDays(10),
                CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Agreed_Sign_Off__c=True,
                CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True,
                CurrencyIsoCode= 'USD'
            ));
        }
        insert lstJBPs;

        for(Integer j=0; j<bulkSize; j++){
         lstObjectives.add(new CAJBP_Objective__c(
           //  Name = 'TestName' + j,
             CAJBP_Joint_Business_Plan__c = lstJBPs[j].id,
             Name = 'Test Objective' + J,
             CAJBP_Description__c = 'Test Description' +J
         )
         );
        }
        insert lstObjectives;
        
        CAJBP_TestFactory.createUsers(2, 0);
        List<User> userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 2];
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c Limit 1].Id;
        CAJBP_JBP_Team_Member__c teamMemberFinance = CAJBP_TestFactory.createJBPTeamMember(userId[0].Id, jbpId, 'Read Only', 'Finance Approver');
        CAJBP_JBP_Team_Member__c teamMemberMarketing = CAJBP_TestFactory.createJBPTeamMember(userId[1].Id, jbpId, 'Read Only', 'Marketing Approver');

        for(Integer k=0; k<bulkSize; k++){

            lstJBPActivities.add(new CAJBP_JBP_Activity__c(
                Name = 'TestName' + k,
                CAJBP_Objective__c = lstObjectives[k].id,
                CAJBP_Paid_for_by__c=paidBy,
                CAJBP_Activity_Type__c = 'Promotion',
                CAJBP_Status__c = 'In Progress',
                CAJBP_Start_Date__c = Date.today(),
                CAJBP_End_Date__c = Date.today().addDays(1),
                CAJBP_Activity_Ownership__c ='Castrol',
                CAJBP_Castrol_Estimated_Cost__c = 1000,
                CAJBP_Partner_Estimated_Cost__c = 900,
                CAJBP_Finance_Approver__c = teamMemberFinance.CAJBP_User__c,
                CAJBP_Marketing_Approver__c = teamMemberMarketing.CAJBP_User__c
            )
            );

        }

        for(Integer l=0; l<bulkSize; l++){

            lstDJAFs.add(new CAJBP_Distributor_Joint_Activity_Fund__c(
               CAJBP_Joint_Business_Plan__c = lstJBPs[l].id
                )
            );

        }

    }
    
    static testMethod void addApproversToActivity() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData(); 
        Id jbpId = [SELECT Id FROM CAJBP_Joint_Business_Plan__c Limit 1].Id;
       /* CAJBP_TestFactory.createUsers(2, 0);
        List<User> userId = [SELECT Id FROM User WHERE Username LIKE 'cajbp.user@test.com#%' LIMIT 2];        
        CAJBP_JBP_Team_Member__c teamMemberFinance = CAJBP_TestFactory.createJBPTeamMember(userId[0].Id, jbpId, 'Read Only', 'Finance Approver');
        CAJBP_JBP_Team_Member__c teamMemberMarketing = CAJBP_TestFactory.createJBPTeamMember(userId[1].Id, jbpId, 'Read Only', 'Marketing Approver');*/
        insert lstDJAFs;
        system.Test.startTest(); 
        	lstJBPActivities[0].CAJBP_Joint_Business_Plan__c = jbpId;
        	insert lstJBPActivities;   
        	
        system.Test.stopTest();
        CAJBP_JBP_Activity__c activity = [Select CAJBP_Finance_Approver__c,CAJBP_Marketing_Approver__c FROM CAJBP_JBP_Activity__c Where Id = : lstJBPActivities[0].Id Limit 1];
		// system.assertEquals(activity.CAJBP_Finance_Approver__c,teamMemberFinance.CAJBP_User__c);
        // system.assertEquals(activity.CAJBP_Marketing_Approver__c,teamMemberMarketing.CAJBP_User__c);
    }
    static testMethod void positiveTestOneRecordWithPaidForByEqualsJAF() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                 try {
                    insert lstJBPActivities;
                }  catch(DmlException e){
                    system.assert(e.getMessage().contains('Joint Activity Fund must be created before creating this activity'));
                
                }
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size(),'JBP Activity was created unexpected.');
    }

    static testMethod void positiveTestOneRecordWithPaidForByNotEqualsJAF() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        
        for(CAJBP_JBP_Activity__c  objActivity: lstJBPActivities){
        
            objActivity.CAJBP_Paid_for_by__c='Partner';
            
        }
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                
                    insert lstJBPActivities;
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(1,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            system.assertEquals(null,lstJBPactivitiesToAsserts[0].CAJBP_Distributor_Joint_Activity_Fund__c ,'JBP Activity was not created correctly.');
    }   
    
     static testMethod void positiveTestWithPaidForByEqualsJAFandJAFisExists() {
         bulkSize = 1;
         paidBy='JAF';
         createTestData();
         
         list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
         system.assertEquals(0,lstJBPactivitiesToAsserts.size());
         
         insert lstDJAFs;
         
         system.Test.startTest();
                
             insert lstJBPActivities;
                
         system.Test.stopTest();
            
            
            
         lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
         system.assertEquals(1,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            
            
         list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFtoAsserts= new list<CAJBP_Distributor_Joint_Activity_Fund__c>([SELECT Id 
                                                                                                              FROM CAJBP_Distributor_Joint_Activity_Fund__c]);
         
         system.assertEquals(lstDJAFtoAsserts[0].id,lstJBPactivitiesToAsserts[0].CAJBP_Distributor_Joint_Activity_Fund__c ,'DJAF on JBP Activity was not populated correctly.');
     
     }
     
     static testMethod void positiveTestWithPaidForByEqualsJAFBulk() {
        bulkSize = 201;
        paidBy='JAF';
        createTestData();
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                 try {
                    insert lstJBPActivities;
                }  catch(DmlException e){
                    system.assert( e.getMessage().contains(system.label.CAJBP_No_JAF_Error),e.getMessage());
                
                }
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size(),'JBP Activity was created unexpected.');
         
         
     }
     
     static testMethod void positiveTestWithPaidForByNotEqualsJAFBulk() {
        bulkSize = 201;
        paidBy='JAF';
        createTestData();
        
         for(CAJBP_JBP_Activity__c  objActivity: lstJBPActivities){
        
            objActivity.CAJBP_Paid_for_by__c='Partner';
            
        }
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
        system.Test.startTest();
                
            insert lstJBPActivities;
                
        system.Test.stopTest();
            
        lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
        
        system.assertEquals(201,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
        
        for(CAJBP_JBP_Activity__c objActivity : lstJBPactivitiesToAsserts ){
        
            system.assertEquals(null,objActivity.CAJBP_Distributor_Joint_Activity_Fund__c ,'JBP Activity was not created correctly.');
        
        }
      
    
         
     }
     
     static testMethod void positiveTestWithPaidForByEqualsJAFandJAFExistsBulk() {
        bulkSize = 201;
        paidBy='JAF';
        createTestData();

        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(0,lstJBPactivitiesToAsserts.size());

        insert lstDJAFs;

        system.Test.startTest();

         insert lstJBPActivities;

        system.Test.stopTest();
            
            
        Map<Id,CAJBP_JBP_Activity__c> mapJBPactivitiesToAsserts = new Map<Id,CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c,CAJBP_Joint_Business_Plan__c
                                                                          FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(201,mapJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            
        Map<id,CAJBP_Distributor_Joint_Activity_Fund__c> mapDJAFtoAsserts= new Map<id, CAJBP_Distributor_Joint_Activity_Fund__c>([SELECT Id,CAJBP_Joint_Business_Plan__c
                                                                                                           FROM CAJBP_Distributor_Joint_Activity_Fund__c]);
        for(Id id : mapJBPactivitiesToAsserts.keySet())
        {
            system.assert(!string.isBlank(mapDJAFtoAsserts.get(mapJBPactivitiesToAsserts.get(id).CAJBP_Distributor_Joint_Activity_Fund__c).Id));
        }
     }
    static testMethod void updateToJAF() {
        bulkSize = 1;
        paidBy='Castrol';
        createTestData();
        insert lstJBPActivities;
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                      FROM CAJBP_JBP_Activity__c]);
        for(integer i=0;i<lstJBPActivities.size();i++)
        {
            lstJBPActivities[i].CAJBP_Paid_for_by__c='JAF';
        }
        system.Test.startTest();
            try
            {
                update lstJBPActivities;
            }
            catch(DmlException e)
            {
                system.assert(e.getMessage().contains('Joint Activity Fund must be created before creating this activity'));
            }
        system.Test.stopTest();
    }

    @isTest
    static void insertActivitieswithJAFRollup() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        insert lstDJAFs;
        CAJBP_Distributor_Joint_Activity_Fund__c jaf = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        CAJBP_Objective__c jbpObjective = [select Id from CAJBP_Objective__c limit 1];

        CAJBP_JBP_Activity__c lstJbpActivity = new CAJBP_JBP_Activity__c(
            CAJBP_Distributor_Joint_Activity_Fund__c = jaf.id,CAJBP_Joint_Business_Plan__c =jaf.CAJBP_Joint_Business_Plan__c,
            CAJBP_Objective__c = jbpObjective.Id,CAJBP_Paid_for_by__c='JAF',
            CAJBP_Activity_Type__c = 'Promotion', CAJBP_Status__c = 'In Progress', CAJBP_Start_Date__c = Date.today(),
            CAJBP_End_Date__c = Date.today().addDays(1),
            CAJBP_Castrol_Estimated_Cost__c = 500, CAJBP_Partner_Estimated_Cost__c = 500,
            CAJBP_Castrol_Actual_Cost__c = 500, CAJBP_Partner_Actual_Cost__c = 450);

        system.Test.startTest();
            insert lstJbpActivity;
        system.Test.stopTest();

       CAJBP_Distributor_Joint_Activity_Fund__c jafassert = [select id, CAJBP_Joint_Business_Plan__c, CAJBP_Estimated_Spend__c, CAJBP_Actual_Spend__c,
            CAJBP_Estimated_Castrol_Spend__c, CAJBP_Estimated_Partner_Spend__c, CAJBP_Actual_Castrol_Spend__c, CAJBP_Actual_Partner_Spend__c
            from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(1000,jafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not updated.');
        system.assertEquals(950,jafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not updated.');

        system.assertEquals(500,jafassert.CAJBP_Estimated_Castrol_Spend__c,'JAF Estimated Castrol Spend was not updated.');
        system.assertEquals(500,jafassert.CAJBP_Estimated_Partner_Spend__c,'JAF Estimated Partner Spend was not updated.');
        system.assertEquals(500,jafassert.CAJBP_Actual_Castrol_Spend__c,'JAF Actual Castrol Spend was not updated.');
        system.assertEquals(450,jafassert.CAJBP_Actual_Partner_Spend__c,'JAF Actual Partner Spend was not updated.');
    }
    @isTest
    static void updateActivitieswithJAFRollup() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        insert lstDJAFs;
        CAJBP_Distributor_Joint_Activity_Fund__c jaf = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        CAJBP_Objective__c jbpObjective = [select Id from CAJBP_Objective__c limit 1];

        CAJBP_JBP_Activity__c lstJbpActivity = new CAJBP_JBP_Activity__c(
            CAJBP_Distributor_Joint_Activity_Fund__c = jaf.id,CAJBP_Joint_Business_Plan__c =jaf.CAJBP_Joint_Business_Plan__c,
            CAJBP_Objective__c = jbpObjective.Id, CAJBP_Paid_for_by__c='JAF',
            CAJBP_Activity_Type__c = 'Promotion', CAJBP_Status__c = 'In Progress', CAJBP_Start_Date__c = Date.today(),
            CAJBP_End_Date__c = Date.today().addDays(1), CAJBP_Castrol_Estimated_Cost__c = 1000,
            CAJBP_Partner_Estimated_Cost__c = 900, CAJBP_Castrol_Actual_Cost__c = 1000, CAJBP_Partner_Actual_Cost__c=700);
        insert lstJbpActivity;

        lstJbpActivity.CAJBP_Castrol_Estimated_Cost__c=400;
        lstJbpActivity.CAJBP_Castrol_Actual_Cost__c=200;

        system.Test.startTest();
            update lstJbpActivity;
        system.Test.stopTest();

        CAJBP_Distributor_Joint_Activity_Fund__c jafassert = [select id, CAJBP_Joint_Business_Plan__c, CAJBP_Estimated_Spend__c, CAJBP_Actual_Spend__c,
                CAJBP_Estimated_Castrol_Spend__c, CAJBP_Estimated_Partner_Spend__c, CAJBP_Actual_Castrol_Spend__c, CAJBP_Actual_Partner_Spend__c
                from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(1300,jafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not updated.');
        system.assertEquals(900,jafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not updated.');

        system.assertEquals(400,jafassert.CAJBP_Estimated_Castrol_Spend__c,'JAF Estimated Castrol Spend was not updated.');
        system.assertEquals(900,jafassert.CAJBP_Estimated_Partner_Spend__c,'JAF Estimated Partner Spend was not updated.');
        system.assertEquals(200,jafassert.CAJBP_Actual_Castrol_Spend__c,'JAF Actual Castrol Spend was not updated.');
        system.assertEquals(700,jafassert.CAJBP_Actual_Partner_Spend__c,'JAF Actual Partner Spend was not updated.');

        lstJbpActivity.CAJBP_Paid_for_by__c = 'Castrol';
        lstJbpActivity.CAJBP_Distributor_Joint_Activity_Fund__c = NULL;

        update lstJbpActivity;

        CAJBP_Distributor_Joint_Activity_Fund__c noJafassert = [select id,CAJBP_Joint_Business_Plan__c,CAJBP_Estimated_Spend__c,CAJBP_Actual_Spend__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(0,noJafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not removed.');
        system.assertEquals(0,noJafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not removed.');
    }
    @isTest
    static void updateWithdrawnActivitieswithJAFRollup() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        insert lstDJAFs;
        CAJBP_Distributor_Joint_Activity_Fund__c jaf = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        CAJBP_Objective__c jbpObjective = [select Id from CAJBP_Objective__c limit 1];

        CAJBP_JBP_Activity__c lstJbpActivity = new CAJBP_JBP_Activity__c(
            CAJBP_Distributor_Joint_Activity_Fund__c = jaf.id,CAJBP_Joint_Business_Plan__c =jaf.CAJBP_Joint_Business_Plan__c,
            CAJBP_Objective__c = jbpObjective.Id, CAJBP_Paid_for_by__c='JAF',
            CAJBP_Activity_Type__c = 'Promotion', CAJBP_Status__c = 'In Progress', CAJBP_Start_Date__c = Date.today(),
            CAJBP_End_Date__c = Date.today().addDays(1),
            CAJBP_Castrol_Estimated_Cost__c = 500, CAJBP_Partner_Estimated_Cost__c = 500,
            CAJBP_Castrol_Actual_Cost__c = 400, CAJBP_Partner_Actual_Cost__c = 450);

        insert lstJbpActivity;

        lstJbpActivity.CAJBP_Castrol_Estimated_Cost__c=200;
        lstJbpActivity.CAJBP_Castrol_Actual_Cost__c=500;

        system.Test.startTest();
            update lstJbpActivity;
        system.Test.stopTest();

        CAJBP_Distributor_Joint_Activity_Fund__c jafassert = [select id,CAJBP_Joint_Business_Plan__c,CAJBP_Estimated_Spend__c,CAJBP_Actual_Spend__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(700,jafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not updated.');
        system.assertEquals(950,jafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not updated.');

        lstJbpActivity.CAJBP_Status__c = 'Withdrawn';

        update lstJbpActivity;

        CAJBP_Distributor_Joint_Activity_Fund__c noJafassert = [select id,CAJBP_Joint_Business_Plan__c,CAJBP_Estimated_Spend__c,CAJBP_Actual_Spend__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(0,noJafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not removed.');
        system.assertEquals(0,noJafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not removed.');
    }
    @isTest
    static void deleteActivitieswithJAFRollup() {
        bulkSize = 1;
        paidBy='JAF';
        createTestData();
        insert lstDJAFs;
        CAJBP_Distributor_Joint_Activity_Fund__c jaf = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        CAJBP_Objective__c jbpObjective = [select Id from CAJBP_Objective__c limit 1];

        CAJBP_JBP_Activity__c lstJbpActivity = new CAJBP_JBP_Activity__c(
        CAJBP_Distributor_Joint_Activity_Fund__c = jaf.id,CAJBP_Joint_Business_Plan__c =jaf.CAJBP_Joint_Business_Plan__c,
        CAJBP_Objective__c = jbpObjective.Id,CAJBP_Paid_for_by__c='JAF',
        CAJBP_Activity_Type__c = 'Promotion', CAJBP_Status__c = 'In Progress', CAJBP_Start_Date__c = Date.today(),
        CAJBP_End_Date__c = Date.today().addDays(1), CAJBP_Castrol_Estimated_Cost__c = 500,
        CAJBP_Partner_Estimated_Cost__c = 400,CAJBP_Castrol_Actual_Cost__c=200,CAJBP_Partner_Actual_Cost__c=500);

            insert lstJbpActivity;

        CAJBP_Distributor_Joint_Activity_Fund__c jafassert = [select id,CAJBP_Joint_Business_Plan__c, CAJBP_Estimated_Spend__c, CAJBP_Actual_Spend__c,
                CAJBP_Estimated_Castrol_Spend__c, CAJBP_Estimated_Partner_Spend__c, CAJBP_Actual_Castrol_Spend__c, CAJBP_Actual_Partner_Spend__c
                from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(900,jafassert.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not updated.');
        system.assertEquals(700,jafassert.CAJBP_Actual_Spend__c,'JAF Actual cost was not updated.');

        system.assertEquals(500,jafassert.CAJBP_Estimated_Castrol_Spend__c,'JAF Estimated Castrol Spend was not updated.');
        system.assertEquals(400,jafassert.CAJBP_Estimated_Partner_Spend__c,'JAF Estimated Partner Spend was not updated.');
        system.assertEquals(200,jafassert.CAJBP_Actual_Castrol_Spend__c,'JAF Actual Castrol Spend was not updated.');
        system.assertEquals(500,jafassert.CAJBP_Actual_Partner_Spend__c,'JAF Actual Partner Spend was not updated.');

        system.Test.startTest();
            delete lstJbpActivity;
        system.Test.stopTest();

       CAJBP_Distributor_Joint_Activity_Fund__c jafassertion = [select id, CAJBP_Joint_Business_Plan__c, CAJBP_Estimated_Spend__c, CAJBP_Actual_Spend__c,
            CAJBP_Estimated_Castrol_Spend__c, CAJBP_Estimated_Partner_Spend__c, CAJBP_Actual_Castrol_Spend__c, CAJBP_Actual_Partner_Spend__c
            from CAJBP_Distributor_Joint_Activity_Fund__c limit 1];
        system.assertEquals(0,jafassertion.CAJBP_Estimated_Spend__c,'JAF Estimate cost was not updated.');
        system.assertEquals(0,jafassertion.CAJBP_Actual_Spend__c,'JAF Actual cost was not updated.');

        system.assertEquals(0,jafassertion.CAJBP_Estimated_Castrol_Spend__c,'JAF Estimated Castrol Spend was not updated.');
        system.assertEquals(0,jafassertion.CAJBP_Estimated_Partner_Spend__c,'JAF Estimated Partner Spend was not updated.');
        system.assertEquals(0,jafassertion.CAJBP_Actual_Castrol_Spend__c,'JAF Actual Castrol Spend was not updated.');
        system.assertEquals(0,jafassertion.CAJBP_Actual_Partner_Spend__c,'JAF Actual Partner Spend was not updated.');
    }
    static testMethod void testAddJBP()
    {
        bulkSize = 1;
        paidBy='Partner';
        createTestData();

        Test.startTest();
            insert lstJBPActivities;
        Test.stopTest();

        CAJBP_JBP_Activity__c activityAssert = [select CAJBP_Joint_Business_Plan__c from CAJBP_JBP_Activity__c limit 1 ];
        system.assertEquals(activityAssert.CAJBP_Joint_Business_Plan__c, lstObjectives[0].CAJBP_Joint_Business_Plan__c);
    }
    @isTest
    Public static void testActivityJBPCurrency()
    {
        bulkSize = 1;
        paidBy='Castrol';
        createTestData();
        for(CAJBP_JBP_Activity__c act : lstJBPActivities)
        {
            act.CurrencyIsoCode = 'EUR';
            act.CAJBP_Castrol_Estimated_Cost__c = 500;
            act.CAJBP_Partner_Estimated_Cost__c = 550;
            act.CAJBP_Castrol_Actual_Cost__c = 200;
            act.CAJBP_Partner_Actual_Cost__c = 250;
        }
        Test.startTest();
            insert lstJBPActivities;
        Test.stopTest();

        CAJBP_JBP_Activity__c activityCurrency = [SELECT Id, CurrencyisoCode, CAJBP_Estimated_Cost__c,CAJBP_Actual_Cost__c FROM CAJBP_JBP_Activity__c Limit 1];

        system.assertEquals('USD', activityCurrency.CurrencyIsoCode,'Activity currency is not updated correctly');
        system.assertEquals(1050, activityCurrency.CAJBP_Estimated_Cost__c,'Activity Estimated Cost is not updated correctly');
        system.assertEquals(450, activityCurrency.CAJBP_Actual_Cost__c,'Activity Actual Cost is not updated correctly');
    }
    static testMethod void testDeleteActivity()
    {
        bulkSize = 1;
        paidBy='Partner';
        createTestData();
        Test.startTest();
            insert lstJBPActivities;
        	 try {
                    delete lstJBPActivities[0];
                }  catch(DmlException e){
                    system.assert(e.getMessage().contains(Label.CAJBP_Validate_JBP_Owner_Error));
                
                }
        Test.stopTest();
    }
}