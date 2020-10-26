/**
* The probability override process is initiated from either the Override Probability or Reset Probability action buttons
* on an opportunity. The actions updates the probability override field, and in the background, triggers the logic to
* sync or reset the standard probability field.
*/
public class SFO_ProbabilityOverrideTriggerHandler 
{
    /*
    * Syncing probability % with custom override only happens on update so check criteria:
    *     - Only valid record types should be processed.
    *     - Probability % override must not be blank.
    *     - Reset to current stage probability if blank.
    */
    public static void syncProbability(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        //Stores current stages that were reset.
        Set<String> currentStages = new Set<String>();

        //Map that stores probability for stage.
        Map<String, Decimal> stageProbabilityMap = new Map<String, Decimal>();

        //Process only reset opportunities to improve performance.
        List<Opportunity> resetOpportunities = new List<Opportunity>();

        for (Opportunity thisOpp :opps) {
            Opportunity oldOpp = (oldOpps != null && oldOpps.containsKey(thisOpp.Id) ? oldOpps.get(thisOpp.Id) : null);

            /*
            * Probability override logic, will only run for opportunity record types thats in VALID_RECORD_TYPES.
            */
            if (SFO_Constant.VALID_RECORD_TYPES.contains(thisOpp.RecordTypeId)) {

                //Probability override was set, so process sync.
                if (thisOpp.CASFO_Probability_Override__c != null) {
                    thisOpp.Probability = thisOpp.CASFO_Probability_Override__c;
                }
                //Probability override was reset, so try assigning current stage probability.
                else if (oldOpp != null
                        && thisOpp.CASFO_Probability_Override__c != oldOpp.CASFO_Probability_Override__c
                        && thisOpp.CASFO_Probability_Override__c == null
                        && String.isNotBlank(thisOpp.StageName)) {

                    //Store the current opportunity stage.
                    currentStages.add(thisOpp.StageName);

                    //We will process only these opportunities later on, and not whole list again.
                    resetOpportunities.add(thisOpp);
                }
            }
        }

        if (currentStages.isEmpty() == false) {
            //Query OpportunityStage to get original probability for stage.
            for (OpportunityStage oppStage :[SELECT MasterLabel, DefaultProbability
                                                FROM OpportunityStage
                                                WHERE MasterLabel IN :currentStages]) {

                stageProbabilityMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }

        if (stageProbabilityMap.isEmpty() == false) {
            //Reset probability back to default for this stage.
            for (Opportunity thisOpp :resetOpportunities) {
                if (stageProbabilityMap.containsKey(thisOpp.StageName)) {
                    thisOpp.Probability = stageProbabilityMap.get(thisOpp.StageName);
                }
            }
        }
    }
}