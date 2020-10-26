/**
 * @author 			Abhinit Kohar
 * @date 			07/02/2020
 * @group			CAJBP
 * @description     Common class for JAF
 *
 * history
 * 07/02/2020	Abhinit Kohar       			Created
 */

public with sharing class CAJBP_JafCommons {

    //This method populates the Currency and Name fields from the related JBP
    public static void populateJafFields(List<CAJBP_Distributor_Joint_Activity_Fund__c> newRecords) {
        Set<Id> jbpIds = new Set<Id>();
        for(CAJBP_Distributor_Joint_Activity_Fund__c jaf : newRecords){
            jbpIds.add(jaf.CAJBP_Joint_Business_Plan__c);
        }

        if(!jbpIds.isEmpty()){
            Map<Id, CAJBP_Joint_Business_Plan__c> jbpMap = CAJBP_JbpHelper.getJbp(jbpIds);

            for(CAJBP_Distributor_Joint_Activity_Fund__c jaf : newRecords){
                String jbpName = jbpMap.get(jaf.CAJBP_Joint_Business_Plan__c).Name;
                if(String.isNotBlank(jbpName) && String.isBlank(jaf.Name)) {
                    jaf.Name = jbpName.replace('JBP','JAF');
                }
                jaf.CurrencyIsoCode = jbpMap.get(jaf.CAJBP_Joint_Business_Plan__c).CurrencyIsoCode;
            }
        }
    }

}