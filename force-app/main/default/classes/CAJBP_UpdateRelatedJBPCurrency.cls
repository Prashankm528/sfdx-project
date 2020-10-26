/**
 * @author 			Abhinit Kohar
 * @date 			27/01/2020
 * @group			CAJBP
 * @description     Service class for updating the related records of JBP. This class implements Queueable interface so that it can be queued.
 */

public class CAJBP_UpdateRelatedJBPCurrency implements Queueable {

    public final map<id, String> jbpIdCurrencyMap;
    set<Id> jbpIds = new set<Id>();
    list<sObject> objList = new list<sObject>();
    String queryString = 'select id, CurrencyIsoCode, CAJBP_Joint_Business_Plan__c,';
    String queryStringWithoutComa = 'select id, CurrencyIsoCode, CAJBP_Joint_Business_Plan__c ';

    /**
     * @description constructor
     * @param jbpIdCurrency of type map<id, String>>
     */
    public CAJBP_UpdateRelatedJBPCurrency(map<id, String> jbpIdCurrency){
        jbpIdCurrencyMap = jbpIdCurrency;
        if(jbpIdCurrencyMap != null && !jbpIdCurrencyMap.isEmpty()){
            jbpIds = jbpIdCurrencyMap.keySet();
        }
    }

    /**
     * @description execute method, which gets called when this class is enqueued.
     */
    public void execute(QueueableContext context) {
        updateRelatedRecords();
    }

    /**
     * @description This is the method where the actual update happens for the related JBP records.
     */
    public void updateRelatedRecords(){
        if(jbpIdCurrencyMap != null && !jbpIdCurrencyMap.isEmpty()){
            populateRelatedActivities();
            populateRelatedRebates();
            populateRelatedProductMixTargets();
            populateRelatedWaysOfWorkingTargets();
            populateRelatedRisks();
            populateRelatedSwots();
            populateRelatedObjectiveSwots();
            populateRelatedObjectives();
            populateRelatedJafs();
            populateRelatedScorecards();

            if(objList != null && !objList.isEmpty()){
                update objList;
            }
        }
    }

    /**
     * @description This method is called from CAJBP_JbpTiggerHandler on update of JBP record to update the JBP related records if the Currency has been updated on JBP. This method enqueues this class, so that it runs asynchronously.
	 * @param newRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param oldRecords of type List<CAJBP_Joint_Business_Plan__c>
	 * @param newMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
	 * @param oldMap of type Map<Id,CAJBP_Joint_Business_Plan__c>
     */
    public static void updateRelatedJBPRecords(List<CAJBP_Joint_Business_Plan__c> newRecords, List<CAJBP_Joint_Business_Plan__c> oldRecords, Map<Id,CAJBP_Joint_Business_Plan__c> newMap, Map<Id,CAJBP_Joint_Business_Plan__c> oldMap){
        map<id, String> jbpIdCurrencyMap = new map<id, String>();
        for(CAJBP_Joint_Business_Plan__c jbp : newRecords){
            if(oldMap.get(jbp.Id).CurrencyIsoCode != jbp.CurrencyIsoCode){
                jbpIdCurrencyMap.put(jbp.Id, jbp.currencyISOCode);
            }
        }

        if(!jbpIdCurrencyMap.isEmpty()){
            System.enqueueJob(new CAJBP_UpdateRelatedJBPCurrency(jbpIdCurrencyMap));
        }
    }

