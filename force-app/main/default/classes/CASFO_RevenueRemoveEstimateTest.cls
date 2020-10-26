/************************************************************************************************************
* Description : Testing class for trigger trgRevenueRemoveEstimate.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-NOV-22   1.0                 Maros Zilka         Initial version - after insert only
* 2016-DEC-08   1.1                 Maros Zilka         Tests are performed as Sales User
*
*************************************************************************************************************/

@isTest
public class CASFO_RevenueRemoveEstimateTest {
	
	/********************************************************************
	* Data Preparation Method 
	* ------------------------
	* Method to create test Account data prior to executing tests
	********************************************************************/
	@isTest static void trgRevenueRemoveEstimate () {
    Integer batchSize = 250;
    List<Revenue__c> result;
    List<Revenue__c> revenues = new List<Revenue__c>();

		//Setup account
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser) {
       

        //Setup Products
        Product2 prodEst = new Product2(Name = 'Initial estimate', ProductCode = 'EST');
        
        Product2 prodRev = new Product2(Name = 'EDGE',
                                 CASFO_Product_Sales_Organisation__c = 'AT01',
                                 Family = 'Lubricants - Automotive');
        
        insert prodEst;
        insert prodRev;


        //Setup Sales User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'Castrol - Alpine FWS Sales'];

        User u = new User(Alias = 'TestUser', Email='TestUser@example.castrol.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestUser@example.castrol.com',
            Business_Unit__c = 'Lubricants - Automotive',   Sales_Organisation__c = 'AT01',
            UserRole = r);

        insert u;

        //Run as Sales User
        System.runAs(u) {
             Account acc = new Account(Name='Test acc');
        acc.RecordTypeId = [SELECT Id, SobjectType, Name 
            FROM RecordType WHERE Name =:'Customer'
            AND SobjectType =:'Account'  LIMIT 1].Id;

        insert acc;

            //Setup Opportunities
            Date d = Date.newInstance(2017, 1, 1);
            Opportunity oppo = new Opportunity (Name='Estimate', CloseDate=d,
                               	 StageName='Lead', AccountId=acc.Id,
                                 CurrencyIsoCode='USD', Supply_Start_Date__c=d);

            insert oppo;
            
            
            
            //Setup Revenues
            Revenue__c revEst = new Revenue__c(Opportunity__c = oppo.Id, Product__c = prodEst.Id,
                                          Type__c = 'New', CurrencyIsoCode = 'USD',
                                          Revenue__c = 1000, Margin__c = 1000,
                                          Volume__c = 1, Is_Estimate__c = 1, OEM__c = 'Ford');

            insert revEst;

            result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :oppo.Id];

            System.assertEquals(result.size(), 1, 'Ther should be only one Revenue and that is Estimate.');
            System.assertEquals(result[0].Product__r.ProductCode, 'EST', 'Ther should be only one Revenue and that is Estimate.');

            for(Integer i = 0; i < batchSize; i++) {
            	revenues.add(new Revenue__c(Opportunity__c = oppo.Id, Product__c = prodRev.Id,
                                          Type__c = 'New', CurrencyIsoCode = 'USD',
                                          Revenue__c = 10, Margin__c = 10,
                                          Volume__c = i, OEM__c = 'Ford'));
            }
            
            Test.startTest();
	            insert revenues;
           Test.stopTest();
            result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :oppo.Id];


        System.assertEquals(result.size(), batchSize, 'Ther should be ' + batchSize + ' revenues (Estimate should be deleted).');

        result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :oppo.Id
        	AND Product__r.ProductCode = :'EST'];

        System.assertEquals(result.size(), 0, 'Ther should not be any Estimates left.');
      }
    }
	}	
}