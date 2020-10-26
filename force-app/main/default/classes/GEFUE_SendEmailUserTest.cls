/*****************************************************************************************
*   Date:           27SEPT20
*   Author:         Danish Memon – TCS (Tata Consultancy Services Ltd.)
*   Description:    Test class for sending email to users
*   Modifications:  
****************************************************************************************/
@isTest
public with sharing class GEFUE_SendEmailUserTest {
    
    @isTest public static void sendEmailTest() {
        Profile pf = [Select Id from profile where Name='System Administrator']; 
        List<User> usr = new List <User>();
        usr.add(new User(Alias='Admin',Email='test@gamil.com',LastName='Testing',Username='standardust@gamil.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = pf.Id, 
                             TimeZoneSidKey='America/Los_Angeles',EmailEncodingKey='UTF-8'));
        insert usr; 
        Test.startTest();
        GEFUE_SendEmailUserSchedulable schClass = new GEFUE_SendEmailUserSchedulable();
        String sch = '0 0 23 * * ?';
        String jobID = System.Schedule('Test User Login Check', sch, schClass);
        System.assert(jobID != NULL, 'Job is not scheduled');
        Test.stopTest();
    }
}