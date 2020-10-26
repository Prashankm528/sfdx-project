@isTest
private class CAPL_BestVideoAndArticleControllerTest {
	@testSetup
	static void setup() {

    	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

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
	        Street = 'teststreet', 
			City = 'testCity',
			State = 'testState',
			PostalCode = 'testCode', 
			Country = 'testCountry',
			CAPL_Birthdate__c = Date.today(),
			CAPL_Job_Role__c = 'testJobRole'
		);
		
        insert u;


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
            CAPL_Title__c = 'test title2',
            CAPL_LinkToVideo__c = 'https://testsite.com/testVideo',
            RecordtypeId = existingVideoRecordType
        );

        videoList.add(existingVideo);

        insert videoList;

        Id caplKnowledgeRecordType = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('CAPL_Knowledge').getRecordTypeId();

        Knowledge__kav newArticleOne = new Knowledge__kav(
    		Title='test article', 
    		UrlName='testarticleurl', 
    		CAPL_ArticleImage__c = 'image',
    		Language='en_US',
    		RecordTypeId = caplKnowledgeRecordType
        );

        insert newArticleOne;
        
        Knowledge__kav newArticleTwo = new Knowledge__kav(
    		Title='test article2', 
    		UrlName='testarticleurl2', 
    		CAPL_ArticleImage__c = 'image',
    		Language='en_US',
    		RecordTypeId = caplKnowledgeRecordType
        );

        insert newArticleTwo;

        List<CAPL_BestVideoArticleComment__c> articleVideoComponents = new List<CAPL_BestVideoArticleComment__c>();

		CAPL_BestVideoArticleComment__c bestArticle = new CAPL_BestVideoArticleComment__c(
			Name = 'BestArticle',
			Identifier__c = newArticleOne.Id
		);

		CAPL_BestVideoArticleComment__c bestVideo = new CAPL_BestVideoArticleComment__c(
			Name = 'BestVideo',
			Identifier__c = newVideo.Id
		);

		articleVideoComponents.add(bestArticle);
		articleVideoComponents.add(bestVideo);

		insert articleVideoComponents;
	}
	
	@isTest 
	static void fetchBestVideoTestSuccess() {
		Test.startTest();
			CAPL_Video__c bestVideo =  CAPL_BestVideoAndArticleController.fetchBestVideo();
		Test.stopTest();

		System.assertEquals(bestVideo.CAPL_Title__c, 'test title');
	}

	@isTest 
	static void fetchBestVideoTestFailure() {
		upsert new CAPL_BestVideoArticleComment__c(
		    Name = 'BestVideo',
		    Identifier__c = null
		);

		Test.startTest();
			CAPL_Video__c bestVideo =  CAPL_BestVideoAndArticleController.fetchBestVideo();
		Test.stopTest();

		System.assertEquals(bestVideo.CAPL_Title__c, 'test title');
	}
	
	@isTest 
	static void fetchBestArticleTestSuccess() {
		User u = [SELECT Id FROM User WHERE LastName = 'TestSurname'];
		Knowledge__kav bestArticle;

		System.runAs(u) {
			Test.startTest();
				bestArticle =  CAPL_BestVideoAndArticleController.fetchBestArticle();
			Test.stopTest();
		}

		System.assertEquals(bestArticle.Title, 'test article');
	}
}