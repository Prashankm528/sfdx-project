/***************************************************************************************************
* Description : Unit Tests for CASFO_SetOwnerOfAccount process builder and flow
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-FEB-21   1.0                 Maros Zilka     	Initial version
*
***************************************************************************************************/

@isTest
private class CASFO_SetOwnerOfAccountTest {
    
    @testSetup static void setup() {
        User testUser = new User();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Castrol_UK_IR_FWS_Sales'];
        
        testUser.Username = 'test.SetOwnerOfAccountTest@test.com';
        testUser.FirstName = 'Test';
        testUser.LastName = 'SetOwnerOfAccountTest';
        testUser.Email = 'test.SetOwnerOfAccountTest@test.com';
        testUser.NTID__c = 'testNTID';
        testUser.Alias = 'testSFO';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LocaleSidKey = 'de_DE';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = p.Id;
        testuser.UserRoleId = r.Id;
        
        insert testUser;     
    }

    @isTest
    static void setToOwnerToNTIDAU() {
        User u = [SELECT Id FROM User WHERE Alias = 'testSFO'];
        
        Account a = new Account();
        
        // For ANZ accounts Marked_for_Deletion field should not be relevant.
        a.Name = 'AU Test';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = true;
        a.Sales_Organisation__c = 'AU0A';
        
        insert a;
        
        Account result = [SELECT Id, OwnerId FROM Account WHERE Name = 'AU Test'];
        
        system.assert(result.OwnerId == u.Id, 'Owner should be set according to NTID.');
    }
    
    @isTest
    static void setToOwnerToNTIDNZ() {
        User u = [SELECT Id FROM User WHERE Alias = 'testSFO'];
        
        Account a = new Account();
        
        // For ANZ accounts Marked_for_Deletion field should not be relevant.
        a.Name = 'AU Test';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = true;
        a.Sales_Organisation__c = 'AU0A';
        
        insert a;
        
        Account result = [SELECT Id, OwnerId FROM Account WHERE Name = 'AU Test'];
        
        system.assert(result.OwnerId == u.Id, 'Owner should be set according to NTID.');
    }
    
    @isTest
    static void setToOwnerToNTIDRU() {
        User u = [SELECT Id FROM User WHERE Alias = 'testSFO'];
        
        Account a = new Account();
        Account b = new Account();
        
        // For Russia accounts owner should be set according to NTID if there block code is either blank
        // or does not start with '01'...
        a.Name = 'RU Test a';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = false;
        a.Sales_Organisation__c = 'RU01';
        a.Order_Block_Code__c = '20';
        a.Type = 'ZMSP';
        
        insert a;
        
        b.Name = 'RU Test b';
        b.Sales_Manager_NTID__c = 'testNTID';
        b.Marked_for_Deletion__c = false;
        b.Sales_Organisation__c = 'RU01';
        b.Order_Block_Code__c = '';
        b.Type = 'ZMSP';
        
        insert b;
        
        Account resulta = [SELECT Id, OwnerId FROM Account WHERE Name = 'RU Test a'];
        Account resultb = [SELECT Id, OwnerId FROM Account WHERE Name = 'RU Test b'];
        
        system.assert(resulta.OwnerId == u.Id, 'Owner should be set according to NTID.');
        system.assert(resultb.OwnerId == u.Id, 'Owner should be set according to NTID.');
    }
    
    @isTest
    static void setToOwnerToNTIDTR() {
        User u = [SELECT Id FROM User WHERE Alias = 'testSFO'];
        
        Account a = new Account();
        Account b = new Account();
        
        // For Turkey owner is set to NTID only if its is NOT ZMBP NOR ZMPY
        a.Name = 'TR Test a';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = false;
        a.Sales_Organisation__c = 'TR01';
        a.Type = 'ZMSP';
        
        insert a;
        
        b.Name = 'TR Test b';
        b.Sales_Manager_NTID__c = 'testNTID';
        b.Marked_for_Deletion__c = false;
        b.Sales_Organisation__c = 'TR01';
        b.Type = 'ZMSH';
        
        insert b;
        
        Account resulta = [SELECT Id, OwnerId FROM Account WHERE Name = 'TR Test a'];
        Account resultb = [SELECT Id, OwnerId FROM Account WHERE Name = 'TR Test b'];
        
        system.assert(resulta.OwnerId == u.Id, 'Owner should be set according to NTID.');
        system.assert(resultb.OwnerId == u.Id, 'Owner should be set according to NTID.');
    }
    
