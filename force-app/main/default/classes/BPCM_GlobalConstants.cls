/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: Class that contains all global constants used across BPCM apex classes.
* @name BPCM_GlobalConstants.cls
*/

public inherited sharing class BPCM_GlobalConstants {
   
    //project prefix
    public static final String BPCM_PREFIX = 'BPCM';
    public static final String CS_BUSINESS_UNIT = 'CS';
    
    //profiles
    public static final String BPCM_BASE_PROFILE = 'BPCM Base';

    //Case Touch History
    public static final String CHT_INB_CALLS_FIELD_APINAME = 'BPCM_Inbound_Calls__c';
    public static final String CHT_OUT_CALLS_FIELD_APINAME = 'BPCM_Outbound_Calls__c';
    public static final String CHT_OUT_EMAILS_FIELD_APINAME = 'BPCM_Outbound_Emails__c';
    public static final String CHT_OUT_SOCIAL_FIELD_APINAME = 'BPCM_Outbound_Social_Posts__c';
    public static final String CHT_TRANSFERS_FIELD_APINAME = 'BPCM_Tranfers__c';
    public static final String CHT_COMMENTS_FIELD_APINAME = 'BPCM_Comments__c';
    public static final String CHT_CASE_UPDATE_FIELD_APINAME = 'BPCM_Case_Updates__c';
    public static final String CHT_TASKS_FIELD_APINAME = 'BPCM_Tasks__c';

    //Case
    public static final String CASE_SOBJECT_TYPE = 'Case';
    public static final String CASE_ORIGIN_EMAIL = 'Email';
    public static final String CASE_ORIGIN_PHONE_CALL = 'Phone Call';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String CASE_STATUS_ASSIGNED = 'Assigned';

    //Taks
    public static final String TK_INB_CALL_TYPE = 'Call-Inbound';
    public static final String TK_OUT_CALL_TYPE = 'Call-Outbound';
    public static final String TK_LOG_CALL_TYPE_INB = 'Inbound';
    public static final String TK_OTHER_TYPE = 'Other';
    public static final String TK_CALL_REC_TYPE = 'BPCM_Call';
    public static final String TK_TASK_REC_TYPE = 'BPCM_Task';
    public static final String TK_STATUS_COMPLETED = 'Completed';
    public static final String TK_SUBTYPE_CALL = 'Call';

    //BPCM Settings custom metadata type
    public static final String SET_CASE_FIELDS_CHECK_UP = 'BPCM_Count_Case_Updates';
    
    //Record Type Names
    public static final string BPCM_CONTACT_RECORDTYPE ='BPCM_Contact';
    public static final string BPCM_LOCATION_RECORDTYPE ='BPCM_Location';
    
}