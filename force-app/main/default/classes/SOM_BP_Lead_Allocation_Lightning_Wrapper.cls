/*****************************************************************************************
* Date:          08AUG19
* Author:        Ganta,Veera Venkata Satyanarayana Murthy (Infosys)
* Comments:      Simple wrapper class to allow us to trigger an Apex class from a custom
*                button (Allocate Lead) on the Lightning Lead page.
*                Triggered From AllocateLead Flow - 
* Usage:         Achieve same functionality across both classic and Lightning
*                environment for Buttons - Allocate(classic)/Allocated Lead(lightning).
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* ***************************************************************************************/
public without sharing class SOM_BP_Lead_Allocation_Lightning_Wrapper 
{   static Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
 
 /***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method call allocateHelper method in SOM_BP_Lead_Allocation apex class.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
 @InvocableMethod(label='Lightning Allocate Lead' description='Method to call allocateHelper method in SOM_BP_Lead_Allocation apex class')
 public static void allocate(List<Lead> leadList)
 {    
     
     List<Lead> lstNew = new List<Lead>();
      system.debug(leadList+'leadList_new');
     try
     {
         for(Lead leadObj : leadList)
         { 
             lstNew.add(leadObj);
             
             if(lstNew.size()>0)
             {
                 SOM_BP_Lead_Allocation.allocateHelper(lstNew, true); 
             }
         }
     }
     catch (Exception e)
     {
         System.debug('Exception occurred'+e.getMessage());
     } 
 }
}