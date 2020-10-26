@isTest 
private with sharing class CDM_DepedentPicklistTest {
  static testMethod void DepedentPicklist() {
   Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
  Map<String, List<String>>  contry =  CDM_DepedentPicklist.getDependentMap(schemaMap.get('CDM_Credit_Debit_Note__c') ,'CDM_Country__c','CDM_Company_Code__c');
 // System.assert(contry!= null);
  System.assertNotEquals(contry,null);
  CDM_DepedentPicklist.getDependentMap(null ,'CDM_Country__c','CDM_Company_Code__c');
   CDM_DepedentPicklist.getDependentMap(null ,'CDM_Country1__c','CDM_Company_Code1__c');
  
  }
  }