/****************************************************************************************************
 *  Date          : 2-JUL-2019
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_EmailMessage_Trigger
 *  Modifications :
 *  02-JUL-2019   : SYAP - Initial
 *  02-JUL-2019   : SYAP - Increased code coverage.
 *  03-MAR-2020   : SYAP - Included PCI Compliance Scenario
 ****************************************************************************************************/
@isTest
public with sharing class GCM_EmailMessage_Trigger_Test {
/****************************************************************************************************
   Test Last Email Timestamp Automation
 ****************************************************************************************************/
    public static testMethod void validateMailboxLastUpdated() {
        // Update User Sender Email
        List<User> users = [select Id, GCM_Sender_Email__c from User where Id = :UserInfo.getUserId()];
        for (User thisUser : users) {
            thisUser.GCM_Sender_Email__c = 'test@bp.com';
        }
        update users;
        
        // Test If Recipient Mailbox Stamped On Case
        Id recordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        System.assert(recordTypeId != null, 'Record Type Not Found');    
        Case thisCase = new Case();
        thisCase.RecordTypeId = recordTypeId;
        thisCase.Subject = 'Test 1234-1234-1234-1234';
        thisCase.Description = 'Test 1234-1234-1234-1234';
        insert thisCase;
        EmailMessage message = new EmailMessage();
        String padding = 'a';
        message.Incoming = true;
        message.FromAddress = 'testfrom@salesforce.com';
        message.ToAddress = 'testto@salesforce.com';
        message.Headers = 'Return-Path: gbssftest5@bp.com Authentication-Results:';
        message.Subject = 'Test 1234-1234-1234-1234';
        message.HtmlBody = 'Test 1234-1234-1234-1234' + padding.repeat(32768 / 2 - message.Subject.length());
        message.TextBody = 'Test 1234-1234-1234-1234' + padding.repeat(32768 / 2 - message.Subject.length());
        message.ParentId = thisCase.Id;
        insert message;
        update message;
        List<Case> cases = [select GCM_Incoming_Message_Date__c from Case where Id = :thisCase.Id and GCM_Incoming_Message_Date__c != null limit 1];
        System.assert(cases.size() > 0, 'Case Not Found');

        EmailMessage messageReply = new EmailMessage();
        messageReply.Incoming = true;
        messageReply.FromAddress = 'testfrom@salesforce.com';
        messageReply.ToAddress = 'testto@salesforce.com';
        messageReply.ParentId = thisCase.Id;
        insert messageReply;
    }
    
/****************************************************************************************************
   Test Long Email
 ****************************************************************************************************/
    public static testMethod void validateLongEmail() {
        // Test If Recipient Mailbox Stamped On Case
        Id recordTypeId = BPG_Error_Logger.queryFirstRecord('select Id from RecordType where DeveloperName = \'GCM_Fuels_Dealer\' and SObjectType = \'Case\'').Id;
        System.assert(recordTypeId != null, 'Record Type Not Found');    
        Case thisCase = new Case();
        thisCase.RecordTypeId = recordTypeId;
        thisCase.Subject = 'Test 1234-1234-1234-1234';
        thisCase.Description = 'Test 1234-1234-1234-1234';
        insert thisCase;
        EmailMessage message = new EmailMessage();
        String padding = 'a';
        message.Incoming = true;
        message.FromAddress = 'testfrom@salesforce.com';
        message.ToAddress = 'testto@salesforce.com';
        message.Headers = 'Return-Path: gbssftest5@bp.com Authentication-Results:';
        message.Subject = 'Test 1234-1234-1234-1234';
        message.HtmlBody = 'Test 1234-1234-1234-1234' + padding.repeat(131072 - message.Subject.length());
        message.TextBody = 'Test 1234-1234-1234-1234' + padding.repeat(131072 - message.Subject.length());
        message.ParentId = thisCase.Id;
        insert message;
        update message;
        List<Case> cases = [select GCM_Incoming_Message_Date__c from Case where Id = :thisCase.Id and GCM_Incoming_Message_Date__c != null limit 1];
        System.assert(cases.size() > 0, 'Case Not Found');
    }
}