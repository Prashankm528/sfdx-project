@isTest
private class CAPL_VoteTestClass {

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

	        CAPL_Video__c newVideo = new CAPL_Video__c(
	            Name = 'new video',
	            CAPL_Title__c = 'test title',
	            RecordtypeId = newVideoRecordType
	        );

	        insert newVideo;

            Id caplKnowledgeRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge').getRecordTypeId();

	        Knowledge__kav newArticleOne = new Knowledge__kav(
	    		Title='test article', 
	    		UrlName='testarticleurl', 
	    		CAPL_ArticleImage__c = 'image',
	    		Language='en_US',
                RecordTypeId = caplKnowledgeRecordType
	        );

	        insert newArticleOne;

	        
	    }
	}

	@isTest 
    static void likeVideoTest() {
        User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'new video' LIMIT 1];
        
        Boolean isLiked;

        System.runAs(u) {
            Test.startTest();
                isLiked = CAPL_VoteClass.likeRecord(video.Id);
            Test.stopTest();
        }
        
        System.assertEquals(isLiked, true);
    }

    @isTest 
    static void likeArticleTest() {
        User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
        Knowledge__kav article = [
        	SELECT Id 
        	FROM Knowledge__kav 
        	WHERE PublishStatus = 'Draft' 
                AND Language = 'en_US' 
            LIMIT 1
        ];
        
        Boolean isLiked;

        System.runAs(u) {
            Test.startTest();
                isLiked = CAPL_VoteClass.likeRecord(article.Id);
            Test.stopTest();
        }
        
        System.assertEquals(isLiked, true);
    }

    @isTest 
    static void fetchNumberOfLikesTest() {
    	User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'new video' LIMIT 1];
        Knowledge__kav article = [
        	SELECT Id 
        	FROM Knowledge__kav 
        	WHERE Title = 'test article'
        		AND PublishStatus = 'Draft' 
                AND Language = 'en_US' 
            LIMIT 1
        ];

        CAPL_Vote__c customVoteOne = new CAPL_Vote__c(
            VotedOn__c = video.Id,
            VotedBy__c = u.Id
        );

        CAPL_Vote__c customVoteTwo = new CAPL_Vote__c(
            VotedOnArticle__c = article.Id,
            VotedBy__c = u.Id
        );

        insert customVoteOne;
        insert customVoteTwo;
    
        Test.startTest();
            Integer numOfLikesVideo = CAPL_VoteClass.fetchNumberOfLikes(video.Id);
            Integer numOfLikesArticle = CAPL_VoteClass.fetchNumberOfLikes(article.Id);
        Test.stopTest();

        System.assertEquals(numOfLikesVideo, 1);
        System.assertNotEquals(numOfLikesArticle, 2);


    }

    @isTest 
    static void isLikedRecordTest() {
        User u = [SELECT Id FROM User WHERE FirstName = 'TestName' LIMIT 1];
        CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'new video' LIMIT 1];

        CAPL_Vote__c customVoteOne = new CAPL_Vote__c(
            VotedOn__c = video.Id,
            VotedBy__c = u.Id
        );

        insert customVoteOne;
        
        Boolean iAlreadyLiked;

        System.runAs(u) {
            Test.startTest();
                iAlreadyLiked = CAPL_VoteClass.isLikedRecord(video.Id);
            Test.stopTest();
        }
        
        System.assertEquals(iAlreadyLiked, true);
    }
	
}