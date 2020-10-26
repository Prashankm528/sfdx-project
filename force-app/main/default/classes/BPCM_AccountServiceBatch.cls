/**
* @ author       -  Gaurav Wadhawan
* @ company      -  IBM
* @ date         -  24/06/2020
* @ description  -  Batch class to merge an Account record when it's duplicated.)
*/
global with sharing class BPCM_AccountServiceBatch implements Database.batchable<sobject>, Database.Stateful
{
  private list<Account> Acclist;
/************************************************************************************************************
*Method for merge an Account record when it's duplicated
*Method for When a new List of Accounts created AND already exist an existing account with the same BPCM_CV_ID__c
(chargevision Id) AND IsPersonAccount is TRUE, New List of account being individually created is the master
*************************************************************************************************************/ 
  global BPCM_AccountServiceBatch(list<Account> Acclistval)
    {
        Acclist = Acclistval;
    }
  /* collect the batches of Account records to be passed to execute */
  global database.querylocator start(database.batchablecontext bc)
    { 
       string query = 'Select Id, BPCM_CV_ID__c from Account where Id IN :Acclist and BPCM_CV_ID__c!=null';	
       return database.getquerylocator(query);
     }
  /* process each batch of Account records default size is 1*/
   global void execute(database.batchablecontext bc, list<account> scope)
     {
         // process each batch of Account records
         if (scope.size() == 1)
         {   
             list<account> acc= new list<account>();
             List<Id> toBeMergeActLst = new List<Id>();
             map<string,Account> cvIdMap = new Map<String,Account> ();
             List<string> accountCVIdList = new List<String>();
             //Master record
             Account masterActLst = [Select Id, BPCM_CV_ID__c from Account where Id IN :scope limit 1];
             for(Account ac : scope) {
                  accountCVIdList.add(ac.BPCM_CV_ID__c);
                  cvIdMap.put(ac.BPCM_CV_ID__c, ac);
             }
             //Duplicate records to be merged
             List<Account> toBeMergeActLstAll = [Select Id, BPCM_CV_ID__c from Account where BPCM_CV_ID__c != null and BPCM_CV_ID__c IN :accountCVIdList and IsPersonAccount = true and RecordType.name like 'BPCM%' limit 3];
             
             for(Account ac : toBeMergeActLstAll) {
             if (ac.Id != scope[0].Id)
              toBeMergeActLst.add(ac.Id);
             }
            
             if(cvIdMap.containsKey(masterActLst.BPCM_CV_ID__c))
                 {
                     try
                     {
                         // Merge duplicate accounts has same BPCM_CV_ID__c into master
                         if(masterActLst.Id != null)
                         {
                           Database.MergeResult[] results = Database.merge(masterActLst, toBeMergeActLst, false);
                             
                           for(Database.MergeResult res : results) 
                           {
                             if (res.isSuccess()) {
                                 System.debug('Merge Records sucessfully:' + res);
                             } 
                             else 
                             {
                                for(Database.Error err : res.getErrors())
                                {
                                    //Error message
                                    System.debug(err.getMessage());
                                }
                              }
                            }
                         }
                     }
                     catch(Exception e)
                     {
                        System.debug('The following error: ' + e.getMessage());
                     }
                 }
           }         
     }
    /* execute any post-processing operations */
    global void finish(database.batchablecontext bc)
    {

    }
 }