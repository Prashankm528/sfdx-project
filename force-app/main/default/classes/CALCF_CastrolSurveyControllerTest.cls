@isTest
public class CALCF_CastrolSurveyControllerTest {

    @testSetup static void setup(){

        List<RecordType> rtypeComp = [Select Name, Id From RecordType where sObjectType='SurveyTaker__c' and isActive=true and Name='Complaints'];
        List<RecordType> rtypeOrder = [Select Name, Id From RecordType where sObjectType='SurveyTaker__c' and isActive=true and Name='Orders'];
        
        Survey__c survTemplate = new Survey__c(Name = 'Complaint template', Thank_You_Text__c = 'Thank_You_Text__c', thankYouText__c = 'thankYouText__c',
            thankYouLink__c = 'thankYouLink__c', Castrol_Header__c = 'Castrol_Header__c', Castrol_Subheader__c = 'Castrol_Subheader__c', Submission_Button_Text__c = 'Submit',
            Page_Title__c = 'Page_Title__c', Topbar_Title__c = 'Topbar_Title__c', Language_Code__c = 'Language_Code__c', Country_Name__c = 'Country_Name__c',
            Required_Field_Label__c='Required_Field_Label__c', Privacy_Statement_Text__c='Privacy_Statement_Text__c', Privacy_Statement_URL__c='Privacy_Statement_URL__c',
            Legal_Notice_Text__c='Legal_Notice_Text__c', Legal_Notice_URL__c='Legal_Notice_URL__c', lcf_Channel__c='Ordering', Expired_Header__c='Expired_Header__c',
            Taken_Header__c='Taken_Header__c', Thank_You_Header__c='Thank_You_Header__c', Expired_Header2__c='Expired_Header2__c', Taken_Header2__c='Taken_Header2__c',
            Thank_You_Header2__c='Thank_You_Header2__c', Expired_Description__c='Expired_Description__c', Taken_Description__c='Taken_Description__c',
            Thank_You_Description__c='Thank_You_Description__c', Thank_You_Description_Iframe__c='Thank_You_Description_Iframe__c', Iframe_Header__c='Iframe_Header__c',
            Iframe_Subheader__c='Iframe_Subheader__c', Label_Left_1_to_5__c='Label_Left_1_to_5__c', Label_Right_1_to_5__c='Label_Right_1_to_5__c',
            Label_Dont_Know_1_to_5__c='Label_Dont_Know_1_to_5__c', Label_Left_0_to_10__c='Label_Left_0_to_10__c', Label_Right_0_to_10__c='Label_Right_0_to_10__c');     
        insert survTemplate;

        Survey_Question__c question1 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1\n2\n3\n4\n5\n6', Type__c='Single Select--Horizontal', OrderNumber__c=0, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        Survey_Question__c question2 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1\n2\n3\n4\n5\n6', Type__c='Single Select--Vertical', OrderNumber__c=1, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        Survey_Question__c question3 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11', Type__c='Single Select--Horizontal', OrderNumber__c=0, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        Survey_Question__c question4 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11', Type__c='Single Select--Vertical', OrderNumber__c=1, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        Survey_Question__c question5 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1', Type__c='Multi-Select--Vertical', OrderNumber__c=2, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        Survey_Question__c question6 = new Survey_Question__c(Name='Question', Survey__c=survTemplate.Id, Question__c='Question text', Native_Language_Question__c='Native question text',
            Choices__c='1', Type__c='Free Text', OrderNumber__c=3, Question_Header__c='Question', CALCF_Question_Short_Name__c = 'NPS');
        insert question1;
        insert question2;
        insert question3;
        insert question4;
        insert question5;
        insert question6;
        
        // get a customer account record id
        Id CustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        system.debug('CustomerRecordTypeId is : ' + CustomerRecordTypeId);
        
        Account account = new Account(Name='Acme');
        account.recordtypeid = CustomerRecordTypeId;
        insert account;

        Contact contact = new Contact(FirstName='Will', LastName='Smith', Accountid = account.id, Home_Location__c = 'Spain' );
        insert contact;

        SurveyTaker__c surveyTestComp = new SurveyTaker__c(Contact__c = contact.Id, RecordType = rtypeComp[0], Survey__c = survTemplate.Id, Survey_Status__c = 'Taken', Sales_Organisation__c = 'AT01',
            Case__c = null, Created_Date__c = Date.today(), Due_Date__c = Date.today()+5, Portal_Messages__c='Portal_Messages__c', Complaint_Owner__c = 'Complaint_Owner__c');
        insert surveyTestComp;
        SurveyTaker__c surveyTestOrder = new SurveyTaker__c(Contact__c = contact.Id, RecordType = rtypeOrder[0], Survey__c = survTemplate.Id, Survey_Status__c = 'Sent', Sales_Organisation__c = 'AT01',
            Case__c = null, Created_Date__c = Date.today(), Due_Date__c = Date.today()+5, Portal_Messages__c='Portal_Messages__c', Complaint_Owner__c = 'Order_Owner__c');
        insert surveyTestOrder;
        
