/* @author            Karishma Gurjar
*  @date              19th Feb, 2020
*  @description       handles trigger events on Notes object for IST CRM Project
*  @ -----------------------------------
*/
public class ICRM_NotesTriggerHandler extends BPG_Trigger_Handler_Utilities{
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    /* Create or Update note in custom Object ICRM Notes */    
    {
        List<ContentDocument> newRecordList= new List<ContentDocument>();
        List<ICRM_Notes__c> notesListToUpdate= new List<ICRM_Notes__c>();
        List<ICRM_Notes__c> notesListToInsert= new List<ICRM_Notes__c>();
        set<id> contentNoteIDSet= new set<id>();
        set<id> AccountIDSet= new set<id>();
        set<id> OpportunityIDSet= new set<id>();
        set<id> ContactIDSet= new set<id>();
        Map<Id,List<Id>> mapAccountNoteIds = new Map<Id,List<Id>>();
        newRecordList=n;
        map<id,id> mapNote=new map<id,id>();
        for(ContentDocument cd : newRecordList){
            contentNoteIDSet.add(cd.id); 
            
        }
        
        List<ContentDocumentLink>c1=new List<ContentDocumentLink>([SELECT Id, ContentDocumentId,  LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in:contentNoteIDSet]);		
        for(ContentDocumentLink cd: [SELECT Id, ContentDocumentId,  LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in:contentNoteIDSet]){
            if(String.valueof(cd.LinkedEntityId).startsWithIgnoreCase('001')){
                AccountIDSet.add(cd.LinkedEntityId);
            }
            if(String.valueof(cd.LinkedEntityId).startsWithIgnoreCase('006')){
                OpportunityIDSet.add(cd.LinkedEntityId);
            }
            if(String.valueof(cd.LinkedEntityId).startsWithIgnoreCase('003')){
                ContactIDSet.add(cd.LinkedEntityId);
            }
            if(mapAccountNoteIds.containskey(cd.ContentDocumentId)){
                mapAccountNoteIds.get(cd.ContentDocumentId).add(cd.LinkedEntityId);
                
            }
            else{
                mapAccountNoteIds.put(cd.ContentDocumentId,new List<id>{cd.LinkedEntityId});
            }
            
        }
        
        Map<id,Account>mapAccount=new Map<id,Account>([SELECT Id, recordtype.Name,BillingCountry FROM Account WHERE Id in:AccountIDSet]);	
        
        Map<id,Opportunity>mapOpportunity=new Map<id,Opportunity>([SELECT Id, recordtype.Name FROM Opportunity WHERE Id in:OpportunityIDSet]);	
        Map<id,Contact>mapContact=new Map<id,Contact>([SELECT Id, recordtype.Name FROM Contact WHERE Id in:ContactIDSet]);	
        
        for(ICRM_Notes__c noteSaved : [SELECT Id, ICRM_Note_ID__c from ICRM_Notes__c WHERE ICRM_Note_ID__c in: contentNoteIDSet]){
            
            mapNote.put(noteSaved.ICRM_Note_ID__c,noteSaved.id);
        } 
        
        for(ContentNote cn : [SELECT Id, Title,Content FROM ContentNote WHERE Id in:contentNoteIDSet]){
            if(!mapNote.IsEmpty() && mapNote.get(cn.id) != NULL){
                
                for(id i : mapAccountNoteIds.get(cn.id)){
                    if(i.getSobjectType().getDescribe().getName() == 'Account' && !mapAccount.IsEmpty() && ((mapAccount.get(i).recordtype.Name == 'IST Prospect') || (mapAccount.get(i).recordtype.Name == 'IST Legal Entity') || (mapAccount.get(i).recordtype.Name == 'IST_Group Account'))){
                        ICRM_Notes__c nt = new ICRM_Notes__c();
                        nt.id=mapNote.get(cn.id);
                        nt.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt.ICRM_Notes_Title__c=cn.Title;
                        nt.ICRM_Note_ID__c=cn.id;
                        nt.ICRM_Notes_Account__c=i;
                        nt.ICRM_Note_Account_Country__c=mapAccount.get(i).BillingCountry;
                        notesListToUpdate.add(nt);
                    }
                    if(i.getSobjectType().getDescribe().getName() == 'Opportunity' && !mapOpportunity.IsEmpty() && (mapOpportunity.get(i).recordtype.Name == 'IST Global Opportunity')){
                        ICRM_Notes__c nt = new ICRM_Notes__c();
                        nt.id=mapNote.get(cn.id);
                        nt.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt.ICRM_Notes_Title__c=cn.Title;
                        nt.ICRM_Note_ID__c=cn.id;	 
                        nt.ICRM_Notes_Opportunity__c=i;
                        notesListToUpdate.add(nt);
                    }
                    if(i.getSobjectType().getDescribe().getName() == 'Contact' && !mapContact.IsEmpty() && (mapContact.get(i).recordtype.Name == 'IST Contact')){
                        ICRM_Notes__c nt = new ICRM_Notes__c();
                        nt.id=mapNote.get(cn.id);
                        nt.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt.ICRM_Notes_Title__c=cn.Title;
                        nt.ICRM_Note_ID__c=cn.id; 
                        nt.ICRM_Notes_Contact__c=i;
                        notesListToUpdate.add(nt);
                    }
                }
                
            }
            
            if(mapNote.IsEmpty() || mapNote.get(cn.id) == NULL){
                for(id i : mapAccountNoteIds.get(cn.id)){
                    if(i.getSobjectType().getDescribe().getName() == 'Account' && !mapAccount.IsEmpty() && ((mapAccount.get(i).recordtype.Name == 'IST Prospect') || (mapAccount.get(i).recordtype.Name == 'IST Legal Entity') || (mapAccount.get(i).recordtype.Name == 'IST_Group Account'))){
                        ICRM_Notes__c nt1 = new ICRM_Notes__c();
                        nt1.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt1.ICRM_Notes_Title__c=cn.Title;
                        nt1.ICRM_Note_ID__c=cn.id;
                        nt1.ICRM_Notes_Account__c=i;
                        nt1.ICRM_Note_Account_Country__c=mapAccount.get(i).BillingCountry;
                        notesListToInsert.add(nt1);
                    }
                    if(i.getSobjectType().getDescribe().getName() == 'Opportunity' && !mapOpportunity.IsEmpty() && (mapOpportunity.get(i).recordtype.Name == 'IST Global Opportunity')){
                        ICRM_Notes__c nt1 = new ICRM_Notes__c();
                        nt1.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt1.ICRM_Notes_Title__c=cn.Title;
                        nt1.ICRM_Note_ID__c=cn.id;
                        nt1.ICRM_Notes_Opportunity__c=i;
                        notesListToInsert.add(nt1);
                    }
                    if(i.getSobjectType().getDescribe().getName() == 'Contact' && !mapContact.IsEmpty() && (mapContact.get(i).recordtype.Name == 'IST Contact')){
                        ICRM_Notes__c nt1 = new ICRM_Notes__c();
                        nt1.ICRM_Notes_Content__c=EncodingUtil.base64Decode(EncodingUtil.base64Encode(cn.Content)).toString().replaceAll('<[/a-zAZ0-9]*>','');
                        nt1.ICRM_Notes_Title__c=cn.Title;
                        nt1.ICRM_Note_ID__c=cn.id;
                        nt1.ICRM_Notes_Contact__c=i;
                        notesListToInsert.add(nt1);
                    }
                    
                }
                
            }
        }
        
        if(!notesListToUpdate.IsEmpty()){
            update notesListToUpdate;
        }
        if(!notesListToInsert.IsEmpty()){
            insert notesListToInsert;
        }
    }
    public override void afterDelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
        
    {
            /* Delete Note from custom Object ICRM Notes */    
        List<ContentDocument> oldRecordList= new List<ContentDocument>();
        List<ICRM_Notes__c> notesListToDelete= new List<ICRM_Notes__c>();
        set<id> contentNoteIDSet= new set<id>();
        map<id,id> mapNote=new map<id,id>();
        oldRecordList=o;
        for(ContentDocument cd : oldRecordList){
            contentNoteIDSet.add(cd.id); 
            
        }
        
        for(ICRM_Notes__c noteSaved : [SELECT Id, ICRM_Note_ID__c from ICRM_Notes__c WHERE ICRM_Note_ID__c in: contentNoteIDSet]){
            
            mapNote.put(noteSaved.ICRM_Note_ID__c,noteSaved.id);
        }
        for(ContentDocument cd : oldRecordList){
            if(!mapNote.IsEmpty()){
                
                ICRM_Notes__c nt = new ICRM_Notes__c();
                nt.id=mapNote.get(cd.id);
                notesListToDelete.add(nt);       
            }
        }
        if(!notesListToDelete.IsEmpty()){
            delete notesListToDelete;
        }
    }  
}