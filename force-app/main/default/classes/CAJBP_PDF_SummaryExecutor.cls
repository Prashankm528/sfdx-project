global with sharing class CAJBP_PDF_SummaryExecutor {
    //Constants used in the PDF data queries.
    public static final String SWOT_STRENGTH = 'Strength';
    public static final String SWOT_WEAKNESS = 'Weakness';
    public static final String SWOT_OPPORTUNITY = 'Opportunity';
    public static final String SWOT_THREAT = 'Threat';
    public static final String ACTIVITY_WITHDRAWN = 'Withdrawn';

    public static final String HEADER_IMAGE_PATH = '/images/main/header/';
    public static final String DEFAULT_HEADER_IMAGE = 'en_header.png';

    //Stores statuses that are invalid for activity data.
    public static Set<String> INVALID_ACTIVITY_STATUSES {
        get {
            if (INVALID_ACTIVITY_STATUSES == null) {
                INVALID_ACTIVITY_STATUSES = new Set<String>{
                    ACTIVITY_WITHDRAWN
                };
            }

            return INVALID_ACTIVITY_STATUSES;
        }

        private set;
    }

    //This stores the custom labels to show as error messages.
    public List<String> messages {get; private set;}
    //Stores the current user details like locale.
    public User currentUser {get; private set;}
    public ID recordId {get; private set;}

    public CAJBP_PDF_SummaryExecutor(ApexPages.StandardController stdController) {
        this.messages = new List<String>();
        //get current user locale to enforce in visualforce page.
        this.currentUser = [SELECT Id, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        this.recordId = ((CAJBP_Joint_Business_Plan__c)stdController.getRecord()).Id;

        //Query joint business plan and validate data.
        CAJBP_Joint_Business_Plan__c record = [
            SELECT Id, CAJBP_Account_Locale__c
            FROM CAJBP_Joint_Business_Plan__c
            WHERE Id = :this.recordId
        ];

        //Throw error if no account locale set on jbp.
        if (String.isBlank(record.CAJBP_Account_Locale__c)) {
            this.messages.add(System.Label.CAJBP_PDF_Missing_Locale);
        }
    }

    /*
    * Creates a PDF cache, used so large data is not transported to the PDF viewer page.
    * Can also be used to store dynamically generated images like charts to be rendered on
    * the PDF.
    */
    @RemoteAction
    global static ID generateCache(ID jbpId, String data) {
        if (String.isBlank(jbpId)) return null;
        return CAJBP_PDF_DataStrategy.createCache(jbpId, data).Id;
    }

    /*
    * Returns an input data strategy for data transformation.
    */
    @ReadOnly
    @RemoteAction
    global static CAJBP_PDF_DataStrategy.InputSummary getPayload(ID recordId) {
        CAJBP_PDF_DataStrategy.InputSummary response = new CAJBP_PDF_DataStrategy.InputSummary();
        response.generatedDate = Date.today();
        response.generatedBy = UserInfo.getName();

        //Query joint business plan.
        response.jbp = [
            SELECT Id, Name, CAJBP_State__c, CAJBP_Year__c, Owner.Name, CAJBP_Account_Status__c,
                CAJBP_JBP_Start_Date__c, CAJBP_JBP_End_Date__c, CAJBP_Account__r.Name,
                CAJBP_Contract_Term_Start_Date__c, CAJBP_Contract_Term_End_Date__c,
                CAJBP_Description__c, CAJBP_Vision_Statement__c, CAJBP_Account_Locale__c,
                CurrencyIsoCode, RecordType.DeveloperName, CAJBP_SellIn_Previous_Annual_Turnover__c,
                CAJBP_SellIn_Previous_Annual_Volume__c, CAJBP_SellOut_Previous_Annual_Turnover__c,
                CAJBP_SellOut_Previous_Annual_Volume__c
            FROM CAJBP_Joint_Business_Plan__c WHERE Id = :recordId
        ];

        if (String.isNotBlank(response.jbp.CAJBP_Description__c)) {
            response.jbp.CAJBP_Description__c = '<div style="width: 500px;">' + response.jbp.CAJBP_Description__c + '</div>';

            if (response.jbp.CAJBP_Description__c.containsIgnoreCase('<img')) {
                response.jbp.CAJBP_Description__c = response.jbp.CAJBP_Description__c.replace('<img', '<div class="container"><img');
                response.jbp.CAJBP_Description__c = response.jbp.CAJBP_Description__c.replace('/img>', '/img></div>');
            }
        }

        if (String.isNotBlank(response.jbp.CAJBP_Vision_Statement__c)) {
            response.jbp.CAJBP_Vision_Statement__c = '<div style="width: 500px;">' + response.jbp.CAJBP_Vision_Statement__c + '</div>';

            if (response.jbp.CAJBP_Vision_Statement__c.containsIgnoreCase('<img')) {
                response.jbp.CAJBP_Vision_Statement__c = response.jbp.CAJBP_Vision_Statement__c.replace('<img', '<div class="container"><img');
                response.jbp.CAJBP_Vision_Statement__c = response.jbp.CAJBP_Vision_Statement__c.replace('/img>', '/img></div>');
            }
        }

        //Extract language used to establish translation and locale for formatting numbers, currency and dates.
        String language = response.jbp.CAJBP_Account_Locale__c.substring(0, response.jbp.CAJBP_Account_Locale__c.indexOf('_'));

        response.objectives = new List<CAJBP_Objective__c>([
            SELECT Name, CAJBP_Actual_Cost__c, CAJBP_Actual_Value__c , CAJBP_Actual_Volume__c,
                CAJBP_Estimated_Cost__c, CAJBP_Estimated_Value__c, CAJBP_Estimated_Volume__c,
                CAJBP_Total_Activities__c, CAJBP_Completed_Activities__c, CurrencyIsoCode,
                (SELECT Name, CAJBP_Status__c, CAJBP_Paid_for_by__c, CAJBP_Estimated_Value__c,
                        CAJBP_Estimated_Volume__c, CAJBP_Estimated_Cost__c, CAJBP_Actual_Value__c,
                        CAJBP_Actual_Volume__c, CAJBP_Actual_Cost__c, CurrencyIsoCode,
                        CAJBP_Start_Date__c, CAJBP_End_Date__c
                    FROM JBP_Activities__r
                    WHERE CAJBP_Status__c NOT IN :INVALID_ACTIVITY_STATUSES
                    ORDER BY CAJBP_Start_Date__c ASC
                )
            FROM CAJBP_Objective__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        //Activity year builds up a data structure of all activities grouped in their allocated year across the relevant months.
        for (AggregateResult activity :[SELECT Id, Name, CAJBP_Activity_Type__c,
                                            CALENDAR_YEAR(CAJBP_Start_Date__c) startYear,
                                            CALENDAR_MONTH(CAJBP_Start_Date__c) startMonth,
                                            CALENDAR_YEAR(CAJBP_End_Date__c) endYear,
                                            CALENDAR_MONTH(CAJBP_End_Date__c) endMonth
                                        FROM CAJBP_JBP_Activity__c
                                        WHERE CAJBP_Start_Date__c != NULL AND CAJBP_End_Date__c != NULL
                                            AND CAJBP_Status__c NOT IN :INVALID_ACTIVITY_STATUSES
                                            AND CAJBP_Joint_Business_Plan__c = :recordId
                                        GROUP BY Id,
                                            Name,
                                            CAJBP_Activity_Type__c,
                                            CALENDAR_YEAR(CAJBP_Start_Date__c),
                                            CALENDAR_MONTH(CAJBP_Start_Date__c),
                                            CALENDAR_YEAR(CAJBP_End_Date__c),
                                            CALENDAR_MONTH(CAJBP_End_Date__c)
                                        ORDER BY CALENDAR_YEAR(CAJBP_Start_Date__c) ASC]) {

            //We only initialise activity year map when there is data.
            if (response.activityYear == null) {
                response.activityYear = new Map<String, List<CAJBP_PDF_DataStrategy.ActivityYear>>();
            }

            CAJBP_PDF_DataStrategy.CalendarActivity calendarActivity = new CAJBP_PDF_DataStrategy.CalendarActivity(activity);

            //When an activity date goes across multiple years, we will need to add them again to that relevant year pot.
            if (calendarActivity.startYear != calendarActivity.endYear) {
                //loop through years ...
                for (Integer i = calendarActivity.startYear; i < calendarActivity.endYear + 1; i++ ) {
                    addToActivityYearMap(
                        response.activityYear,
                        'CAJBP_Activity_Type__c',
                        calendarActivity,
                        i
                    );
                }
            } else {
                addToActivityYearMap(
                    response.activityYear,
                    'CAJBP_Activity_Type__c',
                    calendarActivity,
                    calendarActivity.startYear
                );
            }
        }

        response.swotStrengths = new List<CAJBP_SWOT__c>([
            SELECT Id, Name, CAJBP_Description__c
                FROM CAJBP_SWOT__c
            WHERE Type__c = :SWOT_STRENGTH AND CAJBP_Active__c = TRUE
            AND CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        response.swotWeaknesses = new List<CAJBP_SWOT__c>([
            SELECT Id, Name, CAJBP_Description__c
                FROM CAJBP_SWOT__c
            WHERE Type__c = :SWOT_WEAKNESS AND CAJBP_Active__c = TRUE
            AND CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        response.swotOpportunities = new List<CAJBP_SWOT__c>([
            SELECT Id, Name, CAJBP_Description__c
                FROM CAJBP_SWOT__c
            WHERE Type__c = :SWOT_OPPORTUNITY AND CAJBP_Active__c = TRUE
            AND CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        response.swotThreats = new List<CAJBP_SWOT__c>([
            SELECT Id, Name, CAJBP_Description__c
                FROM CAJBP_SWOT__c
            WHERE Type__c = :SWOT_THREAT AND CAJBP_Active__c = TRUE
            AND CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        response.scorecard = [
            SELECT Id, CAJBP_Sell_In_Volume_Plan__c, CAJBP_Sell_In_YTD_Volume_Actuals__c,
                CAJBP_Sell_In_YTD_Turnover_Actuals__c, CAJBP_Sell_In_Current_Year_MAT_Volume__c,
                CAJBP_Sell_In_Current_Year_MAT_Turnover__c, CAJBP_Sell_Out_YTD_Volume_Actuals__c,
                CAJBP_Sell_Out_YTD_Turnover_Actuals__c, CAJBP_Sell_Out_Current_Year_MAT_Volume__c,
                CAJBP_Sell_Out_Current_Year_MAT_Turnover__c, CurrencyIsoCode
            FROM CAJBP_Scorecard__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        response.singleRebatePPL = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Volume_Target__c, CAJBP_Price_Per_Litre__c,
                CAJBP_Target_Rebate_Amount__c, CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Single_Volume_Rebate_Target_PPL_Sell_In', 'CAJBP_Single_Volume_Rebate_Target_PPL_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.multiRebatePPL = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Volume_Target__c, CAJBP_Price_Per_Litre__c,
                CAJBP_Target_Rebate_Amount__c, CAJBP_Threshold_Volume_Target__c,
                CAJBP_Threshold_Price_Per_Litre__c, CAJBP_Threshold_Rebate_Amount__c,
                CAJBP_Stretch_Volume_Target__c, CAJBP_Stretch_Price_Per_Litre__c,
                CAJBP_Stretch_Rebate_Amount__c, CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Multiple_Volume_Rebate_Target_PPL_Sell_In', 'CAJBP_Multiple_Volume_Rebate_Target_PPL_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.singleRebatePercentage = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Turnover_Target__c, CAJBP_Target_Percentage_Rebate__c,
                CAJBP_Target_Rebate_Amount__c, CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Single_Turnover_Rebate_Target_Percentage_Sell_In', 'CAJBP_Single_Turnover_Rebate_Target_Percentage_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.multiRebatePercentage = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Turnover_Target__c, CAJBP_Target_Percentage_Rebate__c,
                CAJBP_Target_Rebate_Amount__c, CAJBP_Threshold_Turnover_Target__c,
                CAJBP_Threshold_Percentage_Rebate__c, CAJBP_Threshold_Rebate_Amount__c,
                CAJBP_Stretch_Turnover_Target__c, CAJBP_Stretch_Percentage_Rebate__c,
                CAJBP_Stretch_Rebate_Amount__c, CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Multiple_Turnover_Rebate_Target_Percentage_Sell_In', 'CAJBP_Multiple_Turnover_Rebate_Target_Percentage_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.singleRebateVolumePercentage = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Volume_Target__c, CAJBP_Price_Per_Litre__c, CAJBP_Turnover_Target__c,
                CAJBP_Target_Percentage_Rebate__c, CAJBP_Target_Rebate_Amount__c,
                CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Single_Volume_Rebate_Target_Percentage_Sell_In', 'CAJBP_Single_Volume_Rebate_Target_Percentage_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.multiRebateVolumePercentage = new List<CAJBP_Rebate__c>([
            SELECT Id, CAJBP_Volume_Target__c, CAJBP_Price_Per_Litre__c, CAJBP_Turnover_Target__c,
                CAJBP_Target_Percentage_Rebate__c, CAJBP_Target_Rebate_Amount__c,
                CAJBP_Threshold_Volume_Target__c, CAJBP_Threshold_Price_Per_Litre__c,
                CAJBP_Threshold_Turnover_Target__c, CAJBP_Threshold_Percentage_Rebate__c,
                CAJBP_Threshold_Rebate_Amount__c, CAJBP_Stretch_Volume_Target__c,
                CAJBP_Stretch_Price_Per_Litre__c, CAJBP_Stretch_Turnover_Target__c,
                CAJBP_Stretch_Percentage_Rebate__c, CAJBP_Stretch_Rebate_Amount__c,
                CurrencyIsoCode, RecordType.Name
            FROM CAJBP_Rebate__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Multiple_Volume_Rebate_Target_Percentage_Sell_In', 'CAJBP_Multiple_Volume_Rebate_Target_Percentage_Sell_Out')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.mixAnnualPPL = new List<CAJBP_Product_Mix_Target__c>([
            SELECT Id, CAJBP_Volume_Target__c, CAJBP_Price_Per_Litre_Rebate__c,
                CAJBP_Actual_YTD_Volume__c, RecordType.Name, CurrencyIsoCode,
                CAJBP_Product_Variant__r.Name, Product_Brand__c, CAJBP_Product_Mix_Target_Name__c
            FROM CAJBP_Product_Mix_Target__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Annual_Sell_In_PPL_Rebate', 'CAJBP_Annual_Sell_Out_PPL_Rebate')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.mixAnnualPercentage = new List<CAJBP_Product_Mix_Target__c>([
            SELECT Id, CAJBP_Annual_Volume_Target__c, CAJBP_Percentage_Rebate__c,
                CAJBP_Actual_YTD_Volume__c, RecordType.Name, CurrencyIsoCode,
                CAJBP_Product_Variant__r.Name, Product_Brand__c, CAJBP_Product_Mix_Target_Name__c
            FROM CAJBP_Product_Mix_Target__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Annual_Sell_In_Percentage_Rebate', 'CAJBP_Annual_Sell_Out_Percentage_Rebate')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.mixQuarterlyPPL = new List<CAJBP_Product_Mix_Target__c>([
            SELECT Id, CAJBP_Q1_Volume_Target__c, CAJBP_Q2_Volume_Target__c,
                CAJBP_Q3_Volume_Target__c, CAJBP_Q4_Volume_Target__c,
                CAJBP_Price_Per_Litre_Rebate_Q1__c, CAJBP_Price_Per_Litre_Rebate_Q2__c,
                CAJBP_Price_Per_Litre_Rebate_Q3__c, CAJBP_Price_Per_Litre_Rebate_Q4__c,
                CAJBP_Q1_Actual_YTD_Volume__c, CAJBP_Q2_Actual_YTD_Volume__c,
                CAJBP_Q3_Actual_YTD_Volume__c, CAJBP_Q4_Actual_YTD_Volume__c,
                RecordType.Name, CurrencyIsoCode,
                CAJBP_Product_Variant__r.Name, Product_Brand__c, CAJBP_Product_Mix_Target_Name__c
            FROM CAJBP_Product_Mix_Target__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Quarterly_Sell_In_PPL_Rebate', 'CAJBP_Quarterly_Sell_Out_PPL_Rebate')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.mixQuarterlyPercentage = new List<CAJBP_Product_Mix_Target__c>([
            SELECT Id, CAJBP_Q1_Volume_Target__c, CAJBP_Q2_Volume_Target__c,
                CAJBP_Q3_Volume_Target__c, CAJBP_Q4_Volume_Target__c,
                CAJBP_Percentage_Rebate_Q1__c, CAJBP_Percentage_Rebate_Q2__c,
                CAJBP_Percentage_Rebate_Q3__c, CAJBP_Percentage_Rebate_Q4__c,
                CAJBP_Q1_Actual_YTD_Volume__c, CAJBP_Q2_Actual_YTD_Volume__c,
                CAJBP_Q3_Actual_YTD_Volume__c, CAJBP_Q4_Actual_YTD_Volume__c,
                RecordType.Name, CurrencyIsoCode,
                CAJBP_Product_Variant__r.Name, Product_Brand__c, CAJBP_Product_Mix_Target_Name__c
            FROM CAJBP_Product_Mix_Target__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            AND RecordType.DeveloperName IN ('CAJBP_Quarterly_Sell_In_Percentage_Rebate', 'CAJBP_Quarterly_Sell_Out_Percentage_Rebate')
            ORDER BY RecordType.DeveloperName ASC, CreatedDate ASC
        ]);

        response.waysOfWorkingTargets = new List<CAJBP_Ways_of_Working_Target__c>([
            SELECT Id, Name, CAJBP_Status__c, CAJBP_Due_Date__c,
                CAJBP_Rebate__c, CurrencyIsoCode
            FROM CAJBP_Ways_of_Working_Target__c
            WHERE CAJBP_Joint_Business_Plan__c = :recordId
            ORDER BY CreatedDate ASC
        ]);

        try {
            response.jaf = [
                SELECT Id, Name, CAJBP_Castrol_Contribution_Amount__c, CAJBP_Partner_Contribution_Amount__c,
                    CAJBP_Actual_Balance_Remaining__c, CAJBP_Estimated_Balance_Remaining__c,
                    CAJBP_Total_Joint_Activity_Fund__c, CAJBP_Actual_Spend__c, CAJBP_Estimated_Spend__c,
                    CurrencyIsoCode
                FROM CAJBP_Distributor_Joint_Activity_Fund__c
                WHERE CAJBP_Joint_Business_Plan__c = :recordId
                ORDER BY CreatedDate ASC
                LIMIT 1
            ];
        } catch(System.QueryException ex) {
            System.debug('Could not find JAF .......');
        }

        //Generate asset locations for PDF.
        response.assets = new CAJBP_PDF_DataStrategy.AssetLibrary();
        response.assets.pageHeaderImageName = HEADER_IMAGE_PATH + DEFAULT_HEADER_IMAGE;

        try {
            String targetHeaderImageName = language + '_' + 'header.png';

            new PageReference('/resource/CAJBP_PDF_Assets' + HEADER_IMAGE_PATH + targetHeaderImageName).getContent();
            response.assets.pageHeaderImageName = HEADER_IMAGE_PATH + targetHeaderImageName;
        } catch(VisualforceException e) {
            System.debug('Could not find image header, defaulting to en_header .......');
        }

        return response;
    }

    private static void addToActivityYearMap(Map<String, List<CAJBP_PDF_DataStrategy.ActivityYear>> activityYearMap,
                                                String sObjectType, CAJBP_PDF_DataStrategy.CalendarActivity calendarActivity,
                                                Integer targetYear) {

        String contextYear = String.valueOf(targetYear);

        if (!activityYearMap.containsKey(contextYear)) {
            activityYearMap.put(contextYear, new List<CAJBP_PDF_DataStrategy.ActivityYear>());
        }

        activityYearMap.get(contextYear).add(
            CAJBP_PDF_DataStrategy.createActivityYear(
                sObjectType,
                calendarActivity,
                targetYear
            )
        );
    }
}