    @isTest
    static void setToOwnerToNTIDOther() {
        User u = [SELECT Id FROM User WHERE Alias = 'testSFO'];
        
        Account a = new Account();
        Account b = new Account();
        
        // For Turkey owner is set to NTID only if its is NOT ZMBP NOR ZMPY
        a.Name = 'UK Test';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = false;
        a.Sales_Organisation__c = 'UK01';
        
        insert a;
        
        Account result = [SELECT Id, OwnerId FROM Account WHERE Name = 'UK Test'];
        
        system.assert(result.OwnerId == u.Id, 'Owner should be set according to NTID.');
    }
    
    @isTest
    static void setToOwnerToSysAdminRU() {
        User u = [SELECT Id FROM User WHERE Alias = 'sysadmin'];
        
        Account a = new Account();
        
        // For Russia accounts owner should be set to sysadmin if block code starts with '01'

        a.Name = 'RU Test';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = false;
        a.Sales_Organisation__c = 'RU01';
        a.Order_Block_Code__c = '0123456';
        a.Type = 'ZMPY';
        
        insert a;
        
        Account result = [SELECT Id, OwnerId FROM Account WHERE Name = 'RU Test'];
        
        system.assert(result.OwnerId == u.Id, 'Owner should be set according to sysadmin.');
    }
    
    @isTest
    static void setToOwnerToSysAdminTR() {
        User u = [SELECT Id FROM User WHERE Alias = 'sysadmin'];
        
        Account a = new Account();
        Account b = new Account();
        
        // For Turkey owner is set to sysadmin only if type is ZMBP or ZMPY
        a.Name = 'TR Test a';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = false;
        a.Sales_Organisation__c = 'TR01';
        a.Type = 'ZMBP';
        
        insert a;
        
        b.Name = 'TR Test b';
        b.Sales_Manager_NTID__c = 'testNTID';
        b.Marked_for_Deletion__c = false;
        b.Sales_Organisation__c = 'TR01';
        b.Type = 'ZMPY';
        
        insert b;
        
        Account resulta = [SELECT Id, OwnerId FROM Account WHERE Name = 'TR Test a'];
        Account resultb = [SELECT Id, OwnerId FROM Account WHERE Name = 'TR Test b'];
        
        system.assert(resulta.OwnerId == u.Id, 'Owner should be set according to sysadmin.');
        system.assert(resultb.OwnerId == u.Id, 'Owner should be set according to sysadmin.');
    }
    
    @isTest
    static void setToOwnerToSysAdminOther() {
        User u = [SELECT Id FROM User WHERE Alias = 'sysadmin'];
        RecordType prospectRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Prospect'];
        RecordType customerRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer'];
        
        Account a = new Account();
        
        // For Other countries if marked for deletion is true set owner to sysadmin
        a.RecordTypeId = prospectRT.Id;
        a.Name = 'UK Test';
        a.Sales_Manager_NTID__c = 'testNTID';
        a.Marked_for_Deletion__c = true;
        a.Sales_Organisation__c = 'UK01';
        
        insert a;
        
        a = [SELECT Id, OwnerId FROM Account WHERE Name = 'UK Test'];
        
        a.RecordTypeId = customerRT.Id;
        
        update a;
        
        Account result = [SELECT Id, OwnerId FROM Account WHERE Name = 'UK Test'];
        
        system.assert(result.OwnerId == u.Id, 'Owner should be set according to sysadmin.');
    }
}