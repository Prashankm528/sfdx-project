/**
* @author     Sushant Sethi
* @date       22 June 2020
* @description    Test class for BPCM_SocialPersonaTriggerHandler class  
* 
*  
*/
@isTest(SeeAllData=False)
public with sharing class BPCM_SocialPersonaTriggerHandler_Test {

/**
* @description - test method for validating Re-parenting of Social Persona Records
*/
    @isTest
    public static void updateSocialPersonaRecords() {
        
        //Insert Account for Original Parent Contact
        Account locationAccount = BPCM_TestDataFactory.createAccount(true, 'Sushant Sethi', '+91 1223334444', 'BPCM_Location');
                
        //Insert Original Parent Contact
        Contact originalContact = BPCM_TestDataFactory.createContact(true, locationAccount.id, 'LastName','+91 1223334444', 'Sushant@Sethi.com','BPCM_Contact');
        
        //Associate a Social Persona Record with the Original Parent Contact
        SocialPersona spRec = BPCM_TestDataFactory.createSocialPersona(true, 'John Smith', 'John Smith', 'Twitter', 'Twitter','2345556', originalContact.id);
        
        //Associate a Case with the Original Parent Contact
        Case testCase = BPCM_TestDataFactory.createCase(true, 'New Case', 'Please check my homecharge', 'Twitter', 'BPCM_General_EV', originalContact.id);
        //Associate second Case with the Original Parent Contact
        Case testCase2 = BPCM_TestDataFactory.createCase(true, 'New Case', 'Please check charging cable', 'Facebook', 'BPCM_Technical', originalContact.id);
        
        //Associate a Task with the Original Parent Contact
        Task testTask = BPCM_TestDataFactory.createTask(true, 'Task', originalContact.id, testCase.id, 'Test Task','New','BPCM_Task');
        //Associate second Task with the Original Parent Contact
        Task testTask2 = BPCM_TestDataFactory.createTask(true, 'Task', originalContact.id, testCase2.id, 'Test Task2', 'New', 'BPCM_Task');
        
        //Insert Account for New Parent(Customer Account)
        Account consumerAccount = BPCM_TestDataFactory.createPersonAccount(true, 'Sushant', 'Sethi', 'sushant@sethi.com', '+91 1223334444', 'BPCM_Consumer');
        
        
        //Check the Current SocialPersona with associated Cases and Tasks
        //Check that current parent has 2 Cases
        system.assertEquals(2,[SELECT id from Case where Contactid = :originalContact.id].size(),'There are 2 cases attached to originalContact');
        //Check that current parent has 2 Tasks
        system.assertEquals(2,[SELECT id from Task where Whoid = :originalContact.id].size(),'There are 2 tasks attached to originalContact');
        
        Test.startTest(); 
        //Reparent the social Persona Record to a Consumer Account
        spRec.parentid = consumerAccount.id;
        update spRec;
        Test.stopTest();
        
        Id personContactId = BPCM_TestDataFactory.getContactIdFromPersonAccount(consumerAccount.id);
        //Check the Updated SocialPersona with associated Cases and Tasks
        //Check that new parent has 2 Cases
        system.assertEquals(2,[SELECT id from Case where Contactid = :personContactId].size(),'There are 2 cases attached to new Parent');
        //Check that new parent has 2 Tasks
        system.assertEquals(2,[SELECT id from Task where Whoid = :personContactId].size(),'There are 2 tasks attached to new parent');
        //Check that the old contact is deleted
        system.assertEquals(0,[SELECT id from Contact where id = :originalContact.id].size(),'The old parent is deleted from the system ');
        
        }
 
}