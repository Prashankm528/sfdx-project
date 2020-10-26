/************************************************************************************************************
* Description : Testing class for trgOpportunityInactiveProduct.trigger
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-07   1.0                 Maros Zilka         Initial version
* 2016-DEC-09   1.1                 Grant Whitfield     Updated to limit SOQL query on FeedItems
*************************************************************************************************************/

@isTest
public class CASFO_ProductInactiveProductTest {
    static void setData() {
        Integer batchSize = 400;
    
        //Run as system admin
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = 'Castrol - Alpine FWS Sales'];

            //Setup Sales User
            User u = new User(Alias = 'TestUser', Email='TestUser@example.castrol.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='TestUser@example.castrol.com',
                Business_Unit__c = 'Lubricants - Automotive',   Sales_Organisation__c = 'AT01',
                UserRole = r);

            insert u;

            //Setup Inactive Product
            List<Product2> products = new List<Product2>();

            for (Integer i = 0; i < batchSize; i++) {
                products.add(
                    new Product2(
                        Name = 'Test Product ' + i, IsActive = TRUE, Family = 'Lubricants - Automotive',
                        CASFO_Product_Sales_Organisation__c = 'AT01'
                    )
                );
            }
            
            insert products;
            
            //Run as Sales User
            System.runAs(u) {
                Account acc = new Account(Name='Test acc');
                acc.RecordTypeId = [SELECT Id, SobjectType, Name 
                    FROM RecordType WHERE Name = 'Customer'
                    AND SobjectType = 'Account'  LIMIT 1].Id;
                acc.AccountNumber = '123456';

                insert acc;

                //Setup Opportunities
                Date d = Date.newInstance(2017, 1, 1);

                Opportunity opportunity = new Opportunity(
                            Name='Test Trigger Oppty ', CloseDate=d,
                            StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                            CurrencyIsoCode='USD', Supply_Start_Date__c=d
                );

                insert opportunity;

                insert new Revenue__c(
                    Opportunity__c = opportunity.Id, Product__c = products[0].Id,
                    Type__c = 'New', CurrencyIsoCode = 'USD',
                    Revenue__c = 1000, Margin__c = 1000,
                    Volume__c = 1, OEM__c = 'Ford'
                );
            }
        }
    }

    /********************************************************************
    * inactiveProduct
    * ------------------------
    * Method to test sending chatter feed when opportunity is moved from
    * closed stage to open and has inactive product.
    ********************************************************************/

    //SeeAllData needed when sending chatter feed...
    @isTest(SeeAllData=true)
    static void inactiveProduct() {
        //@testSetup anotation is not allowed when using SeeAllData=true
        setData();

        List<Product2> products = [SELECT Id FROM Product2 WHERE Name LIKE 'Test Product%'];

        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Name LIKE 'Test Trigger Oppty%'];

        List<FeedItem> oldFeedItems = [SELECT Id FROM FeedItem WHERE ParentID IN :opportunities];

        Test.startTest();
        for (Product2 p : products) {
            p.IsActive = FALSE;
        }

        upsert products;    
        Test.stopTest();

        List<FeedItem> newFeedItems = [SELECT Id FROM FeedItem WHERE ParentID IN :opportunities];

        System.assert(newFeedItems.size() > oldFeedItems.size(), 'There should be new chatter feeds.');
    }
}