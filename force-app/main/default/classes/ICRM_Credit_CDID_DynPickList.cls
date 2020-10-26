/**
* @author Santosh Verma
* @date 19/08/2019
* @description - This class is used to get the ICOS IDs from the Salesforce Account 
* 
*/
public with sharing class ICRM_Credit_CDID_DynPickList {

/**
* @description - Method to fetch the Sorted values of accounts where ICOS Id not qual to NULL and BPEntity is True
* 
*/
    @AuraEnabled 
    public static List<Account> getValues() {
        // Get the icos_id values from account 
        List<String> CDID = new list <String>(); 
        List<account> CDID1 = [select Name, BPI_ICOS_ID__c, ICRM_BP_Entity__c from account where BPI_ICOS_ID__c <> Null and ICRM_BP_Entity__c = true];  
        System.debug('List check = '+CDID1); 
        
    
        CDID1.sort(); 
        account accrec = new account(); 
        accrec.name = '--None--';
        accrec.BPI_ICOS_ID__c = ' ID '; 
        CDID1.add(accrec); 
        return CDID1;    
    }
}