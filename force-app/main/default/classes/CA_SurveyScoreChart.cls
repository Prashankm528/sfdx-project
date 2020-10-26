/************************************************************************************************************
* Description : Controller for CA_SurveyScoreChart Lightning component used to chart NPS and CES values
*               based on surveys related to given account. As SOQL cannot group by date grouping is done
*               with help of Map object where key is date and value is list of numbers (responses) which
*               are later averaged.
*               Return value is in specific format to ease use of Chart.js List of Lists where first List
*               represents labes (x axis), and second List represents values (y axis).
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*
* 2018-Feb-11   1.0                 Maros Zilka         Initial version
* 2019-Mar-21   1.1                 Maros Zilka         Grouping by Week for Romania
*
*************************************************************************************************************/

public without sharing class CA_SurveyScoreChart {

    private enum GroupPeriod {DAY, WEEK}

    @AuraEnabled
    public static List<List<String>> getCESData(Id recordId) {
        return getData(recordId, 'lcf_CES_Question__c');
    }

    @AuraEnabled
    public static List<List<String>> getNPSData(Id recordId) {
        return getData(recordId, 'lcf_NPS_Question__c');
    }

    private static List<List<String>> getData(Id recordId, String questionFieldName) {
        List<SurveyTaker__c> surveys;
        List<SurveyQuestionResponse__c> questionResponses;

        String sobjectName = recordId.getSObjectType().getDescribe().getName();
        String soqlStr = 'SELECT Id FROM SurveyTaker__c WHERE ';

        switch on sobjectName {
            when 'Account' {
                soqlStr += 'Account__c = :recordId';
            }
            when 'Contact' {
                soqlStr += 'Contact__c = :recordId';
            }
            when else {
                return null;
            }
        }

        surveys = Database.query(soqlStr);

        if (surveys.isEmpty()) {
            return null;
        }

        questionResponses = Database.query(
            'SELECT Response__c, CreatedDate ' +
            'FROM SurveyQuestionResponse__c ' +
            'WHERE ' + questionFieldName + ' = TRUE AND SurveyTaker__c IN :surveys ' +
            'ORDER BY CreatedDate'
            );

        if (questionResponses.isEmpty()) {
            return null;
        }

        return avgGroupedByDate(questionResponses);
    }

    private static List<List<String>> avgGroupedByDate(List<SurveyQuestionResponse__c> responses) {
        Map<String, List<Double>> valuesByDate;

        List<List<String>> avgValuesByDate = new List<List<String>> ();

        List<String> dates = new List<String>();
        List<String> avgValues = new List<String>();


        // For Romanian users we want to group by week
        if ('RO01' == [SELECT Sales_Organisation__c FROM User WHERE Id = :UserInfo.getUserId()].Sales_Organisation__c) {
            valuesByDate = groupBy(responses, GroupPeriod.WEEK);
        } else {
            valuesByDate = groupBy(responses, GroupPeriod.DAY);
        }

        //Calculating avg values per date
        for (String d : valuesByDate.keySet()) {
            Integer i = 0;
            Double total = 0;

            for (Double value : valuesByDate.get(d)) {
                total += value;
                i++;
            }

            dates.add(d);
            avgValues.add((total / i).format());
        }

        // Format required by Chart.js in one list are labels in second list are values...
        avgValuesByDate.add(dates);
        avgValuesByDate.add(avgValues);

        return avgValuesByDate;
    }

    private static Map<String, List<Double>> groupBy(List<SurveyQuestionResponse__c> responses, GroupPeriod period) {
        Map<String, List<Double>> valuesByDate = new Map<String, List<Double>> ();
        String createdDateFormatted;

        // Grouping with Map - SOQL does not support qrouping by date...
        for (SurveyQuestionResponse__c qr : responses)  {
            if (qr.Response__c != '?') {

                switch on period {
                    when DAY {
                        createdDateFormatted = qr.CreatedDate.date().format();
                    }
                    when WEEK {
                        createdDateFormatted = qr.CreatedDate.date().toStartOfWeek().format();
                    }
                    when else {
                        return null;
                    }
                }

                // If there is no such date add it with first response value to the map
                // Else add it to existing list of values for given date (used later get avg)
                if (!valuesByDate.containsKey(createdDateFormatted)) {
                    List<Double> responseValueList = new List<Double>();

                    responseValueList.add(Double.valueOf(qr.Response__c));
                    valuesByDate.put(createdDateFormatted, responseValueList);
                } else {
                    valuesByDate.get(createdDateFormatted).add(Double.valueOf(qr.Response__c));
                }
            }
        }

        return valuesByDate;
    }
}