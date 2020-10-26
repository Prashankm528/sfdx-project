/************************************************************************************************************
* Description : Test class for CA_SurveyScoreChart
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-Feb-11   1.0                 Maros Zilka			Initial version
* 2019-Mar-21   1.1                 Maros Zilka			Testing grouping by day and by week
*
*************************************************************************************************************/

@isTest
public class CA_SurveyScoreChartTest {
	static testmethod void CESTest() {
        List<List<String>> data = new List<List<String>> ();
        
        createData();
        Account a = [SELECT Id FROM Account WHERE Name = 'CES'];
        User u = [SELECT Id FROM User WHERE Username = 'test.CA_SurveyScoreChartTest@test.com'];
    	
        Test.startTest();
        
        	System.runAs(u) {
                data = CA_SurveyScoreChart.getCESData(a.Id);
            }
    	
    	Test.stopTest();
        
        System.assertEquals('8', data[1][0], 'Average response value of CES questions should be 8');
        System.assertEquals('10', data[1][1], 'Average response value of CES questions should be 10');
       	System.assertEquals('5', data[1][2], 'Average response value of CES questions should be 5 (4,6)');
    }
    
    static testmethod void CESTestRomanianUser() {
        List<List<String>> data = new List<List<String>> ();
        
        createData();
        Account a = [SELECT Id FROM Account WHERE Name = 'CES'];
        User u = [SELECT Id FROM User WHERE Username = 'test.CA_SurveyScoreChartTestRO@test.com'];
    	
        Test.startTest();
                	
        	System.runAs(u) {
                data = CA_SurveyScoreChart.getCESData(a.Id);
            }
    	
    	Test.stopTest();
        
        System.assertEquals('9', data[1][0], 'Average response value of CES questions should be 9 (8,10) - First week');
       	System.assertEquals('5', data[1][1], 'Average response value of CES questions should be 5 (4,6) - Second week');
    }
    
    static testmethod void NPSTest() {
        List<List<String>> data = new List<List<String>> ();
        
        createData();
        Account a = [SELECT Id FROM Account WHERE Name = 'NPS'];
        User u = [SELECT Id FROM User WHERE Username = 'test.CA_SurveyScoreChartTest@test.com'];
    	
        Test.startTest();

            System.runAs(u) {
                data = CA_SurveyScoreChart.getNPSData(a.Id);
            }

    	Test.stopTest();

        System.assertEquals('2', data[1][0], 'Average response value of NPS questions should be 2');
        System.assertEquals('4', data[1][1], 'Average response value of NPS questions should be 4');
        System.assertEquals('3', data[1][2], 'Average response value of NPS questions should be 3 (2,4)');
    }

    static testmethod void NPSTestRomanianUser() {
        List<List<String>> data = new List<List<String>> ();
        
        createData();
        Account a = [SELECT Id FROM Account WHERE Name = 'NPS'];
        User u = [SELECT Id FROM User WHERE Username = 'test.CA_SurveyScoreChartTestRO@test.com'];
    	
        Test.startTest();
            
        	System.runAs(u) {
                data = CA_SurveyScoreChart.getNPSData(a.Id);
            }
    	
    	Test.stopTest();

        System.assertEquals('3', data[1][0], 'Average response value of NPS questions should be 3 (2,4) - First week');
        System.assertEquals('3', data[1][1], 'Average response value of NPS questions should be 3 (2,4) - Second week');
    }
    
    static testmethod void NoSurveysTest() {
        List<List<String>> data = new List<List<String>> ();
        
        createData();
        Account a = [SELECT Id FROM Account WHERE Name = 'NoSurveys'];
    	
        Test.startTest();
    	data = CA_SurveyScoreChart.getCESData(a.Id);
    	Test.stopTest();

       	System.assertEquals(null, data, 'Null should be returned if there are no surveys on account.'); 
    }
    
    private static void createData() {
        Account CESAccount;
        Account NPSAccount;
        Account NoSurveysAccount;
        
        Contact CESContact;
        Contact NPSContact;
        Contact NoSurveysContact;
        
        Survey__c testTemplate;
        Survey_Question__c CESQuestion;
        Survey_Question__c NPSQuestion;
        
        SurveyTaker__c CESsurvey;
        SurveyTaker__c NPSsurvey;
        
        SurveyQuestionResponse__c response;

        User romanianUser;
        User nonRomanianUser;
        User sysAdmin = [Select Id FROM User WHERE Name = 'System Admin'];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'Castrol_UK_IR_FWS_Sales'];
        
