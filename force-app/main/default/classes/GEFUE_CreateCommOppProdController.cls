/*****************************************************************************************
*   Date:           8JUNE20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Tests the lightning component GEFUE_NEW_PRODUCt, that filter Products based on Terminal entry.
*   Modifications:  
****************************************************************************************/
public with sharing class GEFUE_CreateCommOppProdController {
    public static List<GEFUE_Product_Terminal__c> lstProductTerminals;

    /* Constructor */
    public GEFUE_CreateCommOppProdController() {
        lstProductTerminals = new List<GEFUE_Product_Terminal__c>();
    }
    
	/* Fetches lookup values based on search KeyWord */
    @AuraEnabled
    public static List <GEFUE_Product_Terminal__c> fetchLookUpValues(String searchKeyWord, String ObjectName, Map<String, GEFUE_Product_Terminal__c> mapProdTerm) {
        List<GEFUE_Product_Terminal__c> returnList = new List <GEFUE_Product_Terminal__c> ();
        for(String str : mapProdTerm.keySet()) {
            if (str.contains(searchKeyWord.toLowerCase())) {
                returnList.add(mapProdTerm.get(str));
            }
        }
        return returnList;
    }
    
	/* Fetches Products based on selected Terminal */
    @AuraEnabled
    public static Map<String, GEFUE_Product_Terminal__c> fetchRelatedProducts(String terminalId) {
        Map<String, GEFUE_Product_Terminal__c> mapStrProdTerm = new Map<String, GEFUE_Product_Terminal__c>();
        if (terminalId != NULL) {
            lstProductTerminals = [
                					SELECT
                						Id,
                						GEFUE_Product__c,
                						GEFUE_Product_Name__c,
                						GEFUE_Product_Description__c,
                						GEFUE_Terminal__c,
                						GEFUE_Product_Code__c
                					FROM
                						GEFUE_Product_Terminal__c
                					WHERE
                                        GEFUE_Terminal__c = :terminalId
            					];
        }
        
        for (GEFUE_Product_Terminal__c prodT : lstProductTerminals) {
            if(prodT.GEFUE_Product_Description__c!= null && prodT.GEFUE_Product_Description__c != '') {
				mapStrProdTerm.put(prodT.GEFUE_Product_Name__c.toLowerCase()+'##'+prodT.GEFUE_Product_Description__c.toLowerCase(), prodT);
     		} else {
         		mapStrProdTerm.put(prodT.GEFUE_Product_Name__c.toLowerCase(), prodT);
			}
        }
        return mapStrProdTerm;
    }
    
	/* Fetches Commercial Opportunity Record based on current record */
    @AuraEnabled
    public static GEFUE_Product_Terminal__c fetchCommercialOpportunityRecord(String recordId) {
        GEFUE_Product_Terminal__c prodTerm = new GEFUE_Product_Terminal__c();
        GEFUE_Commercial_Opportunity_Product__c cop = [	
                                                        SELECT
                                                            Id,
                                                            GEFUE_Product__c,
                                                            GEFUE_Terminal__c,
                                                            GEFUE_Opportunity__c,
            												GEFUE_Product_Description__c
                                                        FROM 
                                                        	GEFUE_Commercial_Opportunity_Product__c
                                                        WHERE
                                                        	Id = :recordId
        												];
        if (cop.GEFUE_Terminal__c != NULL && cop.GEFUE_Product__c != NULL) {
            prodTerm = [
                        SELECT
                            Id,
                            GEFUE_Product__c,
                            GEFUE_Product_Name__c,
                            GEFUE_Product_Description__c,
                			GEFUE_Product_Code__c,
                            GEFUE_Terminal__c
                        FROM
                        	GEFUE_Product_Terminal__c
                        WHERE
                        	GEFUE_Terminal__c = :cop.GEFUE_Terminal__c
                		AND
                			GEFUE_Product__c = :cop.GEFUE_Product__c
            		]; 
        }
        return prodTerm;
    }
}