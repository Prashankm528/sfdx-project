/**
* @author: Gabriela Matos
* @date: 19/06/2020
* @group: BPG
* @description: BPCM Test Data Factory to support Test Class
* @name BPCM_TestDataFactory.cls
*/

@isTest
public with sharing class BPCM_TestDataFactory {
    
    /*
    * create or return only an instance of Peron Account record
    */
    public static Account createPersonAccount(Boolean saveToDB, String firstName, String lastName, String email, String phone, String recordTypeName){

        Account acc = new Account();
        acc.FirstName = firstName;
        acc.LastName = lastName;
        acc.PersonEmail = email;
        acc.PersonOtherPhone = phone;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        if(saveToDB){
            insert acc;
        }

        return acc;
    } 

    /*
    * create or return only an instance of Peron Account record
    */
    public static Account createAccount(Boolean saveToDB, String Name, String phone, String recordTypeName){

        Account accRec = new Account();
        accRec.Name = Name;
        accRec.Phone = phone;
        accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        if(saveToDB){
            insert accRec;
        }

        return accRec;
    }
    
    /*
    * create or return only an instance of Contact record
    */
    public static Contact createContact(Boolean saveToDB, Id AccountID ,String LastName, String phone,string email,String recordTypeName){

        Contact contactRec = new Contact();
        contactRec.AccountId = AccountID;
        contactRec.LastName = LastName;
        contactRec.Phone = phone;
        contactRec.Email = email;
        contactRec.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        if(saveToDB){
            insert contactRec;
        }

        return contactRec;
    }
    
    /*
    * get contactId from a PersonAccount record
    */
    public static Id getContactIdFromPersonAccount(Id accId){
        return [SELECT PersonContactId FROM Account WHERE Id = :accId].PersonContactId;
    }

    /*
    *  create or return only an instance of Case record with default status = new
    */
    public static Case createCase(Boolean saveToDB, String subject, String description, String origin, String recordTypeName, Id contactId){
        return BPCM_TestDataFactory.createCaseWithStatus(saveToDB, subject, description, origin, recordTypeName, contactId, 'New');
    }

    /*
    *  create or return only an instance of Case record with status defined
    */
    public static Case createCaseWithStatus(Boolean saveToDB, String subject, String description, String origin, String recordTypeName, Id contactId, String status){

        Case cs = new Case();
        cs.Subject = subject;
        cs.Description = description;
        cs.Origin = origin;
        cs.ContactId = contactId;
        cs.Status = status;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();

        if(saveToDB){
            insert cs;
        }

        return cs;
    }

    /*
    *  create or return only an instance of EmailMessage record
    */
    public static EmailMessage createEmailMessage(Boolean saveToDB, Boolean inbound, String toAddress, String subject, Id parentId){

        EmailMessage email = new EmailMessage();
        email.Incoming = inbound;
        email.ToAddress= toAddress;
        email.Subject = subject;
        email.ParentId = parentId;

        if(saveToDB){
            insert email;
        }

        return email;
    }

    /*
    *  create or return only an instance of Task record
    */
    public static Task createTask(Boolean saveToDB, String type, Id contactId, Id caseId, String subject, String status, String recordTypeName){

        Task tk = new Task(
            Subject = subject,
            Type = type,
            WhatId = caseId,
            WhoId = contactId,
            Status = status,
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId()
        );

        if(saveToDB){
            insert tk;
        }

        return tk;
    }

    /*
    *  create or return only an instance of FeedItem record
    */
    public static FeedItem createFeedItem(Boolean saveToDB, Id caseId){
        FeedItem fi = new FeedItem();
        fi.ParentId = caseId;
        fi.Body = 'Test';
        fi.Type = 'TextPost';

        if(saveToDB){
            insert fi;
        }

        return fi;
    }

    /*
    *  create or return only an instance of FeedComment record
    */
    public static FeedComment createFeedComment(Boolean saveToDB, Id caseId, Id feedItemId, String body){
        FeedComment fc = new FeedComment();
        fc.FeedItemId = feedItemId;
        fc.CommentBody = body;


        if(saveToDB){
            insert fc;
        }

        return fc;
    }

    /*
    *  create or return only an instance of Social Post record
    */
    public static SocialPost createSocialPost(Boolean saveToDB, String provider, Id socialPersonaId, Id parentId, Boolean outbound) {

        SocialPost sp = new SocialPost();
        sp.Name = 'Post';
        sp.Content = 'Content Post';
        sp.Posted = Date.today();
        sp.PostUrl = 'url';
        sp.Provider = provider;
        sp.MessageType = 'Post';
        sp.ExternalPostId = '444444';
        sp.R6TopicId = '123453';
        sp.ReviewScore = 5;
        sp.PersonaId = socialPersonaId;
        sp.ParentId = parentId;
        sp.IsOutbound = outbound;

        if(saveToDB){
            insert sp;
        }

        return sp;
    }

    /*
    *  create or return only an instance of SocialPersona record
    */
    public static SocialPersona createSocialPersona(Boolean saveToDB, String name, String realName, String provider, String socProvider, String externalId, Id parentId) {

        SocialPersona sp = new SocialPersona();
        sp.Name = name;
        sp.RealName = realName;
        sp.Provider = provider;
        sp.MediaProvider = socProvider;
        sp.ExternalId = externalId;
        sp.ParentId = parentId;

        if(saveToDB){
            insert sp;
        }

        return sp;
    }

    /*
    *  create or return only an instance of AutomationSetup record
    */
    public static BPCM_Automation_Setup__c createAutomationSetup(Boolean saveToDB, Decimal processOrder, String Status, 
                                                                 String recordTypeName, String keyWord, String csRecordType, 
                                                                 String csCategory, String csSubcategory, String csFurSubCategory, 
                                                                 String csPriority){

        BPCM_Automation_Setup__c autoSetup = new BPCM_Automation_Setup__c();
        autoSetup.BPCM_Process_Order__c = processOrder;
        autoSetup.BPCM_Status__c = Status;
        autoSetup.RecordTypeId = Schema.SObjectType.BPCM_Automation_Setup__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        autoSetup.BPCM_Keywords__c = keyWord;
        autoSetup.BPCM_Case_Record_Type__c = csRecordType;
        autoSetup.BPCM_Case_Category__c = csCategory;
        autoSetup.BPCM_Case_Subcategory__c = csSubcategory;
        autoSetup.BPCM_Case_Further_Subcategory__c = csFurSubCategory;
        autoSetup.BPCM_Case_Priority__c = csPriority;

        if(saveToDB){
            insert autoSetup;
        }

        return autoSetup;
    }

    /*
    *  get an admin user record
    */
    public static User getAdminUser(){
        Id sysProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User sysUser = [SELECT Id FROM User WHERE isActive = TRUE AND ProfileId = :sysProfile LIMIT 1];
        return sysUser;
    }

    /*
    *  get an advisor user created while testing
    */
    public static User createAdvisorUser(String name, String pgName){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'BPCM Base'].Id;
        User advisor = createUser(true, profileId, name);
        addGroupMember(pgName, advisor.Id);

        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('AC_Agent', 'BPCM_Advisor')]){
            psaList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = advisor.Id));
        }

        insert psaList;

        return advisor;
    }

    /*
    *  add user to group member of a defined public group/queue
    */
    public static void addGroupMember(String pgName, Id userId){

        GroupMember gm = new GroupMember();
        gm.GroupId = getPublicGroupIdByName(pgName);
        gm.UserOrGroupId = userId;
        insert gm;
    }

    /*
    *  get public group Id by Name
    */
    public static Id getPublicGroupIdByName(String groupName){
        return [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = :groupName].Id;
    }

    /*
    *  get queue Id by Name
    */
    public static Id getQueueIdByName(String queueName){
        return [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueName].Id;
    }

    /*
    *  create or return only an instance of User record 
    */
    public static User createUser(Boolean saveToDB, Id profileId, String name){

        User u = new User(
            FirstName = name,
            Alias = 'bpcm', 
            Email= name+'@bpcm.com.test', 
            EmailEncodingKey='UTF-8', 
            LastName='TestClass', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profileId, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName= name+'@bpcm.com.testclass');

        if(saveToDB){
            insert u;
        }

        return u;
    }

    /*
    *  setup a mock custom metadata type records related with Case Field to track 
    */
    public static void mockBPCMSettingsMap(String caseFieldAPINames, String setDevName){

        BPCM_Setting__mdt stMtd = new BPCM_Setting__mdt();
        stMtd.DeveloperName = setDevName;
        stMtd.Label = 'Test Case Update';
        stMtd.BPCM_Case_Fields_to_Count_Touches__c = caseFieldAPINames;

        Map<String,BPCM_Setting__mdt> bpcmSetMap = new Map<String,BPCM_Setting__mdt>();
        bpcmSetMap.put(setDevName, stMtd);

        BPCM_SettingsService.BPCM_SETTINGS_MTD = bpcmSetMap;
    }

    /**
     * @description: parse the error message to be clear to the final user.  
     * @param: error message threw by the system
     * @return error message to be showed to the user.
     * */
    public static String parseErrorMessage (String msg){
        Pattern p = Pattern.compile( '.* [A-Z|_]+, ([^\\[|\\]|:]*): \\[(.*)]' );
        Matcher m = p.matcher( msg );

        return m.matches() && m.find(1) ? m.group(1) : msg;
    }
}