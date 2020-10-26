/************************************************************************************************************
* Description : Testing class for CASFO_InactiveProductWarningController
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-01   1.0                 Maros Zilka         Initial version
* 2016-DEC-07   1.1                 Maros Zilka         Modified to test multiple inactive products
* 2016-DEC-08   1.2                 Maros Zilka         Added test for visualforce extended controller for
*                                                       SF1 mobile card.
* 2017-AUG-15   1.3                 Maros Zilka         Modifiy setup of testing data to use 
*                                                       new competitor object
* 2017-OCT-09   1.4                 Maros Zilka         Product field renamed
*                                                       from Product_Sales_Organisation__c
*                                                       to CASFO_Product_Sales_Organisation__c
*
*************************************************************************************************************/

//@isTest
public with sharing class CASFO_InactiveProductWarningControllerT {
/*     @testSetup static void setData() {
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

            //Setup Products
            Product2 prodActive = new Product2(Name = 'Active', IsActive = TRUE, Family = 'Lubricants - Automotive',
                CASFO_Product_Sales_Organisation__c = 'AT01');
            
            Product2 prodInactive1 = new Product2(Name = 'Inactive1', IsActive = FALSE, Family = 'Lubricants - Automotive',
                CASFO_Product_Sales_Organisation__c = 'AT01');

            Product2 prodInactive2 = new Product2(Name = 'Inactive2', IsActive = FALSE, Family = 'Lubricants - Automotive',
                CASFO_Product_Sales_Organisation__c = 'AT01');
            
            //insert prodActive;
            //insert prodInactive1;
            //insert prodInactive2;

            List<Product2> productListForTest = new List<Product2>();
            productListForTest.add(prodActive);
            productListForTest.add(prodInactive1);
            productListForTest.add(prodInactive2);
            insert productListForTest;
            
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
                Opportunity opptyClosedInactive = new Opportunity (Name='ClosedInactive', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);
                
                Opportunity opptyClosedActive = new Opportunity (Name='ClosedActive', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);
                
                Opportunity opptyOpenInactive = new Opportunity (Name='OpenInactive', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);

                Opportunity opptyOpenActive = new Opportunity (Name='OpenActive', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);

                Opportunity opptyMultiInactive = new Opportunity (Name='OpenMultiInactive', CloseDate=d,
                                     StageName='Lead', AccountId=acc.Id, Sales_Method__c = 'Spot',
                                     CurrencyIsoCode='USD', Supply_Start_Date__c=d);

                //insert opptyClosedInactive;
                //insert opptyClosedActive;
                //insert opptyOpenInactive;
                //insert opptyOpenActive;
                //insert opptyMultiInactive;

                List<Opportunity> opportunityListForTest = new List<Opportunity>();
                opportunityListForTest.add(opptyClosedInactive);
                opportunityListForTest.add(opptyClosedActive);
                opportunityListForTest.add(opptyOpenInactive);
                opportunityListForTest.add(opptyOpenActive);
                opportunityListForTest.add(opptyMultiInactive);
                insert opportunityListForTest;                

                Opportunity_Competitor__c opptyComp = new Opportunity_Competitor__c(
                    Competitor2__c = competitor.Id,
                    Main_Competitor__c = TRUE,
                    Opportunity__c = opptyClosedActive.Id
                );

                //insert opptyComp;

                Opportunity_Competitor__c opptyInactiveComp = new Opportunity_Competitor__c(
                    Competitor2__c = competitor.Id,
                    Main_Competitor__c = TRUE,
                    Opportunity__c = opptyClosedInactive.Id
                );

                //insert opptyInactiveComp;

                List<Opportunity_Competitor__c> opportunityCompetitorList = new List<Opportunity_Competitor__c>();
                opportunityCompetitorList.add(opptyComp);
                opportunityCompetitorList.add(opptyInactiveComp);
                insert opportunityCompetitorList;

                CASFO_Opportunity_Contact__c oppoContact = new CASFO_Opportunity_Contact__c(
                    CASFO_Contact__c = c.Id,
                    
                    CASFO_Opportunity__c = opptyClosedActive.Id
                );

                //insert oppoContact;

                CASFO_Opportunity_Contact__c oppoInactiveContact = new CASFO_Opportunity_Contact__c(
                    CASFO_Contact__c = c.Id,
                    
                    CASFO_Opportunity__c = opptyClosedInactive.Id
                );

                //insert oppoInactiveContact;

                List<CASFO_Opportunity_Contact__c> opportunityContactList = new List<CASFO_Opportunity_Contact__c>();
                opportunityContactList.add(oppoContact);
                opportunityContactList.add(oppoInactiveContact);
                insert opportunityContactList;

                //Setup Revenues
                List<Revenue__c> revenues = new List<Revenue__c>();

                Revenue__c revClosedActive = new Revenue__c(Opportunity__c = opptyClosedActive.Id, Product__c = prodActive.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revClosedActive);
                
                Revenue__c revClosedInactive = new Revenue__c(Opportunity__c = opptyClosedInactive.Id, Product__c = prodInactive1.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revClosedInactive);


                Revenue__c revOpenActive = new Revenue__c(Opportunity__c = opptyOpenActive.Id, Product__c = prodActive.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revOpenActive);


                Revenue__c revOpenInactive = new Revenue__c(Opportunity__c = opptyOpenInactive.Id, Product__c = prodInactive1.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revOpenInactive);


                Revenue__c revMultiInactive1 = new Revenue__c(Opportunity__c = opptyMultiInactive.Id, Product__c = prodInactive1.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revMultiInactive1);

                Revenue__c revMultiInactive2 = new Revenue__c(Opportunity__c = opptyMultiInactive.Id, Product__c = prodInactive1.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revMultiInactive2);

                Revenue__c revMultiInactive3 = new Revenue__c(Opportunity__c = opptyMultiInactive.Id, Product__c = prodInactive2.Id,
                                              Type__c = 'New', CurrencyIsoCode = 'USD',
                                              Revenue__c = 1000, Margin__c = 1000,
                                              Volume__c = 1, OEM__c = 'Ford');
                revenues.add(revMultiInactive3);
                
                insert revenues;

                List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();
                
                //Move to Closed stage
                opptyClosedActive.StageName = 'Closed - Won';
                opptyClosedActive.Reason__c = 'Brand';
                opptyClosedActive.Reason_Detail__c = 'Brand-Ease';
                opptyClosedActive.Attachment_Exists__c = TRUE;
                opptyClosedActive.Main_Competitor_Name__c = 'Test Brand';
                
                //upsert opptyClosedActive;

                opptyClosedInactive.StageName = 'Closed - Won';
                opptyClosedInactive.Reason__c = 'Brand';
                opptyClosedInactive.Reason_Detail__c = 'Brand-Ease';
                opptyClosedInactive.Attachment_Exists__c = TRUE;
                opptyClosedInactive.Main_Competitor_Name__c = 'Test Brand';
                
                //upsert opptyClosedInactive;

                opportunitiesToUpsert.add(opptyClosedActive);
                opportunitiesToUpsert.add(opptyClosedInactive);

                upsert opportunitiesToUpsert;
            }
        }
    }

    /********************************************************************
    * showWarning_OpenActive
    * ------------------------
    * Method to test on opportunity in open stage with active product.
    * This return null as we do not want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void showWarning_OpenActive() {
        List<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenActive'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_InactiveProductWarningController.showWarning(o.Id);
            Test.stopTest();
        }

        System.assertEquals(result.size(), 0, 'Opportunity is in Lead stage and has only active product. Returned list should be empty.');
    }

    /********************************************************************
    * showWarning_OpenInactive
    * ------------------------
    * Method to test on opportunity in open stage with inactive product.
    * This return product name as we want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void showWarning_OpenInactive() {     
        List<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenInactive'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_InactiveProductWarningController.showWarning(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result.size(), 1,
            'Opportunity is in Lead stage and has one inactive product. List size should be equal to one.');
        System.assertEquals(result.get(0), 'Inactive1',
            'Opportunity is in Lead stage and has inactive product. Return value should be name of product (Inactive).');
    }

    /********************************************************************
    * showWarning_ClosedActive
    * ------------------------
    * Method to test on opportunity in closed stage with active product.
    * This return null as we do not want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void showWarning_ClosedActive() {     
        List<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'ClosedActive'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_InactiveProductWarningController.showWarning(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result.size(), 0, 'Opportunity is in Lead stage and has only active product. Returned list should be empty.');
    }

    /********************************************************************
    * showWarning_ClosedInactive
    * ------------------------
    * Method to test on opportunity in closed stage with inactive product.
    * This return null as we do not want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void showWarning_ClosedInactive() {     
        List<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'ClosedInactive'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_InactiveProductWarningController.showWarning(o.Id);
            Test.stopTest();
        }
        
        System.assertEquals(result.size(), 0, 'Opportunity is in Lead stage and has only active product. Returned list should be empty.');
    }

    /********************************************************************
    * showWarning_ClosedInactive
    * ------------------------
    * Method to test on opportunity in closed stage with inactive product.
    * This return null as we do not want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void showWarning_MultiInactive() {     
        List<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenMultiInactive'];
        
        System.runAs(u) {
            Test.startTest();
            result = CASFO_InactiveProductWarningController.showWarning(o.Id);
            Test.stopTest();
        }

        System.assertEquals(result.size(), 2,
            'Opportunity is in Lead stage and has two unique inactive product. Returned list size should be equal to two.');
    }
    
    /********************************************************************
    * getShow_NoInactive
    * ------------------------
    * Method to test on opportunity in open stage with active product.
    * This return false as we do not want to display warning in that case.
    ********************************************************************/
/*
    @isTest static void getShow_NoInactive() {     
        Boolean result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenActive'];
        
        ApexPages.StandardController stdOppty = new ApexPages.StandardController(o);
        CASFO_InactiveProductWarningController inactiveProductWarningController = new CASFO_InactiveProductWarningController(stdOppty);
        
        System.runAs(u) {
            Test.startTest();
            result = inactiveProductWarningController.getShow();
            Test.stopTest();
        }

        System.assertEquals(result, false,
            'Opportunity is in Lead stage and has inactive product. Returned value should be equal to false.');
    }
    
    /********************************************************************
    * getShow_Inactive
    * ------------------------
    * Method to test on opportunity in open stage with inactive product.
    * This return true as we do want to display warning in this case.
    ********************************************************************/
/*
    @isTest static void getShow_Inactive() {     
        Boolean result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenInactive'];
        
        ApexPages.StandardController stdOppty = new ApexPages.StandardController(o);
        CASFO_InactiveProductWarningController inactiveProductWarningController = new CASFO_InactiveProductWarningController(stdOppty);
        
        System.runAs(u) {
            Test.startTest();
            result = inactiveProductWarningController.getShow();
            Test.stopTest();
        }

        System.assertEquals(result, true,
            'Opportunity is in Lead stage and has inactive product. Returned value should be equal to true.');
    }
    
    /********************************************************************
    * getInactiveProducts
    * ------------------------
    * Method to test on opportunity in open stage with inactive products.
    * This return list (set) of inactive product names.
    ********************************************************************/
/*
    @isTest static void getInactiveProducts() {     
        Set<String> result;
        User u = [SELECT Id FROM User WHERE Alias = 'TestUser'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'OpenMultiInactive'];
        
        ApexPages.StandardController stdOppty = new ApexPages.StandardController(o);
        CASFO_InactiveProductWarningController inactiveProductWarningController = new CASFO_InactiveProductWarningController(stdOppty);
        
        System.runAs(u) {
            Test.startTest();
            result = inactiveProductWarningController.getInactiveProducts();
            Test.stopTest();
        }

        System.assertEquals(result.size(), 2,
            'Opportunity is in Lead stage and has inactive products. Returned value should be equal to 2.');
    } */
}