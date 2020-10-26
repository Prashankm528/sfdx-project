/************************************************************************************************************************
*   Date: 09/16/2020
*   Author:   Pooja Deokar(TCS)
*   Description: Class is use to clone Contract with oppportunity and its related objects
*************************************************************************************************************************/
public with sharing class PCRM_ManualContractRenewal {
	
    public PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();  
    //Method is used to clone opportunity.
    public void manualOpportunityClone(Opportunity OpportunityToCloneObj) 
    {              
		result  = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
        if(OpportunityToCloneObj != null){
            List<Opportunity> lstNewOpportunities = new List<Opportunity>();
            Opportunity objNewOpportunity = new Opportunity();            
                                          
            for(PCRM_Batch_Clone__mdt BatchClone: PCRM_BatchCloneUtil.getCustomMetatdata('Opportunity')){
                objNewOpportunity.put(BatchClone.PCRM_TargetField__c ,OpportunityToCloneObj.get(BatchClone.PCRM_SourceField__c)); 
            }
           	objNewOpportunity.Name = OpportunityToCloneObj.Account.Name +' '+ OpportunityToCloneObj.type.removeStart('PCRM_');
            objNewOpportunity.CloseDate = system.today() + 30;
            
            if(OpportunityToCloneObj.PCRM_Start_Date__c != NULL && OpportunityToCloneObj.PCRM_End_Date__c != NULL){
                objNewOpportunity.PCRM_Start_Date__c = OpportunityToCloneObj.PCRM_End_Date__c.addDays(1);
                objNewOpportunity.PCRM_End_Date__c = PCRM_BatchCloneUtil.getEndDate(OpportunityToCloneObj.PCRM_Start_Date__c,OpportunityToCloneObj.PCRM_End_Date__c) ;
                objNewOpportunity.Name +=  ' '+String.valueof(objNewOpportunity.PCRM_Start_Date__c.year()) + '-' + String.valueof(objNewOpportunity.PCRM_End_Date__c.year())  ; 
                objNewOpportunity.CloseDate = objNewOpportunity.PCRM_Start_Date__c.addDays(OpportunityToCloneObj.PCRM_Start_Date__c.daysBetween(OpportunityToCloneObj.CloseDate));                 
            }                       
            objNewOpportunity.StageName = 'Prospecting';            
            objNewOpportunity.Probability = 10;          
            objNewOpportunity.PCRM_isCreatedFromCloning__c = true;   
            objNewOpportunity.PCRM_Opportunity_Cloned_From__c = OpportunityToCloneObj.id;
            lstNewOpportunities.add(objNewOpportunity);
           
            try{            
                if(lstNewOpportunities != null && (!lstNewOpportunities.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunities,'insert');  
                    PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_ManualContractRenewal','Manual','PCRM_IT_Support');               		
                    //Clone PCRM_Opportunity_Account__c                   
                    manualOpportunityAccountClone(lstNewOpportunities[0],OpportunityToCloneObj.id);
                    //Clone OpportunityLineItems
                    manualCloneOpportunityLineItems(lstNewOpportunities[0],OpportunityToCloneObj.id);
                    //clone contract Agreement 
                    manualCloneContractAgreement(lstNewOpportunities[0],OpportunityToCloneObj.id);
                }                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'Opportunity','PCRM_ManualContractRenewal','Manual','PCRM_IT_Support');
            }
        }
    }
	
	//Method is used to clone PCRM_Opportunity_Account__c.
    public void manualOpportunityAccountClone(Opportunity OpportunityToCloneObj,String oppID) 
    {   
        if(!String.isBlank(oppID)){            
            result  = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();
            List<PCRM_Opportunity_Account__c> lstNewOpportunityAccount = new List<PCRM_Opportunity_Account__c>();
            List<PCRM_Batch_Clone__mdt> lstOppAcctCustomCloneField = new List<PCRM_Batch_Clone__mdt>();

            Id opportunityAccountRTId = Schema.SObjectType.PCRM_Opportunity_Account__c.getRecordTypeInfosByDeveloperName().get('PCRM_Opportunity_Account').getRecordTypeId();
            String strQuery1 = 'SELECT ';
           
            lstOppAcctCustomCloneField =  PCRM_BatchCloneUtil.getCustomMetatdata('PCRM_Opportunity_Account__c');
            for (PCRM_Batch_Clone__mdt BC :lstOppAcctCustomCloneField){
               strQuery1 += BC.PCRM_TargetField__c + ',';
            }  
            strQuery1 += 'ID From PCRM_Opportunity_Account__c Where PCRM_Opportunity__c =:oppID';
            for(PCRM_Opportunity_Account__c objOpportunityAccount : Database.query(strQuery1)){    
                PCRM_Opportunity_Account__c objNewOpportunityAccount = new PCRM_Opportunity_Account__c();
                for(PCRM_Batch_Clone__mdt BatchClone:lstOppAcctCustomCloneField){
                    objNewOpportunityAccount.put(BatchClone.PCRM_TargetField__c ,objOpportunityAccount.get(BatchClone.PCRM_SourceField__c)); 
                }  
                
                objNewOpportunityAccount.PCRM_isCreatedFromCloning__c = True;  
                objNewOpportunityAccount.PCRM_Opportunity__c = OpportunityToCloneObj.id;
                 
                lstNewOpportunityAccount.add(objNewOpportunityAccount);
            }
            try{
                if(lstNewOpportunityAccount != null && (!lstNewOpportunityAccount.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunityAccount,'insert');  
                    PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'PCRM_Opportunity_Account__c','PCRM_BatchCloneOpportunityAccounts','Manual','PCRM_IT_Support');
                }                                       
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'PCRM_Opportunity_Account__c','PCRM_BatchCloneOpportunityAccounts','Manual','PCRM_IT_Support');
            }   
        }
	}
    //Method is used to clone OpportunityLineItem.
    public void manualCloneOpportunityLineItems(Opportunity OpportunityToCloneObj,String oppID) 
    { 
        if(!String.isBlank(oppID)){
            List<OpportunityLineItem> lstNewOpportunityLineItem = new List<OpportunityLineItem>();
            List<PCRM_Batch_Clone__mdt> lstOLICustomCloneField = new List<PCRM_Batch_Clone__mdt>();
            lstOLICustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('OpportunityLineItem');
            result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();    
            
            String strQuery1 = 'SELECT ';        
        	for (PCRM_Batch_Clone__mdt BC : lstOLICustomCloneField){
           		strQuery1 += BC.PCRM_TargetField__c + ',';
            }
            strQuery1 += 'Id From OpportunityLineItem Where OpportunityId =:oppId';
           try{
            for (OpportunityLineItem objOpportunityLineItem: Database.query(strQuery1)){
                OpportunityLineItem objNewOpportunityLineItem = new OpportunityLineItem();
                
            	for(PCRM_Batch_Clone__mdt BatchClone:lstOLICustomCloneField){
                	objNewOpportunityLineItem.put(BatchClone.PCRM_TargetField__c ,objOpportunityLineItem.get(BatchClone.PCRM_SourceField__c)); 
            	}  
                objNewOpportunityLineItem.opportunityId = OpportunityToCloneObj.Id;                            
                objNewOpportunityLineItem.PCRM_isCreatedFromCloning__c = true;
                lstNewOpportunityLineItem.add(objNewOpportunityLineItem);
        	} //for  
                if(lstNewOpportunityLineItem != null && (!lstNewOpportunityLineItem.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunityLineItem,'insert');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItem','manualCloneOpportunityLineItems','Manual','PCRM_IT_Support');
                    // OLISchedule clonning method
                    manualCloneOpportunityLineSchedule(OpportunityToCloneObj,lstNewOpportunityLineItem);
                }                
            }catch(Exception Ex){
                system.debug('Exception ===='+EX);
                  PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItem','manualCloneOpportunityLineItems','Manual','PCRM_IT_Support');
			}   
        }
    }
     //Method is used to clone OpportunityLineItemSchedule.
    public void manualCloneOpportunityLineSchedule(Opportunity OpportunityToCloneObj,List<OpportunityLineItem> lstOpportunityLineItems) 
    { 
       if(lstOpportunityLineItems != null && (!lstOpportunityLineItems.isEmpty())) {
           SET<ID> keys = new SET<ID>();
           map<Id, Id> mapOldOpportunityLineIDsWithNewOpportunityLineIDs = new map<Id, Id>();
           List<OpportunityLineItemSchedule> lstNewOpportunityLineItemSch = new List<OpportunityLineItemSchedule>();
           for(OpportunityLineItem oli:lstOpportunityLineItems){
               mapOldOpportunityLineIDsWithNewOpportunityLineIDs.put(oli.PCRM_OpportunityLineItem_Cloned_From__c, oli.id);
                    keys.add(oli.PCRM_OpportunityLineItem_Cloned_From__c);           
           }
           
            List<PCRM_Batch_Clone__mdt> lstOLICustomCloneField = new List<PCRM_Batch_Clone__mdt>();
            lstOLICustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('OpportunityLineItemSchedules');
            result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();    
          
            String strQuery1 = 'SELECT Id,Opportunity.CloseDate ,(SELECT ';        
        	for (PCRM_Batch_Clone__mdt BC : lstOLICustomCloneField){
           		strQuery1 += BC.PCRM_TargetField__c + ',';
            }
            strQuery1 += 'Id From OpportunityLineItemSchedules ORDER BY ScheduleDate ASC NULLS FIRST ) from OpportunityLineItem where Id IN: keys';
          	 for (OpportunityLineItem objOpportunityLineItem1 : Database.query(strQuery1)){
                Date oppCloseDate = OpportunityToCloneObj.CloseDate ;
             	for (OpportunityLineItemSchedule objOpportunityLineItemSch : objOpportunityLineItem1.OpportunityLineItemSchedules)
                {
                    OpportunityLineItemSchedule objNewOpportunityLineItemSchedule = new OpportunityLineItemSchedule();
                
                    for(PCRM_Batch_Clone__mdt BatchClone:lstOLICustomCloneField){
                        objNewOpportunityLineItemSchedule.put(BatchClone.PCRM_TargetField__c ,objOpportunityLineItemSch.get(BatchClone.PCRM_SourceField__c)); 
                    }  
                    objNewOpportunityLineItemSchedule.OpportunityLineItemId = mapOldOpportunityLineIDsWithNewOpportunityLineIDs.get(objOpportunityLineItemSch.OpportunityLineItemId);
                    objNewOpportunityLineItemSchedule.PCRM_isCreatedFromCloning__c = True; 
                    objNewOpportunityLineItemSchedule.ScheduleDate = oppCloseDate;
                    oppCloseDate = oppCloseDate.addYears(1);
                    lstNewOpportunityLineItemSch.add(objNewOpportunityLineItemSchedule);
                }
             }  
			try{
                if(lstNewOpportunityLineItemSch != null && (!lstNewOpportunityLineItemSch.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewOpportunityLineItemSch,'insert');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItemSchedule','manualCloneOpportunityLineSchedule','Manual','PCRM_IT_Support');
                	//Delete system generated Schedule records
                	manualDeleteOpportunityLineSchedule(lstOpportunityLineItems);
                }                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                  PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItemSchedule','manualCloneOpportunityLineSchedule','Manual','PCRM_IT_Support');
			}              
        }
     }
    //Method is used to delete system generated schedule entries OpportunityLineItemSchedule.
    public void manualDeleteOpportunityLineSchedule(List<OpportunityLineItem> lstOpportunityLineItems) 
    {
        List<OpportunityLineItemSchedule> lstNewOpportunityLineItemSch = new List<OpportunityLineItemSchedule>();
        lstNewOpportunityLineItemSch = [SELECT Id FROM OpportunityLineItemSchedule WHERE PCRM_isCreatedFromCloning__c = false 
                                        AND OpportunityLineItemId IN :lstOpportunityLineItems ];
        try{
                if(lstNewOpportunityLineItemSch != null && (!lstNewOpportunityLineItemSch.isEmpty())) {
                    result = PCRM_BatchCloneUtil.deleteRecords(lstNewOpportunityLineItemSch);  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItemSchedule','manualDeleteOpportunityLineSchedule','Manual','PCRM_IT_Support');
			   }                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                  PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'OpportunityLineItemSchedule','manualDeleteOpportunityLineSchedule','Manual','PCRM_IT_Support');
			}  
    }
     
    //Method is used to clone APXT_Redlining__Contract_Agreement__c.
    public void manualCloneContractAgreement(Opportunity OpportunityToCloneObj,String oppID) 
    { 
         if(!String.isBlank(oppID)){
            List<APXT_Redlining__Contract_Agreement__c> lstNewContractAgreement = new List<APXT_Redlining__Contract_Agreement__c>();
            List<PCRM_Batch_Clone__mdt> lstCustomCloneField = new List<PCRM_Batch_Clone__mdt>();
            lstCustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('APXT_Redlining__Contract_Agreement__c');
            result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();    
            
            String strQuery1 = 'SELECT ';        
        	for (PCRM_Batch_Clone__mdt BC : lstCustomCloneField){
           		strQuery1 += BC.PCRM_TargetField__c + ',';
            }
            strQuery1 += 'Id From APXT_Redlining__Contract_Agreement__c Where PCRM_Opportunity__c =: oppID order by CreatedDate DESC limit 1';
            
            for (APXT_Redlining__Contract_Agreement__c objContAggr: Database.query(strQuery1)){
             
                APXT_Redlining__Contract_Agreement__c objNewContAggr = new APXT_Redlining__Contract_Agreement__c();
                
            	for(PCRM_Batch_Clone__mdt BatchClone:lstCustomCloneField){
                	objNewContAggr.put(BatchClone.PCRM_TargetField__c ,objContAggr.get(BatchClone.PCRM_SourceField__c)); 
            	}  
                if(objContAggr.APXT_Redlining__Effective_Date__c != NULL && objContAggr.APXT_Redlining__Expiration_Date__c != NULL){
                    objNewContAggr.APXT_Redlining__Effective_Date__c = objContAggr.APXT_Redlining__Expiration_Date__c.addDays(1);
                    objNewContAggr.APXT_Redlining__Expiration_Date__c = PCRM_BatchCloneUtil.getEndDate(objContAggr.APXT_Redlining__Effective_Date__c,objContAggr.APXT_Redlining__Expiration_Date__c) ;
	       		 }   
                objNewContAggr.PCRM_Opportunity__c = OpportunityToCloneObj.Id;                            
                objNewContAggr.PCRM_isCreatedFromCloning__c = true;
                lstNewContractAgreement.add(objNewContAggr);
        	} //for  
            
            try{
                if(lstNewContractAgreement != null && (!lstNewContractAgreement.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewContractAgreement,'insert');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Contract_Agreement__c','manualCloneContractAgreement','Manual','PCRM_IT_Support');
					//Clone ManageClauses
					manualCloneManageClauses(JSON.serialize(lstNewContractAgreement));	                    
                }                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Contract_Agreement__c','manualCloneContractAgreement','Manual','PCRM_IT_Support');
			}   
        }
    }
	
	//Method is used to clone Manage Clauses.
	@future
    public static void manualCloneManageClauses(String jsonStrContAggrList) 
    {
        List<APXT_Redlining__Contract_Agreement__c> lstNewContractAgreement = new List<APXT_Redlining__Contract_Agreement__c>();
        lstNewContractAgreement = (List<APXT_Redlining__Contract_Agreement__c>) JSON.deserialize(jsonStrContAggrList, List<APXT_Redlining__Contract_Agreement__c>.class);
        PCRM_BatchCloneUtil.DMLResponseWrapper result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();  
		if(lstNewContractAgreement != null && (!lstNewContractAgreement.isEmpty())) {
           SET<ID> keys = new SET<ID>();
           map<Id, Id> mapOldContractAggrementwithNewIDs = new map<Id, Id>();
           List<APXT_Redlining__Managed_Clause__c> lstNewManagedClause = new List<APXT_Redlining__Managed_Clause__c>();
           for(APXT_Redlining__Contract_Agreement__c objConAgr:lstNewContractAgreement){
               mapOldContractAggrementwithNewIDs.put(objConAgr.PCRM_ContractAgreement_Cloned_From__c, objConAgr.id);
                    keys.add(objConAgr.PCRM_ContractAgreement_Cloned_From__c);           
           }
           
            List<PCRM_Batch_Clone__mdt> lstOLICustomCloneField = new List<PCRM_Batch_Clone__mdt>();
            lstOLICustomCloneField = PCRM_BatchCloneUtil.getCustomMetatdata('APXT_Redlining__Managed_Clause__c');
            result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();    
            
            String strQuery1 = 'SELECT ';        
        	for (PCRM_Batch_Clone__mdt BC : lstOLICustomCloneField){
           		strQuery1 += BC.PCRM_TargetField__c + ',';
            }
            strQuery1 += 'Id From APXT_Redlining__Managed_Clause__c Where APXT_Redlining__Contract_Agreement__c IN: keys';
            for (APXT_Redlining__Managed_Clause__c objManageClause: Database.query(strQuery1)){
                APXT_Redlining__Managed_Clause__c objNewManagedClause = new APXT_Redlining__Managed_Clause__c();
                
            	for(PCRM_Batch_Clone__mdt BatchClone:lstOLICustomCloneField){
                	objNewManagedClause.put(BatchClone.PCRM_TargetField__c ,objManageClause.get(BatchClone.PCRM_SourceField__c)); 
            	}  
				objNewManagedClause.APXT_Redlining__Contract_Agreement__c = mapOldContractAggrementwithNewIDs.get(objManageClause.APXT_Redlining__Contract_Agreement__c);
                objNewManagedClause.PCRM_isCreatedFromCloning__c = True;    
                
                lstNewManagedClause.add(objNewManagedClause);
        	} //for  
            try{
                if(lstNewManagedClause != null && (!lstNewManagedClause.isEmpty())) {
                    result = PCRM_BatchCloneUtil.insertRecords(lstNewManagedClause,'insert');  
                	PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Managed_Clause__c','manualCloneManageClauses','Manual','PCRM_IT_Support');            	 
            	}                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Managed_Clause__c','manualCloneManageClauses','Manual','PCRM_IT_Support');
			} 
            
            //code is used to update the contract agreement set iscreatedfromcloning to unchecked.
            List<APXT_Redlining__Contract_Agreement__c> lstUpdateContractAgreement = new List<APXT_Redlining__Contract_Agreement__c>();

            result = NEW PCRM_BatchCloneUtil.DMLResponseWrapper();  
            for(APXT_Redlining__Contract_Agreement__c objContAggr:lstNewContractAgreement){
                APXT_Redlining__Contract_Agreement__c objNewContAggr = new APXT_Redlining__Contract_Agreement__c();
                objNewContAggr.id = objContAggr.id ;
            	objNewContAggr.PCRM_isCreatedFromCloning__c = false;
                lstUpdateContractAgreement.add(objNewContAggr);
            }
            try{
                if(lstUpdateContractAgreement != null && (!lstUpdateContractAgreement.isEmpty())) {
    
                    result = PCRM_BatchCloneUtil.insertRecords(lstUpdateContractAgreement,'update');  
                    PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Contract_Agreement__c','updateContractAgreement','Manual','PCRM_IT_Support');
                    system.debug('successfully completed manual clone===');
                }                
            }catch(Exception Ex){
                system.debug('Exception Ex ===='+EX);
                PCRM_BatchCloneUtil.logResult(result.strError,result.successIds,'APXT_Redlining__Contract_Agreement__c','updateContractAgreement','Manual','PCRM_IT_Support');
            }   
        }	
    }
}