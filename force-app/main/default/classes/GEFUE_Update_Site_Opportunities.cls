/*****************************************************************************************
*   Date:           07MAY20
*   Author:         Abhishek Sharma – TCS (Tata Consultancy Services Ltd.)
*   Description:    This class is used to copy Package Opportunites Infomation to the 
					related Site Opportunities.
*   Modifications:  
****************************************************************************************/

public with sharing class GEFUE_Update_Site_Opportunities {
    
     /**
     * @description gets Package opportunity ID and copy information to Site Opportunity
     */ 
    @AuraEnabled
    public static String updateSiteCloseDate(String opportunityID){
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GEFUE_Fuels_NA_Branded').getRecordTypeId();
        
        Opportunity parentOppty = [
                                    SELECT
                                        CloseDate,
                                        StageName
                                    FROM
                                    	Opportunity
                                    WHERE
                                    	Id =: opportunityID
                                ];
        
        List<Opportunity> siteOppotyID = [
                                            SELECT
                                            	Id
                                            FROM
                                            	Opportunity
                                            WHERE
                                            	GEFUE_Package__c = :opportunityID
                                            AND
                                            	RecordtypeID = :devRecordTypeId
                                        ];
        List<GEFUE_Opportunity_Terminal__c> childPackageTerminal = [
                                                                        SELECT
                                                                        	Id,
                                                                        	Terminal__c
                                                                        FROM
                                                                        	GEFUE_Opportunity_Terminal__c
                                                                        WHERE
                                                                        	Opportunity__c = :opportunityID
                                                                    ];
        
        List<GEFUE_Opportunity_Stage_Update__mdt> siteStageValue = [
                                                                    SELECT
                                                                        Id, 
                                                                        GEFUE_Opportunity_Stage__c
                                                                    FROM
                                                                    	GEFUE_Opportunity_Stage_Update__mdt
                                                                    WHERE
                                                                    	GEFUE_Opportunity_Recordtype__c = 'GEFUE_Fuels_NA_Branded'
                                                                ];
        
        Map<String,GEFUE_Opportunity_Stage_Update__mdt> mapStageName = New Map<String,GEFUE_Opportunity_Stage_Update__mdt>();
        
        for(GEFUE_Opportunity_Stage_Update__mdt stageMDT : siteStageValue){
            mapStageName.put(stageMDT.GEFUE_Opportunity_Stage__c,stageMDT);
        }
            
        
        for (Opportunity opptyID : siteOppotyID) {
            if (parentOppty != NULL && parentOppty.CloseDate != NULL) {
                opptyID.CloseDate = parentOppty.CloseDate;
            }
            
            if (childPackageTerminal.size() == 1) {
                if (childPackageTerminal[0].Terminal__c != NULL) {
                    opptyID.GEFUE_Terminal__c = childPackageTerminal[0].Terminal__c;
                }
            }
            
                if (parentOppty != NULL) {
                    if(mapStageName.containsKey(parentOppty.StageName)) {
                        opptyID.StageName=parentOppty.StageName;
                    }
                }
            
        }
        try {
        	Database.update(siteOppotyID,false);
        } catch(DmlException e){
            System.debug(e);
        }
        return 'Success in updating';
    }
}