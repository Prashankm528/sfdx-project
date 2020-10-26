/*****************************************************************************************
*	    Date:		    09DEC2019
*       Author:         Rahma Belghouti - Infosys
*       Description:    Utility class for Custom Metadata 
*       Modifications:  
****************************************************************************************/
public with sharing class SFO_CustomMetadataUtility{
    
    /*
    * Returns the settings configured using SFO_Checkbox_Value__c and sharing 
    * the same grouping name
    */
    public static Map<String, Boolean> getConfigSettingBooleanVal(String groupingName)
    {
        List<SFO_Configuration_Settings__mdt> query;
        if(Test.isRunningTest()){
            query = (List<SFO_Configuration_Settings__mdt>) JSON.deserialize( 
                '[{"MasterLabel":"setting1","SFO_Checkbox_Value__c":true, "SFO_Grouping_Name__c":"'+groupingName+'"},'+
                +'{"MasterLabel":"setting2","SFO_Checkbox_Value__c":false, "SFO_Grouping_Name__c":"'+groupingName+'"}]',List<SFO_Configuration_Settings__mdt>.class );     
        }else{
            query = [SELECT MasterLabel, SFO_Checkbox_Value__c FROM SFO_Configuration_Settings__mdt WHERE SFO_Grouping_Name__c =: groupingName];
        }
        
        Map<String, Boolean> BooleanSettingsMap = new Map<String, Boolean> ();
        for(SFO_Configuration_Settings__mdt setting: query){            
            BooleanSettingsMap.put(setting.MasterLabel, setting.SFO_Checkbox_Value__c);
        }
        
        return BooleanSettingsMap;
    }
    
    /*
    * Returns the settings configured using SFO_Text_Value__c and sharing 
    * the same grouping name
    */
    public static List<String> getConfigSettingStringVal(String groupingName)
    {        
        List<SFO_Configuration_Settings__mdt> query;
        if(Test.isRunningTest()){
            query = (List<SFO_Configuration_Settings__mdt>) JSON.deserialize( 
                '[{"MasterLabel":"setting1","SFO_Text_Value__c":"US01", "SFO_Grouping_Name__c":"'+groupingName+'"},'+
                +'{"MasterLabel":"setting2","SFO_Text_Value__c":"ZA0A", "SFO_Grouping_Name__c":"'+groupingName+'"}]',List<SFO_Configuration_Settings__mdt>.class );     
        }else{
            query = [SELECT SFO_Text_Value__c FROM SFO_Configuration_Settings__mdt WHERE SFO_Grouping_Name__c =: groupingName];
        }
        
        List<String> StringSettingsList = new List<String>();
        for(SFO_Configuration_Settings__mdt setting : query){
            StringSettingsList.add(setting.SFO_Text_Value__c);
        }
        
        return StringSettingsList;
    }
    
    /*
    * Returns the settings configured using SFO_Number_Value__c and sharing 
    * the same grouping name
    */
    public static Map<String, Decimal> getConfigSettingNumberVal(String groupingName)
    {        
        List<SFO_Configuration_Settings__mdt> query;
        if(Test.isRunningTest()){
            query = (List<SFO_Configuration_Settings__mdt>) JSON.deserialize( 
                '[{"MasterLabel":"setting1","SFO_Number_Value__c":15, "SFO_Grouping_Name__c":"'+groupingName+'"},'+
                +'{"MasterLabel":"setting2","SFO_Number_Value__c":20, "SFO_Grouping_Name__c":"'+groupingName+'"}]',List<SFO_Configuration_Settings__mdt>.class );     
        }else{
            query = [SELECT SFO_Number_Value__c, MasterLabel FROM SFO_Configuration_Settings__mdt WHERE SFO_Grouping_Name__c =: groupingName];
        }
        
        Map<String, Decimal> NumberSettingsMap = new Map<String, Decimal> ();
        for(SFO_Configuration_Settings__mdt setting : query){
            NumberSettingsMap.put(setting.MasterLabel, setting.SFO_Number_Value__c);
        }
        
        return NumberSettingsMap;
    }
    
}