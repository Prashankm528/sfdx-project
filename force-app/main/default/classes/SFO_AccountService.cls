/*****************************************************************************************
*	Date:		    26-Feb-2020
*   Author:         Jit Patel - SFO 
*   Description:    Account object service for business logic 
****************************************************************************************/

public with sharing class SFO_AccountService
{
    /*
    * return SFO Accounts filter by SFO Record Type Developer Name
    */
    public List<Account> getSfoAccountListByRecordTypeDeveloperName(List<Account> accountList, string recordTypeDeveloperName)
    {
        List<Account> sfoAccountListbyRecordTypeDeveloperName = new List<Account>();
        string accountCustomerRecordTypeId = SFO_Constant.getSfoAccountRecordTypeByDeveloperNameMap().get(recordTypeDeveloperName); 

        for(Account acc : accountList)
        {
            if(acc.RecordTypeId == accountCustomerRecordTypeId && ((acc.Sales_Division_Code__c != null && acc.Sales_Division_Code__c == '02') || (acc.Business_Unit__c != null && acc.Business_Unit__c.containsIgnoreCase('Lubricants'))))
            {
                sfoAccountListbyRecordTypeDeveloperName.add(acc);              
            }
        }

        return sfoAccountListbyRecordTypeDeveloperName;
    }    

    /*
    * return SFO Accounts 
    */
    public List<Account> getSfoAccountList(List<Account> accountList)
    {
        List<Account> sfoAccountList = new List<Account>();

        Map<Id, string> sfoAccountRecordTypeByIdMap = SFO_Constant.getSfoAccountRecordTypeByIdMap(); 

        for(Account acc : accountList)
        {
            if(sfoAccountRecordTypeByIdMap.containsKey(acc.RecordTypeId) && ((acc.Sales_Division_Code__c != null && acc.Sales_Division_Code__c == '02') || (acc.Business_Unit__c != null && acc.Business_Unit__c.containsIgnoreCase('Lubricants'))))
            {
                sfoAccountList.add(acc);           
            }
        }

        return sfoAccountList;
    }   

    /*
    * set Account's field on before insert 
    */    
    public void setSfoAccountFieldsBeforeInsert(List<Account> accountNewListBeforeInsert)
    {
        List<Account> sfoAccountList = new List<Account>();
        
        sfoAccountList = getSfoAccountList(accountNewListBeforeInsert);
        
        /*
        for(Account acc : sfoAccountList)
        {
            acc.SFO_to_Field = acc.SFO_from_Field;
        }
        */
    } 

    /*
    * set Customer Account's field on before insert 
    */      
    public void setSfoCustomerAccountFieldsBeforeInsert(List<Account> accountNewListBeforeInsert)
    {
        List<Account> sfoCustomerAccountList = new List<Account>();
       
        sfoCustomerAccountList = getSfoAccountListByRecordTypeDeveloperName(accountNewListBeforeInsert, 'Customer');

        Set<string> channelVwGroupSet = new Set<string>{'0VW', 'VW6', '0WA', '3VW'};
        Set<string> channelRenaultSet = new Set<string>{'0RE', '0NI', '0DA', 'DNS', 'ALP', 'MTR'};        

        for(Account acc : sfoCustomerAccountList)
        {
            if(acc.Channel__c != null && channelVwGroupSet.contains(acc.Channel__c))
            {
                acc.CASFO_OEM_Network__c = 'VW Group';
            }

            if(acc.Channel__c != null && channelRenaultSet.contains(acc.Channel__c))
            {
                acc.CASFO_OEM_Network__c = 'Renault';
            }   
        }
        
    }   

    /*
    * set Prospect Account's field on before insert 
    */       
    public void setSfoProspectAccountFieldsBeforeInsert(List<Account> accountNewListBeforeInsert)
    {
        List<Account> sfoProspectAccountList = new List<Account>();
        
        /*
        sfoProspectAccountList = getSfoAccountListByRecordTypeDeveloperName(accountNewListBeforeInsert, 'Prospect');

        for(Account acc : sfoProspectAccountList)
        {
            acc.SFO_to_Field = acc.SFO_from_Field;
        }
        */

    }     
}