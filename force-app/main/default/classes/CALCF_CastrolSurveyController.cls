/************************************************************************************************************
* Description : Controller associated with pages rendering the survey.
*				Used by SurveyPage, ResultsPage, TakeSurvey.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-MAR-06   1.0                 Frantisek Kolacny   Clean up of class
* Modifications 2.0                 Rahma Belghouti     Extend visibility for contact update for guest user
*************************************************************************************************************/

global virtual with sharing class CALCF_CastrolSurveyController {

    public String       qQuestion                      {get; set;}
    public String       qChoices                       {get; set;}
    public String       surveyName                     {get; set;}
    public String       pageTitle                      {get; set;}
    public String       topbarTitle                    {get; set;}
    public String       languageCode                   {get; set;}
    public String       topbarCountry                  {get; set;}
    public String       topbarCountryEn                {get; set;}
    public String       surveyHeader                   {get; set;}
    public String       secondLng                      {get; set;}
    public String       touchpointType                 {get; set;}
    public String       expiredHeader                  {get; set;}
    public String       takenHeader                    {get; set;}
    public String       thankYouHeader                 {get; set;}
    public String       expiredHeader2                 {get; set;}
    public String       takenHeader2                   {get; set;}
    public String       thankYouHeader2                {get; set;}
    public String       expiredDescription             {get; set;}
    public String       takenDescription               {get; set;}
    public String       thankYouDescription            {get; set;}
    public String       iframeHeader                   {get; set;}
    public String       iframeSubheader                {get; set;}
    public String       iframeSubheaderVar             {get; set;}
    public String       labelLeft1to5                  {get; set;}
    public String       labelRight1to5                 {get; set;}
    public String       labelLeft0to10                 {get; set;}
    public String       labelRight0to10                {get; set;}
    public String       labelDontKnow1to5              {get; set;}
    public String       surveyId                       {get; set;}
    public String       caseId                         {get; set;}
    public String       contactId                      {get; set;}
    public String       orderRef                       {get; set;}
    public String       contactFirstName               {get; set;}
    public String       iframe                         {get; set;}
    public String       surveySubHeader                {get; set;}
    public String       submitButtonText               {get; set;}
    public String       requiredLabel                  {get; set;}
    public String       legalNoticeText                {get; set;}
    public String       legalNoticeURL                 {get; set;}
    public String       privacyStatementText           {get; set;}
    public String       privacyStatementURL            {get; set;}
    public String       templateId                     {get; set;}
    public String       refTemplateId                  {get; set;}
    public String       contactMeDescription           {get; set;}
    public String       contactMeHeader                {get; set;}
    public String       contactButtonText              {get; set;}
    public String       doNotContactButtonText         {get; set;}
    public String       preview                        {get; set;}
    public String       renderSurveyPreview            {get; set;}
    public String       templateURL                    {get; set;}
    public String       anonymousAnswer                {get; set;}
    public String       baseURL                        {get; set;}
    public String       userId                         {get; set;}
    public String       userName                       {get; set;}
    public Boolean      isExpired                      {get; set;}
    public Boolean      isTaken                        {get; set;}
    public Boolean      thankYouRendered               {get; set;}
    public Boolean      lowScoreRendered               {get; set;}
    public Boolean      optOutRendered                 {get; set;}
    public Boolean      optOutConfirmRendered          {get; set;}
    public Boolean      globalValidationFailed         {get; set;}
    public String       brand                          {get; set;}
    public String       salesOrg                       {get; set;}
    
    public Integer      allQuestionsSize               {get; set;}
    
    public List<String>       newOrder                 {get; set;}
    public List<question>     allQuestions             {get; set;}
    public List<String>       portalMessages           {get; set;}
    
    public SurveyTaker__c survey;
    public Survey__c    surveyTemplate;
    public Contact      contact;

/***********************************************************************************
* Retrieves the list of questions, the survey name, after retrieving the 
* necessary parameters from the url.
***********************************************************************************/   
//------------------------------------------------------------------------------// 
    public CALCF_CastrolSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        templateId   = Apexpages.currentPage().getParameters().get('tId');
        refTemplateId= Apexpages.currentPage().getParameters().get('rtId');
        caseId       = Apexpages.currentPage().getParameters().get('caId');
        secondLng    = Apexpages.currentPage().getParameters().get('lng');
        contactId    = Apexpages.currentPage().getParameters().get('cId');
        orderRef     = Apexpages.currentPage().getParameters().get('oRef');
        surveyId     = Apexpages.currentPage().getParameters().get('Id');
        salesOrg     = Apexpages.currentPage().getParameters().get('sOrg'); 
        preview      = Apexpages.currentPage().getParameters().get('preview') == 'true' ? 'true' : 'false';
        iframe       = Apexpages.currentPage().getParameters().get('w') == '1' ? 'true' : 'false';
        iframeSubheadervar = '';
        thankYouRendered = Apexpages.currentPage().getParameters().get('thanks') == 'true';
        lowScoreRendered = Apexpages.currentPage().getParameters().get('sry') == 'true';

        if(caseId == null || caseId.length()<5){
            caseId = 'none';
        }
        if(contactId == null || contactId.length()<5){
            contactId = 'none';
        }

        // By default the preview is not showing up
        globalValidationFailed = false;
        renderSurveyPreview = 'false';
        
        init();
    } 

    public void init()
    {
        survey = new SurveyTaker__c();
        if(surveyId != null){
           
           List<SurveyTaker__c> surveys = [select Id, Record_Type_Name__c , Survey_Time__c, Survey_Taken_Date_Time__c, Survey_Expiry_Date__c, Survey_Status__c,
           Portal_Messages__c, Survey__r.Country_Name_EN__c, Survey__r.Privacy_Statement_URL__c, Survey__r.Legal_Notice_URL__c, Contact_Dissatisfied_Customer__c, Is_Low_Scoring__c from SurveyTaker__c where Id =:surveyId];
           
           topbarCountryEn      = surveys[0].Survey__r.Country_Name_EN__c;
           privacyStatementURL  = surveys[0].Survey__r.Privacy_Statement_URL__c;
           legalNoticeURL       = surveys[0].Survey__r.Legal_Notice_URL__c;

            if(!surveys.isEmpty()){
                survey = surveys.get(0);

                String portalMessagesTemp = String.valueOf(survey.Portal_Messages__c);
                if(!String.isBlank(portalMessagesTemp)){
                    portalMessages = portalMessagesTemp.split('-;');
                }
            }

            // survey can be set in batch so ensuring that if batch process hasnt run to update status, we also check expiry date directly. 
            if(survey.Survey_Status__c == 'Expired' || survey.Survey_Expiry_Date__c < System.now()){
                isExpired = true;
            } 
            else if(survey.Survey_Status__c == 'Taken'){
                isTaken = true;
            } 
        }

        if (templateId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<question>();
            initQuestions();

            setSurveyNameAndThankYou(templateId);
            anonymousAnswer = 'Anonymous';
            //isInternal =true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
			
            if(thankYouRendered == null) {
                thankYouRendered=false;
            }
            
            if(lowScoreRendered == null) {
                lowScoreRendered=false;
            }
        }
    }


    // POST GO-LIVE CHANGE
    // GW - 18-APR-2016
    // Set the touchpoint to sent when the page is viewed for orders
    // Set the last survey date on contact
    public void setSurveyStatus(){ 
        
        if(survey.Record_Type_Name__c == 'Orders' && isExpired != true && isTaken != true && survey.Id != null && contactId != 'none' && preview == 'false' ){                   
            survey.Survey_Status__c = 'Sent';
            new CALCF_CastrolSurveyController.GuestUserSharingRule(survey).updateSurvey();   
             
            list<contact> surveyContact = [SELECT Id, Last_Surveyed_Date__c FROM Contact WHERE Id =: contactId];        
            contact = surveyContact.get(0);

            if(surveyContact!=null && !surveyContact.isEmpty()) {
                Contact con = surveyContact[0];
                con.Last_Surveyed_Date__c = date.today();               
                new CALCF_CastrolSurveyController.GuestUserSharingRule(contact).updateContact(); 
            }
        }
    }

