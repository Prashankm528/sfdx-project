/************************************************************************************************************
* Description : 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-Jan-29   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/

public class CALCF_CalculateTasksPerSurvey{

    public static void calculateCountOfTasksAndUpdateSurvey(List<Task> tasks, boolean isDelete){

        calculateTaskCount(tasks, isDelete);
    }

    private static void calculateTaskCount(List<Task> tasks, boolean isDelete){

        List<String> surveyIds = new List<String>();
        List<String[]> surveyIdAndCount = new List<String[]>();
        List<Task> allSurveyRelatedTasks = [SELECT id, WhatId FROM Task WHERE What.Type = 'SurveyTaker__c'];

        for(Task task: tasks){

            decimal countOfTasks = 0;

            if(isDelete){
                countOfTasks-- ;
            }

            for(Task t : allSurveyRelatedTasks){

                if(task.WhatId == t.WhatId){
                    countOfTasks++ ;
                }
            }

            String[] values = new String[] {String.valueOf(task.WhatId),String.valueOf(countOfTasks)};
            surveyIdAndCount.add(values);
            surveyIds.add(String.valueOf(task.WhatId));

        }

        List<SurveyTaker__c> surveys = [SELECT Id , LCF_Count_Of_Tasks__c FROM SurveyTaker__c WHERE Id IN :surveyIds];
        List<SurveyTaker__c> surveysToUpdate = new List<SurveyTaker__c>();

        for(String[] IdAndCount: surveyIdAndCount){

            for(SurveyTaker__c survey : surveys){

                if(IdAndCount[0] == String.valueOf(survey.Id)){

                    survey.LCF_Count_Of_Tasks__c = IdAndCount[1];
                    surveysToUpdate.add(survey);
                }
            }
        }

    update surveysToUpdate;


    }
}