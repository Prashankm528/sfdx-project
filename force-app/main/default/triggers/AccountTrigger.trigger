/**
 * @author Jan Majling
 * @date 25/07/2018
 * @description		triggers on Account object
 * 
 * history
 * 07/05/2019	OLCM
 */
trigger AccountTrigger on Account (before insert, before update, before delete, 
                                        after insert, after update, after delete, after undelete) {
                                            
    AccountTriggerHandler handler=new AccountTriggerHandler(Trigger.new,Trigger.old, Trigger.newMap, Trigger.oldMap);
    list<account> listAccNew=Trigger.new;
    list<account> listAccOld=Trigger.old; 
                                            
    if(trigger.isBefore && Trigger.isInsert){
        handler.handleBeforeInsert();   
        handler.beforeInsertUpdate();  
        handler.beforeInsertUpdatesf(); 			
    }
    if(trigger.isBefore && Trigger.isUpdate){
        handler.handleBeforeUpdate();
        handler.beforeInsertUpdate();  
        handler.beforeInsertUpdatesf(); 		   
    }
	if(Trigger.isAfter && Trigger.isUpdate){
		handler.handleAfterUpdate();
	}
	if(Trigger.isAfter && Trigger.isInsert){
		handler.handleAfterInsert();
	}
}