/**
 * @author 			Jan Majling
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     test class for CAJBP_JbpTriggerHandler
 * 
 * history
 * 26/07/2018	Jan Majling				Created
 * 01/08/2018	Jana Cechova			Added check in progress tests
 * 13/09/2019   Venkatesh Muniyasamy    Added jbp deletion logic
 * 03/09/2020   Abhinit Kohar           Added check for Owner change in afterUpdate
 */
 
@isTest(seeAllData = false)

private class CAJBP_JbpTriggerHandlerTest {

    static integer dataSize =1;
    static string jbpState ='In Progress';
    static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
    static Date startDate = Date.today();
    static Date endDate=Date.today().addDays(10);
    static final String CURRENCY_ISO_CODE = 'CAD';
    static string rebateRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Rebate__c' and isactive=true limit 1].Id;
    static string swotType = CAJBP_SWOT__c.Type__c.getDescribe().getPicklistValues()[0].getValue();
    static string productMixTargetRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;

    @testSetup static void setup() {
        Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
        );
        insert account;
    }
    
    @isTest static void testNameChangeOnInsert() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_JBP_Start_Date__c=startDate,
            CAJBP_JBP_End_Date__c=endDate
        );

        Test.startTest();
        insert jbp;
        Test.stopTest();

        jbp = [SELECT Name  FROM CAJBP_Joint_Business_Plan__c WHERE Id = :jbp.Id];

        System.assertEquals('Power Plant Customer Group JBP '+string.valueOf(date.today().year()), jbp.Name );
    }

    @isTest static void testNameChangeOnUpdate() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'Withdrawn',
            CAJBP_JBP_Start_Date__c=startDate,
            CAJBP_JBP_End_Date__c=endDate
        );
        insert jbp;
         
        jbp = [SELECT Name FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Account__c = :account.Id];
        jbp.CAJBP_Year__c = string.valueOf(date.today().year()+1);
       
        Test.startTest();
        update jbp;
        Test.stopTest();

        jbp= [SELECT Name FROM CAJBP_Joint_Business_Plan__c WHERE Id = :jbp.Id];
        system.debug(logginglevel.error, 'jbp' + jbp);
        
        
        System.assertEquals('Power Plant Customer Group JBP ' + string.valueOf(date.today().year()+1), jbp.Name );
    }

    @isTest static void testNameChangeOnBulkInsert() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];

        Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
        insert contact;

        List<CAJBP_Joint_Business_Plan__c> jbps = new List<CAJBP_Joint_Business_Plan__c>();
        for(Integer i=0; i<200; i++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'Closed',
                CAJBP_JBP_Start_Date__c=startDate,
                CAJBP_JBP_End_Date__c=endDate,
                CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Agreed_Sign_Off__c=True,
                CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True
            );
            jbps.add(jbp);
        }

        Test.startTest();
        insert jbps;
        Test.stopTest();


        for(CAJBP_Joint_Business_Plan__c jbp : [SELECT Name FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Account__c = :account.Id]){
            System.assertEquals('Power Plant Customer Group JBP ' + string.valueOf(date.today().year()), jbp.Name );
        }
    }
  
    static testmethod void checkINproggressStatus2records() {
       Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        
        Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
        insert contact;

       CAJBP_Joint_Business_Plan__c jbp1 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress',
            CAJBP_JBP_Start_Date__c=startDate,
            CAJBP_JBP_End_Date__c=endDate,
            CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
            CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
            CAJBP_JBP_Agreed_Sign_Off__c=True,
            CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
            CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
            CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True

        );
       insert jbp1;
       
       list<CAJBP_Joint_Business_Plan__c > lstJBPsToCheck1 = new list<CAJBP_Joint_Business_Plan__c >();
       lstJBPsToCheck1 = [Select id from CAJBP_Joint_Business_Plan__c where Id =:jbp1.id];
       system.assertEquals(1,lstJBPsToCheck1.size());
       
       CAJBP_Joint_Business_Plan__c jbp2 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress'
        );
 
       system.Test.StartTest();
       
       try{ 
          
          insert jbp2;
        
        }catch(DmlException e){
          
          system.assert( e.getMessage().contains('Joint Business Plan with State In Progress or Draft already exists.'),e.getMessage());
        }// catch
             
       system.Test.StopTest();

       list<CAJBP_Joint_Business_Plan__c >lstJBPtoCheck = new list<CAJBP_Joint_Business_Plan__c >([Select id, CAJBP_Account__c, CAJBP_State__c, CAJBP_Year__c  from CAJBP_Joint_Business_Plan__c where CAJBP_Account__c =: account.Id]);
       system.debug(logginglevel.error, 'lstJBPtoCheck ' +lstJBPtoCheck );
       system.assertEquals(1,lstJBPtoCheck.size());
    
    
    }
    
    static testmethod void checkINproggressStatusBulkRecords() {
       
       Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];

       Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
        insert contact;
      
       list<CAJBP_Joint_Business_Plan__c> lstToInsert = new list <CAJBP_Joint_Business_Plan__c>();
        
       CAJBP_Joint_Business_Plan__c jbp1 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress',
            CAJBP_JBP_Start_Date__c=startDate,
            CAJBP_JBP_End_Date__c=endDate,
            CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
            CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
            CAJBP_JBP_Agreed_Sign_Off__c=True,
            CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
            CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
            CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True
        );
       insert jbp1;
       
       for(Integer i=0; i<100; i++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'In Progress',
                CAJBP_JBP_Start_Date__c=startDate,
                CAJBP_JBP_End_Date__c=endDate
            );
            lstToInsert.add(jbp);
        }
        
        for(Integer j=100; j<200; j++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'Draft',
                CAJBP_JBP_Start_Date__c=startDate,
                CAJBP_JBP_End_Date__c=endDate
            );
            lstToInsert.add(jbp);
        }
       
       system.Test.StartTest();
       
       try{ 
                insert lstToInsert;
           }
            catch(DmlException e){
                system.assert( e.getMessage().contains('Joint Business Plan with State In Progress or Draft already exists.'),e.getMessage());
                
                
            }// catch
        
             
       system.Test.StopTest();

       list<CAJBP_Joint_Business_Plan__c>lstJBPtoCheck = new list<CAJBP_Joint_Business_Plan__c >([Select id from CAJBP_Joint_Business_Plan__c ]);
       system.assertEquals(1,lstJBPtoCheck.size(),'JBP was created unexpected.');
    }

    @isTest
    Public static void checkJBPDeletion()
    {
        try
            {
            Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];

            Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
            insert contact;

            List<CAJBP_Joint_Business_Plan__c> createJBP = new List<CAJBP_Joint_Business_Plan__c>();
            for(integer i=0;i<dataSize;i++)
            {
                createJBP.add(new CAJBP_Joint_Business_Plan__c(Name ='JBP' + i,
                        CAJBP_State__c=jbpState,CAJBP_Year__c= string.valueOf(date.today().year()+i),
                        RecordTypeId=jbpRecordType,CAJBP_Account__c=account.Id, CAJBP_JBP_Start_Date__c=startDate,
                        CAJBP_JBP_End_Date__c=endDate, CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                        CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(), CAJBP_JBP_Agreed_Sign_Off__c=True,
                        CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id, CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                        CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True ));
            }
            Test.startTest();
            insert createJBP;
            delete createJBP;
            Test.stopTest();
            }
        catch (Exception ex)
            {
                system.assert(ex.getMessage().contains(String.format(System.Label.CAJBP_InvalidDeleteRecordMsg,new List<String>{'Draft'})));
            }
     }

    @isTest
    static void checkJbpAfterUpdate1(){
        List<User> userList = CAJBP_TestFactory.createAdminUsers(1, 1);
        User user = userList[0];

        Map<String, Object> userMap1 = CAJBP_TestFactory.createSingleUserPermission('NewOwner@test.com');
        User newUser = (User)userMap1.get('user');

        System.runAs(user) {
            CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();
            CAJBP_Objective__c objective = CAJBP_TestFactory.createObjective(jbp.Id);
            CAJBP_JBP_Activity__c activity = CAJBP_TestFactory.createJbpActivity(objective.Id);

            jbp = new CAJBP_Joint_Business_Plan__c(Id = jbp.Id, CurrencyIsoCode = CURRENCY_ISO_CODE);

            Test.startTest();
            update jbp;
            Test.stopTest();

            CAJBP_Objective__c obj = [select id, CurrencyIsoCode from CAJBP_Objective__c where id = :objective.Id];
            system.assertEquals(CURRENCY_ISO_CODE, obj.CurrencyIsoCode);

            CAJBP_JBP_Activity__c act = [select id, CurrencyIsoCode from CAJBP_JBP_Activity__c where id = :activity.Id];
            system.assertEquals(CURRENCY_ISO_CODE, act.CurrencyIsoCode);

            jbp.OwnerId = newUser.Id;
            update jbp;
        }

        System.runAs(newUser) {
            System.assertEquals(1, [select count() from CAJBP_Objective__c]);
        }
    }

    static void checkJbpAfterUpdate2(){
        List<User> userList = CAJBP_TestFactory.createAdminUsers(1, 1);
        User user = userList[0];

        Map<String, Object> userMap1 = CAJBP_TestFactory.createSingleUserPermission('NewOwner@test.com');
        User newUser = (User)userMap1.get('user');

        System.runAs(user) {
            CAJBP_Joint_Business_Plan__c jbp = CAJBP_TestFactory.createJointBusinessPlan();

            CAJBP_Risk__c risk = CAJBP_TestFactory.createRisk(jbp.Id, 'Potential', -100.00, -200.00, startDate);
            insert risk;

            CAJBP_Customer_Contact__c customer = CAJBP_TestFactory.createCustomerContact(jbp);

            jbp = new CAJBP_Joint_Business_Plan__c(Id = jbp.Id, CurrencyIsoCode = CURRENCY_ISO_CODE);

            Test.startTest();
            update jbp;
            Test.stopTest();

            CAJBP_Risk__c ris = [select id, CurrencyIsoCode, CAJBP_Volume__c from CAJBP_Risk__c where id = :risk.Id];
            system.assertEquals(CURRENCY_ISO_CODE, ris.CurrencyIsoCode);
            system.assertEquals(-100.00, ris.CAJBP_Volume__c);

            jbp.OwnerId = newUser.Id;
            update jbp;
        }

        System.runAs(newUser) {
            System.assertEquals(1, [select count() from CAJBP_Risk__c]);
            System.assertEquals(1, [select count() from CAJBP_Customer_Contact__c]);
        }
    }
}