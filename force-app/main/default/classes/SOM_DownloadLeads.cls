/***********************************************************************************
* Date:        08FEB17
* Author:      Jon Marson - Forcify Ltd
* Desc:        Server side controller for the 'Download Leads' lightning component.
*              Upon pressing the button, this class exports all the Leads with a 
*              status of 'New' to which the user has access, and saves them as a CSV
*              file which the user can download from the 'Files' component / tab.  
*              The status of the leads is then updated to 'In Progress', so that they 
*              won't appear in subsequent extracts.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card 
* *********************************************************************************/
public without sharing class SOM_DownloadLeads {
    
    /***********************************************************************************
* Date:        08FEB17
* Author:      Jon Marson - Forcify Ltd
* Desc:        Lightning button used to download Lead.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
    
    @AuraEnabled
    public static Integer download()
    {  Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
     List<Lead> leadList = [SELECT Id, Name, Company, Email, Phone, SOM_Fleet_Size__c, SOM_Fleet_Type__c, SOM_International_Coverage__c, SOM_Monthly_Fuel_Spend__c, SOM_Allocated_Date__c, PostalCode FROM Lead WHERE Status='Allocated' and RecordTypeId = :devRecordTypeId];
     
     if (leadList.size()==0)
         return 0;
     try
     {
         String csv = 'Id,Name,Company,Email,Phone,Fleet Size,Fleet Type,International Coverage?,Monthly Fuel Spend,Allocated Date,Postal Code';
         for (Lead l : leadList)
         {
             csv += '\n="' +l.Id +'",="' +l.Name +'",="' +l.Company +'",="' +l.Email +'",="' +l.Phone +'",="' +l.SOM_Fleet_Size__c +'",="' +l.SOM_Fleet_Type__c +'",="' +l.SOM_International_Coverage__c +'",="' +l.SOM_Monthly_Fuel_Spend__c +'",="' +l.SOM_Allocated_Date__c +'",="' +l.PostalCode +'"';
             l.Status = 'In Progress';
         }        
         update leadList;
         
         User u = [SELECT Account.Name FROM User WHERE id = :UserInfo.getUserId()];
         String title = u.Account.Name +' Leads ' +Datetime.now().format();
         
         ContentVersion contVer = new ContentVersion();
         contVer.Title = title;
         contVer.PathOnClient = title +'.csv'; 
         contVer.VersionData = Blob.valueOf(csv);
         contVer.Origin = 'H';
         insert contVer;
         
         return leadList.size();
     }
     catch (Exception e)
     {
         system.debug('Exception'+e.getMessage());
         return null;
     }  
     
    }
    
}