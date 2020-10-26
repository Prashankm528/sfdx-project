/*****************************************************************************************
*   Date:      10/05/2020
*   Author:    Mansi Dhoke (TCS)  
*   Description: 
*   Changes: 0.1
   
****************************************************************************************/
public with sharing class PCRM_InitiateCloningController 
{
	@AuraEnabled
    public static void initiateCloning(string varOpportunityId)
    {
        List<Opportunity> oppList = New List<Opportunity>();
        List<String> lstType = new List<String>();        
        lstType.add('PCRM_Contract - Long Form');
        lstType.add('PCRM_Contract - Short Form');
        lstType.add('PCRM_Term Sheet');
        lstType.add('PCRM_Document for E-Sign');
        
        List<PCRM_Batch_Clone__mdt> lstOppCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
        List<Opportunity> lstNewOpportunities = new List<Opportunity>(); 
        Id opportunityRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PCRM_PetChems_Acetyls').getRecordTypeId();
        try
        {
            //get the opportunity clone field details from custom metadata
            lstOppCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('Opportunity');
            String strQuery1 = 'SELECT PCRM_Quarter__c,StageName,Account.Name, ';
            for (PCRM_Batch_Clone__mdt BC : lstOppCustomCloneField){
                strQuery1 += BC.PCRM_TargetField__c + ',';
            }      
        	strQuery1 += 'Id FROM Opportunity WHERE ID = :varOpportunityId AND recordTypeId =: opportunityRTId AND Type IN: lstType';
       		
            oppList = Database.query(strQuery1);
            if(oppList != null && oppList.size() > 0)  {                
                PCRM_ManualContractRenewal objManualClone = new PCRM_ManualContractRenewal();
                objManualClone.manualOpportunityClone(oppList[0]);
               //PCRM_ManualCloneOpportunities.executeManualClone(oppList[0]);
            }
            else
            {
                throw new AuraHandledException('Opportunity of Type -Term sheet,Long Form ,Short Form and Document for E-Sign can get clone'); 
            }
        }
        catch(Exception ex)
        {
            system.debug('Exception in class PCRM_InitiateCloningController :'+ex.getmessage());
        }
        
    }
}