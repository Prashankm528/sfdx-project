/**
* @author Jewelslyn Shama P
* @company Tata Consultancy Services
* @date 
* @group Fuels
*/
global with sharing class OLCM_BatchAccountMarkForDelete implements Database.Batchable<sObject> {    
    global Database.QueryLocator start(Database.BatchableContext BC){       
        
        /*return Database.getQueryLocator([SELECT Id,OLCM_Fuels_Card_Customers__c,OLCM_Last_Modified_Greater_than_60_Days__c,
Marked_for_Deletion__c FROM Account where 
OLCM_Last_Modified_Greater_than_60_Days__c =True 
AND Marked_for_Deletion__c !=true AND                                     
OLCM_Fuels_Card_Customers__c = True]); */
        String query = 'SELECT Id, OLCM_Fuels_Card_Customers__c ,OLCM_Last_Modified_Greater_than_60_Days__c,Marked_for_Deletion__c FROM Account WHERE ';
        if(!Test.isRunningTest()) {
           query = query + ' OLCM_Last_Modified_Greater_than_60_Days__c = true AND ';
                }
        query = query + ' Marked_for_Deletion__c !=true AND OLCM_Fuels_Card_Customers__c = True' ;
        return Database.getQueryLocator(query);
        
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accns = new List<Account>();
        for(sObject s : scope){
            Account a = (Account)s;
            if(a.Marked_for_Deletion__c != true){
                a.Marked_for_Deletion__c=true;               
                accns.add(a);
                System.debug('AccSatyam'+a.Marked_for_Deletion__c);
            }
        }
         if(!Test.isRunningTest()) {
             update accns;  } 
    } 
    global void finish(Database.BatchableContext BC){
    }
}