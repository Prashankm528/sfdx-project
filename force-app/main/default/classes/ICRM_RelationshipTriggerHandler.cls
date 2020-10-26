/* @author            Santosh Verma
*  @date              09th June, 2020
*  @description       handles trigger events on (ICRM_Contact_Relationship__c) Relationship object for IST CRM Project
*  @ -----------------------------------
*  @ ------------ Changed by ---
*  @author             
*  @date               
*  @description        
*/
public with sharing class ICRM_RelationshipTriggerHandler extends BPG_Trigger_Handler_Utilities {   
 /* process relationship records for IST   */

    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
        /* Add new values to contact  */
    { 
        ContactUpdate(o,  oMap,  n,  nMap, sot, params, debug); 
    }
    
     public override void afterupdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Add new values to contact  */
    {  
        ContactUpdate(o,  oMap,  n,  nMap, sot, params, debug); 
    }
    
    public override void afterdelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        /* Add new values to contact  */
    {  
        ContactUpdate(o,  oMap,  n,  nMap, sot, params, debug); 
    }
    
    Public void ContactUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {    /* Method to process all active relationship records*/  
     Id ConRecodId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IST Contact').getRecordTypeId(); 
     list<ICRM_Contact_Relationship__c>  RelListNew = new list<ICRM_Contact_Relationship__c>(); 
     set<ID> ContSet = new set<ID>();
        if(trigger.isDelete) {
           RelListNew = o; // trigger.old for delete 
        }
        Else{
            RelListNew = n;   // trigger.new for new/update record
        }
      
        for(ICRM_Contact_Relationship__c  RelPrc :RelListNew){
            ContSet.add(RelPrc.ICRM_Contact__c); 
        }
         
        
     //Get all active relationship records
     
     List<contact> UpdContList = new list<contact>();
     list<ICRM_Contact_Relationship__c> RelListPrc = new list<ICRM_Contact_Relationship__c>();
     RelListPrc = ([Select ICRM_R_Team__c,ICRM_Contact__c,ICRM_Active__c,ICRM_Relationship_Rating__c,ICRM_User_Name__c from ICRM_Contact_Relationship__c where ICRM_Active__c = true and ICRM_Contact__c in :ContSet ]); 
     
        for(Id contId:ContSet){
            Contact ContObj = new contact();
            String relUserId = ''; 
            String relUserTier = '';
            String relUserTeam = '';
            for(ICRM_Contact_Relationship__c ConRelProc:RelListPrc){
                if(ConRelProc.ICRM_Contact__c == contId){
                     relUserId = 
                         relUserId  
                         + ConRelProc.ICRM_Relationship_Rating__c 
                         + ConRelProc.ICRM_User_Name__c  ;
                   
                }
            }
            system.debug('relUserId'+ relUserId);
            ContObj.Id = contId;  
            ContObj.ICRM_All_Relationship_Id__c = relUserId; 
            UpdContList.add(ContObj);
             
        }
       // If list is having some value then update the contact object 
        If(UpdContList.size() > 0){
            try{
          update UpdContList; 
             
            }
            catch(exception exce){  //   String err_msg= exce.getMessage();   

                for(ICRM_Contact_Relationship__c aa: RelListNew){
 					aa.adderror('Maximum Number of Active Relationships Reached on Contact');
                }
            }
        }
    
    } // end ContactUpdate  
    
} // end of class