/****************************************************************************************************
 *  Date          : 21-FEB-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Document_Generator
 * Modifications  : 21-FEB-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Document_Generator_Test {
/****************************************************************************************************
  Test Generate Document
 ****************************************************************************************************/
    @isTest static void testGenerator() {
		// Create Template
        GCM_Document__c template = new GCM_Document__c();
        template.Name = 'TEST';
        template.GCM_Display_Name__c = 'TEST';
        template.GCM_Field_List__c = 'CaseNumber, Contact.FirstName, CreatedDate, ClosedDate, IsClosedOnCreate, Case_References__r.GCM_Item_Details__c';
        template.GCM_HTML__c = '<html>{!Contact.FirstName}</html>';
        template.GCM_SOQL__c = 'select CaseNumber, Contact.FirstName, CreatedDate, ClosedDate, IsClosedOnCreate, (select GCM_Item_Details__c from Case_References__r) from Case where Id = \'{!Id}\'';
        insert template;    

        // Create Contact
        Contact newContact = new Contact();
        newContact.FirstName = 'TEST';
        newContact.LastName = 'TEST';
        insert newContact;
        
        // Create Case
        Case newCase = new Case();
        newCase.GCM_ByPassValidation_Timestamp__c = Datetime.now();
        newCase.Subject = 'TEST';
        newCase.Description = 'TEST';
        newCase.ContactId = newContact.Id;
        insert newCase;
        
        // Create Case References
        GCM_Case_References__c reference = new GCM_Case_References__c();
        reference.GCM_Item_Type__c = 'Invoice Number';
        reference.GCM_Item_Details__c = 'TEST12345678';
        reference.GCM_Case_No__c = newCase.Id;
        insert reference;
        
        // Assert Field Substitution
        List<GCM_Document__c> templates = GCM_Document_Generator.getTemplates();
        String document = GCM_Document_Generator.getDocument('TEST', newCase.Id);
        System.debug(UserInfo.getName());
        System.debug(document);
        System.assert(document.contains('TEST'), 'Contact Name Substituted');
    }
}