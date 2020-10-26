/*****************************************************************************************
*   Date:           07SEPT20
*   Author:         Atanu Ghosh – TCS (Tata Consultancy Services Ltd.)
*   Description:    Batchable class for sending email notification to Opportunity owners
*   Modifications:  
****************************************************************************************/
global with sharing class GEFUE_SendEmailOpportunityBatchable implements Database.Batchable<sObject>{
    
    String query = 'SELECT id, name,OwnerId, RecordType.Name, CloseDate, stagename, GEFUE_Is_Forecasting_for_Volume__c, Owner.Email, Probability FROM Opportunity WHERE RecordTypeId in (Select Id From RecordType where sobjecttype = \'Opportunity\' and developerName in (\'GEFUE_Fuels_NA_Commercial\',\'GEFUE_Fuels_NA_Branded_Package\',\'GEFUE_Fuels_NA_Branded\')) AND StageName NOT IN(\'Closed - Won\',\'Closed - Lost\')';
    public OrgWideEmailAddress owea = [Select Id from OrgWideEmailAddress where Address = 'do-not-reply@bp.com' limit 1];
    
    Messaging.SingleEmailMessage sendMessage(Id templateId, Id ownerId, Id opportunityId, String emailId){
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId, ownerId, opportunityId);
        message.setToAddresses(new String[] {emailId});
        message.setSaveAsActivity(false);
        message.setTargetObjectId(ownerId);
        message.setOrgWideEmailAddressId(owea.id);
        return message;        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Messaging.SingleEmailMessage[] messages  = new List<Messaging.SingleEmailMessage>();
        list<String> availableTemplate = new list<String>{'GEFUE_Fuels_NA_Opty_Close_Date_Approaching_15_days',
            'GEFUE_Fuels_NA_Opty_Close_Date_Approaching_30_days','GEFUE_Fuels_NA_Opty_Close_Date_Approaching_60_days',
            'GEFUE_Fuels_NA_Opty_Close_Date_past_due','GEFUE_Fuels_NA_Opty_Close_Date_Approaching_60_days_not_forecasted',
            'GEFUE_Fuels_NA_Opty_Close_Date_Approaching_30_days_not_forecasted'};
                map<String,id> emailTemplates = new map<String, id>();
        for(EmailTemplate e: [Select developerName,id from EmailTemplate where developerName in :availableTemplate]){
            emailTemplates.put(e.developerName,e.id);
        }
        for(sObject s: scope){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            boolean forecastingFlag = false;
            Opportunity op = (Opportunity)s;
            integer dateDifferene= (date.today()).daysBetween(op.CloseDate);
            if(dateDifferene == 60){
                if(op.GEFUE_Is_Forecasting_for_Volume__c == false && op.Probability >= 50){
                    email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_Approaching_60_days_not_forecasted'),op.ownerId,op.Id,op.Owner.Email);
                    messages.add(email);
                    
                }else{
                    email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_Approaching_60_days'),op.ownerId,op.Id,op.Owner.Email);
                    messages.add(email);
                }
            }
            if(dateDifferene == 30){
                if(op.GEFUE_Is_Forecasting_for_Volume__c == false && op.Probability >= 50){
                    email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_Approaching_30_days_not_forecasted'),op.ownerId,op.Id,op.Owner.Email);
                    messages.add(email);
                    
                }else{
                    email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_Approaching_30_days'),op.ownerId,op.Id,op.Owner.Email);
                    messages.add(email);
                }
            }
            if(dateDifferene == 15){
                email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_Approaching_15_days'),op.ownerId,op.Id,op.Owner.Email);
                messages.add(email);
                
            }
            if(dateDifferene == -1 || dateDifferene == -7){
                email = sendMessage(emailTemplates.get('GEFUE_Fuels_NA_Opty_Close_Date_past_due'),op.ownerId,op.Id,op.Owner.Email);
                messages.add(email);
            }
            
        }
        Messaging.sendEmail(messages);
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
}