/**
 * @author          Jan Majling
 * @date            17/09/2018
 * @group           CAJBP
 * @description     controller for lightning component CAJBP_JbpBridgeChart
 *
 * history
 * 17/09/2018   Jan Majling             Created
 * 22/05/2020   Venkatesh Muniyasamy    Updated.
 */
public with sharing class CAJBP_JbpBridgeChartController {
    /**
     * @description Record Data inner class
     */
    public class ChartData {
        @AuraEnabled
        public Integer previousYear;
        @AuraEnabled
        public Integer currentYear;
        @AuraEnabled
        public Decimal previousYearVolume;
        @AuraEnabled
        public Decimal targetValueVolume;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public List<ActivityRecord> activities;
    }   
    
    /**
     * @description gets chart data
     * @param jbpId of type Id
     * @return ChartData
     */
    @AuraEnabled
    public static ChartData getChartData(Id jbpId) {
        CAJBP_Joint_Business_Plan__c jbp = [
            SELECT RecordTypeId, CAJBP_SellIn_Previous_Annual_Volume__c, CAJBP_Year__c, CAJBP_Account__r.Name,
                (SELECT CAJBP_Sell_In_Volume_Plan__c, CAJBP_Total_Volume_Sell_In_Target__c
                FROM CAJBP_Scorecards__r)
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Id = :jbpId
        ].get(0);

        CAJBP_Scorecard__c scorecard = jbp.CAJBP_Scorecards__r.get(0);
        Boolean isIndirect = CAJBP_JbpBridgeChartController.isIndirectJbp(jbp.RecordTypeId);

        ChartData chartData = new ChartData();
        chartData.previousYearVolume = jbp.CAJBP_SellIn_Previous_Annual_Volume__c;
        chartData.currentYear = Integer.valueOf(jbp.CAJBP_Year__c);
        chartData.previousYear = chartData.currentYear - 1;
        chartData.targetValueVolume = isIndirect ? scorecard.CAJBP_Total_Volume_Sell_In_Target__c : scorecard.CAJBP_Sell_In_Volume_Plan__c;
        chartData.accountName = jbp.CAJBP_Account__r.Name;
        chartData.activities = CAJBP_JbpBridgeChartController.getActivities(jbp.Id);
        return chartData;
    }

    private static void checkFieldAccess(List<String> fieldsToCheck, Schema.SObjectType sObjectType) {
        Map<String, Schema.SObjectField> m = sObjectType.getDescribe().fields.getMap();

        for (String fieldToCheck :fieldsToCheck) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                String fieldlabel = m.get(fieldToCheck).getDescribe().getLabel();
                throw new AuraHandledException('Insufficient access to' + fieldlabel + ' field.');
            }
        }
    }
    
    /**
     * @description gets activities from the provided objectives and risks
     * @param jbpId of joint business plan
     * @return List<ActivityRecord>
     */
    private static List<ActivityRecord> getActivities(ID jbpId) {
        List<ActivityRecord> activities = new List<ActivityRecord>();

        checkFieldAccess(new List<String>{
            'Name',
            'CAJBP_Estimated_Volume__c',
            'CAJBP_Estimated_Cost__c',
            'CAJBP_Actual_Volume__c',
            'CAJBP_Actual_Cost__c'
        }, CAJBP_JBP_Activity__c.getSObjectType());

        checkFieldAccess(new List<String>{
            'Name',
            'CAJBP_Volume__c',
            'CAJBP_Value__c',
            'CAJBP_Impact_Date__c'
        }, CAJBP_Risk__c.getSObjectType());

        List<AggregateResult> activityTypeList = [SELECT CAJBP_Activity_Type__c, SUM(CAJBP_Estimated_Volume__c), SUM(CAJBP_Estimated_Cost__c),
                                            SUM(CAJBP_Actual_Volume__c), SUM(CAJBP_Actual_Cost__c)
                                            FROM CAJBP_JBP_Activity__c
                                            WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                                                AND CAJBP_Objective__r.RecordType.DeveloperName = 'CAJBP_Objective'
                                            GROUP By CAJBP_Activity_Type__c];

        for(AggregateResult summary :  activityTypeList)
        {
            activities.add(new ActivityRecord(summary));
        }

        List<AggregateResult> riskList = [SELECT sum(CAJBP_Volume__c), sum(CAJBP_Value__c)
                                        FROM CAJBP_Risk__c
                                        WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                                            AND CAJBP_Status__c NOT IN ('Withdrawn')];

        for(AggregateResult risk : riskList)
        {
            activities.add(new ActivityRecord(risk,'Risks'));
        }

        activities.sort();
        return activities;
    }

    /**
     * @description checks whether the provided record type Id belongs to indirect JBP
     * @param recordTypeId of type Id
     * @return Boolean
     */
    private static Boolean isIndirectJbp(Id recordTypeId) {
        RecordTypeInfo recordTypeInfo = CAJBP_Joint_Business_Plan__c.sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId);
        return recordTypeInfo.getDeveloperName().contains('Indirect');
    }

    public class ActivityRecord implements Comparable {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Decimal estimatedVolume {get; set;}
        @AuraEnabled
        public Decimal estimatedCost {get; set;}
        @AuraEnabled
        public Decimal actualVolume {get; set;}
        @AuraEnabled
        public Decimal actualCost {get; set;}
        @AuraEnabled
        public Date startDate {get; set;}

        public ActivityRecord(AggregateResult activity) {
            name = (string) activity.get('CAJBP_Activity_Type__c');
            estimatedVolume = (Decimal) activity.get('expr0');
            estimatedCost = (Decimal)  activity.get('expr1');
            actualVolume = (Decimal)  activity.get('expr2');
            actualCost = (Decimal)  activity.get('expr3');
        }

        public ActivityRecord(AggregateResult risk,string riskName) {
            name = riskName;
            estimatedVolume = (Decimal) risk.get('expr0');
            estimatedCost = (Decimal) risk.get('expr1');
        }

        public Integer compareTo(Object compareTo) {
            ActivityRecord other = (ActivityRecord)compareTo;
            Integer returnValue = 0;

            if (this.startDate != null && other.startDate != null) {
                if (this.startDate > other.startDate) {
                    returnValue = 1;
                } else if (this.startDate < other.startDate) {
                    returnValue = -1;
                }
            }

            return returnValue;
        }
    }
}