public without sharing class ISTCP_FileUploadController {

    /**
    * @description Queries ISTCP_Feature_Access__c for current user.
    * @author Ravi Potla | 6/12/2020 
    * @return List<ISTCP_File_Type__mdt>
    **/
    @AuraEnabled(cacheable = true)
    public static List < ISTCP_File_Type__mdt > fetchPickListValue() {
        Set<String> filetypeSet = new Set<String>();
        system.debug('userloggedin:' + UserInfo.getUserId());
        for(ISTCP_Feature_Access__c access : [Select ISTCP_Feature__r.Name from ISTCP_Feature_Access__c where ISTCP_User__c =: UserInfo.getUserId()]){
            filetypeSet.add(access.ISTCP_Feature__r.Name);
        }
        ISTCP_File_Type__mdt[] fileTypeMappings = [SELECT MasterLabel FROM ISTCP_File_Type__mdt where Parent_Type__c in: filetypeSet];
        return fileTypeMappings;
    }

    /**
    * @description Queries ISTCP_BP_Number_Entitlement__c for current user.
    * @author Ravi Potla | 6/12/2020 
    * @return List<ISTCP_BP_Number_Entitlement__c>
    **/
    @AuraEnabled(cacheable = true)
    public static List < ISTCP_BP_Number_Entitlement__c > fetchBPNumberPickListValue() {
        system.debug('userloggedin:' + UserInfo.getUserId());
        ISTCP_BP_Number_Entitlement__c[] bpNumbers = [SELECT ISTCP_BP_Number__r.Name FROM ISTCP_BP_Number_Entitlement__c where ISTCP_User__c =: UserInfo.getUserId()];
        return bpNumbers;
    }

    /**
    * @description Queries ISTCP_Frequency__c set for BP number selected.
    * @author Ravi Potla | 6/12/2020 
    * @return List<ISTCP_Frequency__c>
    **/
    @AuraEnabled(cacheable = true)
    public static List < ISTCP_Frequency__c > fetchDueDayPickListValue(String bpNumber) {
        system.debug('userloggedin:' + UserInfo.getUserId());
        ISTCP_Frequency__c[] dueDays = [SELECT ISTCP_Period__c FROM ISTCP_Frequency__c where ISTCP_Counterparty__r.Name =: bpNumber];
        return dueDays;
    }
    
    /**
    * @description Create ISTCP Log record, ContentVersion and ContentDocumentLink.
    * @author Ravi Potla | 6/12/2020 
    * @return ContentVersion
    **/
    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, String base64Data, String fileType, String bpNumber, String period) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        system.debug('filetypevalue:' + fileType + 'BPNumbervalue:' + bpNumber + 'recordIdvalue:' + idParent);
        ISTCP_Log__c log = new ISTCP_Log__c();
        log.ISTCP_BP_Number__c = bpNumber;
        log.ISTCP_Document_Type__c = fileType;
        log.ISTCP_Status__c = 'Ready to be Picked';
        log.ISTCP_Period__c = period;
        log.ISTCP_Uploaded_By__c = UserInfo.getUserId();
        insert log;

        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;

        //get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = log.Id;
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        insert conDocLink;
        return cv;
    }

}