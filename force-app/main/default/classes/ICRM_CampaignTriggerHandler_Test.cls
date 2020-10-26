/**
* @author     : Santosh Verma
* @date       : 06/03/2020
* @description:   Test class for Campaign Handler    
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_CampaignTriggerHandler_Test {
    /*  Create Test Data for Test Methods */ 
    @testSetup 
    static void testdataSetup(){
    /*Create Test Data for Test Methods */ 
            
       Id CamRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('IST_Campaign').getRecordTypeId();  
       string CMemRecId = Schema.getGlobalDescribe().get('CampaignMember').getDescribe().getRecordTypeInfosByName().get('IST Campaign Member').getRecordTypeId();
        Campaign  camobj = new Campaign(); 
        camobj.name = 'TestCampaign001';
        camobj.RecordTypeId = CamRecId; 
        camobj.Type = 'Webinar'; 
        camobj.CampaignMemberRecordTypeId = CMemRecId;
        
        try{
        Insert camobj; 
        }catch(exception exc){
           String s= exc.getMessage();
        }
        
    }   
    
    @isTest
    public static void testProcessCMS(){
    /* Test the result after trigger*/
     Test.startTest();   
        list<CampaignMemberstatus>  cmpmemSt = new list<CampaignMemberstatus>();
        Campaign testCampId =  [select id, name from Campaign  where name = 'TestCampaign001' limit 1]; 
           cmpmemSt = [select id, campaignid  from CampaignMemberstatus where campaignid =:testCampId.Id ]; 
        
        integer  i = cmpmemSt.size();  
          system.assert(cmpmemSt.size() >2, 'Test class is failed');
         
     Test.stopTest();
    }
      
}