@isTest
private class CAPL_VideoDetailTestClass {
/*
    @testSetup
    static void setup() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User userWithRole = new User(
            alias = 'hasrole', 
            email='userwithrole@roletest1.com', 
            userroleid = r.id,
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = pf.Id, 
            timezonesidkey='America/Los_Angeles', 
            username='userwithrole@testclass_bp'+System.currentTimeMillis()+'.com'

        );

        Account a;
        Contact con;
        Contact con2;
        
        System.runAs(userWithRole) {
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            a = new Account(
                RecordTypeId = recordTypeId, 
                Name = 'testAccountName'
            );

            insert a;

            con = new Contact(
                FirstName = 'TestName',
                LastName = 'TestSurname',
                Email = 'test@test.com',
                Home_Location__c = 'United Kingdom',
                MailingStreet  = 'abc',
                MailingCity  = 'test',
                MailingState  = 'te',
                MailingPostalCode  = 'test123',
                MailingCountry  = 'testcountry',
                AccountId = a.Id
            );

            insert con;

            Account acc = [
                SELECT PersonContactId 
                FROM Account 
                WHERE Id = :a.Id
            ];

            Profile p = [SELECT Id FROM Profile WHERE Name = 'RE IDP External Identity'];

            User u = new User(
                FirstName = 'TestName',
                LastName = 'TestSurname',
                Email = 'testedemail@email.com',
                Username = 'test@test.com.test!!!',
                Alias = 'astest',
                ProfileId = p.Id,
                TimeZoneSidKey    = 'America/Denver',
                LocaleSidKey      = 'en_US',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactId = con.Id,
                Street = 'teststreet', 
                City = 'testCity',
                State = 'testState',
                PostalCode = 'testCode', 
                Country = 'testCountry',
                CAPL_Birthdate__c = Date.today(),
                CAPL_Job_Role__c = 'testJobRole'
            );
            
            insert u;

            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'CAPL_CommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );

            Id newVideoRecordType = Schema.SObjectType.CAPL_Video__c.getRecordTypeInfosByName().get('Upload new video').getRecordTypeId();
            Id existingVideoRecordType = Schema.SObjectType.CAPL_Video__c.getRecordTypeInfosByName().get('Use link to existing video').getRecordTypeId();

            List<CAPL_Video__c> videoList = new List<CAPL_Video__c>();

            CAPL_Video__c newVideo = new CAPL_Video__c(
                Name = 'new video',
                CAPL_Title__c = 'test title',
                RecordtypeId = newVideoRecordType
            );

            videoList.add(newVideo);

            CAPL_Video__c existingVideo = new CAPL_Video__c(
                Name = 'existing video',
                CAPL_Title__c = 'test title',
                CAPL_LinkToVideo__c = 'https://testsite.com/testVideo',
                RecordtypeId = existingVideoRecordType
            );

            videoList.add(existingVideo);

            insert videoList;

            ContentVersion contentVersion = new ContentVersion(
                Title = 'testVideo',
                PathOnClient = 'testVideo.mp4',
                VersionData = Blob.valueOf('test video content'),
                IsMajorVersion = true
            );

            insert contentVersion;    

            ContentDocument doc = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument
                LIMIT 1
            ];

            ContentDocumentLink cdl = New ContentDocumentLink(
                LinkedEntityId = newVideo.id,
                ContentDocumentId = doc.Id,
                shareType = 'V'
            );

            insert cdl;
        }
    }
    
    @isTest 
    static void fetchRecordTypeNameTest() {
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'new video' LIMIT 1];

        Test.startTest();
            String recordTypeName =  CAPL_VideoDetailClass.fetchRecordTypeName(video.Id);
        Test.stopTest();

        System.assertEquals(recordTypeName, 'Upload new video');
    }
    
    @isTest 
    static void fetchVideoDetailsTest() {
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'existing video' LIMIT 1];

        Test.startTest();
            CAPL_Video__c fetchedVideo =  CAPL_VideoDetailClass.fetchVideoDetails(video.Id);
        Test.stopTest();

        System.assertEquals(fetchedVideo.CAPL_LinkToVideo__c, 'https://testsite.com/testVideo');
    }

    @isTest 
    static void fetchAttachedDocumentIdTest() {
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'new video' LIMIT 1];
        
        ContentDocumentLink documentLink = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :video.Id
            LIMIT 1
        ];

        ContentVersion contentVersion = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :documentLink.ContentDocumentId
            LIMIT 1
        ];

        ContentDistribution contentDistribution = [
            SELECT Id, Name, ContentDownloadUrl 
            FROM ContentDistribution 
            WHERE ContentVersionId = :contentVersion.Id
            LIMIT 1
        ];

		Test.startTest();
			String fileURL = CAPL_VideoDetailClass.fetchAttachedDocumentId(video.Id);
		Test.stopTest();

		System.assertEquals(fileURL, contentDistribution.ContentDownloadUrl);
    }
 */   
}