/***********************************************************************************
* Sets the survey's name variable
* param: sID   The survey ID as specified in the DB
***********************************************************************************/   
//----------------------------------------------------------------------------//    
    public void setSurveyNameAndThankYou(String sId){
        Survey__c s =   [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, 
                        thankYouLink__c, Survey_Container_CSS__c, Castrol_Header__c, 
                        Castrol_Subheader__c, Submission_Button_Text__c, Page_Title__c, Topbar_Title__c, 
                        Language_Code__c, Country_Name__c, EN_Reference_Template__c, EN_Reference_Template__r.Language_Code__c, 
                        Required_Field_Label__c, Privacy_Statement_Text__c, Privacy_Statement_URL__c, Legal_Notice_Text__c, 
                        Legal_Notice_URL__c, lcf_Channel__c, Expired_Header__c, Taken_Header__c, Thank_You_Header__c, 
                        Expired_Header2__c, Taken_Header2__c, Thank_You_Header2__c, Expired_Description__c, 
                        Taken_Description__c, Thank_You_Description__c, Thank_You_Description_Iframe__c, Iframe_Header__c, 
                        Iframe_Subheader__c, Label_Left_1_to_5__c, Label_Right_1_to_5__c, Label_Dont_Know_1_to_5__c, 
                        Label_Left_0_to_10__c, Label_Right_0_to_10__c, Contact_Me_Description__c, Contact_Me_Header__c, 
                        Contact_Button_Text__c, Do_Not_Contact_Button_Text__c, CALCF_Brand__c
                        FROM Survey__c WHERE Id =:sId];

        surveyName              = s.Name;
        pageTitle               = s.Page_Title__c;
        topbarTitle             = s.Topbar_Title__c;
        languageCode            = s.Language_Code__c;
        topbarCountry           = s.Country_Name__c;
        surveyHeader            = s.Castrol_Header__c;
        surveySubHeader         = s.Castrol_Subheader__c;
        submitButtonText        = s.Submission_Button_Text__c;
        requiredLabel           = s.Required_Field_Label__c;
        privacyStatementText    = s.Privacy_Statement_Text__c;
        legalNoticeText         = s.Legal_Notice_Text__c;
        expiredHeader           = s.Expired_Header__c;
        takenHeader             = s.Taken_Header__c;
        thankYouHeader          = s.Thank_You_Header__c;
        expiredHeader2          = s.Expired_Header2__c;
        takenHeader2            = s.Taken_Header2__c;
        thankYouHeader2         = s.Thank_You_Header2__c;
        expiredDescription      = s.Expired_Description__c;
        takenDescription        = s.Taken_Description__c;
        thankYouDescription     = s.Thank_You_Description__c;
        touchpointType          = s.lcf_Channel__c;
        labelLeft1to5           = s.Label_Left_1_to_5__c;
        labelRight1to5          = s.Label_Right_1_to_5__c;
        labelDontKnow1to5       = s.Label_Dont_Know_1_to_5__c;
        labelLeft0to10          = s.Label_Left_0_to_10__c;
        labelRight0to10         = s.Label_Right_0_to_10__c;
        templateURL             = s.URL__c+'id='+sId;
        contactMeDescription    = s.Contact_Me_Description__c;
        contactMeHeader         = s.Contact_Me_Header__c;
        contactButtonText       = s.Contact_Button_Text__c;
        doNotContactButtonText  = s.Do_Not_Contact_Button_Text__c;
        brand                   = s.CALCF_Brand__c;

        if(iframe == 'true') {
            thankYouDescription = s.Thank_You_Description_Iframe__c;
            iframeHeader        = s.Iframe_Header__c;
            iframeSubheader     = s.Iframe_Subheader__c;
            if(touchpointType == 'Ordering') {
                iframeSubheaderVar  = orderRef;
            }
        } else {
            thankYouDescription = s.Thank_You_Description__c;
        }
    }

    //query contact first name for Thank you message
    public String getContactName(){
    
        
        if (ContactId <> 'none' && ContactId <> null && ContactId.Left(3) == '003'){
            List<Contact> tempContact = [SELECT Id, FirstName 
                                   FROM Contact
                                   WHERE Id =: ContactId];
            contactFirstName = tempContact[0].FirstName;
        } 
        else {
            contactFirstName = '';
        }  
        return contactFirstName;                
    }

