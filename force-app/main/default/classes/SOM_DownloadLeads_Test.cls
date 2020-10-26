/*********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Test class for DownloadLeads class
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *******************************************************************************/
@isTest
public with sharing class SOM_DownloadLeads_Test 
{
 /*********************************************************************************
 * Date:    08FEB17
 * Author:  Jon Marson - Forcify Ltd
 * Desc:    Method use to test Lead downloads.
 * Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
 * *******************************************************************************/
    static testMethod void testDownload()
    {    
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        
        Lead lead1 = new Lead(recordtypeid=devRecordTypeId,LastName='Test1', Company='TestCompany1', Status='New', Email='test1@bp.test');
        Lead lead2 = new Lead(recordtypeid=devRecordTypeId,LastName='Test2', Company='TestCompany2', Status='Allocated', Email='test2@bp.test');
        Lead lead3 = new Lead(recordtypeid=devRecordTypeId,LastName='Test3', Company='TestCompany3', Status='Allocated', Email='test3@bp.test');
        Lead lead4 = new Lead(recordtypeid=devRecordTypeId,LastName='Test4', Company='TestCompany4', Status='New', Email='test4@bp.test');       
        
        insert new Lead[] {lead1, lead2, lead3, lead4};
            Test.startTest();
        Integer numDownloaded = SOM_DownloadLeads.download();
        Test.stopTest();
        System.assertEquals(2, numDownloaded);
    }
    static testMethod void testZeroList()
    {    
        
        Test.startTest();   
        Integer numDownloaded = SOM_DownloadLeads.download();
        Test.stopTest();
        System.assertEquals(0, numDownloaded);
    }
}