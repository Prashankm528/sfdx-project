/*********************************************************************************************************************************************
* Description : Apex Controller for Send Task As Email Lightning Component. Used for various opeations:
*  - Select sending options from Custom Settings (Send_Task_Settings__c)
*  - DML for updating of Tasks
*  - Describing custom fields on Activity 
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------       
* 2016-NOV-14   1.0                 Grant Whitfield     Initial version 
/*********************************************************************************************************************************************/

public with sharing class CA_SendTaskAsEmailController {
	
	public static String taskType;
	public static String parentName;
	
    /***********************************************************************************
    * getTaskType
    * ------------------------
    * Method is using the record Id of a Task, to get Type of related record.
    ***********************************************************************************/
    @AuraEnabled
    public static String getTaskType(String recordId) {
        Task task = [SELECT what.type FROM task WHERE Id = :recordId];
    	taskType= string.valueOf(task.what.type);
        return taskType;
    }
    
    
    /***********************************************************************************
    * getAssignmentOptions 
    * ------------------------
    * Selects the Name and Display Name from custom settings to render in the Send To picklist. 
    * Requires Business Unit and Sales Org of the Account in order to make lookup to Custom Setting - Send_Task_Settings__c
    ***********************************************************************************/
    @AuraEnabled
    public static List<Send_Task_Settings__c> getAssignmentOptions(String recordId, String businessUnit, String salesOrg) {
    	
    	Task task = [SELECT what.type FROM task WHERE Id = :recordId];
    	
    	if(string.valueOf(task.what.type) == 'SurveyTaker__c'){
    		
    		return [SELECT Name, Display_Name__c FROM Send_Task_Settings__c WHERE Business_Unit__c = :businessUnit AND Sales_Organisation__c = :salesOrg AND LCF_Available__c = true];
    	}else{
    		
    		return [SELECT Name, Display_Name__c FROM Send_Task_Settings__c WHERE Business_Unit__c = :businessUnit AND Sales_Organisation__c = :salesOrg AND SFO_Available__c = true];
    	}
    }

    /***********************************************************************************
    * getTaskDetails 
    * ------------------------
    * Used the record Id of a Task, to get details of the record in order to pre-propulate elements on the component.  
    * This is used as Salesforce Lightning Data Services are not currently available  
    ***********************************************************************************/
    @AuraEnabled 
    public static Task getTaskDetails(String recordId) {
        
        return [SELECT Id, Account.Name, Subject, Description, ActivityDate, Priority, Task_Sent_as_Email__c, Account.Sales_Organisation__c, Account.Business_Unit__c FROM Task WHERE Id = :recordId];

    }
    
    /***********************************************************************************
    * getParentSpecificDetails
    * ------------------------
    * Used the record Id of a Task, to get Type and all needed properties of related record.
    * This method is used to process two different types of Tasks. First is related to SurveyTaker__c,
    * second related to Account.
    ***********************************************************************************/
    @AuraEnabled 
    public static String[] getParentSpecificDetails(String recordId) {
    	
    	Task task = [SELECT Account.Name, whatId, what.type, Account.Sales_Organisation__c, Account.Business_Unit__c, Is_Survey_Related__c FROM task WHERE Id = :recordId];
    	string taskParentId = string.valueOf(task.whatId);
    	taskType= string.valueOf(task.what.type); 
    	
        if(taskType == 'SurveyTaker__c'){
        	
        	SurveyTaker__c survey = [SELECT  Name, Account__r.Sales_Organisation__c, Account__r.Business_Unit__c FROM SurveyTaker__c Where Id = :taskParentId];
        	
        	task.Is_Survey_Related__c = true;
        	update task;      		
        	return new String[]{string.valueOf(survey.Name), string.valueOf(survey.Account__r.Sales_Organisation__c), string.valueOf(survey.Account__r.Business_Unit__c)};  
        	     	
        }else{        	
        	
        	return new String[]{string.valueOf(task.Account.Name), string.valueOf(task.Account.Sales_Organisation__c), string.valueOf(task.Account.Business_Unit__c)};
        }      	        	        	      
    }
    
    /***********************************************************************************
    * getTaskPriorityValues 
    * ------------------------
    * Describes and returns the values of the Priority field on Task so that it can be rendered
    * correctly on UI. This is used due to bug in using force:inputField with picklist where it is disabled as default.
    ***********************************************************************************/
    @AuraEnabled
    public static List<String> getTaskPriorityValues() {
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }

        return options;
    }


    /***********************************************************************************
    * saveTask 
    * ------------------------
    * Saves the Task record with the values from the UI component. Sets the Send Task as Email flag 
    * which in turn will trigger the Send Task as Email process / flow 
    ***********************************************************************************/
    @AuraEnabled
    public static boolean saveTask(Task taskToSend, String sendToName ) {

        boolean success = true;

        taskToSend.Send_Task_as_Email__c = true;
        taskToSend.Send_Task_Setting_Name__c = sendToName;

        try{
            update(taskToSend);
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            success = false;
        }

        return success;

    }

}