        // Run as to prevent mixed DML opertaion error
        System.runAs(sysAdmin) {

            romanianUser = new User(
                Username = 'test.CA_SurveyScoreChartTestRO@test.com',
                FirstName = 'Test',
                LastName = 'SetOwnerOfAccountTest',
                Email = 'test.CA_SurveyScoreChartTestRO@test.com',
                NTID__c = 'testNTIDRO',
                Alias = 'SFORO',
                TimeZoneSidKey = 'Europe/Berlin',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'de_DE',
                LanguageLocaleKey = 'en_US',
                Sales_Organisation__c = 'RO01',
                ProfileId = p.Id,
                UserRoleId = r.Id
            );
            
            insert romanianUser;
    
            nonRomanianUser = new User(
                Username = 'test.CA_SurveyScoreChartTest@test.com',
                FirstName = 'Test',
                LastName = 'SetOwnerOfAccountTest',
                Email = 'test.CA_SurveyScoreChartTest@test.com',
                NTID__c = 'testNTID',
                Alias = 'tesSFO',
                TimeZoneSidKey = 'Europe/Berlin',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'de_DE',
                LanguageLocaleKey = 'en_US',
                Sales_Organisation__c = 'UK01',
                ProfileId = p.Id,
                UserRoleId = r.Id
            );
    
            insert nonRomanianUser;
            
            CESAccount = new Account (name = 'CES', 
            BillingCity ='TestCity', BillingCountry ='TestCountry', 
            BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
            insert CESAccount;
            
            NPSAccount = new Account (name = 'NPS', 
            BillingCity ='TestCity', BillingCountry ='TestCountry', 
            BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
            insert NPSAccount;
            
            NoSurveysAccount = new Account (name = 'NoSurveys', 
            BillingCity ='TestCity', BillingCountry ='TestCountry', 
            BillingStreet ='TestStreet', BillingPostalCode ='t3stcd3');
            insert NoSurveysAccount;
        
            CESContact = new Contact (FirstName = 'John',
            LastName = 'Smith',AccountId = CESAccount.Id,Email = 'john@mail.com',
            Survey_Opt_Out__c = false);
            insert CESContact;
            
            NPSContact = new Contact (FirstName = 'Adam',
            LastName = 'Manly',AccountId = NPSAccount.Id,Email = 'adam@mail.com',
            Survey_Opt_Out__c = false);
            insert NPSContact;
            
            NoSurveysContact = new Contact (FirstName = 'Simon',
            LastName = 'Alexander',AccountId = NoSurveysAccount.Id,Email = 'simon@mail.com',
            Survey_Opt_Out__c = false);
            insert NoSurveysContact;
        
            testTemplate = new Survey__c();
            testTemplate.name = 'testtest';
            insert testTemplate;
        
            CESQuestion = new Survey_Question__c();
            CESQuestion.Survey__c = testTemplate.id;
            CESQuestion.OrderNumber__c = 5;
            CESQuestion.Lcf_CES__c = TRUE;
            CESQuestion.Question__c = 'How likely is it that you would recommend Castrol to a friend or colleague?';
            CESQuestion.CALCF_Question_Short_Name__c = 'CES';
            insert CESQuestion;
            
            NPSQuestion = new Survey_Question__c();
            NPSQuestion.Survey__c = testTemplate.id;
            NPSQuestion.OrderNumber__c = 5;
            NPSQuestion.Lcf_NPS__c = TRUE;
            NPSQuestion.Question__c = 'How likely is it that you would recommend Castrol to a friend or colleague?';
            NPSQuestion.CALCF_Question_Short_Name__c = 'NPS';
            insert NPSQuestion;
        
            NPSsurvey = new SurveyTaker__c();
            NPSsurvey.Survey__c = testTemplate.id;
            NPSsurvey.Survey_Time__c = datetime.now();
            NPSsurvey.Contact__c = NPSContact.Id;
            NPSsurvey.Account__c = NPSAccount.Id;
            NPSsurvey.Survey_Status__c = 'Taken';
            NPSsurvey.Mode__c = 'Batch';
            NPSsurvey.Sales_Organisation__c = 'UK01';
            insert NPSsurvey;
            
            CESsurvey = new SurveyTaker__c();
            CESsurvey.Survey__c = testTemplate.id;
            CESsurvey.Survey_Time__c = datetime.now();
            CESsurvey.Contact__c = CESContact.Id;
            CESsurvey.Account__c = CESAccount.Id;
            CESsurvey.Survey_Status__c = 'Taken';
            CESsurvey.Mode__c = 'Batch';
            CESsurvey.Sales_Organisation__c = 'UK01';
            insert CESsurvey;
    
            /* NPS SURVEY RESPONSES */
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '2';
            response.SurveyTaker__c = NPSsurvey.Id;
            response.Survey_Question__c = NPSQuestion.id;
            insert response;
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '4';
            response.SurveyTaker__c = NPSsurvey.Id;
            response.Survey_Question__c = NPSQuestion.id;
            insert response;
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '2';
            response.SurveyTaker__c = NPSsurvey.Id;
            response.Survey_Question__c = NPSQuestion.id;
            insert response;
    
            Date startOfWeek = Date.today().addDays(-15).toStartOfWeek();
            Test.setCreatedDate(response.Id, Datetime.newInstance(startOfWeek, Time.newInstance(0, 0, 0, 0)));
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '4';
            response.SurveyTaker__c = NPSsurvey.Id;
            response.Survey_Question__c = NPSQuestion.id;
            insert response;
            
            Test.setCreatedDate(response.Id, Datetime.newInstance(startOfWeek.addDays(+2), Time.newInstance(0, 0, 0, 0)));
            
            /* CES SURVEY RESPONSES */
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '4';
            response.SurveyTaker__c = CESsurvey.Id;
            response.Survey_Question__c = CESQuestion.id;
            insert response;
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '6';
            response.SurveyTaker__c = CESsurvey.Id;
            response.Survey_Question__c = CESQuestion.id;
            insert response;
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '8';
            response.SurveyTaker__c = CESsurvey.Id;
            response.Survey_Question__c = CESQuestion.id;
            insert response;
    
            startOfWeek = Date.today().addDays(-15).toStartOfWeek();
            Test.setCreatedDate(response.Id, Datetime.newInstance(startOfWeek, Time.newInstance(0, 0, 0, 0)));
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '10';
            response.SurveyTaker__c = CESsurvey.Id;
            response.Survey_Question__c = CESQuestion.id;
            insert response;
            
            Test.setCreatedDate(response.Id, Datetime.newInstance(startOfWeek.addDays(+2), Time.newInstance(0, 0, 0, 0)));
            
            response = new SurveyQuestionResponse__c();
            response.Response__c = '?';
            response.SurveyTaker__c = CESsurvey.Id;
            response.Survey_Question__c = CESQuestion.id;
            insert response;
        }
    }
}