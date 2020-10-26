/************************************************************************************************************
* Description : Batch Class that performs delete on sObjects, scope of which is defined in scheduled classes   
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-SEP-06   1.0                 Grant Whitfield     Initial version 
*
*************************************************************************************************************/

global class CA_BatchDelete implements Database.Batchable<sObject> {
    
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
        DataBase.emptyRecycleBin(scope);
        
   }
    
    global void finish(Database.BatchableContext BC) {
       
    }
    
}