        lcf_settings__c settings = new lcf_settings__c();
        settings.Opt_Out_Period__c = '30';
        
        insert settings;

    }

    @isTest static void testController_Complaints_iframe_survey() {

        SurveyTaker__c surveyTest = [SELECT Id, Complaint_Owner__c, Survey_Status__c, Contact_Dissatisfied_Customer__c FROM SurveyTaker__c WHERE Complaint_Owner__c='Complaint_Owner__c' LIMIT 1];
        Survey__c survTemplate = [SELECT Id, Name FROM Survey__c WHERE Name = 'Complaint template' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'Will' LIMIT 1];

        PageReference pageRef = Page.CastrolSurvey;
        pageRef.getParameters().put('Id', surveyTest.Id);
        pageRef.getParameters().put('tId', survTemplate.Id);        
        pageRef.getParameters().put('cId', contact.Id);         
        pageRef.getParameters().put('w', '1');
        Test.setCurrentPage(pageRef);

        ApexPAges.StandardController sc = new ApexPages.StandardController(surveyTest);
        CALCF_CastrolSurveyController testController = new CALCF_CastrolSurveyController(sc);

        testController.setSurveyStatus();
        testController.submitResults();
        testController.getContactName();
        testController.doNotContactMe();
        testController.doNotOptOut();   
        testController.doOptOut();
        
        System.assertEquals('Taken',surveyTest.Survey_Status__c); 
        System.assertEquals(false,surveyTest.Contact_Dissatisfied_Customer__c);

    }

    @isTest static void testController_Complaints_expired_survey() {

        SurveyTaker__c surveyTest   = [SELECT Id, Complaint_Owner__c, Survey_Status__c, Contact_Dissatisfied_Customer__c FROM SurveyTaker__c WHERE Complaint_Owner__c='Complaint_Owner__c' LIMIT 1];
        Survey__c survTemplate      = [SELECT Id, Name FROM Survey__c WHERE Name = 'Complaint template' LIMIT 1];
        surveyTest.Survey_Status__c = 'Expired';
        update surveyTest;

        PageReference pageRef = Page.CastrolSurvey;
        pageRef.getParameters().put('Id', surveyTest.Id);
        pageRef.getParameters().put('tId', survTemplate.Id);    
        pageRef.getParameters().put('w', '0');  
        pageRef.getParameters().put('preview', 'false');
        Test.setCurrentPage(pageRef);

        ApexPAges.StandardController sc             = new ApexPages.StandardController(surveyTest);
        CALCF_CastrolSurveyController testController   = new CALCF_CastrolSurveyController(sc);

        testController.setSurveyStatus();
        testController.submitResults();
        testController.contactMe();
        testController.optOut();    
        
        System.assertEquals('Expired',surveyTest.Survey_Status__c);
        System.assertEquals(false,surveyTest.Contact_Dissatisfied_Customer__c);  

    }

    @isTest static void testController_Orders_iframe_survey() {

        SurveyTaker__c surveyTest = [SELECT Id, Complaint_Owner__c, Survey_Status__c, Contact_Dissatisfied_Customer__c FROM SurveyTaker__c WHERE Complaint_Owner__c='Order_Owner__c' LIMIT 1];
        Survey__c survTemplate = [SELECT Id, Name FROM Survey__c WHERE Name = 'Complaint template' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'Will' LIMIT 1];

        PageReference pageRef = Page.CastrolSurvey;
        pageRef.getParameters().put('Id', surveyTest.Id);
        pageRef.getParameters().put('tId', survTemplate.Id);        
        pageRef.getParameters().put('cId', contact.Id);         
        pageRef.getParameters().put('w', '1');
        Test.setCurrentPage(pageRef);

        ApexPAges.StandardController sc = new ApexPages.StandardController(surveyTest);
        CALCF_CastrolSurveyController testController = new CALCF_CastrolSurveyController(sc);

        testController.setSurveyStatus();
        testController.submitResults();
        testController.getContactName();
        testController.doNotContactMe();
        testController.doNotOptOut();   
        testController.doOptOut();
        
        System.assertEquals('Sent',surveyTest.Survey_Status__c); 
        System.assertEquals(false,surveyTest.Contact_Dissatisfied_Customer__c);

    }
}