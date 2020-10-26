/* @author            Santosh Verma
*  @date              05th March, 2020
*  @description       PBI (1026926/1062296) Handles trigger events on Campaign object for IST CRM Project
*  @ -----------------------------------
*  @ ------------ Changed by ---
*  @author             
*  @date               
*  @description        
*/
public with sharing class ICRM_CampaignTriggerHandler extends BPG_Trigger_Handler_Utilities{            
     /* process campaign records for IST */  
 
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Add new values to CMS  */
    { 
        CampMemInsert(o,  oMap,  n,  nMap, sot, params, debug); 
    }
    
    
    Public void CampMemInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {    /* Method to process CMS*/ 
     list<CampaignMemberstatus> CMSList = new list<CampaignMemberstatus>();
     List<Campaign> listNewCampaign = new List<Campaign>();  
     Set<ID> SetDltCampMS = new Set<ID>();
     Id CMrecodId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('IST_Campaign').getRecordTypeId();  
     ICRM_MDT_Camp_Member_status__mdt[] CampMemMdt= [select DeveloperName, ICRM_MDT_Campaign_Type__c,ICRM_MDT_Camp_Member_Default__c,ICRM_MDT_Camp_Member_Responded__c,ICRM_MDT_Camp_Member_Status__c,MasterLabel,ICRM_Is_InActive__c from ICRM_MDT_Camp_Member_status__mdt where ICRM_Is_InActive__c = False ORDER BY MasterLabel ASC ];
    
  
 
        listNewCampaign = n; 
        list<CampaignMemberstatus> CMSListDlt = new list<CampaignMemberstatus>([SELECT Id,Label, CampaignId ,HasResponded, IsDefault FROM CampaignMemberStatus where CampaignId in : listNewCampaign]);
			system.debug('CMSListDlt0'+CMSListDlt);
        for(Campaign cmppro : listNewCampaign){
  			//  recordType check-- Only process for IST Campaign   
            If(CMrecodId == cmppro.RecordTypeId){
      				 string CampType = cmppro.Type;  
               		 for(ICRM_MDT_Camp_Member_status__mdt CampMemMdtProc : CampMemMdt){
                   			If(CampType == CampMemMdtProc.ICRM_MDT_Campaign_Type__c ){
                        			CampaignMemberstatus  CMSListObj = new CampaignMemberstatus(); 
                         			CMSListObj.CampaignId = cmppro.id;
                         			CMSListObj.HasResponded = CampMemMdtProc.ICRM_MDT_Camp_Member_Responded__c;
                         			CMSListObj.IsDefault = CampMemMdtProc.ICRM_MDT_Camp_Member_Default__c; 
                         			CMSListObj.Label = CampMemMdtProc.ICRM_MDT_Camp_Member_Status__c; 
                          
                       				CMSList.add(CMSListObj);
                                	SetDltCampMS.add(cmppro.Id); // storing Camp id for removing unwanted CMS records
                       		} // end if
               		}// end For2    
            } //end if
        } //end for 1 
  		for (CampaignMemberstatus CMSUpdate:CMSList){			
        	for (CampaignMemberstatus CMSUpdlt:CMSListDlt){
            	If(CMSUpdlt.CampaignId == CMSUpdate.CampaignId & CMSUpdate.Label == CMSUpdlt.Label){
                         CMSUpdate.Id = CMSUpdlt.Id; 
                }
       }}
  //====================================================================
        If(CMSList.size() > 0){
       
           //--update/insert required new values to CM
            Upsert CMSList;
            
            //-------------------------------Process to remove all inactive status from CMS records--------------------------------------------------
            		If(SetDltCampMS.size() > 0) {
        ICRM_MDT_Camp_Member_status__mdt[] CampMemRmvMdt= [select DeveloperName, ICRM_MDT_Campaign_Type__c,ICRM_MDT_Camp_Member_Default__c,ICRM_MDT_Camp_Member_Responded__c,ICRM_MDT_Camp_Member_Status__c,ICRM_Is_InActive__c from ICRM_MDT_Camp_Member_status__mdt where ICRM_Is_InActive__c = True];                
        list<CampaignMemberstatus> CMSListRmv = new list<CampaignMemberstatus>([SELECT Id,Label, CampaignId ,HasResponded, IsDefault FROM CampaignMemberStatus where CampaignId in : SetDltCampMS]);                
        list<CampaignMemberstatus> CMSFinalRmv = new list<CampaignMemberstatus>();                
        List<campaign> NewCamp = new list<campaign>([select Id, Type from campaign where id in:SetDltCampMS]);
                       
                        
                        for(Campaign NewCamppro : NewCamp){
  							//  Only process IST Campaign which are having additional CMS values as per SET     
  							 string nCampType = NewCamppro.Type;  
                            For(CampaignMemberstatus CMSLRMV: CMSListRmv){
               		 				for(ICRM_MDT_Camp_Member_status__mdt CMRmvMdtprc : CampMemRmvMdt){
                                        CampaignMemberstatus  CMSObjrmv = new CampaignMemberstatus();
                   						If(nCampType == CMRmvMdtprc.ICRM_MDT_Campaign_Type__c & NewCamppro.Id == CMSLRMV.CampaignId & CMRmvMdtprc.ICRM_MDT_Camp_Member_Status__c ==CMSLRMV.Label  ){
                                            CMSObjrmv.Id = CMSLRMV.Id ;  CMSFinalRmv.add(CMSObjrmv);
                                        }}}}
       //Finally delete all non required values/record from CMS
                        If(CMSFinalRmv.size() > 0){
            				
                            try{
        							
                            		delete CMSFinalRmv;  
        						}catch(exception exce){
           							 String s= exce.getMessage();
        							}
                        }
                        
        		} // If delete 
            //---------------------------------------------------------------------------------
        }  // ---upsert list processing
    } // end CampMemInsert  
    
} // end of class