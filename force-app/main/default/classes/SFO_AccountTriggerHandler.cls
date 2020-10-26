/*****************************************************************************************
*	Date:		    29-Aug-2019
*   Author:         Matt - SFO 
*   Description:    Account trigger handler
*   Modifications:  06APR2020 Rahma Belghouti - Set Channel Manager based on the Channel Manager NTID
****************************************************************************************/
public with sharing class SFO_AccountTriggerHandler extends BPG_Trigger_Handler_Utilities {
    
    private List<Account> Records;
    
    public SFO_AccountTriggerHandler(List<Account> newRecords) {
        this.Records = newRecords;
    }
    
    public SFO_AccountTriggerHandler() { }
    
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_AccountTriggerHandler((List<Account>) newList)
            .setBusinessUnit()
            .setAccountTypeSearch()
            .setChannelManager();
        
        new SFO_AccountService().setSfoCustomerAccountFieldsBeforeInsert(newList);
        new SFO_AccountService().setSfoProspectAccountFieldsBeforeInsert(newList);
        new SFO_AccountService().setSfoAccountFieldsBeforeInsert(newList);
    }
    
    public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        new SFO_AccountTriggerHandler((List<Account>) newList)
            .setBusinessUnit()
            .setAccountTypeSearch()
            .setChannelManager();
    }
    
    private SFO_AccountTriggerHandler setBusinessUnit(){
        new SFO_UpdateAccountBUFromCSDDivCode(Records).setAccountBUFromCSDDivCode();
        return this;
    }
    @TestVisible
    private SFO_AccountTriggerHandler setAccountTypeSearch(){
        
        Map<String, String> picklistValue2Label = new Map<String, String>();
        for(Schema.PicklistEntry ple : Account.Type.getDescribe().getPicklistValues() ){
            picklistValue2Label.put(ple.getValue(), ple.getLabel());
        }
        for(Account a : Records){
            a.Search_type__c = picklistValue2Label.get(a.Type);
        }
        return this;
    }
    /*
    * Sets Channel Manager field based on Channel Manager NTID
    * (Where Channel Manager NTID matches a user NTID)
    */
    private SFO_AccountTriggerHandler setChannelManager(){
        Set<String> ntids = new Set<String>();
        Map<String, Account> mapAccounts = new Map<String, Account>();
        
        for(Account account: Records){
            if(String.isNotBlank(account.CASFO_Channel_Manager_NTID__c)){                
                ntids.add(account.CASFO_Channel_Manager_NTID__c.toLowerCase()); 
                mapAccounts.put(account.CASFO_Channel_Manager_NTID__c.toLowerCase(), account);
            }
        }
        for(User user: [SELECT Id, NTID__c FROM User WHERE NTID__c IN :ntids]){
            mapAccounts.get(user.NTID__c.toLowerCase()).CASFO_Channel_Manager__c = user.Id;
        }
        
        return this;
    }
}