/**
* @Author:       Gaurav Wadhawan
* @Date  :       18 June 2020
* @Description : This class handles trigger activities related to BPCM Account object
**/
public with sharing class BPCM_AccountTriggerHandler extends BPG_Trigger_Handler_Utilities{

	/**
    * @description handles after Insert trigger event
    */
   public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
         List<Account> newRecords = new List<Account>();
         newRecords = n;
         BPCM_AccountService.MergeAccounts(newRecords);
    }
}