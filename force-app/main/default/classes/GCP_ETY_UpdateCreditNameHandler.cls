/*****************************************************************************************
*   Date:         18/10/2019
*   Author:       Subin M Nair
*   Description:  Handler class for GCP_ETY_UpdateCreditName trigger which will update the name of BPLE and Counterparty 
                  Credit Entities with the associated Account's name
*   Test Class :  GCP_ETY_UpdateCreditNameHandlerTest
****************************************************************************************/
public with sharing class GCP_ETY_UpdateCreditNameHandler 
{
    public static boolean flag = true;
    public static boolean avoidRecursion()
    {
        if(flag)
        {
            flag = false;
            return true;
        }
        else return flag;
    }
 public static void updateName(List<GCP_ETY_Credit_Entity__c> newRecords)
 {
 
  try{
  
     List<RecordType> recordTypeList = [Select Id,DeveloperName From RecordType where sObjectType='GCP_ETY_Credit_Entity__c' and isActive=true and DeveloperName in ('GCP_ETY_BPLE','GCP_ETY_Counterparty')];     
     List<GCP_ETY_Credit_Entity__c> creditList = [Select Id,Name,GCP_ETY_Account__c,GCP_ETY_Account__r.Name,GCP_ETY_Name__c from GCP_ETY_Credit_Entity__c where RecordtypeId in: recordTypeList and Id in: newRecords];
     List<GCP_ETY_Credit_Entity__c> updateList = new List<GCP_ETY_Credit_Entity__c>();
     String accName;
     for(GCP_ETY_Credit_Entity__c cd : creditList)
     {
         if(cd.GCP_ETY_Account__r.Name != null)
         {
             accName = cd.GCP_ETY_Account__r.Name;
         }
         if(accName.length() > 80)
         {
             cd.Name = accName.substring(0,80);
         }
         else {cd.Name = accName;}
         cd.GCP_ETY_Name__c = accName;
         updateList.add(cd);
     }
     if(updateList.size()>0)
         Update updateList;
     }
     Catch(Exception e)
     {
         system.debug('Exception Occured : '+e);
     }
     
    flag = false;
  }
}