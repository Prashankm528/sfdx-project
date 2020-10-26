@isTest
private class CAPL_CreateSharableLinkTriggerTest {
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

		Test.startTest();
			insert contentVersion;
		Test.stopTest();   

		List<ContentDistribution> contentDistributionList = [
            SELECT Id, Name, ContentDownloadUrl 
            FROM ContentDistribution 
            WHERE ContentVersionId = :contentVersion.Id
            LIMIT 1
        ];

		System.assertEquals(contentDistributionList.get(0).Name, contentVersion.Title);
	}
*/	
}