/***********************************************************************************
* Class: question
* Retrieves the question information and puts it in the question object
***********************************************************************************/   
//----------------------------------------------------------------------------//        
    public class question{
        public String   name                   {get; set;}
        public String   id                     {get; set;}
        public String   question               {get; set;}
        public String   orderNumber            {get; set;}
        public String   choices                {get; set;}
        public String   selectedOption         {get; set;}
        public String   questionType           {get; set;}    
        public String   renderFreeText         {get; set;}
        public String   renderSelectRadio      {get; set;}
        public String   renderSelectCheckboxes {get; set;} 
        public String   renderSelectRow        {get; set;}
        public String   singleOptionsForChart  {get; set;}
        public String   questionHeader         {get; set;}
        public String   questionPlaceholderText{get; set;}
        
        public Boolean  required               {get; set;}
        public Boolean  is1to5                 {get; set;}
        public Boolean  is0to10                {get; set;}
        public Boolean  isFreeText             {get; set;}
        public Boolean  validationFailed       {get; set;}
        
        public List<String> strList            {get; set;}
        public List<SelectOption> rowOptions   {get; set;}     
        public List<String> selectedOptions    {get; set;}
        public List<SelectOption> singleOptions{get; set;}
        public List<SelectOption> multiOptions {get; set;}
        
        public question(Survey_Question__c sq) {
            name = sq.Name;
            id = sq.Id;
            question = sq.Native_Language_Question__c;
            orderNumber = String.valueOf(sq.OrderNumber__c+1);
            choices = sq.Choices__c;
            required = sq.Required__c;
            questionType = sq.Type__c;
            questionHeader = sq.Question_Header__c;
            questionPlaceholderText = sq.Freetext_Placeholder_Text__c;

            singleOptionsForChart = ' ';
            selectedOption = '';
            selectedOptions = new List<String>();
            validationFailed = false;
            if (sq.Type__c=='Single Select--Vertical'){
                renderSelectRadio='true';
                singleOptions = stringToSelectOptions(choices);

                renderSelectCheckboxes='false';
                renderFreeText='false';
                renderSelectRow = 'false';
                selectedOption = '';
                selectedOptions = new List<String>();

                is1to5      = false;
                is0to10     = false;
                isFreeText  = false;

                if(singleOptions.size() == 6){
                    is1to5      = true;
                } else if(singleOptions.size() == 11){
                    is0to10     = true;
                }

                                        
            }
            else if (sq.Type__c=='Multi-Select--Vertical'){        
                renderSelectCheckboxes='true';
                multiOptions = stringToSelectOptions(choices);
                renderSelectRadio='false';
                renderFreeText='false';
                renderSelectRow = 'false';
                selectedOption = '';
                selectedOptions = new List<String>();

                is1to5      = false;
                is0to10     = false;
                isFreeText  = false;
            }
            else if (sq.Type__c=='Single Select--Horizontal'){   
                renderSelectCheckboxes='false';
                rowOptions = stringToSelectOptions(choices);
                renderSelectRadio='false';
                renderFreeText='false';
                renderSelectRow = 'true';
                selectedOption = '';
                selectedOptions = new List<String>();    

                is1to5      = false;
                is0to10     = false;
                isFreeText  = false; 

                if(rowOptions.size() == 6){
                    is1to5      = true;
                } else if(rowOptions.size() == 11){
                    is0to10     = true;
                }
            }
            else if (sq.Type__c=='Free Text'){
                renderFreeText='true';
                renderSelectRadio='false';
                renderSelectCheckboxes='false';
                renderSelectRow = 'false';
                choices='';

                is1to5      = false;
                is0to10     = false;
                isFreeText  = true;
            }
        }
               
/***********************************************************************************
* Splits up the string as given by the user and adds each option
*  to a list to be displayed as option on the Visualforce page
*  param: str   String as submitted by the user
*  returns the List of SelectOption for the visualforce page
***********************************************************************************/   
//----------------------------------------------------------------------------//     
        private List<SelectOption> stringToSelectOptions(String str){
            if (str == '')
            {
                return new List<SelectOption>();
            }
            strList = str.split('\n');

            List<SelectOption> returnVal = new List<SelectOption>();
            Integer i = 0;
            for(String s: strList){
                if (s!='') {    
                    if (s != 'null' && s!= null) {
                        String sBis = s.replace(' ', '%20');
                        singleOptionsForChart += s.trim()+'|';
                        returnVal.add(new SelectOption(String.valueOf(i),s));
                        System.debug('*****VALUES: ' + s);
                        i++;
                    }
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
            return returnVal;
        } 
    }
     
/***********************************************************************************
* Fills up the List of questions to be displayed on the Visualforce page
***********************************************************************************/   
//----------------------------------------------------------------------------//  
    public void initQuestions() {
            qQuestion = '';
            qChoices ='';
        
        List<Survey_Question__c> allQuestionsObject = 
                                        [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, 
                                        s.OrderNumber__c, s.Name, s.Choices__c , s.Native_Language_Question__c, 
                                        s.Question_Header__c, s.Freetext_Placeholder_Text__c
                                        From Survey_Question__c s 
                                        WHERE s.Survey__c =: templateId ORDER BY s.OrderNumber__c];
        allQuestions = new List<question>();
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        // Make sure that the order number follow each other (after deleting a question, orders might not do so) 
        for (Survey_Question__c q : allQuestionsObject){
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            question theQ = new question(q);
            allQuestions.add(theQ);
        }
        allQuestionsSize = allQuestions.size();
    }   
    
    public void submitResults()
    {

        List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();

        Boolean showLowScore = false;
        globalValidationFailed = false;
        for (question q : allQuestions)
        {
            q.validationFailed = false;
            SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
            
            if (q.renderSelectRadio == 'true')
            {
                
                if (q.required &&  (q.selectedOption == null || q.selectedOption == ''))
                {
                    q.validationFailed = true;
                }
                
                if (q.selectedOption == null || q.selectedOption == '')
                {
                   sqr.Response__c = '';
                }
                else
                {
                   sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            else if (q.renderFreeText == 'true')
            {
                if (q.required && q.choices == '')
                {
                    q.validationFailed = true;
                }
                
                if(q.choices != ''){
                    survey.Survey_Has_Comments__c = true;
                } 
                
                System.debug('*****Select Radio ' + q.choices);
                
                sqr.Response__c = q.choices;
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
            else if (q.renderSelectCheckboxes == 'true')
            {
                if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0))
                {
                    q.validationFailed = true;
                }
                
                for (String opt : q.selectedOptions)
                {
                    sqr = new SurveyQuestionResponse__c();
                    if (opt == '' || opt == null)
                    {
                       sqr.Response__c = '';
                    }               
                    else
                    {   
                      sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            else if (q.renderSelectRow == 'true')
            {
                if (q.required && (q.selectedOption == null || q.selectedOption == ''))
                {
                    q.validationFailed = true;
                }
                
                if (q.selectedOption == null || q.selectedOption == '')
                {
                   sqr.Response__c = '';
                }
                else
                {
                   sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }

            sqr.lcf_Hideable_Response__c =  sqr.Response__c;

            if (q.validationFailed == true) {
                 globalValidationFailed = true;
            } 
            
            if(q.validationFailed == false && q.is0to10){
                if(q.selectedOption != '' && Integer.valueOf(q.selectedOption) <= 3){
                	survey.Contact_Dissatisfied_Customer__c = true; 
                    survey.Is_Low_Scoring__c = true;
                	showLowScore=true;                  
                }           
            }
        }
        if (globalValidationFailed == true){
            return;
        }
        if(AddSurveyTaker())
        {   

           if(!String.isBlank(survey.Id)){           	   
               survey.Survey_Status__c = 'Taken';
               survey.Survey_Taken_Date_Time__c = datetime.now();
               new CALCF_CastrolSurveyController.GuestUserSharingRule(survey).updateSurvey();
           } 
           
           // GW added - amending from above
           for (SurveyQuestionResponse__c sqr : sqrList){
               sqr.SurveyTaker__c = surveyId;
               if(!String.isBlank(survey.Id)){
                }
            }
           
            new CALCF_CastrolSurveyController.GuestUserSharingRule(sqrList).insertSurveyQuestions();
            
            lowScoreRendered=showLowScore; 
            thankYouRendered = lowScoreRendered ? false : true;
        }
    }
    
    public PageReference redirectUserToBrand(){
        contactMe();

        if (brand == 'aral') {
            return new PageReference('http://www.aral.de');
        } else {
            return new PageReference('http://www.castrol.com');
        }
	}

    public void contactMe(){
        lowScoreRendered=false;
        thankYouRendered=true;
        survey.Contact_Dissatisfied_Customer__c = true;
        survey.Contact_Status__c = 'Requires Contact';
        new CALCF_CastrolSurveyController.GuestUserSharingRule(survey).updateSurvey();      
    }
    
    public void doNotContactMe(){
        lowScoreRendered=false;
        thankYouRendered=true; 
        survey.Contact_Dissatisfied_Customer__c = false;
        new CALCF_CastrolSurveyController.GuestUserSharingRule(survey).updateSurvey();   
    } 

    public void optOut(){
        optOutRendered=true;          
        thankYouRendered=false; 
        optOutConfirmRendered=false;
        lowScoreRendered=false;
        isExpired=false;
        isTaken=false;
    }

    public void doOptOut(){
        optOutRendered=false;
        thankYouRendered=false;
        optOutConfirmRendered=true;
        if(survey.Id != null && contactId != 'none' && preview == 'false' ){
             
            list<contact> surveyContact = [SELECT Id, Survey_Opt_Out_Requested__c FROM Contact WHERE Id =: contactId];        
            contact = surveyContact.get(0);

            if(surveyContact!=null && !surveyContact.isEmpty()) {
                if (salesOrg == 'DE01') {
                        Contact con = surveyContact[0];
                        con.Survey_Opt_Out__c = true;
                        new CALCF_CastrolSurveyController.GuestUserSharingRule(con).updateContact(); 
                } else {
                Contact con = surveyContact[0];
                con.Survey_Opt_Out_Requested__c = true;
                new CALCF_CastrolSurveyController.GuestUserSharingRule(con).updateContact(); 
            }
            }
        }
    }

    public void doNotOptOut(){
        if(survey.Survey_Status__c == 'Taken'){
            isTaken = true;
            optOutRendered=false;
            thankYouRendered=false;  
        }
        else {
            optOutRendered=false;
            thankYouRendered=false;  
        }  
    }  
    
    private Boolean AddSurveyTaker()
    {
        String userId;
        
        if (surveyId == null)
        {
            return false;
        }
        if(caseId.toUpperCase() =='NONE'|| caseId.length()<5)
          caseId = null;    
        if(contactId.toUpperCase() =='NONE'|| contactId.length()<5)
          contactId = null;         
        if (anonymousAnswer != 'Anonymous')
        {
            userId = UserInfo.getUserId();
        }
        else
        {
            userId = null;
        }
        
        if(anonymousAnswer != 'Anonymous' && (contactId != null || caseId != null))
        {
            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Contact__c=:contactId and Survey__c=:surveyId and Case__c = :caseId and User__c=:UserId];
            if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));
                
                return false;
            }
        }
        return true;
    }
    private without sharing class GuestUserSharingRule{
        SurveyTaker__c survey;
        public GuestUserSharingRule(SurveyTaker__c survey){
            this.survey = survey;
        }
        public void updateSurvey(){
            update survey;
        }
        Contact contact;
        public GuestUserSharingRule(Contact contact){
            this.contact = contact;
        }
        public void updateContact(){
            update contact;
        }
        List<SurveyQuestionResponse__c> questionResponse;
        public GuestUserSharingRule(List<SurveyQuestionResponse__c> questionResponse){
            this.questionResponse = questionResponse;
        }
        public void insertSurveyQuestions(){
            insert questionResponse;
        }
    }
}