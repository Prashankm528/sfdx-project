@isTest
/**
* @author      Avinash Jain
* @date      13/09/2019
* @description    Test class for GCP_TFD_updateGenerateButton class used for Generate button lightning component      
*/
public with sharing class GCP_TFD_Test_updateGenerateButton {
    @isTest
    //Method 1 to test Updatecasegeneratebutton method...
    Public static void TestUpdatebutton(){
        case cs = GCP_TFD_TestDataFactory.Updatecasegeneratebutton();   
        Test.startTest();
        GCP_TFD_UpdateGenerateButton.updategeneratebutton(cs.id);
        Test.stopTest();
        System.assertEquals(true, [Select GCP_TFD_Generate_Document__c from case where id =:cs.id].GCP_TFD_Generate_Document__c);
    }
    @isTest
    //Method 2 to test getCase method...
    Public static void TestUpdatebutton2(){
        case cs = GCP_TFD_TestDataFactory.Updatecasegeneratebutton();   
        Test.startTest();
        GCP_TFD_UpdateGenerateButton.updategeneratebutton(cs.id);
        GCP_TFD_UpdateGenerateButton.getCase(cs.Id);
        Test.stopTest();
        System.assertEquals(true, [Select GCP_TFD_Generate_Document__c from case where id =:cs.id].GCP_TFD_Generate_Document__c);
    }
     @isTest
    //Method 3 to test updateisgenericfield method...
    Public static void TestUpdatebutton3(){
        case cs = GCP_TFD_TestDataFactory.Updatecasegenericbutton();   
        Test.startTest();
        GCP_TFD_UpdateGenerateButton.updateisgenericfield(cs.id,'Yes');
        GCP_TFD_UpdateGenerateButton.updateisgenericfield(cs.Id,'No');
        Test.stopTest();
        System.assertEquals(false, [Select GCP_TFD_Generate_Document__c from case where id =:cs.id].GCP_TFD_Generate_Document__c);
    }
}