/**************************************************************************************************************************************
* Description : Testing class for Opportunity Channel Process Builder + Opportunity Channel Flow + SFO_Opportunity_Channel__mdt mapping
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2019-JUNE-27   1.0                Adam Janicko        Initial version
*
* 2020-Apr-08   2.0                 Jit Patel           Added role to excluded  
***************************************************************************************************************************************/

@isTest
public class SFO_OpportunityChannelTest {
    @isTest
    static void flowTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole roleToCheck = [SELECT Id, Name FROM UserRole WHERE Name = 'Castrol - Africa Direct Assets Manager'];
        Date today = system.today();
        
        User user = new User(Alias = 'test', Email='test@example.castrol.com', 
                        EmailEncodingKey='UTF-8', LastName='test', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='test@example.castrol.com',
                        UserRoleId = roleToCheck.Id);
        insert user;
        
       	Account acc;
        System.runAs(user) {
            acc = new Account(Name='Test acc');
            acc.RecordTypeId = [SELECT Id, SobjectType, DeveloperName 
                                FROM RecordType WHERE DeveloperName = 'Prospect'
                                AND SobjectType = 'Account' LIMIT 1].Id;
            acc.AccountNumber = '123456';
            insert acc;
        }
        
        //create Opportunity and check if channel got populated
        Opportunity oppo;
        System.runAs(user) {
            oppo = new Opportunity(Name='Test Trigger Oppty ', CloseDate=today, StageName='Lead', AccountId=acc.Id, CurrencyIsoCode='USD', Supply_Start_Date__c=today);
            oppo.RecordTypeId = [SELECT Id, SobjectType, Name 
                                FROM RecordType WHERE DeveloperName = 'General'
                                AND SobjectType = 'Opportunity' LIMIT 1].Id;
            insert oppo;
        }
        
