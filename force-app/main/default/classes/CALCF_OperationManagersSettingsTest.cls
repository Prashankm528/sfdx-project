/************************************************************************************************************
* Description : Test class for Operation Managers Settings Controller
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-Nov-06   1.0                 Frantisek Kolacny   Initial version
* 2017-Nov-14   1.1                 Frantisek Kolacny   Adding Survey Type to page
*
*************************************************************************************************************/
@isTest
private class CALCF_OperationManagersSettingsTest {

    /***********************************************************************************
    * Data Preparation Method 
    * ------------------------
    * Create custom settings for testing purposes.
    ***********************************************************************************/
    @testSetup static void testSetUp(){

        List<LCF_Operations_Manager_Settings__c> settings = new List<LCF_Operations_Manager_Settings__c>();

        LCF_Operations_Manager_Settings__c setting = new LCF_Operations_Manager_Settings__c();
        setting.Operations_Manager_Email__c = 'David@ibm.com';
        setting.Operations_Manager_First_Name__c = 'David';
        setting.Sales_Organization__c = 'UK01';
        setting.Survey_Type__c = 'Complaints';
        setting.name = '1';
        settings.add(setting);      

        LCF_Operations_Manager_Settings__c setting2 = new LCF_Operations_Manager_Settings__c();
        setting2.Operations_Manager_Email__c = 'Salvador@ibm.com';
        setting2.Operations_Manager_First_Name__c = 'Salvador';
        setting2.Sales_Organization__c = 'ES01';
        setting2.Survey_Type__c = 'Orders';
        setting2.name = '2';
        settings.add(setting2);

        insert settings;
    }

    /***********************************************************************************
    * Drop down values test
    * ------------------------
    * Method will test if values for drop down will be loaded correctly.
    ***********************************************************************************/
    static testmethod void dropDownValuesTest(){

        // arrange
        CALCF_OpManagersSettingController target = new CALCF_OpManagersSettingController();

        // act
        // All is done in constructor.

        // assert
        System.assertEquals(2, target.SalesOrgs.size());

    }

    /***********************************************************************************
    * Load text boxes
    * ------------------------
    * Method will test if text boxes on page will be loaded correctly.
    ***********************************************************************************/
    static testmethod void loadTextBoxes(){

        // arrange
        CALCF_OpManagersSettingController target = new CALCF_OpManagersSettingController();
        target.selectedVal = 'UK01';
        target.selectedType = 'Complaints';

        // act
        target.loadTextBoxes();

        // assert
        System.assertEquals('david@ibm.com', target.SettingProxy.Email);
        System.assertEquals('David', target.SettingProxy.Name);

    }


    /***********************************************************************************
    * Save new value
    * ------------------------
    * Method will test if new value will be saved.
    ***********************************************************************************/
    static testmethod void saveNewValue(){

        // arrange
        CALCF_OpManagersSettingController target = new CALCF_OpManagersSettingController();
        target.selectedVal = 'UK01';
        target.selectedType = 'Complaints';
        target.loadTextBoxes();

        target.SettingProxy.Email = 'newmail@ibm.com';
        target.SettingProxy.Name = 'NewName';

        // act
        target.Save();
        target.selectedVal = 'UK01';
        target.selectedType = 'Complaints';
        target.loadTextBoxes();

        // assert
        System.assertEquals('newmail@ibm.com', target.SettingProxy.Email);
        System.assertEquals('NewName', target.SettingProxy.Name);

    }

}