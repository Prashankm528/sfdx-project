/*******************************************************************************************************************************************************
* Description : Apex Controller for Survey Opt Out Lightning Component. Used for opt out contacts with the same email address. 

*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------       
* 2017-AUG-09   1.0                 Frantisek Kolacny   Initial version 
* 2017-AUG-22   1.1                 Grant Whitfield     CASSFO-1955 : Now 'without sharing' and limited search for all contacts to use DeduplicationId
/********************************************************************************************************************************************************/
public without sharing class CALCF_OptOutContactController {
	
	/***********************************************************************************
    * getEmail 
    * ------------------------
    * Method will return email address of Contact.
    ***********************************************************************************/
    @AuraEnabled
    public static String getEmail(String recordId) {
    	
    	Contact con = [SELECT Email FROM Contact WHERE id =: recordId];
    	return con.Email;

    }
    
    /***********************************************************************************
    * isOptedOut 
    * ------------------------
    * Method will true if contact is opted out.
    ***********************************************************************************/
    @AuraEnabled
    public static boolean isOptedOut(String recordId) {
    	
    	Contact con = [SELECT Survey_Opt_Out__c FROM Contact WHERE id =: recordId];
    	return con.Survey_Opt_Out__c;

    }
    
    /***********************************************************************************
    * hasAnEmail 
    * ------------------------
    * Method will return true if contact have email populated.
    ***********************************************************************************/
    @AuraEnabled
    public static boolean hasAnEmail(String recordId) {
    	
    	Contact con = [SELECT Email FROM Contact WHERE id =: recordId];
    	if(con.Email == null || con.Email.trim() == ''){
    		return false; 
    	}else{
    		return true;
    	}

    }
	
	/***********************************************************************************
    * optOut 
    * ------------------------
    * Method will opt out all contacts with the same email address, where a DeduplicationId
    * is present. DeduplicationId is only for Castrol / Lubes contacts. 
    ***********************************************************************************/
    @AuraEnabled
    public static boolean optOut(String recordId) {
    	
    	Contact con = [SELECT Email, Survey_Opt_Out__c FROM Contact WHERE id =: recordId];
    	
    	if(con.Email == null || con.Email == ''){
    		con.Survey_Opt_Out__c = true;
    		update con;
    		return true;
    	}
    	
    	List<Contact> allContactsToOptOut = [SELECT Id, Survey_Opt_Out__c FROM Contact WHERE Email =: con.Email AND Contact_Deduplication_Id__c != ''];
    	List<Contact> contactToUpdate = new List<Contact>();
    	
    	for(Contact c : allContactsToOptOut){
    		c.Survey_Opt_Out__c = true;
    		contactToUpdate.add(c);
    	}
    	
    	try{
    		update contactToUpdate;
    		return true;    		
    	}catch (Exception ex){
    		return false;
    	}

    }
    
    /***********************************************************************************
    * checkPermissionSet 
    * ------------------------
    * Method will check if user have permission set and rights to Opt Out Contact.
    * Will return true if yes, false if no.
    ***********************************************************************************/
    @AuraEnabled
    public static boolean checkPermissionSet() {
    	
    	String permissionSetName = lcf_settings__c.getInstance().CX_Op_Manager_Permission_Set_Name__c;
    	String userId = UserInfo.getUserId();
    	List<PermissionSetAssignment> permission = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =:permissionSetName AND AssigneeId =:userId];
    	
    	if(permission.size() == 1){
    		return true;    		
    	}else{
    		return false;
    	}
    }
    
}