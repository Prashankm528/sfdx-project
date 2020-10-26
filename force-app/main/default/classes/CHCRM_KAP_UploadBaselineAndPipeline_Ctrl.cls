/***********************************************************************************************
* @author           WuTong
* @date             2020/09/11
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_UploadBaselineAndPipeline_CMP
*@test class        CHCRM_KAP_UploadBaselineAndPipeline_CtrlTest
* history
* 2020/09/11  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_UploadBaselineAndPipeline_Ctrl {
    
     @AuraEnabled
    public static Boolean checkRoleCanView(){
        for(Profile p : [select id from profile where PermissionsModifyAllData = true]){
            if(p.Id == UserInfo.getProfileId()){
                return true;
            }
        }
        String type = 'BaselineAndPipeline';
        List<CHCRM_Upload_Permission_Control__mdt> controls = [SELECT Id , CHCRM_Type__c , Role_DevName__c, CHCRM_Is_Include_subordination__c FROM CHCRM_Upload_Permission_Control__mdt WHERE CHCRM_Type__c=:type];
        UserRole role = [Select u.Name , u.DeveloperName, u.Id from UserRole u WHERE u.id =:UserInfo.getUserRoleId() LIMIT 1];
        if(!controls.isEmpty()){
            for(CHCRM_Upload_Permission_Control__mdt control : controls){
                if(control.CHCRM_Is_Include_subordination__c){
                    if(CHCRM_RoleHierarchyUtils.isParentRoleSubordination(control.Role_DevName__c ,role.Id)){
                        return true;
                    }
                }else{
                    if(control.Role_DevName__c == role.DeveloperName){
                        return true;
                    }
                }             
            }
        }        
        return false;
    }
    
    @AuraEnabled
    public static void uploadFile(Blob file , String emails , String templateType , String kapId){
        String [] csvContent = file.toString().split('\n');
        CHCRM_Sales_Plan_Upload__c salesUpload = new CHCRM_Sales_Plan_Upload__c();
        salesUpload.CHCRM_Template_Name__c = templateType;
        salesUpload.OwnerId = UserInfo.getUserId();
        insert salesUpload;
        Datetime now = System.now();
        createFile(file, salesUpload.Id , templateType , now); 
        //调用Batch解析csv
        Database.executeBatch(new CHCRM_KAP_UploadBaseAndPipeLineBatch(file,salesUpload.Id ,emails.trim() ,templateType , kapId), 500);
    }
    
    
    private static void createFile (Blob fileBody, String campaignId , String templateType ,Datetime now) {
        User curUser = [SELECT ID , Name FROM User WHERE Id =:UserInfo.getUserId()];
        String nowFormat = now.format('YYYY-MM-DD HH:mm:ss');
        Attachment uploadFile = new Attachment();
        uploadFile.Body = fileBody;
        uploadFile.Name = templateType + nowFormat +'.csv';
        uploadFile.ParentId = campaignId;
        uploadFile.Description = curUser.Name +' Upload '+templateType+ ' at ' + nowFormat;
        uploadFile.ContentType = 'text/plain; charset=UTF-8';
        insert uploadFile;
    }
    
    
}