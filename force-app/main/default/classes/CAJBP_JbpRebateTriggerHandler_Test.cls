/**
 * @author			Venkatesh Muniyasamy
 * @date			23/07/2019
 * @group			CAJBP
 * @description		test class for CAJBP_JbpRebateTrigger trigger.
 *
 * history
 * 23/07/2019	Venkatesh Muniyasamy			Created
 * 30/01/2020	Venkatesh Muniyasamy			Updated for JBP Currency.
*/

@isTest(seeAllData=false)
public with sharing class CAJBP_JbpRebateTriggerHandler_Test 
{
    static integer dataSize;
    static string accountType;
    static string jbpState;
    static CAJBP_Scorecard__c score;
    static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
    static string rebateRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Rebate__c' and isactive=true limit 1].Id;
    
    @isTest
    public static void checkRebateJBPUpdated() 
    {
        dataSize = 1;
        jbpState = 'Draft';
        createTestData(jbpState);
        CAJBP_Scorecard__c scoreCard = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c Limit 1];
        List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
        rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=scoreCard.Id,RecordTypeId=rebateRecordType));
        Test.startTest();
        insert rebate;
        Test.stopTest();
        CAJBP_Rebate__c rebateAssert = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Rebate__c Limit 1 ];
        system.debug('Scorecard JBP is ' + scoreCard.CAJBP_Joint_Business_Plan__c +' and Rebate JBP is '+ rebateAssert.CAJBP_Joint_Business_Plan__c);
        system.assertEquals(scoreCard.CAJBP_Joint_Business_Plan__c, rebateAssert.CAJBP_Joint_Business_Plan__c, System.Label.CAJBP_Rebate_Error);
    }
    @isTest
    public static void checkRebateJBPUpdatedBulk() 
    {
        dataSize = 10;
        jbpState = 'Draft';
        createTestData(jbpState);
        List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
        List<CAJBP_Scorecard__c> scoreCard = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c];
        for(CAJBP_Scorecard__c score: scoreCard)
        {
            rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=score.Id,
            RecordTypeId=rebateRecordType,CAJBP_Threshold_Price_Per_Litre__c=1.00,
            CAJBP_Threshold_Volume_Turnover_Target__c=1000.00,CAJBP_Threshold_Rebate_Amount__c=1000.00));
        }
        Test.startTest();
        insert rebate;
        Test.stopTest();
        List<CAJBP_Rebate__c> rebateAssert = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Rebate__c Where
                                                CAJBP_Joint_Business_Plan__c != null];
        system.debug('Scorecard Size is ' + scoreCard.size() +' and Rebate with JBP size is '+ rebateAssert.size());
        system.assertEquals(scoreCard.size(), rebateAssert.size(), Label.CAJBP_Rebate_Error);
    }
    @isTest
    Public static void checkRebateDeletion()
    {
        try 
            {
            dataSize = 1;
            jbpState = 'In Progress';
            createTestData(jbpState);
            score = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c Limit 1];
            List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
            rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=score.Id,RecordTypeId=rebateRecordType));
            Test.startTest();
            insert rebate;
            delete rebate;
            Test.stopTest();
            } 
        catch (Exception ex) 
            { 
                system.assert(ex.getMessage().contains(String.format(System.Label.CAJBP_InvalidDeleteRecordMsg,new List<String>{'Draft'})));
            }
     }
    @isTest
    public static void checkRebateDeletionBulk() 
    {
        try 
            {
            dataSize = 10;
            jbpState = 'In Progress';
            createTestData(jbpState);
            List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
            List<CAJBP_Scorecard__c> scoreCard = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c];
            for(CAJBP_Scorecard__c score: scoreCard)
            {
                rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=score.Id,
                RecordTypeId=rebateRecordType,CAJBP_Threshold_Price_Per_Litre__c=1.00,
                CAJBP_Threshold_Volume_Turnover_Target__c=1000.00,CAJBP_Threshold_Rebate_Amount__c=1000.00));
            }
            Test.startTest();
            insert rebate;
            delete rebate;
            Test.stopTest();
            } 
       catch (Exception ex) 
            {
            List<CAJBP_Rebate__c> rebateAssert = [select id,CAJBP_Joint_Business_Plan__c from CAJBP_Rebate__c];
            system.assertEquals(10, rebateAssert.size());
            }
    }
    
    @isTest
    Public static void checkRebateJBPCurrency()
    {
        dataSize = 1;
        jbpState = 'In Progress';
        createTestData(jbpState);

        List<CAJBP_Rebate__c> rebate = new List<CAJBP_Rebate__c>();
        List<CAJBP_Scorecard__c> scoreCard = [select Id,name,CAJBP_Joint_Business_Plan__c from CAJBP_Scorecard__c];

        for(CAJBP_Scorecard__c score: scoreCard)
        {
            rebate.add(new CAJBP_Rebate__c (CAJBP_Scorecard__c=score.Id,
            RecordTypeId=rebateRecordType,CAJBP_Threshold_Price_Per_Litre__c=1.00,
            CAJBP_Threshold_Volume_Turnover_Target__c=1000.00,CAJBP_Threshold_Rebate_Amount__c=2000.00,
            CurrencyIsoCode='EUR'));
        }

        Test.startTest();
            insert rebate;
        Test.stopTest();

        CAJBP_Rebate__c rebateAssert = [SELECT id,CAJBP_Joint_Business_Plan__c, CurrencyIsoCode, CAJBP_Threshold_Volume_Turnover_Target__c,CAJBP_Threshold_Rebate_Amount__c
                                                 FROM CAJBP_Rebate__c WHERE CAJBP_Joint_Business_Plan__c != null Limit 1];

        system.assertEquals('USD', rebateAssert.CurrencyIsoCode,'JAF currency is not updated correctly');
        system.assertEquals(1000, rebateAssert.CAJBP_Threshold_Volume_Turnover_Target__c,'JAF Castrol Contribution is not updated correctly');
        system.assertEquals(2000, rebateAssert.CAJBP_Threshold_Rebate_Amount__c,'JAF Partner Contribution is not updated correctly');
    }
    public static void createTestData(string jbpState)
    {
        Account act = new Account(Name='JBP Account',Type='Sold-To Party');
        insert act;
        
        Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=act.id);
        insert contact;

        List<CAJBP_Joint_Business_Plan__c> createJBP = new List<CAJBP_Joint_Business_Plan__c>();
        for(integer i=0;i<dataSize;i++)
        {
            createJBP.add(new CAJBP_Joint_Business_Plan__c(Name ='JBP' + i,
                    CAJBP_State__c=jbpState,CAJBP_Year__c= string.valueOf(date.today().year()+i), 
                    RecordTypeId=jbpRecordType,CAJBP_Account__c=act.Id,CAJBP_JBP_Start_Date__c = Date.today(),
                    CAJBP_JBP_End_Date__c = Date.today().addDays(10),
                    CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                    CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                    CAJBP_JBP_Agreed_Sign_Off__c=True,
                    CurrencyIsoCode='USD')); 
        }
        insert createJBP;
    }    

}