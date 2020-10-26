/************************************************************************************************************
* Description : Testing class for trgOpportunityInactiveProduct.trigger
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-07   1.0                 Maros Zilka         Initial version
* 2016-DEC-09   1.1                 Grant Whitfield     Limiting SOQL query to avoid governance limits
* 2017-AUG-15   1.2                 Maros Zilka         Modifiy setup of testing data to use 
*                                                       new competitor object
* 2017-OCT-09   1.3                 Maros Zilka         Product field renamed
*                                                       from Product_Sales_Organisation__c
*                                                       to CASFO_Product_Sales_Organisation__c
*
*************************************************************************************************************/

//@isTest
public class CASFO_OpportunityInactiveProductTest {
  /*  static void setData() {
        Integer batchSize = 1;
    
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
                Sales_Organisation__c = 'AT01',
                UserRole = r);

            insert u;

            //Setup Inactive Product
            
            Product2 inactiveProduct = new Product2(Name = 'inactiveProduct', IsActive = FALSE, Family = 'Lubricants - Automotive',
                CASFO_Product_Sales_Organisation__c = 'AT01');
            
            insert inactiveProduct;
            
            //Run as Sales User
            System.runAs(u) {
                Account acc = new Account(Name='Test acc');
                acc.RecordTypeId = [SELECT Id, SobjectType, Name 
                    FROM RecordType WHERE Name = 'Customer'
                    AND SobjectType = 'Account'  LIMIT 1].Id;
                acc.AccountNumber = '123456';

                insert acc;

                Competitor__c competitor = new Competitor__c (Name = 'Competitor');

                insert competitor;

                Contact c = new Contact (
                    AccountId = acc.Id,
                    FirstName = 'Test',
                    LastName = 'Test'
                );

                insert c;

                //Setup Opportunities
                Date d = Date.newInstance(2017, 1, 1);
                List<Opportunity> opportunities = new List<Opportunity>();
                List<Opportunity_Competitor__c> opptyCompetitors = new List<Opportunity_Competitor__c>();
                List<CASFO_Opportunity_Contact__c> opptyContacts = new List<CASFO_Opportunity_Contact__c>();
                List<Revenue__c> revenues = new List<Revenue__c>();
                
                for(Integer i = 0; i < batchSize; i++) {
                    opportunities.add(
                        new Opportunity(
                            Name='Test Trigger Oppty ' + i, CloseDate=d,
                            StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                            CurrencyIsoCode='USD', Supply_Start_Date__c=d
                        )
                    );
                }
                
                insert opportunities;
                
                for (Opportunity o : opportunities) {
                    opptyCompetitors.add(
                         new Opportunity_Competitor__c(
                            Competitor2__c = competitor.Id,
                            Main_Competitor__c = TRUE,
                            Opportunity__c = o.Id
                        )
                    );
                    
                    opptyContacts.add(
                        new CASFO_Opportunity_Contact__c(
                            CASFO_Contact__c = c.Id,
                            CASFO_Opportunity__c = o.Id
                        )
                    );
                    
                    revenues.add(
                        new Revenue__c(
                            Opportunity__c = o.Id, Product__c = inactiveProduct.Id,
                            Type__c = 'New', CurrencyIsoCode = 'USD',
                            Revenue__c = 1000, Margin__c = 1000,
                            Volume__c = 1, OEM__c = 'Ford'
                        )
                    );
                }
                
                insert opptyCompetitors;
                insert opptyContacts;
                insert revenues;

                for (Opportunity o : opportunities) {
                    o.StageName = 'Closed - Won';
                    o.Reason__c = 'Brand';
                    o.Reason_Detail__c = 'Brand-Ease';
                    o.Attachment_Exists__c = TRUE;
                    o.Main_Competitor_Name__c = 'Test Brand';
                }

                upsert opportunities;
            }
        }
    }

    /********************************************************************
    * inactiveProduct
    * ------------------------
    * Method to test sending chatter feed when opportunity is moved from
    * closed stage to open and has inactive product.
    ********************************************************************/
/*
    //SeeAllData needed when sending chatter feed...
    @isTest(SeeAllData=true)
    static void inactiveProduct() {
        //@testSetup anotation is not allowed when using SeeAllData=true    
        setData();
        
        List<FeedItem> oldFeedItems = new List<FeedItem>();

        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Name LIKE 'Test Trigger Oppty%'];
        oldFeedItems = [SELECT Id FROM FeedItem WHERE ParentId IN :opportunities];

        Test.startTest();
        System.runAs(u) {
            for (Opportunity o : opportunities) {
                o.StageName = 'Lead';
            }
                    
            upsert opportunities;    
        }
                
        Test.stopTest();

        List<FeedItem> newFeedItems = [SELECT Id FROM FeedItem WHERE ParentId IN :opportunities];

        System.assert(newFeedItems.size() > oldFeedItems.size(), 'There should be new chatter feeds.');
    }
    */
}