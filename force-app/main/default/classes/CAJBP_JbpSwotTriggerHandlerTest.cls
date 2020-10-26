/**
 * @author 			Venkatesh Muniyasamy
 * @date 			13/09/2019
 * @group			CAJBP
 * @description     Test Class for Trigger Handler on CAJBP_SWOT__c object
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 31/01/2020   Venkatesh Muniyasamy            Updated for JBP Currency
 */
@isTest(seeAllData=false)
public with sharing class CAJBP_JbpSwotTriggerHandlerTest
{
    static integer dataSize;
    static string accountType;
    static string jbpState;
    static CAJBP_Joint_Business_Plan__c jbp;
    static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
    static string swotType = CAJBP_SWOT__c.Type__c.getDescribe().getPicklistValues()[0].getValue();

    @isTest
    Public static void testSwotDeletion()
    {
        try
            {
            dataSize = 1;
            jbpState = 'In Progress';
            createTestData(jbpState);
            jbp = [select Id,name from CAJBP_Joint_Business_Plan__c Limit 1];
            List<CAJBP_SWOT__c> swot = new List<CAJBP_SWOT__c>();
            swot.add(new CAJBP_SWOT__c (CAJBP_Joint_Business_Plan__c=jbp.Id,Name='Swot Record',Type__c = swotType));
            Test.startTest();
            insert swot;
            delete swot;
            Test.stopTest();
            }
        catch (Exception ex)
            {
                system.assert(ex.getMessage().contains(String.format(System.Label.CAJBP_InvalidDeleteRecordMsg,new List<String>{'Draft'})));
            }
    }

    @isTest
    Public static void testSwotJBPCurrency()
    {
        dataSize = 1;
        jbpState = 'In Progress';
        createTestData(jbpState);
        jbp = [select Id,name, currencyisoCode from CAJBP_Joint_Business_Plan__c Limit 1];
        List<CAJBP_SWOT__c> swot = new List<CAJBP_SWOT__c>();
        swot.add(new CAJBP_SWOT__c (CAJBP_Joint_Business_Plan__c=jbp.Id,Name='Swot Record',Type__c = swotType,
                                    CurrencyIsoCode='EUR'));
        Test.startTest();
            insert swot;
        Test.stopTest();

        CAJBP_SWOT__c swotCurrency = [SELECT Id, CurrencyisoCode FROM CAJBP_SWOT__c WHERE CAJBP_Joint_Business_Plan__c =: jbp.Id Limit 1];

        system.assertEquals(jbp.currencyisoCode, swotCurrency.CurrencyIsoCode,'Swot currency is not updated correctly');
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