        Opportunity updatedOppo = [SELECT Channel__c FROM Opportunity WHERE Id = :oppo.Id];
        System.assert(updatedOppo.Channel__c != null, 'Channel was not populated on Opportunity as it should have been');
    }
    
    @isTest
    static void metadataMappingTest() {
        Set<String> rolesToExclude = new Set<String>();
        rolesToExclude.add('Castrol - GBS User');
        rolesToExclude.add('Castrol - SFO');
        rolesToExclude.add('Castrol - EU Sales Director');
        rolesToExclude.add('Castrol - EU, Turkey & Central Asia Sales Director');
        rolesToExclude.add('Castrol - Belarus Distributor DBM');
        rolesToExclude.add('Castrol - Identity Provider Support Admin');
        rolesToExclude.add('Castrol - North Europe Technical Engineer');
        rolesToExclude.add('Castrol - Romania A&I Distributor Sales');
        rolesToExclude.add('Castrol - Romania FWS Sales');
        rolesToExclude.add('Castrol - Romania Industrial Sales/Tech Engineer');
        rolesToExclude.add('Castrol - South Europe Cluster Sales Director');
        rolesToExclude.add('Castrol - South Europe Technical Engineer');
        rolesToExclude.add('Castrol - Turkey Support');
        rolesToExclude.add('Castrol - Turkey Technical Engineer');
        rolesToExclude.add('Castrol - UCA Distributor Business Manager');
        rolesToExclude.add('Castrol - UCA Sales Manager');
        rolesToExclude.add('Castrol - UK & IR & Nordics Industrial Technical Engineer');
        rolesToExclude.add('Castrol - UK & IR CMS Contract Manager');
        rolesToExclude.add('Castrol - UK & IR Industrial CMS Operations Manager');
        rolesToExclude.add('Castrol - Africa Marketing & Competitive Intelligence Manager');
        rolesToExclude.add('Castrol - Africa OpEx Manager');
        rolesToExclude.add('Castrol - Africa SA Sales Manager');
        rolesToExclude.add('Castrol - Africa Sales Director');
        rolesToExclude.add('Castrol - Australia Automotive Sales Agent North');
        rolesToExclude.add('Castrol - Australia Automotive Sales Agent South');
        rolesToExclude.add('Castrol - Australia Automotive Sales Agent West');
        rolesToExclude.add('Castrol - Australia National Key Account Manager Automotive');
        rolesToExclude.add('Castrol - Australia National Sales Manager Automotive');
        rolesToExclude.add('Castrol - Australia National Sales Manager Retail');
        rolesToExclude.add('Castrol - Australia NKAM Retail & Automotive');
        rolesToExclude.add('Castrol - Australia Regional Sales Manager Automotive North');
        rolesToExclude.add('Castrol - Australia Regional Sales Manager Automotive South');
        rolesToExclude.add('Castrol - Australia Regional Sales Manager Automotive West');
        rolesToExclude.add('Castrol - Australia Retail Sales & Support Manager');
        rolesToExclude.add('Castrol - Australia Retail Sales Agent');
        rolesToExclude.add('Castrol - Australia & New Zealand Sales Director');
        rolesToExclude.add('Castrol - Australia Support Manager');
        rolesToExclude.add('Castrol - Iberia & Italy A&I Distributor Sales Manager');
        rolesToExclude.add('Castrol - Regional Vice President Europe & Africa');
        rolesToExclude.add('Castrol - Russia & Belarus Country Leadership Lead');
        rolesToExclude.add('Castrol - Russia CVO/Industrial Sales');
        rolesToExclude.add('Castrol - Russia CVO/Industrial Sales Manager');
        rolesToExclude.add('Castrol - South Cluster Automotive Business Development Manager');
        // US Roles
        rolesToExclude.add('Castrol - Canada Indirect Sales Manager');
        rolesToExclude.add('Castrol - US & Canada VP');
        rolesToExclude.add('Castrol - US Direct & Indirect Sales Director');

        rolesToExclude.add('Castrol - US Industrial CMS Sales');
        rolesToExclude.add('Castrol - US Industrial CMS Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Eng and Prod Sales');

        rolesToExclude.add('Castrol - US Industrial Sales');
        rolesToExclude.add('Castrol - US Industrial Sales Director');
        rolesToExclude.add('Castrol - US Industrial Sales Manager');

        rolesToExclude.add('Castrol - GME Regional Sales Director'); 
        rolesToExclude.add('Castrol - GME Sales Ops Executive');

        rolesToExclude.add('Castrol - US HD National Accounts Sales Manager');
        rolesToExclude.add('Castrol - US HD National Accounts Sales');

        rolesToExclude.add('Castrol - US Industrial Wind Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Wind Sales');  
       
        rolesToExclude.add('Castrol - US Industrial Elevators & Escalators Sales');
        
        rolesToExclude.add('Castrol - US Industrial Lubecon Southeast Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Lubecon Southeast Sales');  

        rolesToExclude.add('Castrol - US Industrial Lubecon West Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Lubecon West Sales'); 

        rolesToExclude.add('Castrol - US Industrial Lubecon Northeast Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Lubecon Northeast Sales');  

        rolesToExclude.add('Castrol - US Industrial Indirect Southeast Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Indirect Southeast Sales');  

        rolesToExclude.add('Castrol - US Industrial Indirect West Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Indirect West Sales'); 

        rolesToExclude.add('Castrol - US Industrial Indirect Northeast Sales Manager');
        rolesToExclude.add('Castrol - US Industrial Indirect Northeast Sales'); 

        rolesToExclude.add('Castrol - India - Industrial & HD Sales Manager'); 
        rolesToExclude.add('Castrol - India - GM Heavy Duty'); 
        rolesToExclude.add('Castrol - India - Heavy Duty Regional Manager'); 
        rolesToExclude.add('Castrol - India - Heavy Duty KAM'); 
        rolesToExclude.add('Castrol - India - GM Industrial'); 
        rolesToExclude.add('Castrol - India - Industrial Regional Managers'); 
        rolesToExclude.add('Castrol - India - Industrial KAM'); 

        rolesToExclude.add('Castrol - Thailand Country Sales Director'); 
        rolesToExclude.add('Castrol - Thailand Sales Operation Manager');         
        rolesToExclude.add('Castrol - Thailand Sales Channel Sales Manager - Branded Workshop'); 
        rolesToExclude.add('Castrol - Thailand Sales Channel Sales Manager - CVO'); 
        rolesToExclude.add('Castrol - Thailand Sales Channel Sales Manager - Distributor'); 
        rolesToExclude.add('Castrol - Thailand Sales Channel Sales Manager - Industrial'); 
        rolesToExclude.add('Castrol - Thailand Sales Channel Sales Manager - OEM'); 
        rolesToExclude.add('Castrol - Thailand Business Development Manager - Industrial'); 
        rolesToExclude.add('Castrol - Thailand Sales - Industrial'); 

        Test.startTest();
        List<UserRole> rolesToCheck = [SELECT Name 
                                       FROM UserRole 
                                       WHERE Name LIKE 'Castrol%' AND (NOT Name LIKE '%CX%') AND (NOT Name LIKE '%China%') 
                                       AND (Name LIKE '%Castrol_US_Direct%') AND (Name LIKE '%Castrol_US_Indirect%')
                                       AND Name NOT IN :rolesToExclude ORDER BY Name];
        List<SFO_Channel_Mapping__mdt> mappedRoles = [SELECT Role_Name__c FROM SFO_Channel_Mapping__mdt ORDER BY Role_Name__c];
        Test.stopTest();
        
        Set<String> mappedRoleNames = new Set<String>();
        for(SFO_Channel_Mapping__mdt mappedRole : mappedRoles) {
            mappedRoleNames.add(mappedRole.Role_Name__c);
        }
        
        Set<String> missingRoles = new Set<String>();
        for(UserRole roleToCheck : rolesToCheck) {
            if(!mappedRoleNames.contains(roleToCheck.Name)) {
                missingRoles.add(roleToCheck.Name);
                System.debug('Missing role: ' + roleToCheck.Name);
            }
        }
        System.assert(missingRoles.isEmpty(), 'These roles are not mapped nor excluded' + missingRoles);

    }
}