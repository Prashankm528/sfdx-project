/**
 * @author			Venkatesh Muniyasamy
 * @date 			  25/11/2019
 * @group			  CAJBP
 * @description	Provides SWOT list of JBP SWOT Custom Component for Related List
 *
 * history
 * 25/11/2019	Venkatesh Muniyasamy	Created
 * 23/12/2019 	Venkatesh Muniyasamy    Updated for Test Class Mock
 */
public class CAJBP_SwotController
{
   @TestVisible
    private static SwotDAO SwotService = new SwotDAO();

    //Returns the list SWOT for the given JBP
    @AuraEnabled(cacheable=false)
    public static Map<String, List<Swot>> getSwots(Id jbpId) {
        return SwotService.getSwots(jbpId);
    }

    @AuraEnabled
    public static void updateSwots(String json) {
        try {
            update ((List<CAJBP_SWOT__c>) System.JSON.deserialize(json, List<CAJBP_SWOT__c>.class));
        } catch(System.Exception ex) {
            System.AuraHandledException auraException = new System.AuraHandledException(ex.getMessage());
            auraException.initCause(ex);

            throw auraException;
        }
    }

    public virtual with sharing class SwotDAO {

        public virtual Map<String, List<Swot>> getSwots(Id jbpId) {
            Map<String, List<Swot>> swotMap = new Map<String, List<Swot>>();

            for (CAJBP_SWOT__c swotItem :[SELECT Id, Name, Type__c, CAJBP_Sort_Order__c,
                                            CAJBP_Colour__c, CAJBP_Description__c,
                                            CAJBP_Active__c,
                                            (SELECT Id FROM Objective_SWOTs__r)
                                        FROM CAJBP_SWOT__c
                                        WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                                            AND Type__c != NULL
                                        ORDER BY CAJBP_Type_Order__c ASC,
                                                CAJBP_Sort_Order__c ASC NULLS LAST]) {

                if(!swotMap.containsKey(swotItem.Type__c)) {
                    swotMap.put(swotItem.Type__c, new List<Swot>());
                }

                swotMap.get(swotItem.Type__c).add(new Swot(swotItem));
            }

            return swotMap;
        }
    }

    public class Swot {
        @AuraEnabled
        public ID id {get; private set;}
        @AuraEnabled
        public String title {get; private set;}
        @AuraEnabled
        public String description {get; private set;}
        @AuraEnabled
        public String colour {get; private set;}
        @AuraEnabled
        public String type {get; private set;}
        @AuraEnabled
        public Integer objectives {get; private set;}
        @AuraEnabled
        public Boolean active {get; private set;}

        public Swot(CAJBP_SWOT__c record) {
            id = record.Id;
            title = record.Name;
            description = record.CAJBP_Description__c;
            colour = record.CAJBP_Colour__c;
            type = record.Type__c;
            objectives = record.Objective_SWOTs__r.size();
            active = record.CAJBP_Active__c;
        }
    }
}