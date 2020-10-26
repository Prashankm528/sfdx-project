/************************************************************************************************************************
*   Date: 08/25/2020
*   Author:   Pooja Deokar(TCS)
*   Description: The job processes the accounts and clones associated + valid, Quarterly/ Monthly opportunities onto the Account.
*              The job gets called from a schedulable process.
*   Change Log: initial draft created for cloning latest created opportunities onto given set of accounts.
*************************************************************************************************************************/
public with Sharing class PCRM_BatchCloneOpportunity implements Queueable{
    List<String> lstFrequency = new List<String>();   
    List<Opportunity> lstAllOpp = new List<Opportunity>();
    List<PCRM_Batch_Clone__mdt> lstOppCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
    
    // Constructor: initialize the input parameters
    public PCRM_BatchCloneOpportunity(List<String> lstFrq){
         if (lstFrq != null && lstFrq.size() > 0){
            this.lstFrequency = lstFrq;           
        }
        //get the opportunity clone field details from custom metadata
        lstOppCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('Opportunity');        
    }
    //Execute method
	public void execute(QueueableContext context) { 
        List<Opportunity> lstNewOpportunities = new List<Opportunity>(); 
        PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
       
        List<String> lstType = new List<String>();        
        lstType.add('PCRM_Spot');
        lstType.add('PCRM_Negotiated');
        lstType.add('PCRM_Formula');
        String QuoteStatus ='Presented';
        
        Id opportunityRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PCRM_PetChems_Acetyls').getRecordTypeId();
        Id accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        String strQuery = 'SELECT Id, Name, PCRM_Quote_Frequency__c,CurrencyIsoCode, (SELECT Id FROM Opportunities WHERE recordTypeId =: opportunityRTId AND Type IN: lstType order by CreatedDate DESC limit 1 ) FROM Account WHERE recordTypeId =: accountRTId AND Sales_Division_Code__c = \'69\' AND PCRM_Quote_Frequency__c IN: lstFrequency';
		
        for (Account objAccount: Database.query(strQuery))
        {
            if(objAccount.Opportunities != null && (!objAccount.Opportunities.isEmpty())){                
               lstAllOpp.addAll(objAccount.Opportunities);  
            }            	           
        }
        
        String strQuery1 = 'SELECT Id,PCRM_Quarter__c,StageName,Account.Name, ';
        for (PCRM_Batch_Clone__mdt BC : lstOppCustomCloneField){
            strQuery1 += BC.PCRM_TargetField__c + ',';
        }      
        strQuery1 += ' (select Id,status, OpportunityId from Quotes where (status = \'Presented\' OR Status = \'Accepted\' ) AND IsSyncing = true) FROM Opportunity WHERE ID IN: lstAllOpp';

         //Check if this opportunity has a corresponding quote in Presented state
        for (Opportunity objOpportunity: Database.query(strQuery1)){
           
            if(objOpportunity.Quotes != null  && (!objOpportunity.Quotes.isEmpty()) && lstFrequency.contains(objOpportunity.PCRM_Quote_Frequency__c)){
              Opportunity objNewOpportunity = new Opportunity();
                                 
                for(PCRM_Batch_Clone__mdt BatchClone:lstOppCustomCloneField){
                	objNewOpportunity.put(BatchClone.PCRM_TargetField__c ,objOpportunity.get(BatchClone.PCRM_SourceField__c)); 
                }  
                String strYear = String.valueof(System.Today().year());
                if (objOpportunity.PCRM_Quote_Frequency__c == 'Quarterly'){
                    objNewOpportunity.Name = objOpportunity.PCRM_Quote_Frequency__c + 'Opportunity-' + objOpportunity.Account.Name +'-'+ PCRM_BatchCloneUtil.getYear('Quarterly') +'-'+ PCRM_BatchCloneUtil.getQuarter();
                } 
                else { 
                    objNewOpportunity.Name = objOpportunity.PCRM_Quote_Frequency__c + 'Opportunity-' + objOpportunity.Account.Name +'-'+ PCRM_BatchCloneUtil.getYear('Monthly') +'-'+ PCRM_BatchCloneUtil.getMonth();
                }
                objNewOpportunity.StageName = 'Prospecting';
                objNewOpportunity.CloseDate = system.today() + 30;
                objNewOpportunity.Probability = 10;
                objNewOpportunity.PCRM_isFirstSyncWithQuote__c = true;
                objNewOpportunity.PCRM_isCreatedFromCloning__c = true;
                lstNewOpportunities.add(objNewOpportunity);
            }           
        }      
        try{            
            if(lstNewOpportunities != null && (!lstNewOpportunities.isEmpty())) {
                result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunities,'insert');  
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_BatchCloneOpportunity','Scheduled','PCRM_IT_Support');
         	}                
        }catch(Exception Ex){
            PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_BatchCloneOpportunity','Scheduled','PCRM_IT_Support');
		}
    }
}