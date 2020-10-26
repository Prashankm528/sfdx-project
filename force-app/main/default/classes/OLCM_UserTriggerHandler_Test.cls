/*
* @author Satyam
* @company Tata Consultancy Services
* @date 3/02/2019
* @group Fuels
* @description      Test class for OLCM_UserTriggerHandler
*/

@isTest
public with sharing class OLCM_UserTriggerHandler_Test {
    @isTest
    public static void test1(){
        Set<Id> userIds=new Set<Id> ();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            // Insert account as current user
            
            UserRole r = new UserRole(DeveloperName = 'OLCM_DE_SALES_Sat', Name = 'Fuel - BEk Sales Manager');
            insert r;                                                                
            
            system.debug('userrolename'+r.name+'id'+r.id);
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'BPG_BP Base Platform'].Id,
                LastName = 'Fuell',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com'+'satyam',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'tfuel',
                TimeZoneSidKey = 'Europe/London',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_GB',
                FirstName = 'test1',
                UserRoleId = r.Id,
                LocaleSidKey='en_GB',
                CurrencyIsoCode ='USD',
                CommunityNickname   ='testFuel1',
                City    ='ramtirath'
            );
            insert u;
            Account a=new Account (name = 'testname1', Marked_for_Deletion__c=True,
                                   BillingCity ='TestCity1', BillingCountry ='Belgium', OLCM_Sales_Organisation_Description__c='BE01',
                                   BillingStreet ='TestStreet1', BillingPostalCode ='t3stcd3',OLCM_Sales_Division_Description__c='01',
                                   OLCM_Distribution_Channel_Description__c='12');
            insert a;
            
            system.debug('usertest'+u.OLCM_Country_Code__c+'id'+u.UserRoleId);
            userIds.add(u.id);
        }
        
        OLCM_UserTriggerHandler.handleAfterInsertUpdate(userIds);
        system.assertEquals(1, userIds.size(), 'userid set value is 1');
        
    }
}