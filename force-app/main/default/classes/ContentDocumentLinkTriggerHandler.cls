/**
 * @Who     Platform Team - Customer Org <adam.walker1@bp.com>
 * @when    10-04-2018
 * @what    The Generic Trigger Handler for the ContentDocumentLinkTrigger. Please add your product specific handler this class
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/
public class ContentDocumentLinkTriggerHandler {

    private final List<ContentDocumentLink> newRecords;
    private final List<ContentDocumentLink> oldRecords;
    private final Map<Id, ContentDocumentLink> newMap;
    private final Map<Id, ContentDocumentLink> oldMap;

   /**
*————————————————————————————————————————————————————
* @Description
* get trigger varible values.
*————————————————————————————————————————————————————
* @param    
* @return   
*————————————————————————————————————————————————————
**/ 
    public ContentDocumentLinkTriggerHandler(List<ContentDocumentLink> newRecords, List<ContentDocumentLink> oldRecords, Map<Id, ContentDocumentLink> newMap, Map<Id,ContentDocumentLink> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }

   /**
*————————————————————————————————————————————————————
* @Description
* Before insert trigger method.
*————————————————————————————————————————————————————
* @param    
* @return   void
*————————————————————————————————————————————————————
**/
    public void handleBeforeInsert() {

        //Set visibility to 'AllUsers'
        //CAPL_ContentVisibilityTriggerHandler.changeVisibility(newRecords);
       
    }

  /**
*————————————————————————————————————————————————————
* @Description
* After insert trigger method.
*————————————————————————————————————————————————————
* @param    
* @return   void
*————————————————————————————————————————————————————
**/
    public void handleAfterInsert() {
       // for (CDM_Credit_Debit_Note__c  cdm : [SELECT Id,(SELECT Id FROM ContentDocumentLinks) FROM CDM_Credit_Debit_Note__c WHERE Id IN : parentIds AND CDM_Country__c = 'Switzerland' Limit 1]) {
           // if(cdm.ContentDocumentLinks!=null) 
        //CDM_ContentDocumentHelper.updateCDMRecordFormDocument();
        //CASFO_FillNoteTitle fillNoteTitle = new CASFO_FillNoteTitle(newMap);
        //fillNoteTitle.fillNoteTitle();
         
    }

  /**
*————————————————————————————————————————————————————
* @Description
* Before update trigger method.
*————————————————————————————————————————————————————
* @param    
* @return   void
*————————————————————————————————————————————————————
**/
    public void handleBeforeUpdate() {

    }

  /**
*————————————————————————————————————————————————————
* @Description
* After Update trigger method.
*————————————————————————————————————————————————————
* @param    
* @return   void
*————————————————————————————————————————————————————
**/
    public void handleAfterUpdate() {

    }

}