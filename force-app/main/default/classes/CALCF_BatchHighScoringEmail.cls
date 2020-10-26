/************************************************************************************************************
* Description : Batch Process for updating Survey.To_be_sent__c if meet requirements.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-JAN-13   1.0                 Frantisek Kolacny   Initial version 
*
*************************************************************************************************************/
global class CALCF_BatchHighScoringEmail implements Database.Batchable<sObject>{

        public List<Messaging.SingleEmailMessage> listMail { get; set; }

        global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([SELECT Operations_Manager_Email__c, Operations_Manager_First_Name__c, Sales_Organization__c, Survey_Type__c 
                                        FROM LCF_Operations_Manager_Settings__c WHERE Operations_Manager_Email__c != '']);                       
        }        
        
        global void execute(Database.BatchableContext BC, List<sObject> scope){

            Datetime fromTime = system.now().addDays(-7).date();

            List<SurveyQuestionResponse__c> responses = [SELECT Id, Response__c, lcf_Account_Sales_Organisation__c, Survey_Touchpoint_Type__c FROM SurveyQuestionResponse__c 
                                                        WHERE lcf_NPS_Level__c = 'Promoter'
                                                        AND CreatedDate > :fromTime];

            List<LCF_Operations_Manager_Settings__c> settings = (List<LCF_Operations_Manager_Settings__c>)scope;

            listMail = new List<Messaging.SingleEmailMessage>();

            List<CALCF_High_Scoring_Digest__c> digestsToBeUpdated = new List<CALCF_High_Scoring_Digest__c>();


            for(LCF_Operations_Manager_Settings__c s : settings){

                Integer count = 0; 

                for(SurveyQuestionResponse__c r : responses){

                    if(r.lcf_Account_Sales_Organisation__c == s.Sales_Organization__c && 
                        r.Survey_Touchpoint_Type__c == s.Survey_Type__c){
                        count++;                                              
                    } 

                }

                if(s.Operations_Manager_Email__c != ''){

                    CALCF_High_Scoring_Digest__c digest = new CALCF_High_Scoring_Digest__c();
                    digest.CALCF_Start_Date__c = system.now().addDays(-7).date();
                    digest.CALCF_End_Date__c = system.now().date();
                    digest.CALCF_Survey_Type__c = s.Survey_Type__c.replace('_', '   ');
                    digest.CALCF_Operations_Manager_First_Name__c = s.Operations_Manager_First_Name__c;
                    digest.CALCF_Operations_Manager_Email__c = s.Operations_Manager_Email__c;
                    digest.CALCF_High_Score_Count__c = count;
                    digest.CALCF_Sales_Organization__c = s.Sales_Organization__c;
                    digest.CALCF_Fire_Email__c = true;
                    digestsToBeUpdated.add(digest);
                }
            }

            System.debug(String.valueOf(digestsToBeUpdated));
            insert digestsToBeUpdated;
                       
        }
        
        global void finish(Database.BatchableContext BC){
            
        }     
}