/**
* @ author       -  Gaurav Wadhawan
* @ company      -  IBM
* @ date         -  10/06/2020
* @ description  -  The system must merge an Account record when it's duplicated.)
*/
public with sharing class BPCM_AccountService {    
/************************************************************************************************************
*Method for merge an Account record when it's duplicated
*Method for When a new Account is created AND already exist an existing account with the same BPCM_CV_ID__c
(chargevision Id) AND IsPersonAccount is TRUE, New account being created is the master
*************************************************************************************************************/ 
    public static void MergeAccounts(list<Account> Acclist){        
        map<string,Account> cvIdMap = new Map<String,Account> ();
        List<string> accountCVIdList = new List<String> ();
        List<Id> toBeMergeActLst = new List<Id>();
        for(Account ac : Acclist) {
          if (ac.BPCM_CV_ID__c != null)
          {
          accountCVIdList.add(ac.BPCM_CV_ID__c);
          cvIdMap.put(ac.BPCM_CV_ID__c, ac);
          }
        }
        
        if (accountCVIdList.size() == 1)
        {   //Duplicate Records to be merged

            List<Account> toBeMergeActLstAll = [Select Id, BPCM_CV_ID__c from Account where BPCM_CV_ID__c != null and BPCM_CV_ID__c IN :accountCVIdList and IsPersonAccount = true and RecordType.name like 'BPCM%' limit 3];
            
            for(Account acc : toBeMergeActLstAll) {
            if (acc.Id != Acclist[0].Id)
              toBeMergeActLst.add(acc.Id);
            }
    
            if(toBeMergeActLst.size() > 0) {
                //Master Record
                Account masterActLst = [Select Id, BPCM_CV_ID__c from Account where BPCM_CV_ID__c != null and Id IN :Acclist limit 1];
    
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
        else
        {   
            if (accountCVIdList.size() > 1)
            {
            BPCM_AccountServiceBatch obj = new BPCM_AccountServiceBatch(Acclist);
            Database.executeBatch(obj,1);
            }
        }
    }
}