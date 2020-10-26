/***********************************************************************************************
* @author           WuTong
* @date             2020/09/11
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_UploadBaselineAndPipeline_CMP
*@test class        CHCRM_KAP_UploadBaseAndPipeLineBatchTest
* history
* 2020/09/11  WuTong  Created 
************************************************************************************************/
global with sharing class CHCRM_KAP_UploadBaseAndPipeLineBatch implements Database.batchable<String>, Database.Stateful{
    global Blob csvFile;
    
    global CHCRM_Sales_Plan_Upload__c salesUpload;
    
    global List<String> emailList = new List<String>();
    
    global String templateType;
    
    global Map<String , CHCRM_UploadFileMapping> mappingMap;
    
    global Map <String, Integer > fieldNumberMap;
    
    global Boolean hasError;
    
    global Id uploadId;
    
    global String csvHeader = '生产线,设备编号,数量,Error Message\n';        
    
    global List<String> exceptionList = new List<String>();
    
    global String emails;
    
    global String kapId;
    
    global CHCRM_KAP_UploadBaseAndPipeLineBatch(Blob csvFile,Id uploadId ,String emails , String templateType , String kapId){
        // init Baseline and pipeline csv file
        this.csvFile = csvFile;
        //init Baseline and pipeline Upload Record Id
        this.uploadId = uploadId;
        //init Baseline and pipeline emails
        this.emails = emails;
        //init kap 
        this.kapId = kapId;
        //init Baseline and pipeline email
        if(emails!=''){
            if(!emails.split(';').isEmpty()){
            	this.emailList = emails.split(';'); 
            }
        }
        //init Baseline and pipeline TemplateType        
        this.templateType = templateType;
        //find Upload Config By templateType
        CHCRM_Data_Upload_Config__mdt config = [SELECT Id ,
                                                              CHCRM_Field_Mapping__c , 
                                                              CHCRM_Object_API_Name__c 
                                                         FROM CHCRM_Data_Upload_Config__mdt 
                                                        WHERE Label =:templateType 
                                                        limit 1];
        //convet config string to json
        List<CHCRM_UploadFileMapping> csvHeaderMappingList = (List<CHCRM_UploadFileMapping>)System.JSON.deserialize(config.CHCRM_Field_Mapping__c, 
                                                                                                                    List<CHCRM_UploadFileMapping>.class);
        this.mappingMap = getUploadMappingMap(csvHeaderMappingList);
        //csv first row is header name
        this.fieldNumberMap = getHeaderMap(csvFile.toString()
                                           .split('\n')[0]
                                           .split(','));
        hasError = false;
    }
    
    private static Map<String , CHCRM_UploadFileMapping> getUploadMappingMap(List<CHCRM_UploadFileMapping> headerList){
        Map<String , CHCRM_UploadFileMapping> mappingMap = new Map<String , CHCRM_UploadFileMapping>();
        for(CHCRM_UploadFileMapping item : headerList){
            mappingMap.put(item.columnName,
                           item);
        }
        return mappingMap;
    }
    
    private static Map< String, Integer > getHeaderMap(List<String> header){
        Map < String, Integer > fieldNumberMap = new Map < String, Integer >();
        for(Integer i = 0; i < header.size(); i++){
            fieldNumberMap.put(header[i].trim(), i);
        }
        return fieldNumberMap;
    }
    
    private static Boolean checkIsNotBlank(List<String> rowValue){
        if(String.isBlank(rowValue[0].trim()) && String.isBlank(rowValue[1].trim()) && String.isBlank(rowValue[2].trim())){
            return false;   
        }
        return true;
    }
    
    global Iterable<String> Start(Database.batchableContext context){        
        return csvFile.toString().split('\n');
    }
    
    global void Execute(Database.BatchableContext context, List<String> scope){
        try{            
            List<sObject> upsertList = new List<sObject>();
            //second row start 
            for(Integer i = 1; i < scope.size(); i++){
                List<String> rowValue = scope[i].split(',');
                if(!checkIsNotBlank(rowValue)){
                    continue;
                }
                String errorMessage = '';
                sObject obj ;
                if(templateType == 'Baseline'){
                    obj = new CHCRM_KAP_Baseline__c();
                }else if(templateType == 'Pipeline'){
                    obj = new CHCRM_KAP_Pipeline__c();
                }             
                //直接映射字段处理
                for(String key : mappingMap.keySet()){
                    CHCRM_UploadFileMapping mapping = mappingMap.get(key);
                    String value = rowValue[fieldNumberMap.get(mapping.columnName)].trim();
                    if(mapping.isRequired && String.isBlank(value)){
                        errorMessage = errorMessage + (mapping.columnName + '不能为空;');
                    }else{
                        if(String.isBlank(value)){
                            continue;
                        }
                        if(mapping.fieldType == 'String'){
                            obj.put(mapping.field , value );                                 
                            
                        }else if(mapping.fieldType == 'Decimal'){
                            try{
                                obj.put(mapping.field, 
                                        Decimal.valueOf(value).setscale(2,System.RoundingMode.UP));                                 
                            }catch(Exception e){
                                errorMessage = errorMessage 
                                               + (mapping.columnName + '应当填写数字类型;');
                            }
                            
                        }                   
                    }                           
                }
                //记录通过校验 可以插入到系统中
                if(String.isBlank(errorMessage)){
                    obj.put('CHCRM_Key_Account_Plan__c',kapId);
                    obj.put('CHCRM_Fill_Date__c',System.today());
                    upsertList.add(obj);
                }else{
                    //错误处理
                    hasError = true;
                    String pruductLine = rowValue[fieldNumberMap.get('生产线/风场')].trim();
                    String code = rowValue[fieldNumberMap.get('设备编号')].trim();
                    String amount = rowValue[fieldNumberMap.get('数量')].trim();
                    csvHeader = csvHeader 
                                + pruductLine 
                        		+ ',' + code 
                        		+ ',' + amount 
                        		+ ','+ errorMessage 
                        		+ '\n';                    
                }
            }
            if(upsertList.size() > 0){
                insert upsertList;
            }
        }catch(Exception e){
            exceptionList.add(e.getStackTraceString());
        }
    }
    
    global void Finish(Database.BatchableContext batchableContext){
        User ur = [SELECT Id,
                               Name,
                        	   Email
                          FROM User 
                         WHERE Id =:UserInfo.getUserId() 
                         limit 1];        
        Messaging.SingleEmailMessage sml = new Messaging.SingleEmailMessage();
        CHCRM_Sales_Plan_Upload__c salesUpload = [SELECT Id, 
                                                         CHCRM_Notification_Email__c,
                                                  		 CHCRM_Status__c ,
                                                         CHCRM_Comments__c
                                                    FROM CHCRM_Sales_Plan_Upload__c 
                                                   WHERE Id =:uploadId];
        String emailBody = 'Dear '
            				+ ur.Name 
             				+ ' <p/>';
        
        if(hasError){
            string errMsg = '存在异常的数据没有导入成功，详情请参考附件！<p/>';
            Attachment att = new Attachment();
            String nowFormat = System.now().format('YYYY-MM-DD HH:mm:ss');
            att.Name = templateType + nowFormat +'_Error_List.csv';
            att.ParentId = uploadId;
            att.Description = ur.Name 
                				+ ' Upload '
                                + templateType 
                				+ 'Error Message';
            att.ContentType = 'text/plain; charset=UTF-8';
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf('\uFEFF'+csvHeader);
            att.Body = csvBlob;
            string cname= 'Data_Error_List.csv';
            csvAttc.setContentType('text/csv; charset=UTF-8');
            csvAttc.setBody(csvBlob);
            csvAttc.setFileName(cname);
            sml.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            emailBody = emailBody + errMsg;
            salesUpload.CHCRM_Status__c = 'Failure'; 
            insert att;
        }
        if(exceptionList.size() > 0 ){
            salesUpload.CHCRM_Status__c = 'Failure';
            emailBody = emailBody + '发生了系统级别异常，请联系管理员！<p/>';
            String comments = '';
            for(String exceptionMsg : exceptionList){
                emailBody = emailBody 
                    		+ exceptionMsg 
                    		+ ';<p/> ';
                comments = comments 
                    		+ exceptionMsg 
                    		+ ';';
            }
            salesUpload.CHCRM_Comments__c = comments;
        }
        if(!hasError && exceptionList.size() == 0){
            emailBody = emailBody +  '所有的数据已经成功导入系统中！';
            salesUpload.CHCRM_Status__c = 'Completed';            
        }
        salesUpload.CHCRM_Notification_Email__c = emails;
        update salesUpload;
        emailList.add(ur.Email);
        sml.setHtmlBody(emailBody);
              
        sml.setBccSender(false);
        sml.setSubject(templateType + '导入 结果通知'); 
        sml.setUseSignature(false);
        
        sml.setToAddresses(emailList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sml });       
    }
    

    

}