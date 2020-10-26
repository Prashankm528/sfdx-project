/**
* @author: Gabriela Matos
* @date: 17/06/2020
* @group: BPG
* @description: Service class for BPCM_Case_Touch_History__c custom object.
* @name BPCM_CaseTouchHistoryService.cls
*/

public without sharing class BPCM_CaseTouchHistoryService {

    public static String userName = [SELECT Name FROM User WHERE Id =: UserInfo.getUserId()].Name;

    /** 
     * @description: get all esiting BPCM_Case_Touch_History__c records already in for the Case Ids
     * @author Gabriela Matos | 17/06/2020
     * @param: Set of Case Ids
     * @return Map of Case Id with a list of BPCM_Case_Touch_History__c
     * */
    public static Map<Id, List<BPCM_Case_Touch_History__c>> getCaseTouchHistory(Set<Id> caseIdSet){

        Map<Id, List<BPCM_Case_Touch_History__c>> csIdcsTouchHistMap = new Map<Id, List<BPCM_Case_Touch_History__c>>();

        for(BPCM_Case_Touch_History__c cth : [SELECT BPCM_Case__c,
                                                     BPCM_Case_Updates__c,
                                                     BPCM_Comments__c,
                                                     BPCM_Inbound_Calls__c,
                                                     BPCM_User__c,
                                                     BPCM_UserId__c,
                                                     BPCM_Outbound_Calls__c,
                                                     BPCM_Outbound_Emails__c,
                                                     BPCM_Outbound_Social_Posts__c,
                                                     BPCM_Tranfers__c,
                                                     BPCM_Tasks__c            
                                                FROM BPCM_Case_Touch_History__c
                                               WHERE BPCM_Case__c IN :caseIdSet
                                               ORDER BY BPCM_UserId__c]){
            
            if(csIdcsTouchHistMap != null && csIdcsTouchHistMap.containsKey(cth.BPCM_Case__c)){
                csIdcsTouchHistMap.get(cth.BPCM_Case__c).add(cth);
            } else {
                csIdcsTouchHistMap.put(cth.BPCM_Case__c, new List<BPCM_Case_Touch_History__c>{cth});
            }   
        }

        return csIdcsTouchHistMap;
    }

    /** 
     * @description: capture the interactions done on the Case 
     * @author Gabriela Matos | 17/06/2020
     * @param: Map of Case Id with a list of CaseTouch info
     * @return void
     * */
    public static void captureCaseTouches(Map<Id, List<String>> csIdInteractionsMap){

        List<BPCM_Case_Touch_History__c> newCaseTouchesList = new List<BPCM_Case_Touch_History__c>();
        Set<Id> caseIdSet = csIdInteractionsMap.KeySet();

        //get existing BPCM_Case_Touch_History__c records for the cases in context
        Map<Id, List<BPCM_Case_Touch_History__c>> csIdcsTouchHistMap = BPCM_CaseTouchHistoryService.getCaseTouchHistory(caseIdSet);
        if(csIdcsTouchHistMap != null && csIdcsTouchHistMap.size()>0){
            BPCM_CaseTouchHistoryService.addTouchByOwner(csIdInteractionsMap, csIdcsTouchHistMap);
        } else {
            for(Id csId : caseIdSet){
                for(String interaction : csIdInteractionsMap.get(csId)){
                    if(newCaseTouchesList.isEmpty()){
                        newCaseTouchesList.add(BPCM_CaseTouchHistoryService.buildNewCaseTouchHistoryRecord(interaction, csId, UserInfo.getUserId(), userName));
                    } else {
                        //if there is more than one interaction at once, it will add at the same BPCM_Case_Touch_History__c record.
                        BPCM_Case_Touch_History__c newCth = newCaseTouchesList.get(0);
                        Decimal count;
                        if((Decimal) newCth.get(interaction) != null){
                            count = (Decimal) newCth.get(interaction);
                            count++;
                        } else { count = 1; }
                        newCth.put(interaction, count);
                    }
                }
            }
        }

        if(!newCaseTouchesList.isEmpty()){
            BPCM_CaseTouchHistoryService.insertCaseTouchHistoryRecords(newCaseTouchesList);
        }
        
    }

    /** 
     * @description: verify if there is already a record for the owner. 
     * 1. if exists, it will add a touch to the interaction
     * 2. if not, it will create a new record to capture the interaction done by the User.
     * @author Gabriela Matos | 17/06/2020
     * @param: Map of Case Id with a list of CaseTouch info
     * @param: Map of Case Id with a list of existing BPCM_Case_Touch_History__c records
     * @return void
     * */
    public static void addTouchByOwner(Map<Id, List<String>> csIdInteractionsMap, Map<Id, List<BPCM_Case_Touch_History__c>> csIdcsTouchHistMap){
        
        List<BPCM_Case_Touch_History__c> newCaseTouchesList = new List<BPCM_Case_Touch_History__c>();
        List<BPCM_Case_Touch_History__c> upCaseTouchesList = new List<BPCM_Case_Touch_History__c>();
        Map<String, BPCM_Case_Touch_History__c> cthByUserMap = new Map<String, BPCM_Case_Touch_History__c>();

        for(Id caseId : csIdInteractionsMap.KeySet()){

            for(String interaction : csIdInteractionsMap.get(caseId)){
                Decimal count;
                
                if(csIdcsTouchHistMap.containsKey(caseId)){
                    
                    //iterate into BPCM_Case_Touch_History__c list and group by userId
                    for(BPCM_Case_Touch_History__c cth : csIdcsTouchHistMap.get(caseId)){
                        cthByUserMap.put(cth.BPCM_UserId__c, cth);
                    }

                    //check if there is an existing record for the current user
                    if(!cthByUserMap.isEmpty() && cthByUserMap.containsKey(UserInfo.getUserId())){
                        BPCM_Case_Touch_History__c cth = cthByUserMap.get(UserInfo.getUserId());
                        //get the current value for the interaction performed
                        count = (Decimal) cth.get(interaction);
                        count++;
                        upCaseTouchesList.add(BPCM_CaseTouchHistoryService.buildUpCaseTouchHistoryRecord(interaction, cth.Id, userName, count));
                    } else {
                        if(newCaseTouchesList.isEmpty()){
                            //create a new case touch history record when there is no existing record for the current User
                            newCaseTouchesList.add(BPCM_CaseTouchHistoryService.buildNewCaseTouchHistoryRecord(interaction, caseId, UserInfo.getUserId(), userName));
                        } else {
                            //if there is more than one interaction at once, it will add at the same BPCM_Case_Touch_History__c record.
                            BPCM_Case_Touch_History__c newCth = newCaseTouchesList.get(0);
                            Decimal newCount;
                            if((Decimal) newCth.get(interaction) != null){
                                newCount = (Decimal) newCth.get(interaction);
                                newCount++;
                            } else { newCount = 1; }
                            newCth.put(interaction, newCount); 
                        }
                    }

                } else {
                    if(newCaseTouchesList.isEmpty()){
                        //create a new case touch history record when there is no existing record for the current User
                        newCaseTouchesList.add(BPCM_CaseTouchHistoryService.buildNewCaseTouchHistoryRecord(interaction, caseId, UserInfo.getUserId(), userName));
                    } else {
                        //if there is more than one interaction at once, it will add at the same BPCM_Case_Touch_History__c record.
                        BPCM_Case_Touch_History__c newCth = newCaseTouchesList.get(0);
                        Decimal newCount;
                        if((Decimal) newCth.get(interaction) != null){
                            newCount = (Decimal) newCth.get(interaction);
                            newCount++;
                        } else { newCount = 1; }
                        newCth.put(interaction, newCount);
                    }
                }
            } 
        }

        if(!newCaseTouchesList.isEmpty()){
            BPCM_CaseTouchHistoryService.insertCaseTouchHistoryRecords(newCaseTouchesList);
        }

        if(!upCaseTouchesList.isEmpty()){
            BPCM_CaseTouchHistoryService.updateCaseTouchHistoryRecords(upCaseTouchesList);
        }
    }
    
    /** 
     * @description: build an instance of BPCM_Case_Touch_History__c record to be updated
     * @author Gabriela Matos | 17/06/2020
     * @param: CaseTouch record
     * @return BPCM_Case_Touch_History__c record to be updated
     * */
    public static BPCM_Case_Touch_History__c buildUpCaseTouchHistoryRecord(String interaction, String chtId, String userName, Decimal count){

        BPCM_Case_Touch_History__c upCth = new BPCM_Case_Touch_History__c(
            Id = chtId,
            BPCM_User__c = userName
        );
        upCth.put(interaction, count);
        
        return upCth;
    }

    /** 
     * @description: build an instance of BPCM_Case_Touch_History__c record to be created
     * @author Gabriela Matos | 17/06/2020
     * @param: CaseTouch record
     * @return BPCM_Case_Touch_History__c record to be created
     * */
    public static BPCM_Case_Touch_History__c buildNewCaseTouchHistoryRecord(String interaction, String caseId, String userId, String userName){
       
        BPCM_Case_Touch_History__c newCth = new BPCM_Case_Touch_History__c(
            BPCM_Case__c = caseId,
            BPCM_UserId__c = userId,
            BPCM_User__c = userName
        );
        newCth.put(interaction, 1);
        
        return newCth;
    }

    /** 
     * @description: commit insert new records
     * @author Gabriela Matos | 17/06/2020
     * @param: new BPCM_Case_Touch_History__c records to be inserted
     * @return void
     * */
    public static void insertCaseTouchHistoryRecords(List<BPCM_Case_Touch_History__c> newRecords){

        try{
            Database.insert(newRecords, false);

        } catch(Exception e){	 
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'BPCM_CaseTouchHistoryService', 'insertCaseTouchHistoryRecords', (new Map<Id, BPCM_Case_Touch_History__c>(newRecords)).KeySet(), 'BPCM_App_Administrator'); 
        }
    }

    /** 
     * @description: commit update existing records
     * @author Gabriela Matos | 17/06/2020
     * @param: BPCM_Case_Touch_History__c records to be updated
     * @return void
     * */
    public static void updateCaseTouchHistoryRecords(List<BPCM_Case_Touch_History__c> upRecords){
        
        List<Id> errorIds = new List<Id>();

        try{
            Database.SaveResult[] resultList = Database.update(upRecords, false);
            for(Database.SaveResult sr : resultList){
                if(!sr.isSuccess()){
                    errorIds.add(sr.getId());
                }
            }

        } catch(Exception e){	 
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'BPCM_CaseTouchHistoryService', 'updateCaseTouchHistoryRecords', errorIds, 'BPCM_App_Administrator'); 
        }
    }

    /** 
     * @description: verify and add Case interactions into a map to be processed
     * @author Gabriela Matos | 18/06/2020
     * @param: Map of interactions by Case Id
     * @param: Case Id to be added
     * @param: Interaction to be added
     * @return Map of interactions by Case Id 
     * */
    public static Map<Id, List<String>> addCsInteractionsMap(Map<Id, List<String>> csIdInteractionsMap, String caseId, String interaction){  
        
        if(!csIdInteractionsMap.isEmpty() && csIdInteractionsMap.containsKey(caseId)){
            csIdInteractionsMap.get(caseId).add(interaction);
        } else { csIdInteractionsMap.put(caseId, new List<String>{interaction}); }
            
        return csIdInteractionsMap;
    }
}