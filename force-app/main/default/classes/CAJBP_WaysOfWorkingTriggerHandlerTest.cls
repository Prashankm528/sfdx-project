/**
 * @author 			Venkatesh Muniyasamy
 * @date 			31/10/2020
 * @group			CAJBP
 * @description     Test class for on CAJBP_Ways_of_Working_Target__c trigger
 *
 * history
 * 31/10/2020	Venkatesh Muniyasamy			Created
 */

@isTest(seeAllData=false)
public with sharing class CAJBP_WaysOfWorkingTriggerHandlerTest
{
    static integer dataSize;
    static string accountType;
    static string jbpState;
    static CAJBP_Joint_Business_Plan__c jbp;
    static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;

    @isTest
    Public static void testWaysofWorkingJBPCurrency()
    {
        dataSize = 1;
        jbpState = 'In Progress';
        createTestData(jbpState);
        jbp = [select Id,name, currencyisoCode from CAJBP_Joint_Business_Plan__c Limit 1];

        List<CAJBP_Ways_of_Working_Target__c> ways = new List<CAJBP_Ways_of_Working_Target__c>();
        ways.add(new CAJBP_Ways_of_Working_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,Name='Ways',
                    CAJBP_Description__c = 'Ways Description', CAJBP_Due_Date__c = Date.Today().addDays(5),
                    CurrencyIsoCode='EUR'));

        Test.startTest();
            insert ways;
        Test.stopTest();

        CAJBP_Ways_of_Working_Target__c waysCurrency = [SELECT Id, CurrencyisoCode FROM CAJBP_Ways_of_Working_Target__c WHERE CAJBP_Joint_Business_Plan__c =: jbp.Id Limit 1];

        system.assertEquals(jbp.currencyIsoCode, waysCurrency.CurrencyIsoCode,'Ways of Working Target currency is not updated correctly');
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
                    CAJBP_JBP_Agreed_Sign_Off__c=True,CurrencyIsoCode='USD' ));
        }
        insert createJBP;
    }
}