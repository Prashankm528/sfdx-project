/**
*___________________________________________________
*@Name:     CDM_ContentDocumentHelper 
*@Author:   Chandra Kanchi
*@Created:  Jan 26, 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for get upload bulk CDM Eform from parent CDM form.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public without sharing class CDM_ContentDocumentHelper {
 
    public static void updateCDMRecordFormDocument(List<ContentDocumentLink> n,List<ContentDocumentLink> o) {
    List<ContentDocumentLink> contentDocLinks = ( n == null ? o : n );
    List<ID> parentIds = new List<ID>();
    List<ID> swissIds = new List<ID>();
    List<ID> cLinkIds = new List<ID>();
    List<ID> NLIds = new List<ID>();
    if(!contentDocLinks.isEmpty()) {
        //system.debug(cdls.size());
          for ( ContentDocumentLink cdl : contentDocLinks ) {
                String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(sObjName == 'CDM_Credit_Debit_Note__c')
                    parentIds.add( cdl.LinkedEntityId );
                }
              
                system.debug('parentIds>>>>>>>>'+parentIds);
              
          if(!parentIds.isEmpty()) {
            //if(!parentIds.isEmpty()) {
            if(parentIds!=null)   
             if(parentIds.size()>0)
                for (CDM_Credit_Debit_Note__c  cdm : [SELECT Id,CDM_Country__c,(SELECT Id FROM ContentDocumentLinks order by ContentDocumentId desc) FROM CDM_Credit_Debit_Note__c WHERE Id IN : parentIds AND (CDM_Country__c = 'Switzerland' OR CDM_Country__c = 'Netherlands') Limit 1]) {
                system.debug('Inside Method>>>>>>>>' +cdm.ContentDocumentLinks.size());
                if(cdm.ContentDocumentLinks!=null) {
                    if(cdm.ContentDocumentLinks.size() > 0) {
                       if(cdm.CDM_Country__c == 'Switzerland')
                       swissIds.add(cdm.id);
                       else
                       NLIds.add(cdm.id);    
                       cLinkIds.add(cdm.ContentDocumentLinks[0].id); 
                     }  
                }
                
        
            }
          }  
            
            if(!swissIds.isEmpty() && !cLinkIds.isEmpty())
                CDM_EformsCsvUpload.createChildEformsData(swissIds[0],cLinkIds[0]);
        	if(!NLIds.isEmpty() && !cLinkIds.isEmpty())
            {
                system.debug('Coming here as well');
                CDM_EformsCsvUpload.updateParentNetAmountNL(NLIds[0],cLinkIds[0]);
            }
        }
    }
     /**
    *————————————————————————————————————————————————————
    * @Description
    * Before  Delete trigger handler method
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    
    public static void deleteCDMRecordFormDocument(List<ContentDocumentLink> o) {
        system.debug(o);
    	List<ContentDocumentLink> cdls = o;
        List<ID> parentIds = new List<ID>();
        CDM_Credit_Debit_Note__c cdmrec;
        List<CDM_Credit_Debit_Note__c> cdmrectoupdate = new List<CDM_Credit_Debit_Note__c>();
        if(!cdls.isEmpty()) {
            system.debug(cdls.size());
            for ( ContentDocumentLink cdl : cdls ) {
                String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(sObjName == 'CDM_Credit_Debit_Note__c')
                    parentIds.add( cdl.LinkedEntityId );
            }
            if(!parentIds.isEmpty()) {
                for (CDM_Credit_Debit_Note__c  cdm : [SELECT Id,CDM_CH_Csv_Upload__c FROM CDM_Credit_Debit_Note__c WHERE Id IN : parentIds AND CDM_Country__c = 'Switzerland' Limit 1]) {
                    cdmrec = new CDM_Credit_Debit_Note__c();
                    cdmrec.CDM_CH_Csv_Upload__c = true;
                    cdmrectoupdate.add(cdmrec);
                }
            }
            update cdmrectoupdate;
        }   
    }
    **/
}