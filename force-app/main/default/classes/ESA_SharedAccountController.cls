/******SharedAccountController******/
/*Description : This Apex class is for SharedAccountList Lightning Component.
                This class contains method which gets the list of Shared Accounts.
 *Project     : ESA B2B Fuels
 *Copyright   : Tata Consultancy Services Ltd
 *Last Modified Date : 4/10/19
*/


public with sharing class ESA_SharedAccountController { 
    
/******getAccountNames******/
/*Description : This class contains method which gets the list of Shared Accounts.                
 *Project     : ESA B2B Fuels
 *Copyright   : Tata Consultancy Services Ltd
 *Last Modified Date : 4/10/19
*/
    @auraEnabled
    public static List<Account> getAccountNames(Id accountId){
        List<Account> accList = new List<Account>();
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = [select Name,ESA_Sales_Organisation__c,ESA_Business_Unit__c,ESA_Customer_Id__c from Account where Id=:accountId AND RecordTypeId=:recTypeId];
        accList = [select Name,Type,Owner.Name,toLabel(ESA_Relationship_Type__c),toLabel(ESA_Business_Unit__c),toLabel(ESA_Sales_Organisation__c) from Account where (ESA_Customer_Id__c=:acct.ESA_Customer_Id__c OR Name=:acct.Name) AND (ESA_Sales_Organisation__c !=: acct.ESA_Sales_Organisation__c) AND ESA_Business_Unit__c IN ('ESA_B2B_Fuels','ESA_Coke','ESA_PTC','ESA_B2B_LPG') AND ESA_Customer_Id__c!= NULL]; 
        return accList;    
    } 
    
}