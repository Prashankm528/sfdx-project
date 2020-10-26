global with sharing class CAJBP_PDF_DataStrategy {
    public static final String PDF_HEADER = 'JBP_PDF_PAYLOAD';

    public static List<String> EMPTY_MONTHS {
        get {
            if (EMPTY_MONTHS == null) {
                EMPTY_MONTHS = new List<String>();

                for (Integer i = 0; i < 12; i++) {
                    EMPTY_MONTHS.add('');
                }
            }

            return EMPTY_MONTHS;
        }

        private set;
    }

    public static Map<Integer, String> CALENDAR_MONTHS {
         get {
            if (CALENDAR_MONTHS == null) {
                CALENDAR_MONTHS = new Map<Integer, String>{
                    1 => 'JAN',
                    2 => 'FEB',
                    3 => 'MAR',
                    4 => 'APR',
                    5 => 'MAY',
                    6 => 'JUN',
                    7 => 'JUL',
                    8 => 'AUG',
                    9 => 'SEP',
                    10 => 'OCT',
                    11 => 'NOV',
                    12 => 'DEC'
                };
            }

            return CALENDAR_MONTHS;
        }

        private set;
    }

    /*
    * Retrieves a PDF generated cache.
    */
    global static String getDataCache(ID cacheId) {
        return [
            SELECT Body FROM Attachment
            WHERE ParentId = :cacheId
            AND Name LIKE :(PDF_HEADER + '%')
            LIMIT 1
        ].Body.toString();
    }

    /*
    * Generates a PDF cache. There can only be 1 cache record for a JBP.
    * This stores the data transformation/snapshot for rendering the PDF.
    */
    public static CAJBP_PDF_Generated_Cache__c createCache(ID jbpId, String data) {
        CAJBP_PDF_Generated_Cache__c cache = null;

        try {
            cache = [
                SELECT Id
                FROM CAJBP_PDF_Generated_Cache__c
                WHERE CAJBP_Joint_Business_Plan__c = :jbpId
                LIMIT 1
            ];
        } catch(System.QueryException ex) {
            cache = null;
        }

        //Generate the container record to store attachment.
        if (cache == null) {
            cache = new CAJBP_PDF_Generated_Cache__c();
            cache.CAJBP_Joint_Business_Plan__c = jbpId;
            insert cache;
        }

        //Check if data cache exsits.
        List<Attachment> caches = new List<Attachment>([
            SELECT Id FROM Attachment
            WHERE ParentId = :cache.Id
            AND Name LIKE :(PDF_HEADER + '%')
        ]);

        //Delete any existing caches.
        if (!caches.isEmpty()) {
            delete caches;
            Database.emptyRecycleBin(caches);
        }

        Attachment document = new Attachment();
        document.ParentId = cache.Id;
        document.Body = Blob.valueOf(data);
        document.ContentType = 'application/json';
        document.Name = PDF_HEADER + '#' + jbpId + '#' + cache.Id;
        insert document;

        return cache;
    }

    /*
    * Creates an activity year object from a starting target year and activity.
    */
    public static ActivityYear createActivityYear(String sObjectType, CalendarActivity calendarActivity, Integer targetYear) {
        return new ActivityYear(
            sObjectType,
            calendarActivity.title,
            calendarActivity.type,
            String.valueOf(targetYear),
            (targetYear == calendarActivity.startYear ? calendarActivity.startMonth : 1),
            (targetYear < calendarActivity.endYear ? 12 : calendarActivity.endMonth)
        );
    }

    global class AssetLibrary {
        public String pageHeaderImageName {get; set;}
    }

    global class InputSummary {
        public AssetLibrary assets {get; set;}
        public Date generatedDate {get; set;}
        public String generatedBy {get; set;}
        public CAJBP_Joint_Business_Plan__c jbp {get; set;}
        public CAJBP_Distributor_Joint_Activity_Fund__c jaf {get; set;}
        public List<CAJBP_Objective__c> objectives {get; set;}
        public Map<String, List<ActivityYear>> activityYear {get; set;}

        public List<CAJBP_SWOT__c> swotStrengths {get; set;}
        public List<CAJBP_SWOT__c> swotWeaknesses {get; set;}
        public List<CAJBP_SWOT__c> swotOpportunities {get; set;}
        public List<CAJBP_SWOT__c> swotThreats {get; set;}

        public CAJBP_Scorecard__c scorecard {get; set;}
        public List<CAJBP_Rebate__c> singleRebatePPL {get; set;}
        public List<CAJBP_Rebate__c> singleRebatePercentage {get; set;}
        public List<CAJBP_Rebate__c> multiRebatePPL {get; set;}
        public List<CAJBP_Rebate__c> multiRebatePercentage {get; set;}
        public List<CAJBP_Rebate__c> singleRebateVolumePercentage {get; set;}
        public List<CAJBP_Rebate__c> multiRebateVolumePercentage {get; set;}

        public List<CAJBP_Product_Mix_Target__c> mixAnnualPPL {get; set;}
        public List<CAJBP_Product_Mix_Target__c> mixAnnualPercentage {get; set;}
        public List<CAJBP_Product_Mix_Target__c> mixQuarterlyPPL {get; set;}
        public List<CAJBP_Product_Mix_Target__c> mixQuarterlyPercentage {get; set;}
        public List<CAJBP_Ways_of_Working_Target__c> waysOfWorkingTargets {get; set;}
    }

    global class OutputSummary {
        public AssetLibrary assets {get; set;}
        public String generatedDate {get; set;}
        public String generatedBy {get; set;}
        public JointBusinessPlan jbp {get; set;}
        public List<Objective> objectives {get; set;}
        public Map<String, List<ActivityYear>> activityYear {get; set;}
        public List<SWOT> swotStrengths {get; set;}
        public List<SWOT> swotWeaknesses {get; set;}
        public List<SWOT> swotOpportunities {get; set;}
        public List<SWOT> swotThreats {get; set;}
        public Scorecard scorecard {get; set;}
        public List<Rebate> singleRebatePPL {get; set;}
        public List<Rebate> singleRebatePercentage {get; set;}
        public List<Rebate> multiRebatePPL {get; set;}
        public List<Rebate> multiRebatePercentage {get; set;}
        public List<Rebate> singleRebateVolumePercentage {get; set;}
        public List<Rebate> multiRebateVolumePercentage {get; set;}
        public List<ProductMixTarget> mixAnnualPPL {get; set;}
        public List<ProductMixTarget> mixAnnualPercentage {get; set;}
        public List<ProductMixTarget> mixQuarterlyPPL {get; set;}
        public List<ProductMixTarget> mixQuarterlyPercentage {get; set;}
        public List<WaysOfWorkingTarget> waysOfWorkingTargets {get; set;}
        public JointActivityFund jaf {get; set;}
    }

    global class JointBusinessPlan {
        public CAJBP_Joint_Business_Plan__c record {get; set;}
        public ID id {get; set;}
        public String name {get; set;}
        public String state {get; set;}
        public String accountStatus {get; set;}
        public String year {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String termStartDate {get; set;}
        public String termEndDate {get; set;}
        public String vision {get; set;}
        public String description {get; set;}
        public String accountName {get; set;}
        public String ownerName {get; set;}
        public String recordType {get; set;}
        public String currencyIsoCode {get; set;}
        public String locale {get; set;}
        public String sellInPreviousVolume {get; set;}
        public String sellInPreviousTurnover {get; set;}
        public String sellOutPreviousVolume {get; set;}
        public String sellOutPreviousTurnover {get; set;}
    }

    global class SWOT {
        public ID id {get; set;}
        public String title {get; set;}
        public String description {get; set;}
    }

    global class Objective {
        public ID id {get; set;}
        public String title {get; set;}
        public String totalActivities {get; set;}
        public String completedActivities {get; set;}
        public String estimatedCost {get; set;}
        public String estimatedValue {get; set;}
        public String estimatedVolume {get; set;}
        public String actualCost {get; set;}
        public String actualValue {get; set;}
        public String actualVolume {get; set;}
        public String currencyIsoCode {get; set;}
        public List<Activity> activities {get; set;}
    }

    global class Activity {
        public CAJBP_JBP_Activity__c record {get; set;}
        public ID id {get; set;}
        public String objectiveId {get; set;}
        public String title {get; set;}
        public String status {get; set;}
        public String paidBy {get; set;}
        public String estimatedValue {get; set;}
        public String estimatedVolume {get; set;}
        public String estimatedCost {get; set;}
        public String actualValue {get; set;}
        public String actualVolume {get; set;}
        public String actualCost {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String currencyIsoCode {get; set;}
    }

    global class Scorecard {
        public ID id {get; set;}
        public String sellInVolumePlan {get; set;}
        public String sellInActualVolume {get; set;}
        public String sellInActualTurnover {get; set;}
        public String sellInMatVolume {get; set;}
        public String sellInMatTurnover {get; set;}
        public String sellOutActualVolume {get; set;}
        public String sellOutActualTurnover {get; set;}
        public String sellOutMatVolume {get; set;}
        public String sellOutMatTurnover {get; set;}
        public String currencyIsoCode {get; set;}
    }

    global class Rebate {
        public ID id {get; set;}
        public String name {get; set;}
        public String targetVolume {get; set;}
        public String targetPPL {get; set;}
        public String targetTurnover {get; set;}
        public String targetPercentage {get; set;}
        public String targetRebate {get; set;}
        public String thresholdVolume {get; set;}
        public String thresholdPPL {get; set;}
        public String thresholdTurnover {get; set;}
        public String thresholdPercentage {get; set;}
        public String thresholdRebate {get; set;}
        public String stretchVolume {get; set;}
        public String stretchPPL {get; set;}
        public String stretchTurnover {get; set;}
        public String stretchPercentage {get; set;}
        public String stretchRebate {get; set;}
        public String currencyIsoCode {get; set;}
    }

    global class ProductMixTarget {
        public ID id {get; set;}
        public String product {get; set;}
        public String recordTypeName {get; set;}
        public String currencyIsoCode {get; set;}
        public String annualVolumeTarget {get; set;}
        public String annualPPL {get; set;}
        public String annualVolumeTargetPercentage {get; set;}
        public String annualPercentage {get; set;}
        public String actualYtdVolume {get; set;}
        public String q1Volume {get; set;}
        public String q2Volume {get; set;}
        public String q3Volume {get; set;}
        public String q4Volume {get; set;}
        public String q1PPL {get; set;}
        public String q2PPL {get; set;}
        public String q3PPL {get; set;}
        public String q4PPL {get; set;}
        public String q1Percentage {get; set;}
        public String q2Percentage {get; set;}
        public String q3Percentage {get; set;}
        public String q4Percentage {get; set;}
        public String q1ActualYtdVolume {get; set;}
        public String q2ActualYtdVolume {get; set;}
        public String q3ActualYtdVolume {get; set;}
        public String q4ActualYtdVolume {get; set;}
    }

    global class WaysOfWorkingTarget {
        public CAJBP_Ways_of_Working_Target__c record {get;set;}
        public ID id {get; set;}
        public String title {get; set;}
        public String status {get; set;}
        public String dueDate {get; set;}
        public String rebatePercentage {get; set;}
    }

    global class JointActivityFund {
        public ID id {get; set;}
        public String name {get; set;}
        public String castrolContribution {get; set;}
        public String partnerContribution {get; set;}
        public String totalFund {get; set;}
        public String estimatedSpend {get; set;}
        public String actualSpend {get; set;}
        public String estimatedRemaining {get; set;}
        public String actualRemaining {get; set;}
        public String currencyIsoCode {get; set;}
    }

    public class CalendarActivity {
        public String title {get; set;}
        public String type {get; set;}
        public Integer startYear {get; set;}
        public Integer startMonth {get; set;}
        public Integer endYear {get; set;}
        public Integer endMonth {get; set;}

        public CalendarActivity(AggregateResult activity) {
            title = String.valueOf(activity.get('Name'));
            type = String.valueOf(activity.get('CAJBP_Activity_Type__c'));
            startYear = Integer.valueOf(activity.get('startYear'));
            startMonth = Integer.valueOf(activity.get('startMonth'));
            endYear = Integer.valueOf(activity.get('endYear'));
            endMonth = Integer.valueOf(activity.get('endMonth'));
        }
    }

    global class ActivityYear {
        public String sobjectType {get; set;}
        public String title {get; set;}
        public String type {get; set;}
        public String year {get; set;}
        public List<String> months {get; set;}

        public ActivityYear(String sobjectType, String title, String type, String year, Integer startMonth, Integer endMonth) {
            months = new List<String>(EMPTY_MONTHS);
            this.sobjectType = sobjectType;
            this.title = title;
            this.type = type;
            this.year = year;

            for (Integer i = startMonth - 1; i < endMonth; i ++) {
                months.set(i, CALENDAR_MONTHS.get(i + 1));
            }
        }
    }
}