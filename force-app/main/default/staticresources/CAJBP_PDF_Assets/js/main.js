const DataParser = function(locale, currencyIsoCode) {
    const config = {
        dateTimeFormat: new Intl.DateTimeFormat(locale),
        numberFormat: new Intl.NumberFormat(locale, {style: 'decimal', minimumFractionDigits: 0, maximumFractionDigits: 0}),
        volumeFormat: new Intl.NumberFormat(locale, {style: 'decimal', minimumFractionDigits: 0, maximumFractionDigits: 0}),
        currencyFormat: new Intl.NumberFormat(locale, {style: 'decimal', minimumFractionDigits: 0, maximumFractionDigits: 2})
    };

    function formatDate(date) {
        if (date) {
            return config.dateTimeFormat.format(date);
        }

        return '';
    }

    function formatNumber(value) {
        return formatValue(config.numberFormat.format(value || 0.00));
    }

    function formatVolume(value) {
        return formatValue(config.volumeFormat.format(value || 0.00));
    }

    function formatCurrency(value) {
        return formatValue(config.currencyFormat.format(value || 0.00));
    }

    function formatValue(value) {
        if (value) {
            return value.replace(/[\u202F\u00A0\u2000\u2001\u2003]/g, ' ');
        }

        return '';
    }

    function formatBreaks(value) {
        if (value) {
            return value.replace(/(?:\r\n|\r|\n)/g, '<br>')
        }

        return '';
    }

    return {
        getConfig: function() {
            return config;
        },
        createJbp: function(jbp) {
            if (!jbp) return null;

            return {
                record: {
                    sobjectType: 'CAJBP_Joint_Business_Plan__c',
                    Id: jbp.Id,
                    CAJBP_State__c: jbp.CAJBP_State__c || '',
                    CAJBP_Account_Status__c: jbp.CAJBP_Account_Status__c || '',
                    CAJBP_Description__c: jbp.CAJBP_Description__c || '',
                    CAJBP_Vision_Statement__c: jbp.CAJBP_Vision_Statement__c || '',
                },
                id: jbp.Id || '',
                name: jbp.Name || '',
                state: jbp.CAJBP_State__c || '',
                accountStatus: jbp.CAJBP_Account_Status__c || '',
                year: jbp.CAJBP_Year__c || '',
                startDate: formatDate(jbp.CAJBP_JBP_Start_Date__c),
                endDate: formatDate(jbp.CAJBP_JBP_End_Date__c),
                termStartDate: formatDate(jbp.CAJBP_Contract_Term_Start_Date__c),
                termEndDate: formatDate(jbp.CAJBP_Contract_Term_End_Date__c),
                vision: jbp.CAJBP_Vision_Statement__c || '',
                description: jbp.CAJBP_Description__c || '',
                accountName: (jbp.CAJBP_Account__r ? jbp.CAJBP_Account__r.Name || '' : ''),
                ownerName: jbp.Owner.Name || '',
                recordType: jbp.RecordType.DeveloperName || '',
                currencyIsoCode: jbp.CurrencyIsoCode || '',
                locale: jbp.CAJBP_Account_Locale__c || '',
                sellInPreviousVolume: formatNumber(jbp.CAJBP_SellIn_Previous_Annual_Volume__c),
                sellInPreviousTurnover: formatCurrency(jbp.CAJBP_SellIn_Previous_Annual_Turnover__c),
                sellOutPreviousVolume: formatNumber(jbp.CAJBP_SellOut_Previous_Annual_Volume__c),
                sellOutPreviousTurnover: formatCurrency(jbp.CAJBP_SellOut_Previous_Annual_Turnover__c)
            };
        },
        createSwots: function (swots) {
            if (!swots) return null;

            return swots.map((swot) => {
                return {
                    id: swot.Id || '',
                    title: swot.Name || '',
                    description: formatBreaks(swot.CAJBP_Description__c || '')
                };
            });
        },
        createObjectives: function(objectives) {
            var self = this;
            if (!objectives) return null;

            return objectives.map((objective) => {
                return {
                    id: objective.Id || '',
                    title: objective.Name || '',
                    totalActivities: formatNumber(objective.CAJBP_Total_Activities__c),
                    completedActivities: formatNumber(objective.CAJBP_Completed_Activities__c),
                    estimatedCost: formatCurrency(objective.CAJBP_Estimated_Cost__c),
                    estimatedValue: formatCurrency(objective.CAJBP_Estimated_Value__c),
                    estimatedVolume: formatVolume(objective.CAJBP_Estimated_Volume__c),
                    actualCost: formatCurrency(objective.CAJBP_Actual_Cost__c),
                    actualValue: formatCurrency(objective.CAJBP_Actual_Value__c),
                    actualVolume: formatVolume(objective.CAJBP_Actual_Volume__c),
                    currencyIsoCode: objective.CurrencyIsoCode || '',
                    activities: self.createObjectiveActivities(objective)
                };
            });
        },
        createObjectiveActivities: function (objective) {
            if (!objective.JBP_Activities__r) return null;

            return objective.JBP_Activities__r.map((activity) => {
                return {
                    record: {
                        sobjectType: 'CAJBP_JBP_Activity__c',
                        Id: activity.Id,
                        CAJBP_Status__c: activity.CAJBP_Status__c || ''
                    },
                    id: activity.Id || '',
                    objectiveId: activity.CAJBP_Objective__c || '',
                    title: activity.Name || '',
                    status: activity.CAJBP_Status__c || '',
                    paidBy: activity.CAJBP_Paid_for_by__c || '',
                    estimatedValue: formatCurrency(activity.CAJBP_Estimated_Value__c),
                    estimatedVolume: formatVolume(activity.CAJBP_Estimated_Volume__c),
                    estimatedCost: formatCurrency(activity.CAJBP_Estimated_Cost__c),
                    actualValue: formatCurrency(activity.CAJBP_Actual_Value__c),
                    actualVolume: formatVolume(activity.CAJBP_Actual_Volume__c),
                    actualCost: formatCurrency(activity.CAJBP_Actual_Cost__c),
                    startDate: formatDate(activity.CAJBP_Start_Date__c),
                    endDate: formatDate(activity.CAJBP_End_Date__c),
                    currencyIsoCode: activity.CurrencyIsoCode || ''
                };
            });
        },
        createScorecard: function(scorecard) {
            if (!scorecard) return null;

            return {
                id: scorecard.Id || '',
                sellInVolumePlan: formatVolume(scorecard.CAJBP_Sell_In_Volume_Plan__c),
                sellInActualVolume: formatVolume(scorecard.CAJBP_Sell_In_YTD_Volume_Actuals__c),
                sellInActualTurnover: formatCurrency(scorecard.CAJBP_Sell_In_YTD_Turnover_Actuals__c),
                sellInMatVolume: formatVolume(scorecard.CAJBP_Sell_In_Current_Year_MAT_Volume__c),
                sellInMatTurnover: formatCurrency(scorecard.CAJBP_Sell_In_Current_Year_MAT_Turnover__c),
                sellOutActualVolume: formatVolume(scorecard.CAJBP_Sell_Out_YTD_Volume_Actuals__c),
                sellOutActualTurnover: formatCurrency(scorecard.CAJBP_Sell_Out_YTD_Turnover_Actuals__c),
                sellOutMatVolume: formatVolume(scorecard.CAJBP_Sell_Out_Current_Year_MAT_Volume__c),
                sellOutMatTurnover: formatCurrency(scorecard.CAJBP_Sell_Out_Current_Year_MAT_Turnover__c),
                currencyIsoCode: scorecard.CurrencyIsoCode || ''
            };
        },
        createRebate: function (rebates) {
            if (!rebates) return null;

            return rebates.map((target) => {
                return {
                    id: target.Id || '',
                    name: target.RecordType.Name || '',
                    targetVolume: formatVolume(target.CAJBP_Volume_Target__c),
                    targetPPL: formatCurrency(target.CAJBP_Price_Per_Litre__c),
                    targetTurnover: formatCurrency(target.CAJBP_Turnover_Target__c),
                    targetPercentage: formatNumber(target.CAJBP_Target_Percentage_Rebate__c),
                    targetRebate: formatCurrency(target.CAJBP_Target_Rebate_Amount__c),
                    thresholdVolume: formatVolume(target.CAJBP_Threshold_Volume_Target__c),
                    thresholdPPL: formatCurrency(target.CAJBP_Threshold_Price_Per_Litre__c),
                    thresholdTurnover: formatCurrency(target.CAJBP_Threshold_Turnover_Target__c),
                    thresholdPercentage: formatNumber(target.CAJBP_Threshold_Percentage_Rebate__c),
                    thresholdRebate: formatCurrency(target.CAJBP_Threshold_Rebate_Amount__c),
                    stretchVolume: formatVolume(target.CAJBP_Stretch_Volume_Target__c),
                    stretchPPL: formatCurrency(target.CAJBP_Stretch_Price_Per_Litre__c),
                    stretchTurnover: formatCurrency(target.CAJBP_Stretch_Turnover_Target__c),
                    stretchPercentage: formatNumber(target.CAJBP_Stretch_Percentage_Rebate__c),
                    stretchRebate: formatCurrency(target.CAJBP_Stretch_Rebate_Amount__c),
                    currencyIsoCode: target.CurrencyIsoCode || ''
                };
            });
        },
        createProductMix: function (rebates) {
            if (!rebates) return null;

            return rebates.map((target) => {
                return {
                    id: target.Id || '',
                    product: target.CAJBP_Product_Mix_Target_Name__c,
                    recordTypeName: target.RecordType.Name,
                    currencyIsoCode: target.CurrencyIsoCode,
                    annualVolumeTarget: formatVolume(target.CAJBP_Volume_Target__c),
                    annualPPL: formatCurrency(target.CAJBP_Price_Per_Litre_Rebate__c),
                    annualVolumeTargetPercentage: formatVolume(target.CAJBP_Annual_Volume_Target__c),
                    annualPercentage: formatNumber(target.CAJBP_Percentage_Rebate__c),
                    actualYtdVolume: formatVolume(target.CAJBP_Actual_YTD_Volume__c),
                    q1Volume: formatVolume(target.CAJBP_Q1_Volume_Target__c),
                    q2Volume: formatVolume(target.CAJBP_Q2_Volume_Target__c),
                    q3Volume: formatVolume(target.CAJBP_Q3_Volume_Target__c),
                    q4Volume: formatVolume(target.CAJBP_Q4_Volume_Target__c),
                    q1PPL: formatCurrency(target.CAJBP_Price_Per_Litre_Rebate_Q1__c),
                    q2PPL: formatCurrency(target.CAJBP_Price_Per_Litre_Rebate_Q2__c),
                    q3PPL: formatCurrency(target.CAJBP_Price_Per_Litre_Rebate_Q3__c),
                    q4PPL: formatCurrency(target.CAJBP_Price_Per_Litre_Rebate_Q4__c),
                    q1Percentage: formatNumber(target.CAJBP_Percentage_Rebate_Q1__c),
                    q2Percentage: formatNumber(target.CAJBP_Percentage_Rebate_Q2__c),
                    q3Percentage: formatNumber(target.CAJBP_Percentage_Rebate_Q3__c),
                    q4Percentage: formatNumber(target.CAJBP_Percentage_Rebate_Q4__c),
                    q1ActualYtdVolume: formatVolume(target.CAJBP_Q1_Actual_YTD_Volume__c),
                    q2ActualYtdVolume: formatVolume(target.CAJBP_Q2_Actual_YTD_Volume__c),
                    q3ActualYtdVolume: formatVolume(target.CAJBP_Q3_Actual_YTD_Volume__c),
                    q4ActualYtdVolume: formatVolume(target.CAJBP_Q4_Actual_YTD_Volume__c),
                };
            });
        },
        createWaysOfWorkingTargets: function (waysOfWorkingTargets) {
            if (!waysOfWorkingTargets) return null;

            return waysOfWorkingTargets.map((target) => {
                return {
                    record: {
                        sobjectType: 'CAJBP_Ways_of_Working_Target__c',
                        Id: target.Id,
                        CAJBP_Status__c: target.CAJBP_Status__c || ''
                    },
                    id: target.Id || '',
                    title: target.Name || '',
                    status: target.CAJBP_Status__c,
                    dueDate: formatDate(target.CAJBP_Due_Date__c),
                    rebatePercentage: formatNumber(target.CAJBP_Rebate__c)
                };
            });
        },
        createJaf: function(jaf) {
            if (!jaf) return null;

            return {
                id: jaf.Id || '',
                name: jaf.Name || '',
                castrolContribution: formatCurrency(jaf.CAJBP_Castrol_Contribution_Amount__c),
                partnerContribution: formatCurrency(jaf.CAJBP_Partner_Contribution_Amount__c),
                totalFund: formatCurrency(jaf.CAJBP_Total_Joint_Activity_Fund__c),
                estimatedSpend: formatCurrency(jaf.CAJBP_Estimated_Spend__c),
                actualSpend: formatCurrency(jaf.CAJBP_Actual_Spend__c),
                estimatedRemaining: formatCurrency(jaf.CAJBP_Estimated_Balance_Remaining__c),
                actualRemaining: formatCurrency(jaf.CAJBP_Actual_Balance_Remaining__c),
                currencyIsoCode: jaf.CurrencyIsoCode || ''
            };
        }
    }
};