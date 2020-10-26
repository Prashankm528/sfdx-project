/**
 * @author 			Abhinit Kohar
 * @date 			07/02/2020
 * @group			CAJBP
 * @description     Test class for CAJBP_JafCommons
 *
 * history
 * 07/02/2020	Abhinit Kohar       			Created
 */

@isTest(seeAllData=false)
private class CAJBP_JafCommonsTest {
    static integer dataSize;
    static string accountType;
    static string jbpState;
    static CAJBP_Joint_Business_Plan__c jbp;
    static string jbpRecordType = [select id from RecordType where name='Indirect JBP'].id;

    @isTest
    Public static void testJafDeletion()
    {
        try
        {
            dataSize = 1;
            jbpState = 'In Progress';
            createTestData(jbpState);
            jbp = [select Id,name from CAJBP_Joint_Business_Plan__c Limit 1];
            List<CAJBP_Distributor_Joint_Activity_Fund__c> jaf = new List<CAJBP_Distributor_Joint_Activity_Fund__c>();
            jaf.add(new CAJBP_Distributor_Joint_Activity_Fund__c (CAJBP_Joint_Business_Plan__c=jbp.Id,CAJBP_Castrol_Contribution_Amount__c=100,CAJBP_Partner_Contribution_Amount__c=100));
            Test.startTest();
            insert jaf;
            delete jaf;
            Test.stopTest();
        }
        catch (Exception ex)
        {
            system.assert(ex.getMessage().contains(String.format(System.Label.CAJBP_InvalidDeleteRecordMsg,new List<String>{'Draft'})));
        }
    }
    @isTest
    Public static void testPopulateJafFields()
    {
        dataSize = 1;
        jbpState = 'In Progress';
        createTestData(jbpState);

        jbp = [select Id,name from CAJBP_Joint_Business_Plan__c Limit 1];
        List<CAJBP_Distributor_Joint_Activity_Fund__c> jaf = new List<CAJBP_Distributor_Joint_Activity_Fund__c>();
        jaf.add(new CAJBP_Distributor_Joint_Activity_Fund__c (CAJBP_Joint_Business_Plan__c=jbp.Id, CAJBP_Castrol_Contribution_Amount__c=100, CAJBP_Partner_Contribution_Amount__c=200,
                CurrencyIsoCode='EUR'));

        Test.startTest();
        insert jaf;
        Test.stopTest();

        CAJBP_Distributor_Joint_Activity_Fund__c jafJbp = [SELECT Id, Name, CurrencyisoCode, CAJBP_Castrol_Contribution_Amount__c, CAJBP_Partner_Contribution_Amount__c FROM CAJBP_Distributor_Joint_Activity_Fund__c WHERE CAJBP_Joint_Business_Plan__c =: jbp.Id Limit 1];

        //for Currency
        system.assertEquals('USD', jafJbp.CurrencyIsoCode,'JAF currency is not updated correctly');
        system.assertEquals(100, jafJbp.CAJBP_Castrol_Contribution_Amount__c,'JAF Castrol Contribution is not updated correctly');
        system.assertEquals(200, jafJbp.CAJBP_Partner_Contribution_Amount__c,'JAF Partner Contribution is not updated correctly');

        //for Jaf Name
        system.assertEquals('JAF Account JAF ' + string.valueOf(date.today().year()), jafJbp.Name,'JAF Name is not updated correctly');
    }

    @isTest
    Public static void testPopulateJafFieldsForMultipleJafs()
    {
        dataSize = 2;
        jbpState = 'In Progress';
        createTestData(jbpState);

        List<CAJBP_Joint_Business_Plan__c> jbpList = [select Id,name from CAJBP_Joint_Business_Plan__c];
        List<CAJBP_Distributor_Joint_Activity_Fund__c> jaf = new List<CAJBP_Distributor_Joint_Activity_Fund__c>();
        jaf.add(new CAJBP_Distributor_Joint_Activity_Fund__c (CAJBP_Joint_Business_Plan__c=jbpList[0].Id, CAJBP_Castrol_Contribution_Amount__c=100, CAJBP_Partner_Contribution_Amount__c=200,
                CurrencyIsoCode='EUR'));
        jaf.add(new CAJBP_Distributor_Joint_Activity_Fund__c (CAJBP_Joint_Business_Plan__c=jbpList[1].Id, CAJBP_Castrol_Contribution_Amount__c=100, CAJBP_Partner_Contribution_Amount__c=200,
                CurrencyIsoCode='EUR'));

        Test.startTest();
        insert jaf;
        Test.stopTest();

        CAJBP_Distributor_Joint_Activity_Fund__c jafJbp = [SELECT Id, Name FROM CAJBP_Distributor_Joint_Activity_Fund__c WHERE CAJBP_Joint_Business_Plan__c =: jbpList[0].Id Limit 1];
        CAJBP_Distributor_Joint_Activity_Fund__c jafJbp1 = [SELECT Id, Name FROM CAJBP_Distributor_Joint_Activity_Fund__c WHERE CAJBP_Joint_Business_Plan__c =: jbpList[1].Id Limit 1];

        system.assertEquals('JAF Account JAF ' + string.valueOf(date.today().year()), jafJbp.Name,'JAF Name is not updated correctly');
        system.assertEquals('JAF Account JAF ' + string.valueOf(date.today().year()+1), jafJbp1.Name,'JAF Name is not updated correctly');
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
                    CAJBP_JBP_Start_Date__c = Date.today(),	CAJBP_JBP_End_Date__c = Date.Today().addDays(20),
                    RecordTypeId=jbpRecordType,CAJBP_Account__c=act.Id,
                    CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                    CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                    CAJBP_JBP_Agreed_Sign_Off__c=True,
                    CurrencyIsoCode='USD'));
        }
        insert createJBP;
    }
}