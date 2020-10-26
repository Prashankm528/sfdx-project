/**
 * @author			Venkatesh Muniyasamy
 * @date			29/01/2020
 * @group			CAJBP
 * @description		handles currency assignment for CAJBP_Objective__c
 *
 * history
 * 29/01/2020	Venkatesh Muniyasamy    Created
 */
public with sharing class CAJBP_RelatedJbpCurrency
{
    public static Map<Id,string> jbpCurrency;

    public static void assignJbpCurrency(SObjectField jbpIdField, SObjectField currencyField, List<sObject> newRecords)
    {
        Set<Id> jbpId = new Set<Id>();

        for(SObject jbpcurrency : newRecords)
        {
            jbpId.add(string.valueOf(jbpcurrency.get(jbpIdField)));
        }

        jbpId.remove(null);

        jbpCurrency = CAJBP_JbpHelper.getJbpCurrency(jbpId);

        for(SObject obj : newRecords)
        {
            obj.put(currencyField,jbpCurrency.get(string.valueOf(obj.get(jbpIdField))));
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
}