/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description     helper class for JBP object
 * 
 * history
 * 25/07/2018	Jan Majling			Created
 * 28/01/2020   Venkatesh Muniyasamy    Updated for Objective Currency as JBPs
 * 29/01/2020   Abhinit Kohar           Added a method getFieldNameOfTypeCurrency
 * 06/02/2020   Abhinit Kohar           Added method getJbp to return the map of JBPs based on JBP Ids
 */
public with sharing class CAJBP_JbpHelper {
	private static final Map<String,String> TYPES_BY_CODE = new Map<String,String>{
		'ZMHI' => Label.CAJBP_CustomerGroup,
		'ZMSP' => Label.CAJBP_SoldToParty
	};
    private static string type;
    /**
     * @description creates name for JBP
     * @param jbp of type CAJBP_Joint_Business_Plan__c
     * @param account of type Account
     * @return String
     */
    public static String createName(CAJBP_Joint_Business_Plan__c jbp, Account account) {
        type = string.isBlank(TYPES_BY_CODE.get(account.Type))?'':TYPES_BY_CODE.get(account.Type);
        if(type=='')
        {
            return String.format(
                '{0} JBP {1}',
                new String[]{
                    account.Name,
                    jbp.CAJBP_Year__c != null ? jbp.CAJBP_Year__c : ''
                    }
                );
        }
        else
        {
            return String.format(
                '{0} {1} JBP {2}',
                new String[]{
                    account.Name,
                    type,
                    jbp.CAJBP_Year__c != null ? jbp.CAJBP_Year__c : ''
                    }
                );
        }
    }
     /**
     * @description creates Scorecard record for JBP
     * @param jbp of type CAJBP_Joint_Business_Plan__c
     * @return 
     */
     public void createScorecardRecord(List<CAJBP_Joint_Business_Plan__c> lstNewJBPs) {
     
        list<CAJBP_Scorecard__c> lstScorecardToInsert = new list<CAJBP_Scorecard__c>();
        set<Id> setJBPid = new set<Id>();
        
        // Get the list of relevant JBPs
        for (CAJBP_Joint_Business_Plan__c objJBP: lstNewJBPs){
            setJBPid.add(objJBP.id);
        }
        
        list<CAJBP_Joint_Business_Plan__c > lstJBPs = new list<CAJBP_Joint_Business_Plan__c >([SELECT Id, CAJBP_Account__r.Name, CAJBP_Year__c
        	FROM CAJBP_Joint_Business_Plan__c
        	WHERE Id IN:setJBPid]
        );
        for(CAJBP_Joint_Business_Plan__c objJBP : lstJBPs){
            
            lstScorecardToInsert.add(new CAJBP_Scorecard__c(
                Name =  objJBP.CAJBP_Account__r.Name +' Scorecard ' + objJBP.CAJBP_Year__c,
                CAJBP_Joint_Business_Plan__c = objJBP.Id
            
            ));
        }
       
        if(!lstScorecardToInsert.isEmpty()){
            
            try{
                insert lstScorecardToInsert;
            
            }catch (DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                
            } 
        
        }
    
    }

    public static Map<Id,String> getJbpCurrency(set<Id> jbpId)
    {
        Map<Id,String> jbpCurrency = new Map<id,string>();
        List<CAJBP_Joint_Business_Plan__c> jbpCurrencyList = [SELECT id, currencyISOCode FROM CAJBP_Joint_Business_Plan__c
                                                                WHERE id =: jbpId];
        for(CAJBP_Joint_Business_Plan__c jbp : jbpCurrencyList)
        {
            if(jbpCurrency.get(jbp.Id)==null)
            jbpCurrency.put(jbp.id,jbp.CurrencyIsoCode);
        }

        return jbpCurrency;
    }

    public static Map<Id, CAJBP_Joint_Business_Plan__c> getJbp(set<Id> jbpIds) {
        return new Map<Id, CAJBP_Joint_Business_Plan__c>([SELECT id, Name, currencyISOCode FROM CAJBP_Joint_Business_Plan__c WHERE id = :jbpIds]);
    }

    /**
    * @description retrieve all the Currency fields of and Object
    * @param objectAPIName String (API Name of sObject)
    * @return List<String> (list of API names of the fields of type currency)
    */
    public static List<String> getFieldNameOfTypeCurrency(String objectAPIName){
        List<String> fieldNames =  new list<String>();
        List<string> types = new List<String>{objectAPIName};
        types.add(objectAPIName);

        if(!types.isEmpty()){
            Schema.DescribeSobjectResult r = Schema.describeSObjects(types)[0];

            for(string apiName : r.fields.getMap().keySet()){
                if(r.fields.getMap().get(apiName).getDescribe().getType() == Schema.DisplayType.Currency){
                    fieldNames.add(r.fields.getMap().get(apiName).getDescribe().getName());
                }
            }
        }
        return fieldNames;
    }
}