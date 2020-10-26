/**
 * @author			Venkatesh Muniyasamy
 * @date			13/09/2019
 * @group			CAJBP
 * @description		test class for CAJBP_Product_Mix_Target__c trigger.
 *
 * history
 * 13/09/2019	Venkatesh Muniyasamy			Created
 * 30/01/2020	Venkatesh Muniyasamy			Updated for JBP Currency.
 * 22/06/2020	Venkatesh Muniyasamy			Updated for Product Mix Target Name.
*/
@isTest(seeAllData=false)
public with sharing class CAJBP_ProductMixTargetTriggerHandlerTest 
{
    static integer dataSize;
    static string accountType;
    static string jbpState;
    static CAJBP_Joint_Business_Plan__c jbp;
    static id jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;
    static id productId;
    static string productMixTargetRecordType = [select id,name from recordtype where sobjecttype='CAJBP_Product_Mix_Target__c' and name ='Annual Sell-In PPL Rebate' and isactive=true limit 1].Id;

    @isTest
    Public static void testProductMixTargetDeletion()
    {
        try
            {
                dataSize = 1;
                jbpState = 'In Progress';

                createTestData(jbpState);

                jbp = [select Id,name,(select id from CAJBP_Scorecards__r Limit 1) from CAJBP_Joint_Business_Plan__c Limit 1];

                List<CAJBP_Product_Mix_Target__c> productMixTarget = new List<CAJBP_Product_Mix_Target__c>();

                productMixTarget.add(new CAJBP_Product_Mix_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,
                CAJBP_Product_Mix_Target_Name__c = 'EDGE',CAJBP_Price_Per_Litre_Rebate__c=100.00,
                CAJBP_Volume_Target__c=10000,recordtypeid = productMixTargetRecordType,
                CAJBP_Scorecard__c = jbp.CAJBP_Scorecards__r.get(0).Id));

                Test.startTest();
                    insert productMixTarget;
                    delete productMixTarget;
                Test.stopTest();
            }
        catch (Exception ex)
            {
                system.assert(ex.getMessage().contains(String.format(System.Label.CAJBP_InvalidDeleteRecordMsg,new List<String>{'Draft'})));
            }
    }

    @isTest
    Public static void testProductMixTargetJBPCurrency()
    {
        dataSize = 1;
        jbpState = 'In Progress';
        createTestData(jbpState);

        jbp = [select Id,name,(select id from CAJBP_Scorecards__r Limit 1)  from CAJBP_Joint_Business_Plan__c Limit 1];
        List<CAJBP_Product_Mix_Target__c> productMixTarget = new List<CAJBP_Product_Mix_Target__c>();
        productMixTarget.add(new CAJBP_Product_Mix_Target__c (CAJBP_Joint_Business_Plan__c=jbp.Id,
        CAJBP_Product_Mix_Target_Name__c = 'EDGE', CAJBP_Price_Per_Litre_Rebate__c=100.00,
        CAJBP_Volume_Target__c=10000,recordtypeid = productMixTargetRecordType,
        CurrencyIsoCode='USD',CAJBP_Scorecard__c = jbp.CAJBP_Scorecards__r.get(0).Id));

        Test.startTest();
            insert productMixTarget;
        Test.stopTest();

        CAJBP_Product_Mix_Target__c productMixTargetCurrency = [SELECT Id, CurrencyisoCode,CAJBP_Price_Per_Litre_Rebate__c FROM CAJBP_Product_Mix_Target__c WHERE CAJBP_Joint_Business_Plan__c =: jbp.Id Limit 1];

        system.assertEquals('EUR', productMixTargetCurrency.CurrencyIsoCode,'Product Mix Target currency is not updated correctly');
        system.assertEquals(100, productMixTargetCurrency.CAJBP_Price_Per_Litre_Rebate__c,'Product Mix Target currency PPL is not updated correctly');
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
                RecordTypeId=jbpRecordType,CAJBP_Account__c=act.Id,
                CAJBP_JBP_Start_Date__c=Date.Today(),
                CAJBP_JBP_End_Date__c=Date.today(),
                CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Agreed_Sign_Off__c=True,
                CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True,
                CurrencyIsoCode = 'EUR' ));
        }
        insert createJBP;
        Product2 product = new Product2(Name='Generator',CASFO_Product_Sales_Organisation__c='UK01' );
        insert product;
    }

}