    /**
     * @description This method populates the objList with the related JBP Objectives.
     */
    private void populateRelatedObjectives(){
        String queryString = getQueryString('CAJBP_Objective__c');
        for(CAJBP_Objective__c objective : Database.query(queryString + ' FROM CAJBP_Objective__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            objective.CurrencyIsoCode = jbpIdCurrencyMap.get(objective.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(objective);

            objList.add(objective);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Activities.
     */
    private void populateRelatedActivities(){
        String queryString = getQueryString('CAJBP_JBP_Activity__c');
        for(CAJBP_JBP_Activity__c activity : Database.query(queryString + ' FROM CAJBP_JBP_Activity__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            activity.CurrencyIsoCode = jbpIdCurrencyMap.get(activity.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(activity);

            objList.add(activity);
        }
    }

    /**
     * @description This method populates the objList with the related JBP JAFs.
     */
    private void populateRelatedJafs(){
        String queryString = getQueryString('CAJBP_Distributor_Joint_Activity_Fund__c');
        for(CAJBP_Distributor_Joint_Activity_Fund__c jaf : Database.query(queryString + ' FROM CAJBP_Distributor_Joint_Activity_Fund__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            jaf.CurrencyIsoCode = jbpIdCurrencyMap.get(jaf.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(jaf);

            objList.add(jaf);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Scorecards.
     */
    private void populateRelatedScorecards(){
        String queryString = getQueryString('CAJBP_Scorecard__c');
        for(CAJBP_Scorecard__c scorecard : Database.query(queryString + ' FROM CAJBP_Scorecard__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            scorecard.CurrencyIsoCode = jbpIdCurrencyMap.get(scorecard.CAJBP_Joint_Business_Plan__c);
            objList.add(scorecard);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Rebates.
     */
    private void populateRelatedRebates(){
        String queryString = getQueryString('CAJBP_Rebate__c');
        for(CAJBP_Rebate__c rebate : Database.query(queryString + ' FROM CAJBP_Rebate__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            rebate.CurrencyIsoCode = jbpIdCurrencyMap.get(rebate.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(rebate);

            objList.add(rebate);
        }
    }

    /**
     * @description This method populates the objList with the related Product Mix Targets.
     */
    private void populateRelatedProductMixTargets(){
        String queryString = getQueryString('CAJBP_Product_Mix_Target__c');
        for(CAJBP_Product_Mix_Target__c productMixTarget : Database.query(queryString + ' FROM CAJBP_Product_Mix_Target__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            productMixTarget.CurrencyIsoCode = jbpIdCurrencyMap.get(productMixTarget.CAJBP_Joint_Business_Plan__c);
            objList.add(productMixTarget);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Way of Working Targets.
     */
    private void populateRelatedWaysOfWorkingTargets(){
        String queryString = getQueryString('CAJBP_Ways_of_Working_Target__c');
        for(CAJBP_Ways_of_Working_Target__c waysOfWorkingTarget : Database.query(queryString + ' FROM CAJBP_Ways_of_Working_Target__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            waysOfWorkingTarget.CurrencyIsoCode = jbpIdCurrencyMap.get(waysOfWorkingTarget.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(waysOfWorkingTarget);

            objList.add(waysOfWorkingTarget);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Risks.
     */
    private void populateRelatedRisks(){
        String queryString = getQueryString('CAJBP_Risk__c');
        for(CAJBP_Risk__c risk : Database.query(queryString + ' FROM CAJBP_Risk__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            risk.CurrencyIsoCode = jbpIdCurrencyMap.get(risk.CAJBP_Joint_Business_Plan__c);
            CAJBP_RecordValidator.ignoreValidation(risk);

            objList.add(risk);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Swots.
     */
    private void populateRelatedSwots(){
        String queryString = getQueryString('CAJBP_SWOT__c');
        for(CAJBP_SWOT__c swot : Database.query(queryString + ' FROM CAJBP_SWOT__c where CAJBP_Joint_Business_Plan__c in :jbpIds')){
            swot.CurrencyIsoCode = jbpIdCurrencyMap.get(swot.CAJBP_Joint_Business_Plan__c);
            objList.add(swot);
        }
    }

    /**
     * @description This method populates the objList with the related JBP Objective Swots.
     */
    private void populateRelatedObjectiveSwots(){
        List<String> currencyFields = CAJBP_JbpHelper.getFieldNameOfTypeCurrency('CAJBP_Objective_SWOT__c');
        String queryStringCurrency;
        String queryString = 'select id, CurrencyIsoCode, CAJBP_Objective__r.CAJBP_Joint_Business_Plan__c,';
        String queryStringWithoutComa = 'select id, CurrencyIsoCode, CAJBP_Objective__r.CAJBP_Joint_Business_Plan__c ';
        String finalQueryString;

        if(currencyFields != null && !currencyFields.isEmpty()){
            queryStringCurrency = string.join(currencyFields,',');
            finalQueryString = queryString + queryStringCurrency;
        } else {
            finalQueryString = queryStringWithoutComa;
        }

        for(CAJBP_Objective_SWOT__c swot : Database.query(finalQueryString + ' FROM CAJBP_Objective_SWOT__c where CAJBP_Objective__r.CAJBP_Joint_Business_Plan__c in :jbpIds')){
            swot.CurrencyIsoCode = jbpIdCurrencyMap.get(swot.CAJBP_Objective__r.CAJBP_Joint_Business_Plan__c);
            objList.add(swot);
        }
    }

    /**
     * @description This method generates the query string with all the currency fields of the passed in Object name.
     * @param objName API name of the object.
     */
    private String getQueryString(String objName){
        List<String> currencyFields = CAJBP_JbpHelper.getFieldNameOfTypeCurrency(objName);

        String queryStringCurrency;
        String finalQueryString;

        if(currencyFields != null && !currencyFields.isEmpty()){
            queryStringCurrency = string.join(currencyFields,',');
            finalQueryString = queryString + queryStringCurrency;
        } else {
            finalQueryString = queryStringWithoutComa;
        }

        return finalQueryString;
    }
}