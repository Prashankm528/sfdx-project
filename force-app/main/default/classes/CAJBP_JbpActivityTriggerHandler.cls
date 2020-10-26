/**
 * @author			Jana Cechova
 * @date			10/09/2018
 * @group			CAJBP
 * @description		handle triggers on CAJBP_JbpActivityTrigger
 *
 * history
 * 10/09/2018		Jan Cechova			Created
 * 03/10/2018		Jan Majling			Updated to set records in constructor
 * 22/10/2019   Venkatesh Muniyasamy    Updated for JAF Rollup
 * 12/12/2019   Venkatesh Muniyasamy    Updated for JAF removal for non JAF Activities
 * 30/01/2020   Venkatesh Muniyasamy    Updated for Related JBP Currency Update
 * 01/07/2020   Venkatesh Muniyasamy    Updated for Related JBP Total Rollup
 * 10/09/2020   Pooja Dhiman        Created a boolean so that while updating activities preventJAFActivityWithApprovers doesn't get invoked by Team member
 */
public with sharing class CAJBP_JbpActivityTriggerHandler {
	private final List<CAJBP_JBP_Activity__c> newRecords;
	private final List<CAJBP_JBP_Activity__c> oldRecords;
	private final Map<Id,CAJBP_JBP_Activity__c> newMap;
	private final Map<Id,CAJBP_JBP_Activity__c> oldMap;
    Map<Id,CAJBP_Distributor_Joint_Activity_Fund__c> jafs;
    Boolean isDelete = false;
    SObjectField jbpIdField =  Schema.CAJBP_JBP_Activity__c.Fields.CAJBP_Joint_Business_Plan__c;
    SObjectField currencyField =  Schema.CAJBP_JBP_Activity__c.Fields.CurrencyIsoCode;

	/**
	 * @description constructor
	 * @param newRecords of type List<CAJBP_JBP_Activity__c>
	 * @param oldRecords of type List<CAJBP_JBP_Activity__c>
	 * @param newMap of type Map<Id,CAJBP_JBP_Activity__c>
	 * @param oldMap of type Map<Id,CAJBP_JBP_Activity__c>
	 */
	public CAJBP_JbpActivityTriggerHandler(List<CAJBP_JBP_Activity__c> newRecords, List<CAJBP_JBP_Activity__c> oldRecords, Map<Id,CAJBP_JBP_Activity__c> newMap, Map<Id,CAJBP_JBP_Activity__c> oldMap) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
		this.newMap = newMap;
		this.oldMap = oldMap;
	}
	/**
	 * @description handles JBP activites on before insert
	 */
    public void handleBeforeInsert()
    {
        this.validateJAF();
        this.addJBP();
        this.totalCost();
		this.setJBPApprovers();
		this.preventJAFActivityWithApprovers();
        CAJBP_RelatedJbpCurrency.assignJbpCurrency(jbpIdField,currencyField, this.newRecords);
    }

    public void handleAfterInsert()
    {
        this.totalJAFActivities();
    }

    public void handleBeforeUpdate()
    {
        this.validateJAF();
        this.totalCost();
        this.setJBPApprovers();
        if(!CAJBP_JbpTeamMemberHelper.isExecutingFromTeamMemberTrigger){
            this.preventJAFActivityWithApprovers();
        }
    }

    public void handleAfterUpdate()
    {
        this.totalJAFActivities();
    }
	
	public void handleBeforeDelete()
    {
        this.validateJBPOwnerOfActivity();
    }

    public void handleAfterDelete()
    {
        this.isDelete=true;
        this.totalJAFActivities();
    }

    //set JBP Team Member's Finance / Marketing Approver to activity
    public void setJBPApprovers() {
        Set<Id> jbpIds = new Set<Id>();
        Map<Id,Id> financeApproverMap;
        Map<Id,Id> marketingApproverMap;
        for(CAJBP_JBP_Activity__c activity : this.newRecords){
            jbpIds.add(activity.CAJBP_Joint_Business_Plan__c);
        }
        jbpIds.remove(null);
        
        if(jbpIds.size()>0) {
            financeApproverMap = new Map<Id,Id>();
            marketingApproverMap = new Map<Id,Id>();
            for(CAJBP_JBP_Team_Member__c teamMember :  [SELECT CAJBP_Role__c, CAJBP_User__c, CAJBP_Joint_Business_Plan__c 
                                                       FROM CAJBP_JBP_Team_Member__c 
                                                       WHERE CAJBP_Joint_Business_Plan__c IN: jbpIds AND (CAJBP_Role__c = 'Marketing Approver' OR CAJBP_Role__c = 'Finance Approver')])
            {
                if(teamMember.CAJBP_Role__c == 'Marketing Approver'){
                    marketingApproverMap.put(teamMember.CAJBP_Joint_Business_Plan__c,teamMember.CAJBP_User__c); 
                } else {
                    financeApproverMap.put(teamMember.CAJBP_Joint_Business_Plan__c,teamMember.CAJBP_User__c);
                }
               
            }
        }

        for(CAJBP_JBP_Activity__c activityJBP : this.newRecords) 
        {
            if(financeApproverMap.containsKey(activityJBP.CAJBP_Joint_Business_Plan__c)){
                activityJBP.CAJBP_Finance_Approver__c = financeApproverMap.get(activityJBP.CAJBP_Joint_Business_Plan__c);
            }
            if(marketingApproverMap.containsKey(activityJBP.CAJBP_Joint_Business_Plan__c)){
            	activityJBP.CAJBP_Marketing_Approver__c = marketingApproverMap.get(activityJBP.CAJBP_Joint_Business_Plan__c);
            }
        }        
    }
	
	//set JBP Team Member's Finance / Marketing Approver to activity
    public void preventJAFActivityWithApprovers() {
        Set<Id> activityIds = new Set<Id>();
         for(CAJBP_JBP_Activity__c activity : this.newRecords){
             if(activity.CAJBP_Paid_for_by__c == 'JAF' && 
                								(activity.CAJBP_Finance_Approver__c == null || activity.CAJBP_Marketing_Approver__c == null)){
                activity.addError(System.Label.CAJBP_JAF_Activity_Team_Member_Approver_Error);   
             }
        }
    } 

    public void totalJAFActivities()
    {
        Set<Id> jafIds = new Set<Id>();

        if(this.isDelete && this.oldRecords !=null)
        {
            for(CAJBP_JBP_Activity__c activity :this.oldRecords)
            {
                jafIds.add(activity.CAJBP_Distributor_Joint_Activity_Fund__c);
            }
        }
        else if(this.newRecords != null)
        {
            for(CAJBP_JBP_Activity__c activity :this.newRecords)
            {
                jafIds.add(activity.CAJBP_Distributor_Joint_Activity_Fund__c);

                if(this.oldRecords !=null)
                {
                    jafIds.add(this.oldMap.get(activity.Id).CAJBP_Distributor_Joint_Activity_Fund__c);
                }
            }
        }

        jafIds.remove(null);

        if(jafIds.size()>0)
        {
            jafs = new Map<Id,CAJBP_Distributor_Joint_Activity_Fund__c>([SELECT id, CAJBP_Joint_Business_Plan__c,	CAJBP_Estimated_Spend__c,
	            CAJBP_Actual_Spend__c, CAJBP_Estimated_Castrol_Spend__c, CAJBP_Estimated_Partner_Spend__c,
                CAJBP_Actual_Castrol_Spend__c, CAJBP_Actual_Partner_Spend__c
                from  CAJBP_Distributor_Joint_Activity_Fund__c
                where Id IN : jafIds]);

            for(CAJBP_Distributor_Joint_Activity_Fund__c jaf: jafs.values())
            {
                jafs.get(jaf.id).CAJBP_Estimated_Spend__c=0;
                jafs.get(jaf.id).CAJBP_Actual_Spend__c=0;
                jafs.get(jaf.id).CAJBP_Estimated_Castrol_Spend__c=0;
                jafs.get(jaf.id).CAJBP_Estimated_Partner_Spend__c=0;
                jafs.get(jaf.id).CAJBP_Actual_Castrol_Spend__c=0;
                jafs.get(jaf.id).CAJBP_Actual_Partner_Spend__c=0;
            }

            List<CAJBP_JBP_Activity__c> totalActivityJaf = [SELECT CAJBP_Distributor_Joint_Activity_Fund__c, CAJBP_Estimated_Cost__c, CAJBP_Actual_Cost__c,
                    CAJBP_Partner_Actual_Cost__c, CAJBP_Partner_Estimated_Cost__c, CAJBP_Castrol_Actual_Cost__c, CAJBP_Castrol_Estimated_Cost__c
                    from CAJBP_JBP_Activity__c where CAJBP_Distributor_Joint_Activity_Fund__c IN : jafIds and CAJBP_Distributor_Joint_Activity_Fund__c !=null and
                    CAJBP_Status__c !='Withdrawn'];

            if(totalActivityJaf.size() >0)
            {
                for(CAJBP_JBP_Activity__c jafActivity: totalActivityJaf )
                {
                    Decimal Estimate = (jafActivity.CAJBP_Estimated_Cost__c>0? jafActivity.CAJBP_Estimated_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Spend__c;
                    Decimal Actual = (jafActivity.CAJBP_Actual_Cost__c >0?jafActivity.CAJBP_Actual_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Spend__c;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Spend__c = Estimate;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Spend__c = Actual;

                    Decimal actualPartnerCost = (jafActivity.CAJBP_Partner_Actual_Cost__c >0?jafActivity.CAJBP_Partner_Actual_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Partner_Spend__c;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Partner_Spend__c = actualPartnerCost;

                    Decimal actualCastrolCost = (jafActivity.CAJBP_Castrol_Actual_Cost__c >0?jafActivity.CAJBP_Castrol_Actual_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Castrol_Spend__c;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Actual_Castrol_Spend__c = actualCastrolCost;

                    Decimal estimatedCastrolCost = (jafActivity.CAJBP_Castrol_Estimated_Cost__c >0?jafActivity.CAJBP_Castrol_Estimated_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Castrol_Spend__c;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Castrol_Spend__c = estimatedCastrolCost;

                    Decimal estimatedPartnerCost = (jafActivity.CAJBP_Partner_Estimated_Cost__c >0?jafActivity.CAJBP_Partner_Estimated_Cost__c:0) + jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Partner_Spend__c;
                    jafs.get(jafactivity.CAJBP_Distributor_Joint_Activity_Fund__c).CAJBP_Estimated_Partner_Spend__c = estimatedPartnerCost;
                }
            }
            /**Aggregator SUM converting the currency into corporate currency, hence commented this section
            List<AggregateResult> totalActivityJaf = [SELECT CAJBP_Distributor_Joint_Activity_Fund__c, SUM(CAJBP_Estimated_Cost__c) totalEstimatedCost, SUM(CAJBP_Actual_Cost__c) totalActualCost
            from CAJBP_JBP_Activity__c where CAJBP_Distributor_Joint_Activity_Fund__c IN : jafIds and CAJBP_Distributor_Joint_Activity_Fund__c !=null group by CAJBP_Distributor_Joint_Activity_Fund__c ];
            for(AggregateResult aggResult : totalActivityJaf)
            {
                Decimal Estimate= (Decimal)aggResult.get('totalEstimatedCost')>0 ? (Decimal)aggResult.get('totalEstimatedCost'): 0;
                Decimal Actual= (Decimal)aggResult.get('totalActualCost')>0 ? (Decimal)aggResult.get('totalActualCost'): 0;

                jafs.get((Id)aggResult.get('CAJBP_Distributor_Joint_Activity_Fund__c')).CAJBP_Estimated_Spend__c = Estimate;
                jafs.get((Id)aggResult.get('CAJBP_Distributor_Joint_Activity_Fund__c')).CAJBP_Actual_Spend__c = Actual;
            }*/
            update jafs.values();
        }
    }
	
	//Validate if user who is deleting activity is JBP owner
    public void validateJBPOwnerOfActivity(){
        Map<Id,CAJBP_JBP_Activity__c> ownerIdMap = new Map<Id,CAJBP_JBP_Activity__c>([Select CAJBP_Joint_Business_Plan__r.OwnerId
                                                                                      From CAJBP_JBP_Activity__c 
                                                                                      Where Id IN : this.oldRecords]);                
        Boolean hasDeletePermission = FeatureManagement.checkPermission('CAJBP_Admin_Custom_Permission');
        if(!hasDeletePermission){
            for (CAJBP_JBP_Activity__c activity : this.oldRecords){
                if(ownerIdMap.get(activity.Id).CAJBP_Joint_Business_Plan__r.OwnerId != UserInfo.getUserId()){                    
                    activity.addError(System.Label.CAJBP_Validate_JBP_Owner_Error);                
                }
            }
        }        
    } 

    public void validateJAF()
    {
        Set<Id> objectiveIds = new Set<Id>();
        Map<Id, Id> objectiveIdsToJbpIds = new Map<Id, Id>();
        Map<Id, Id> jbpIdsToJafIds = new Map<Id, Id>();

        for (CAJBP_JBP_Activity__c activity :this.newRecords)
        {
            if(activity.CAJBP_Paid_for_by__c == 'JAF')
            {
                objectiveIds.add(activity.CAJBP_Objective__c);
            }
            else
            {
                activity.CAJBP_Distributor_Joint_Activity_Fund__c = null;
            }
        }
        objectiveIds.remove(null);
        if(objectiveIds.size()>0)
        {
            //Link between activity and JAF is the objective and JBP.
            for (CAJBP_Objective__c objective :[SELECT Id, CAJBP_Joint_Business_Plan__c
                                                    FROM CAJBP_Objective__c
                                                    WHERE Id IN :objectiveIds])
            {
                objectiveIdsToJbpIds.put(objective.Id, objective.CAJBP_Joint_Business_Plan__c);
            }

            //Store JBP to JAF.
            for (CAJBP_Distributor_Joint_Activity_Fund__c fund :[SELECT Id, CAJBP_Joint_Business_Plan__c
                                                                    FROM CAJBP_Distributor_Joint_Activity_Fund__c
                                                                    WHERE CAJBP_Joint_Business_Plan__c
                                                                        IN :new Set<Id>(objectiveIdsToJbpIds.values())
                                                                    ORDER BY CreatedDate DESC])
            {
                jbpIdsToJafIds.put(fund.CAJBP_Joint_Business_Plan__c, fund.Id);
            }

            for (CAJBP_JBP_Activity__c activity :this.newRecords){
                //Get the JBP id for this activity objective.
                Id jbpId = objectiveIdsToJbpIds.get(activity.CAJBP_Objective__c);

                if (activity.CAJBP_Paid_for_by__c == 'JAF')
                {
                    if (!jbpIdsToJafIds.containsKey(jbpId)) {
                        activity.addError(System.Label.CAJBP_No_JAF_Error);
                    } else {
                        if (activity.CAJBP_Distributor_Joint_Activity_Fund__c == null) {
                            activity.CAJBP_Distributor_Joint_Activity_Fund__c = jbpIdsToJafIds.get(jbpId);
                        }
                    }
                }
            }
        }
    }

    public void totalCost()
    {
        Decimal castrolEstimated,partnerEstimated, castrolActual,partnerActual;

        for(CAJBP_JBP_Activity__c activity : this.newRecords)
        {
            castrolEstimated = activity.CAJBP_Castrol_Estimated_Cost__c !=null ? activity.CAJBP_Castrol_Estimated_Cost__c:0;
            partnerEstimated = activity.CAJBP_Partner_Estimated_Cost__c !=null ? activity.CAJBP_Partner_Estimated_Cost__c:0;
            castrolActual = activity.CAJBP_Castrol_Actual_Cost__c !=null ? activity.CAJBP_Castrol_Actual_Cost__c :0;
            partnerActual = activity.CAJBP_Partner_Actual_Cost__c !=null ? activity.CAJBP_Partner_Actual_Cost__c :0;

            activity.CAJBP_Estimated_Cost__c = castrolEstimated + partnerEstimated;
            activity.CAJBP_Actual_Cost__c = castrolActual + partnerActual;
        }

    }

    public void addJBP()
    {
        Set<Id> objectiveId = new Set<Id>();
        Map<Id,Id> objectiveJBP = new Map<Id,Id>();

        for(CAJBP_JBP_Activity__c jbpActivity : this.newRecords)
        {
            objectiveId.add(jbpActivity.CAJBP_Objective__c);
        }

        objectiveId.remove(null);

        if(objectiveId.size()>0)
        {
            List<CAJBP_Objective__c> objectiveValue = [select id, CAJBP_Joint_Business_Plan__c from CAJBP_Objective__c where id IN: objectiveId];
            for(cajbp_Objective__c assignJBP: objectiveValue)
            {
                objectiveJBP.put(assignJBP.Id,assignJBP.CAJBP_Joint_Business_Plan__c);
            }
        }

        for(CAJBP_JBP_Activity__c activityJBP : this.newRecords)
        {
            activityJBP.CAJBP_Joint_Business_Plan__c = objectiveJBP.get(activityJBP.CAJBP_Objective__c);
        }
    }
}