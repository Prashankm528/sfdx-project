/***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Test class for ContactStagehandler class.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
@istest
public with sharing class SOM_ContactStagehandler_Test {
    
/***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method use to test ContactStagehandler class.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
    static testMethod void testHandler(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(Name='Test',  RecordTypeId=accRecordTypeId);
        Test.startTest();
        insert acc;
        
        Id opptRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        date dt = date.parse('05/11/2020');
        Opportunity oppt = new Opportunity(Name = 'TestOpportunity',CloseDate=dt,Type='New Business',AccountId=acc.Id, StageName = 'Qualification (New)',RecordTypeId=opptRecordTypeId);
        insert oppt;
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();   
        Contact con = new Contact(SOM_Opportunity_Stage__c='Contact Made (New)',accountid=acc.id,FirstName='Test ',LastName='Contact',Phone='1316546849649',RecordTypeId=conRecordTypeId);
        insert con;
        
        OpportunityContactRole opptyRole  = new OpportunityContactRole(IsPrimary=true,contactid=con.id,opportunityid=oppt.id);
        insert opptyRole;

        oppt.StageName = 'Contact Made (New)';
        update oppt;
        Test.stopTest();
        SOM_ContactStageHelper.updateContactOpptyStage(null,null);
        system.assertEquals(oppt.StageName, con.SOM_Opportunity_Stage__c);
    }
}