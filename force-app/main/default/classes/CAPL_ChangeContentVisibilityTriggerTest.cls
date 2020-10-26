@isTest
private class CAPL_ChangeContentVisibilityTriggerTest {
/*	
	@isTest 
	static void changeContentVisibility() {
		CAPL_Video__c existingVideo = new CAPL_Video__c(
        	Name = 'existing video',
        	CAPL_Title__c = 'test title',
        	CAPL_LinkToVideo__c = 'https://testsite.com/testVideo'
        );

        insert existingVideo;

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
			LinkedEntityId = existingVideo.id,
			ContentDocumentId = doc.Id,
			shareType = 'V'
		);

		Test.startTest();
			insert cdl;
		Test.stopTest();

		CAPL_Video__c video = [SELECT Id FROM CAPL_Video__c WHERE Name = 'existing video' LIMIT 1];
		
		ContentDocumentLink documentLink = [
    		SELECT Visibility
    		FROM ContentDocumentLink 
    		WHERE LinkedEntityId = :video.Id
    		LIMIT 1
    	];

		System.assertEquals(documentLink.Visibility, 'AllUsers');
	}
*/	
}