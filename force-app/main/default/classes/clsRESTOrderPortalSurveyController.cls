/************************************************************************************************************
* Description : API for creating Survey. Contains logic for matching contacts.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*
* 2017-FEB-13   1.0                 Frantisek Kolacny   Initial version
* 2018-JUN-02   1.1                 Maros Zilka         Added integration id format for PL01, RO01
* 2018-SEP-04   1.2                 Maros Zilka         SonarQube Fixes + styling
* 2020-May-15   1.3                 Rahma Belghouti     Fix Summer 20 critical update issue
*************************************************************************************************************/

@RestResource(urlMapping='/castrolordersurvey')
global with sharing class clsRESTOrderPortalSurveyController {

    global class PortalRequestDataType{
        public String ExternalContactId;
        public String ExternalUserId;
        public String ContactFirstName;
        public String ContactLastName;
        public String ContactEmailAddress;
        public String ExternalAccountId;
        public String ExternalAccountName;
        public String SalesOrg;
        public String DivCode;
        public String DistChannel;
        public String PortalBrand;
        public String Locale;
        public String LanguageCode;
        public String ReferenceNumber;
        public String Source;
        public String ExternalUserSource;
        public String PortalMessages;
        public String ShipTo;
        public String Apikey;
        public String SourceURL;
    }

    global class PortalReturnDataType {
        public String ContactId;
        public String AccountId;
        public String surveyURL;
        public String Errors;
    }

    @HttpGet
    global static void doGet() {

        System.debug('REST API: get service');

        PortalRequestDataType data = new PortalRequestDataType();
        data.SourceURL = RestContext.request.params.get('SourceURL');
        data.ExternalContactId = RestContext.request.params.get('ExternalContactId');
        data.ExternalUserId = RestContext.request.params.get('ExternalUserId');
        data.ContactFirstName = RestContext.request.params.get('ContactFirstName');
        data.ContactLastName = RestContext.request.params.get('ContactLastName');
        data.ContactEmailAddress = RestContext.request.params.get('ContactEmailAddress');
        data.ExternalAccountId = RestContext.request.params.get('ExternalAccountId');
        data.ExternalAccountName = RestContext.request.params.get('ExternalAccountName');
        data.SalesOrg = RestContext.request.params.get('SalesOrg');
        data.DivCode = RestContext.request.params.get('DivCode');
        data.DistChannel = RestContext.request.params.get('DistChannel');
        data.PortalBrand = RestContext.request.params.get('Brand');
        data.Locale = RestContext.request.params.get('Locale');
        data.LanguageCode = RestContext.request.params.get('LanguageCode');
        data.ReferenceNumber = RestContext.request.params.get('ReferenceNumber');
        data.Source = RestContext.request.params.get('Source');
        data.ExternalUserSource = RestContext.request.params.get('ExternalUserSource');
        data.PortalMessages = RestContext.request.params.get('PortalMessages');
        data.ShipTo = RestContext.request.params.get('ShipTo');
        data.Apikey = RestContext.request.params.get('Apikey');
        String callback = RestContext.request.params.get('callback');

        system.debug(data);

        Contact contact;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/javascript');
        PortalReturnDataType httpReturn = new PortalReturnDataType();
        
        // Class name for logger.
        String className = 'clsRESTOrderPortalSurveyController';
        
        try{
            // Is API active ?
            if(lcf_settings__c.getInstance().Order_Survey_API_Active__c == false) {
                
                httpReturn.Errors = Label.LCF_Rest_APINotActive;
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;
            }
            
            // Validate input data. 
            string validationString = validate(data);
            if(String.isNotBlank(validationString)) {

                httpReturn.Errors = Label.LCF_Rest_RequiredParamMissing + validationString;
                
                // Custom Logger.
                clsCustomDebugLogger.logApiError(httpReturn.Errors, className, String.valueOf(data));
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;
            }
            
            //Distribution Channel and Division Code are concatenated prior to create Business Unit via UKMS mapping translation
            String divCodeName = getDivCodeName(data.DistChannel + data.DivCode);
            String salesforceDivCode = getDivCodeTranslation(data.DistChannel + data.DivCode);
            String salesforceSalesOrganization = getSalesOrgTranslation(data.SalesOrg);
            String deDeplicationKey = data.ContactFirstName.toUpperCase() + data.ContactLastName.toUpperCase() + data.ContactEmailAddress.toUpperCase();
            String channel = 'Orders';
            String ReferenceNumber = data.ReferenceNumber != null ? data.ReferenceNumber : '';
            
            // Api Key check.
            if(data.Apikey != lcf_settings__c.getInstance().Portal_API_Key__c){

                httpReturn.Errors = Label.LCF_Rest_APIKEYNotCorrect;
                
                // Custom Logger.
                clsCustomDebugLogger.logApiWarning(httpReturn.Errors, className, String.valueOf(data));
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;
            }
            
            // Check if we have translated Sales Org and if it s active.
            if (salesforceSalesOrganization == '' || salesforceDivCode == '') {
                httpReturn.Errors = Label.LCF_Rest_Not_Supported_Sales_Org_Or_Div_Code;

                clsCustomDebugLogger.logApiError(httpReturn.Errors, className, String.valueOf(data));

                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;
            }

            // TODO: Move this to custom settings

            String accountKey;
            String integrationConstant;
            List<Account> accounts;
            
            switch on salesforceSalesOrganization {
                when 'PL01' {
                    // 033 for PL01 accounts
                    integrationConstant = '033';
                }
                when 'RO01' {
                    // 017 for RO01 accounts
                    integrationConstant = '017';
                }
                when else {
                    // 020 is default value for other countries
                    integrationConstant = '020';
                }
            }
            
            accountKey = data.ExternalAccountId + 
                integrationConstant + 
                salesforceSalesOrganization + 
                salesforceDivCode;
            
            // Another exception for RO01 which appends type of account to Integration ID (4 chars)
            // Even if ignoring last 4 chars it should be unique match
            if (salesforceSalesOrganization == 'RO01') {
                accountKey += '____';
                accounts = [SELECT Id
                            FROM Account
                            WHERE Integration_Id__c LIKE :accountKey
                            AND Marked_for_Deletion__c = false
                            AND (
                                Business_Unit__c IN ('Lubricants - Industrial', 'Lubricants - Automotive')
                            	OR 
                                (Sales_Organisation__c = 'PL01' AND Business_Unit__c = 'Lubricants - Export')
                            )
                ];

            } else {

                accounts = [SELECT Id
                            FROM Account
                            WHERE Integration_Id__c = :accountKey
                            AND Marked_for_Deletion__c = false
                            AND (
                                Business_Unit__c IN ('Lubricants - Industrial', 'Lubricants - Automotive')
                            	OR 
                                (Sales_Organisation__c = 'PL01' AND Business_Unit__c = 'Lubricants - Export')
                            )
                ];

            }

            // If there is no account in system DO NOT SURVEY 
            if (accounts.isEmpty()) {
                httpReturn.Errors = Label.LCF_Rest_AccountNotExist;
                
                // Custom Logger.
                clsCustomDebugLogger.logApiWarning(httpReturn.Errors, className, String.valueOf(data));
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;         
            }
            
            // Look-up Contact source for new request.
            List<Contact_Source__c> contactSource = [SELECT Id, Contact__c, Review__c, Review_Comments__c,  Account_ERP_ID__c, Account_Integration_Id__c, Business_Unit__c, 
                                                    Account_Name__c, Contact_Deduplication_Id__c, Contact_Email__c,Contact_First_Name__c, Contact_Last_Name__c, External_Contact_Id__c,
                                                    External_User_Id__c, Sales_Organisation__c, Source_System__c, Reference__c, Source_URL__c 
                                                    FROM Contact_Source__c WHERE External_User_Id__c = :data.ExternalUserId AND User_Source__c = :data.ExternalUserSource];
            
            if(!contactSource.isEmpty()){
                
                // Not all contact source entries have Contact populated. 
                if(!String.isBlank(contactSource.get(0).Contact__c)){
                    
                    // If Contact field is populated, look-up for Contact in salesforce.
                    String contactId = String.valueOf(contactSource.get(0).Contact__c); 
                    List<Contact> contacts = [SELECT Id, Last_Surveyed_Date__c, Survey_Opt_Out__c, Next_Surveyable_Date__c, Test_Contact__c FROM Contact WHERE Id = :contactId];    
                    
                    if(contacts.isEmpty()){
                        // If there is no contact returned end the flow and flag record in contact source.
                        contactSource.get(0).Review__c = true;
                        contactSource.get(0).Review_Comments__c = Label.LCF_Rest_WrongContactInContactSource;
                        update contactSource;
                        
                        // End the flow, we do not have contact where to send survey.
                        httpReturn.Errors = Label.LCF_Rest_NoContactAssociated;
                        res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                        return;
                    }

                    // If there is one contact connected to one record in contact source,
                    // we can will send survey for this contact.
                    if(contacts.size() == 1){
                        contact = contacts.get(0);
                    }

                }else{
                    
                    if(contactSource.get(0).Review__c == true){
                        
                        // Update latest information for reviewer.
                        Contact_Source__c sourceToUpdate = contactSource.get(0);
                        sourceToUpdate.Account_ERP_ID__c = data.ExternalAccountId;
                        sourceToUpdate.Account_Integration_Id__c = accountKey;
                        sourceToUpdate.Business_Unit__c = divCodeName;
                        sourceToUpdate.Account_Name__c = data.ExternalAccountName;
                        sourceToUpdate.Contact_Deduplication_Id__c = deDeplicationKey;
                        sourceToUpdate.Contact_Email__c = data.ContactEmailAddress;
                        sourceToUpdate.Contact_First_Name__c = data.ContactFirstName;
                        sourceToUpdate.Contact_Last_Name__c = data.ContactLastName;
                        sourceToUpdate.External_Contact_Id__c = data.ExternalContactId;
                        sourceToUpdate.External_User_Id__c = data.ExternalUserId;
                        sourceToUpdate.Sales_Organisation__c = salesforceSalesOrganization;
                        sourceToUpdate.Source_System__c =  data.Source;
                        sourceToUpdate.Reference__c =  data.ReferenceNumber;
                        sourceToUpdate.Source_URL__c =  data.SourceURL;
                        sourceToUpdate.CALCF_Ship_To__c = data.ShipTo;
                        
                        if(data.ContactEmailAddress != null && data.ContactEmailAddress != '') {
                            
                            List<Contact> contactsByDeDuplication = [SELECT Id, Last_Surveyed_Date__c, Survey_Opt_Out__c, Next_Surveyable_Date__c, Test_Contact__c 
                                                                    FROM Contact WHERE Contact_Deduplication_Id__c = :deDeplicationKey];
                            
                            if(contactsByDeDuplication.isEmpty()){
                                sourceToUpdate.Review_Comments__c = Label.LCF_Rest_NoContactForContactSource;
                                httpReturn.Errors = Label.LCF_Rest_NoContactAssociated;
                                // End the flow, we do not have contact where to send survey.
                                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                                update sourceToUpdate;
                                return;
                                
                            }
                            if(contactsByDeDuplication.size() > 1){
                                sourceToUpdate.Review_Comments__c = Label.LCF_Rest_MultipleContactsForContactSource;
                                httpReturn.Errors = Label.LCF_Rest_MultipleContactsAssociated;
                                // End the flow, we do not have contact where to send survey.
                                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                                update sourceToUpdate;
                                return;
                            }  
                            if(contactsByDeDuplication.size() == 1){
                                sourceToUpdate.Review_Comments__c = '';
                                sourceToUpdate.Review__c = false;
                                contact = contactsByDeDuplication.get(0);
                                sourceToUpdate.Contact__c = contact.Id;
                                update sourceToUpdate;
                            }               
                        }else{
                            httpReturn.Errors = Label.LCF_Rest_NoContactAssociated;
                            res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                            update sourceToUpdate;
                            return;
                        }
                    }
                }
            }
            
            // If there is no record in Contact Source.
            if(contactSource.isEmpty()) {
                
                // Without an email address we risk matching to the wrong Contacts.
                if(data.ContactEmailAddress == null || data.ContactEmailAddress == '') {
                    
                    httpReturn.Errors = Label.LCF_Rest_NoContactEmailAddress;
                    res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');

                    return;
                }
                
                // Create record in Contact Source Table. 
                Contact_Source__c newContactSource = new Contact_Source__c();
                newContactSource.Account_ERP_ID__c = data.ExternalAccountId;
                newContactSource.Account_Integration_Id__c = accountKey;
                newContactSource.Business_Unit__c = divCodeName;
                newContactSource.Account_Name__c = data.ExternalAccountName;
                newContactSource.Contact_Deduplication_Id__c = deDeplicationKey;
                newContactSource.Contact_Email__c = data.ContactEmailAddress;
                newContactSource.Contact_First_Name__c = data.ContactFirstName;
                newContactSource.Contact_Last_Name__c = data.ContactLastName;
                newContactSource.External_Contact_Id__c = data.ExternalContactId;
                newContactSource.External_User_Id__c = data.ExternalUserId;
                newContactSource.Sales_Organisation__c = salesforceSalesOrganization;
                newContactSource.Source_System__c =  data.Source;
                newContactSource.User_Source__c = data.ExternalUserSource;
                newContactSource.Reference__c =  data.ReferenceNumber;
                newContactSource.Source_URL__c =  data.SourceURL;
                newContactSource.CALCF_Ship_To__c = data.ShipTo;
                
                List<Contact> contactsByDeDuplication = [SELECT Id, Last_Surveyed_Date__c, Survey_Opt_Out__c, Next_Surveyable_Date__c, Test_Contact__c 
                                                        FROM Contact WHERE Contact_Deduplication_Id__c = :deDeplicationKey];
                                                        
                if(contactsByDeDuplication.isEmpty()) {
                    
                    // If there is no contact found.
                    newContactSource.Review__c = true;
                    newContactSource.Review_Comments__c = Label.LCF_Rest_NoContactForContactSource;
                    new clsRESTOrderPortalSurveyController.GuestUserSharingRule(newContactSource).insertContactSource();
                        
                    // End the flow, we do not have contact where to send survey.
                    httpReturn.Errors = Label.LCF_Rest_NoContactAssociated;
                    res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                    return;
                }
                
                                                                    
                if(contactsByDeDuplication.size() > 1){
                    
                    // Multiple contacts for Contact Source record. 
                    newContactSource.Review__c = true;
                    newContactSource.Review_Comments__c = Label.LCF_Rest_MultipleContactsForContactSource;
                    new clsRESTOrderPortalSurveyController.GuestUserSharingRule(newContactSource).insertContactSource();
                        
                    // End the flow, we do not have contact where to send survey.
                    httpReturn.Errors = Label.LCF_Rest_MultipleContactsAssociated;
                    res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                    return;
                }
                
                                                                    
                if(contactsByDeDuplication.size() == 1){
                    newContactSource.Contact__c = contactsByDeDuplication.get(0).Id;
                    new clsRESTOrderPortalSurveyController.GuestUserSharingRule(newContactSource).insertContactSource(); 
                    contact = contactsByDeDuplication.get(0);
                }
                
            }        
            
            if(contact == null){
                
                // End the flow, we do not have contact where to send survey.
                httpReturn.Errors = Label.LCF_Rest_NoContactAssociated;
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;
            }
            
            if (data.ExternalContactId.length() < 50) {
                contact.CA_Portal_Id__c = data.ExternalContactId;
                new clsRESTOrderPortalSurveyController.GuestUserSharingRule(contact).updateContact();   
        	}
            
            // Test Mode check
            if(lcf_settings__c.getInstance().Test_Mode__c == true){
                
                // If the LCF is in Test Mode, it will only process contact marked as Test Contacts.
                if(contact.Test_Contact__c == false){
                    httpReturn.Errors = Label.LCF_Rest_Test_Mode;
                    
                    // Custom Logger.
                    clsCustomDebugLogger.logApiWarning(httpReturn.Errors, className, String.valueOf(data));
                    res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                    return;   
                }                   
            }
            
            // Checking for relationships      
            List<Contact> relatedContacts = [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accounts.get(0).Id)];
            Boolean contactFound = false;
            for(Contact con : relatedContacts){
                
                if(con.Id == contact.Id){                                                       
                    contactFound = true;
                    break;              
                }
            }
            
            if(!contactFound){
                // If there is no realtionship created, create one.
                AccountContactRelation rel = new AccountContactRelation();
                rel.AccountId = accounts.get(0).Id;
                rel.ContactId = contact.Id;
                insert rel;
            }
            

            
            // Check do not survey period and next surveyable date.
            Integer doNotSurveyPeriod = Integer.valueOf(lcf_settings__c.getInstance().Do_Not_Survey_Period__c);
            if( (contact.Last_Surveyed_Date__c == null || contact.Last_Surveyed_Date__c <= datetime.now().addDays(-doNotSurveyPeriod)) 
                && contact.Survey_Opt_Out__c == false 
                && (contact.Next_Surveyable_Date__c == null || contact.Next_Surveyable_Date__c <= datetime.now().date())){
                
            List<Survey__c> template;
            String brand;
            
                if (data.PortalBrand == 'aral') {
                    brand = 'aral';
                } else {
                    brand = 'castrol';
                }
                
                
                template = [SELECT Id FROM Survey__c WHERE 
                            Sales_Organization__c = :salesforceSalesOrganization AND 
                            Language_Code__c = :data.LanguageCode AND 
                            Active__c = true AND 
                            lcf_Channel__c = 'Orders' AND 
                            CALCF_Brand__c = :brand 
                            order by LastModifiedDate desc limit 1];
                            
                if(template.isEmpty()){
                    
                    // End the flow, we do not have active template for selected language.
                    httpReturn.Errors = Label.LCF_Rest_NoTemplateAvailable;
                    res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                    return;
                }
                
                // If there is Contact and Survey template and all others conditions are satisfied create survey.
                RecordType recordType = [select Id from RecordType where SobjectType = 'SurveyTaker__c' and DeveloperName = 'Orders'];
                SurveyTaker__c surveyRequest = new SurveyTaker__c();
                
                surveyRequest.RecordTypeId = recordType.Id;
                surveyRequest.Contact__c = contact.Id;
                surveyRequest.Reference_Number__c = ReferenceNumber;            
                surveyRequest.Portal_Messages__c = data.PortalMessages;      
                surveyRequest.Order_Ship_To__c = data.ShipTo;
                surveyRequest.Source_System__c = data.Source;
                surveyRequest.Survey_Status__c = 'Pending';
                surveyRequest.Mode__c = 'Online';
                surveyRequest.Account__c = accounts.get(0).Id;
                surveyRequest.Sales_Organisation__c = salesforceSalesOrganization;
                surveyRequest.survey__c = template.get(0).Id;
                
                   //insert surveyRequest;
                   List<SurveyTaker__c> newSurvey = new clsRESTOrderPortalSurveyController.GuestUserSharingRule(surveyRequest).insertSurvey(); 
                   
                // Logic on URL here to prevent having to perform SOQL again.
                httpReturn.ContactId = contact.Id;
                httpReturn.AccountId = accounts.get(0).Id;
                httpReturn.surveyURL = newSurvey.get(0).IFrame_URL__c;

                
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                
            }else{
                httpReturn.Errors = Label.RestResp_NoSurveyRequired;
                res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
                return;         
            }
        }catch(exception e){
            
            System.debug(e);
            httpReturn.Errors = 'An exception occured, for details see logs';
            
            // Custom Logger.
            clsCustomDebugLogger.logApiError(e, httpReturn.Errors, className, String.valueOf(data));
            res.responseBody = Blob.valueOf(callback + '(' + JSON.serialize(httpReturn) + ')');
            return;
        }
    }

    // Check all mandatroy parameters in request.
    private static string validate(PortalRequestDataType data){
        
        String restult = '';
        
        if(String.isEmpty(data.ExternalContactId)){
            restult = restult + 'ExternalContactId ';
        }
        
        if(String.isEmpty(data.ExternalUserId)){
            restult = restult + 'ExternalUserId ';
        }
        
        if(String.isEmpty(data.ContactFirstName)){
            restult = restult + 'ContactFirstName ';
        }
        
        if(String.isEmpty(data.ContactLastName)){
            restult = restult + 'ContactLastName ';
        }
        
        if(String.isEmpty(data.ContactEmailAddress)){
            restult = restult + 'ContactEmailAddress ';
        }
        
        if(String.isEmpty(data.ExternalAccountId)){
            restult = restult + 'ExternalAccountId ';
        }
        
        if(String.isEmpty(data.SalesOrg)){
            restult = restult + 'SalesOrg ';
        }
        
        if(String.isEmpty(data.DivCode)){
            restult = restult + 'DivCode ';
        }

        if(String.isEmpty(data.DistChannel)){
            restult = restult + 'DistChannel ';
        }       
        
        if(String.isEmpty(data.Locale)){
            restult = restult + 'Locale ';
        }
        
        if(String.isEmpty(data.LanguageCode)){
            restult = restult + 'LanguageCode ';
        }
        
        if(String.isEmpty(data.ExternalUserSource)){
            restult = restult + 'ExternalUserSource ';
        }
        
        if(String.isEmpty(data.Apikey)){
            restult = restult + 'Apikey ';
        }
        
        return restult;
    }
    
    // Find Div code Name
    private static String getDivCodeName(String key) {
        // Get lists from custom settings.
        List<UKMS_DIV_CODE_MAPPING__c> lstDivCodeMapping = UKMS_DIV_CODE_MAPPING__c.getall().values();
        for (UKMS_DIV_CODE_MAPPING__c row : lstDivCodeMapping) {
            
            if (row.Source_System_Code__c == key && row.Active__c == true) {
                return row.Div_Code_Name__c;
            }
        }

        return '';
    }
    
    // Find Salesforce equivalent to external system Div code.
    private static String getDivCodeTranslation(String key) {
        // Get lists from custom settings. 
        List<UKMS_DIV_CODE_MAPPING__c> lstDivCodeMapping = UKMS_DIV_CODE_MAPPING__c.getall().values();
        for(UKMS_DIV_CODE_MAPPING__c row : lstDivCodeMapping){
            
            if (row.Source_System_Code__c == key && row.Active__c == true) {
                return row.Salesforce_Code__c;
            }
        }

        return '';
    }
    
    // Find Salesforce equivalent to external system Sales organization.
    private static String getSalesOrgTranslation(String key) {
        // Get lists from custom settings. 
        List<UKMS_SALES_ORG_MAPPING__c> lstSalesOrgMapping = UKMS_SALES_ORG_MAPPING__c.getall().values();
        for (UKMS_SALES_ORG_MAPPING__c row : lstSalesOrgMapping) {
            
            if (row.Source_System_Code__c == key && row.Active__c == true) {
                return row.Salesforce_Code__c;
            }
        }

        return '';
    }
     private without sharing class GuestUserSharingRule{
        Contact contact;
        public GuestUserSharingRule(Contact contact){
            this.contact = contact;
        }
        public void updateContact(){
            update contact;
        }
        Contact_Source__c contactSource;
        public GuestUserSharingRule(Contact_Source__c contactSource){
            this.contactSource = contactSource;
        }
        public void insertContactSource(){
            insert contactSource;
        }
        SurveyTaker__c survey;
        public GuestUserSharingRule(SurveyTaker__c survey){
            this.survey = survey;
        }
        public List<SurveyTaker__c> insertSurvey(){
            insert survey;
            // Salesforce portal contains formula field which keeps logic for create URL, 
            // to keeps this logic on one place we need to query our survey again. 
            List<SurveyTaker__c> newSurvey=[SELECT IFrame_URL__c FROM SurveyTaker__c WHERE Id =:survey.Id];                
            return newSurvey;
        }
    }
}