/**
* @author: Gabriela Matos
* @date: 19/06/2020
* @group: BPG
* @description: BPCM service class for BPCM_Settings custom metadata type object
* @name BPCM_SettingsService.cls
*/

public inherited sharing class BPCM_SettingsService {


    /** 
     * @description: get bpcm settings custom metadata type recordS 
     * @author Gabriela Matos | 19/06/2020
     * @return Map of BPCM_Setting__mdt by developer name
     * */
    public static Map<String, BPCM_Setting__mdt> BPCM_SETTINGS_MTD {
        get {
            if (BPCM_SETTINGS_MTD == null) {
                BPCM_SETTINGS_MTD = new Map<String, BPCM_Setting__mdt>();
                for(BPCM_Setting__mdt bpcmSet : [SELECT DeveloperName, 
                                                        BPCM_FCR_Period_Hours__c, 
                                                        BPCM_Case_Fields_to_Count_Touches__c
                                                   FROM BPCM_Setting__mdt LIMIT :Limits.getLimitQueryRows()]){
                    BPCM_SETTINGS_MTD.put(bpcmSet.DeveloperName, bpcmSet);                                  
                }                                       
            }
            return BPCM_SETTINGS_MTD;
        }
        set;
    }
    
    /** 
     * @description: get case fields to check it they have been updated (tracking) 
     * @author Gabriela Matos | 19/06/2020
     * @param: developer name (string)
     * @return List of Case Field API Names
     * */
    public static List<String> getCaseFieldsToCheckUpdate(String devName){

        List<String> csFieldsList = new List<String>();
        Map<String, BPCM_Setting__mdt> bpcmSetMap = BPCM_SettingsService.BPCM_SETTINGS_MTD;

        if(!bpcmSetMap.isEmpty() && bpcmSetMap.containsKey(devName)){
            csFieldsList = bpcmSetMap.get(devName).BPCM_Case_Fields_to_Count_Touches__c.split(',');
        }
        return csFieldsList;
    }
}