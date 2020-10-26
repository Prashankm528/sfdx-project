/***********************************************************************************************
* @author           Sean
* @date             2020/03/30
* @group            CHCRM
* @description      Test class for CHCRM_FileUploadHandler

* history
* 2020/03/30  Sean  Created 
************************************************************************************************/
@isTest
private with sharing class CHCRM_FileUploadHandlerTests {
    
    /*@testSetup
    static void testSetup(){
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        insert events;
        
        List<ContentVersion> cvs = CHCRM_TestSetup.createContentVersions(1);
        insert cvs;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId IN:cvs];
        
        ContentDocumentLink cdl = CHCRM_TestSetup.createContentDocumentLink(events[0].Id,documents[0].Id);
        insert cdl;
    }*/
    
    /**
     * @description test getFiles method and deleteFiles method
     * @param  null
     * @return void
     */    
    private static testMethod void testGetAndDeleteFiles() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        List<Event> events = CHCRM_TestSetup.createEvents(1);
        insert events;
        
        List<ContentVersion> cvs = CHCRM_TestSetup.createContentVersions(1);
        insert cvs;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId IN:cvs];
        
        ContentDocumentLink cdl = CHCRM_TestSetup.createContentDocumentLink(events[0].Id,documents[0].Id);
        insert cdl;
        //Test.setMock(HttpCalloutMock.class, new CHCRM_SurIntegrationHttpCalloutMock());
        //List<Event> events = [Select Id FROM Event];
        //List<ContentDocument> documents = [Select Id FROM ContentDocument];
        
        
        List<ContentDocument> cds = CHCRM_FileUploadHandler.getFiles(events[0].Id);
        System.assertEquals(1, cds.size());
        
        CHCRM_FileUploadHandler.deleteFiles(documents[0].Id);
        cds = CHCRM_FileUploadHandler.getFiles(events[0].Id);
        System.assertEquals(0, cds.size());
        Test.stopTest();
    }
}