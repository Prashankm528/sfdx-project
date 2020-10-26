/***************************************************************************************************
* Description : Controller class to page allowing LCF user with specific permission set for
*                OP manager change Operation Managers Settings custom settings.
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2017-Nov-06   1.0                 Frantisek Kolacny   Initial version
* 2017-Nov-14   1.1                 Frantisek Kolacny   Adding Survey Type to page
* 2018-SEP-27   1.2                 Maros Zilka         SonarCube Fixes
*
***************************************************************************************************/

global virtual class CALCF_OpManagersSettingController {

    public boolean SaveDisabled{get;set;}
    public SettingProxy SettingProxy{get;set;}
    public String ExMessage{get;set;}
    public List<SelectOption> SalesOrgs{get;set;}
    public List<SelectOption> SurveyTypes{get;set;}
    public String selectedVal{get;set;}
    public String selectedType{get;set;}

    public CALCF_OpManagersSettingController() {
        init();
    }

    public void init() {
        SettingProxy = new SettingProxy();
        SettingProxy.LoadOptions();
        SalesOrgs = SettingProxy.SalesOptions;
        SurveyTypes = SettingProxy.TypesOptions;
        SaveDisabled = true;
    }

    // Loading of input text boxes using Apex Proxy class.
    public pageReference LoadTextBoxes() {

        SettingProxy.LoadSetting([
            SELECT Id, Operations_Manager_Email__c, Operations_Manager_First_Name__c
            FROM LCF_Operations_Manager_Settings__c
            WHERE Sales_Organization__c =: selectedVal AND Survey_Type__c =:selectedType
            ]);
        SaveDisabled = false;
        return null;
    }

    // Saving changed values using Apex Proxy class.
    public pageReference Save() {

        SettingProxy.SaveSettingProxy();
        SettingProxy = new SettingProxy();
        SaveDisabled = true;
        return null;
    }

    // Apex Proxy class which will allow to change custom settings in VF page.
    public class SettingProxy {

        public List<SelectOption> SalesOrgs{get;set;}
        public String Email {get;set;}
        public String Name {get;set;}
        public Id Id {get;set;}
        public List<SelectOption> SalesOptions{get;set;}
        public List<SelectOption> TypesOptions{get;set;}

        // Method will load selecting options for Survey Types and Sales Orgs on page.
        public void LoadOptions() {

            SalesOptions = new List<SelectOption>();
            TypesOptions = new List<SelectOption>();

            List<LCF_Operations_Manager_Settings__c> setting = [
                SELECT Survey_Type__c, Sales_Organization__c
                FROM LCF_Operations_Manager_Settings__c];
            Map<String, String> typesMap = new Map<String,String>();
            Map<String, String> salesOrgMap = new Map<String,String>();

            for(LCF_Operations_Manager_Settings__c val : setting) {
                typesMap.put(val.Survey_Type__c, val.Survey_Type__c);
                salesOrgMap.put(val.Sales_Organization__c, val.Sales_Organization__c);
            }

            for(String val : typesMap.values()) {
                TypesOptions.add(new selectOption(val, val));
            }

            for(String val : salesOrgMap.values()) {
                SalesOptions.add(new selectOption(val, val));
            }
        }

        // Loading of custom settings which are specified in input parameter of method.
        public void LoadSetting(LCF_Operations_Manager_Settings__c settingsToUpdate){
            this.Email = settingsToUpdate.Operations_Manager_Email__c;
            this.Name = settingsToUpdate.Operations_Manager_First_Name__c;
            this.Id = settingsToUpdate.Id;
        }

        // Get method for currently loaded settings.
        public LCF_Operations_Manager_Settings__c getSetting() {
            return new LCF_Operations_Manager_Settings__c (
                Id = this.Id,
                Operations_Manager_Email__c = this.Email,
                Operations_Manager_First_Name__c = this.Name
            );
        }

        // Method will save currently loaded custom settings.
        public void SaveSettingProxy() {

            LCF_Operations_Manager_Settings__c settings = this.getSetting();

            update settings;
        }
    }
}