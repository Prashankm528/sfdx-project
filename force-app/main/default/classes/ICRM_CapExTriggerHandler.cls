/**
* @author Irfan Ahmed
* @date 19/06/2020
* @company IBM Company
* @description - Handler class for triggers on CapEx object
* *
*/

/* Class to handle Capex trigger */
public with sharing class ICRM_CapExTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    /* Operation on before insert */   
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        string recTypeid = Schema.getGlobalDescribe().get('ICRM_CapEx__c').getDescribe().getRecordTypeInfosByName().get('ICRM CapEx').getRecordTypeId();        
        List<ICRM_CapEx__c> capExNewList = new List<ICRM_CapEx__c>();
        List<ICRM_CapEx__c> capExListtoVerify = new List<ICRM_CapEx__c>();
        capExNewList = n; 
        for(ICRM_CapEx__c cap : capExNewList){
            if(cap.recordTypeId == recTypeid){
                capExListtoVerify.add(cap); 
            }
        }
        
        if(!capExListtoVerify.isEmpty()){
            capExVerifyYearQuarter(capExListtoVerify);
        } 
    }
    /** Method to Check CapEx Quarter and Year**/
    public void capExVerifyYearQuarter(List<ICRM_CapEx__c> capExListtoVerify){
        
        for(ICRM_CapEx__c cp : capExListtoVerify){
            if(cp.ICRM_Project__c != null){

                List<ICRM_CapEx__c> cpRc = [Select ICRM_Date__c from ICRM_CapEx__c Where ICRM_Project__c =: cp.ICRM_Project__c];
                for(ICRM_CapEx__c cpRec : cpRc){
                    Decimal quarterDc = (Decimal.valueOf(cpRec.ICRM_Date__c.month()))/Decimal.valueOf(3);
                    integer quarterInt = (integer)quarterDc.round(System.RoundingMode.CEILING);
                    Decimal newQuarterDc = (Decimal.valueOf(cp.ICRM_Date__c.month()))/Decimal.valueOf(3);
                    integer newQuarterInt = (integer)newQuarterDc.round(System.RoundingMode.CEILING);
                    if(cp.ICRM_Date__c.year() == cpRec.ICRM_Date__c.year() && quarterInt == newQuarterInt){
                        cp.addError('There is already a Capital Expenditure on this Project for this Quarter and Year.');
                        break;
                    }
                }
                
            }
        }
    }
}