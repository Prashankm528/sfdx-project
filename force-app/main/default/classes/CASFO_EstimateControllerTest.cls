/************************************************************************************************************
* Description : Testing class for EstimateController.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-NOV-22   1.0                 Maros Zilka         Initial version - after insert only
* 2016-DEC-08   1.1                 Maros Zilka         Tests are performed as Sales User
* 2017-AUG-15   1.2                 Maros Zilka         Modifiy setup of testing data to use 
*                                                       new competitor object
* 2017-OCT-09   1.3                 Maros Zilka         Product field renamed
*                                                       from Product_Sales_Organisation__c
*                                                       to CASFO_Product_Sales_Organisation__c
*
*************************************************************************************************************/

@isTest 
public class CASFO_EstimateControllerTest {
    @testSetup static void setData() {
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
                Sales_Organisation__c = 'AT01',
                UserRole = r);

            insert u;
            
            //Run as Sales User
            System.runAs(u) {
                //Setup account
                Account acc = new Account(Name='Test acc');
                acc.RecordTypeId = [SELECT Id, SobjectType, Name 
                    FROM RecordType WHERE Name =:'Customer'
                    AND SobjectType =:'Account'  LIMIT 1].Id;

                insert acc;

                //Setup Opportunities
                Date d = Date.newInstance(2017, 1, 1);
                Opportunity oppoEst = new Opportunity (Name='Estimate', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id,
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);
                
                Opportunity oppoEmp = new Opportunity (Name='Empty', CloseDate=d,
                                   	 StageName='Lead', AccountId=acc.Id,
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);
                
                Opportunity oppoRev = new Opportunity (Name='Revenue', CloseDate=d,
                                   	 StageName='Lead', AccountId=acc.Id,
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);

                Opportunity oppoLead = new Opportunity (Name='Lead', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id,
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);

                Opportunity oppoImpl = new Opportunity (Name='Implementation', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id,
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);
                
                List<Opportunity> opportunityListForTest = new List<Opportunity>();
                opportunityListForTest.add(oppoEst);
                opportunityListForTest.add(oppoEmp);
                opportunityListForTest.add(oppoRev);
                opportunityListForTest.add(oppoLead);
                opportunityListForTest.add(oppoImpl);
                insert opportunityListForTest;

                Competitor__c competitor = new Competitor__c (Name = 'Competitor');

                insert competitor;

                Contact c = new Contact (
                    AccountId = acc.Id,
                    FirstName = 'Test',
                    LastName = 'Test'
                );

                insert c;

                Opportunity_Competitor__c opptyComp = new Opportunity_Competitor__c(
                    Competitor2__c = competitor.Id,
                    Main_Competitor__c = TRUE,
                    Opportunity__c = oppoImpl.Id
                );

                insert opptyComp;

                CASFO_Opportunity_Contact__c oppoContact = new CASFO_Opportunity_Contact__c(
                    CASFO_Contact__c = c.Id,
                    CASFO_Opportunity__c = oppoImpl.Id
                );

                insert oppoContact;

                oppoImpl.StageName = 'Implementation';
                oppoImpl.Attachment_Exists__c = TRUE;
                oppoImpl.Reason__c = 'Brand';
                oppoImpl.Reason_Detail__c = 'Brand-Ease';
                oppoImpl.Main_Competitor_Name__c = 'Test Brand';
                oppoImpl.Sales_Method__c = 'Spot';

                Revenue__c revImp = new Revenue__c(Opportunity__c = oppoImpl.Id, Product__c = prodRev.Id,
                    Type__c = 'New', CurrencyIsoCode = 'USD',
                    Revenue__c = 1000, Margin__c = 1000,
                    Volume__c = 1);
                
                //Setup Revenues
                Revenue__c revEst = new Revenue__c(Opportunity__c = oppoEst.Id, Product__c = prodEst.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, Is_Estimate__c = 1);
                
                Revenue__c revRev = new Revenue__c(Opportunity__c = oppoRev.Id, Product__c = prodRev.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1);

                List<Revenue__c> revenueListForTest = new List<Revenue__c>();
                revenueListForTest.add(revImp);
                revenueListForTest.add(revEst);
                revenueListForTest.add(revRev);
                insert revenueListForTest;
                
                upsert oppoImpl;
            }
        }
	}

    /************************************************************************
    * getStage_Lead Test
    * ------------------------
    * Method should return TRUE as when opportunity is in LEAD stage.  
    ************************************************************************/
    @isTest static void getStage_Lead() {     
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Lead'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getStage(o.Id);
            Test.stopTest();
        }
        
        System.assert(result == true, 'Opportunity is in LEAD return value should be TRUE.');
    }



    /************************************************************************
    * getStage_Lead Test
    * ------------------------
    * Method should return TRUE as when opportunity is in LEAD stage.  
    ************************************************************************/
    @isTest static void getStage_Implementation() {     
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Implementation'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getStage(o.Id);
            Test.stopTest();
        }
        
        System.assert(result == false, 'Opportunity is in IMPLEMENTATION return value should be FALSE.');
    }

    /************************************************************************
    * getEstimate_Empty Test
    * ------------------------
    * Method should return null if there is no Estimate on Opportunity  
    ************************************************************************/
    @isTest static void getEstimate_Empty() {     
        Revenue__c result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Empty'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getEstimate(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result, null, 'On empty Opportunity method should return null.');
    }

    /************************************************************************
    * getEstimate_Estimate Test
    * ------------------------
    * Method should return Estimate Revenue if it is set on Opportunity.   
    ************************************************************************/
    @isTest static void getEstimate_Estimate() {     
        Revenue__c result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Estimate'];
        Revenue__c r =  [SELECT Id, Name FROM Revenue__c WHERE Opportunity__r.Id = :o.Id];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getEstimate(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result.Id, r.Id, 'Estimate should be returned.');
    }
    
    /************************************************************************
    * getOpportunity Test
    * ------------------------
    * Method should successfully return opportunity with name.   
    ************************************************************************/
    @isTest static void getOpportunity() {     
        Opportunity result;
        Opportunity o = [SELECT Id, Name FROM Opportunity LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getOpportunity(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result, o, 'getOpportunity should return correct opportunity by ID.');
    }

    /************************************************************************
    * getOpportunity Test
    * ------------------------
    * Method should successfully return opportunity with name.   
    ************************************************************************/
    @isTest static void getCommit() {     
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Estimate' LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.getCommit(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result, false, 'getOpportunity should return correct opportunity by ID.');
    }

    /************************************************************************
    * hasRevenues_noRevenues Test
    * ------------------------
    * Method should return false if there are no Revenues.   
    ************************************************************************/
    @isTest static void hasRevenues_noRevenues() {
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Empty'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.hasRevenues(o.Id);
            Test.stopTest();
        }
        
        System.assert(result == false, 'When passed opportunity without Revenues it should return false.');
    }

    /************************************************************************
    * hasRevenues_withRevenues Test
    * ------------------------
    * Method should return true if there are Revenues.   
    ************************************************************************/    
    @isTest static void hasRevenues_withRevenues() {
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Revenue'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.hasRevenues(o.Id);
            Test.stopTest();
        }
        
        System.assert(result == true, 'When passed opportunity with Revenues (Not counting estimate) it should return true.');
    }
    
    /************************************************************************
    * hasRevenues_withEstimate Test
    * ------------------------
    * Method should return false if there is only Estimate.   
    ************************************************************************/
    @isTest static void hasRevenues_withEstimate() {
        Boolean result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Estimate'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_EstimateController.hasRevenues(o.Id);
            Test.stopTest();
        }
        
        System.assert(result == false, 'When passed opportunity with estimate it should return false.');
    }
    
    /************************************************************************
    * saveEstimate_noRevenues Test
    * ------------------------
    * Method should create Estimate   
    ************************************************************************/
    @isTest static void saveEstimate_noRevenues() {
        List<Revenue__c> result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Empty'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];

        System.runAs(u) {
            Test.startTest();
            CASFO_EstimateController.saveEstimate(o.Id, 'New', 1000, 1000, 1);
            Test.stopTest();
        }
        
        result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :o.Id];
        System.assert(result.size() == 1, 'When there is no estimate product method should not create any new revenue.');
        System.assertEquals('EST', result[0].Product__r.ProductCode, 'Only revenue should be Estimate Revenue.');
    }
    
    /************************************************************************
    * saveEstimate_hasEstimate Test
    * ------------------------
    * Method should create Estimate   
    ************************************************************************/
    @isTest static void saveEstimate_hasEstimate() {
        List<Revenue__c> result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Estimate'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            CASFO_EstimateController.saveEstimate(o.Id, 'New', 1000, 1000, 1);
            Test.stopTest();
        }
        
        result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :o.Id];
        System.assert(result.size() == 1, 'When there is no estimate product method should not create any new revenue.');
        System.assertEquals('EST', result[0].Product__r.ProductCode, 'Only revenue should be Estimate Revenue.');
    }
    
    /************************************************************************
    * saveEstimate_hasRevenue Test
    * ------------------------
    * Method should create Estimate   
    ************************************************************************/
    @isTest static void saveEstimate_hasRevenue() {
        List<Revenue__c> result;
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Revenue'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        System.runAs(u) {
            Test.startTest();
            CASFO_EstimateController.saveEstimate(o.Id, 'New', 1000, 1000, 1);
            Test.stopTest();
        }
        
        result = [SELECT Id, Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :o.Id];
        System.assert(result.size() == 1, 'When there is no estimate product method should not create any new revenue.');
        System.assertEquals('EST', result[0].Product__r.ProductCode, 'Only revenue should be Estimate Revenue.');
    }
    
    /************************************************************************
    * saveEstimate without estimate product Test
    * ------------------------
    * Methof should fail as there is no EST product.
    ************************************************************************/
    
    @isTest static void saveEstimate_no_est_product() {
        String result;
        Product2 estProduct = [SELECT Id FROM Product2 WHERE ProductCode = :'EST' LIMIT 1];
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = :'Revenue'];
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        
        delete estProduct;

        System.runAs(u) {
        	result = CASFO_EstimateController.saveEstimate(o.Id, 'New', 1000, 1000, 1);
        }
        
        System.assertEquals(result, 'Initial estimate Product does not exist. Could not create Estimate.', 'No values returned for OEM picklist');
    }
}