@isTest
private class CAPL_VideosTestClass {

	@testSetup
    static void setup() {
        CAPL_Video__c video = new CAPL_Video__c(
        	Name = 'test video',
        	CAPL_Title__c = 'test title'
        );

        insert video;
   	}
	
	@isTest 
	static void fetchVideosTest() {

		Test.startTest();
			List<CAPL_Video__c> videoList =  CAPL_VideosClass.fetchVideos();
		Test.stopTest();

		System.assertEquals(videoList.size(), 1);
	}	
}