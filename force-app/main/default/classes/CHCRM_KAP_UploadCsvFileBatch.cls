/***********************************************************************************************
* @author           WuTong
* @date             2020/08/27
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_UploadCsvFiles_CMP batch
* @test class       CHCRM_KAP_UploadCsvFileBatchTest
* history
* 2020/08/27  WuTong  Created 
************************************************************************************************/
global with sharing class CHCRM_KAP_UploadCsvFileBatch implements Database.batchable<String>, Database.Stateful{
    
    global String pbvCsvHeader = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,Product Brand Variant,Error Message\n';
    
    global String skuCsvHeader = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SUB_CHANNEL_SUB_CODE,SKU code,Error Message\n';
    
    global String customGrpHeader = 'SUB_CHANNEL_ACCOUNT_CODE,Year,SKU code,Error Message\n';
    
    global String emails;
    
    global Blob csvFile;
    
    global Map <String, Integer > fieldNumberMap;
    
    global Boolean hasError;
    
    global Id uploadId;
    
    global CHCRM_Sales_Plan_Upload__c salesUpload;
    
    global List<String> emailList = new List<String>();
    
    global String templateType;
    
    global List<String> exceptionList = new List<String>();
    
    global Map<String , CHCRM_UploadFileMapping> mappingMap;
        
    global CHCRM_KAP_UploadCsvFileBatch(Blob csvFile,Id uploadId ,String emails , String templateType){
        // init Sales Target csv file
        this.csvFile = csvFile;
        //init Sales Target Upload Record Id
        this.uploadId = uploadId;
        //init Sales Target emails
        this.emails = emails;
        //check Sales Target email is Blank
        if(emails!=''&&!emails.split(';').isEmpty()){
            this.emailList = emails.split(';'); 
        }
        //init SalesTarget TemplateType        
        this.templateType = templateType;
        //find Upload Config By Sales Target templateType
        CHCRM_Data_Upload_Config__mdt configMapping;
        configMapping = [SELECT Id , CHCRM_Field_Mapping__c , CHCRM_Object_API_Name__c FROM CHCRM_Data_Upload_Config__mdt WHERE Label =:templateType limit 1];
        //convet Sales Target Upload config string to json
        List<CHCRM_UploadFileMapping> csvHeaderMappingList;
        csvHeaderMappingList = (List<CHCRM_UploadFileMapping>)System.JSON.deserialize(configMapping.CHCRM_Field_Mapping__c, List<CHCRM_UploadFileMapping>.class);
        //get Sales Target Mapping Map
        this.mappingMap = getMappingMap(csvHeaderMappingList);
        //Sales Target csv first row is header name
        this.fieldNumberMap = getHeaderMap(csvFile.toString().split('\n')[0].split(','));
        hasError = false;
    }
    
    global Iterable<String> Start(Database.batchableContext batchableContext){        
        return csvFile.toString().split('\n');
    }
    
    global void Execute(Database.BatchableContext batchableContext, List<String> scope){
        List<String> skuCodeList = new List<String>();
        List<String> productBrandNameList = new List<String>();
        List<String> subChannelCodeList = new List<String>();
        List<String> subChannelSubCodeList = new List<String>();
        Map<String ,String> subChannelAccountMap = new Map<String , String>();
        try{
            for(Integer i = 1; i < scope.size(); i++){
                List<String> rowValue = scope[i].split(',');
                if(!checkIsNotBlank(rowValue)){
                    continue;
                }
                String subChannel = rowValue[fieldNumberMap.get('SUB_CHANNEL_ACCOUNT_CODE')].trim();
                subChannelCodeList.add(subChannel);
                if(templateType == 'PBV'){
                    String productBrandName = rowValue[fieldNumberMap.get('Product Brand Variant')].trim();
                    productBrandNameList.add(productBrandName);
                    String subChannelSubCode = rowValue[fieldNumberMap.get('SUB_CHANNEL_SUB_CODE')].trim();
                    subChannelSubCodeList.add(subChannelSubCode);
                }
                if(templateType == 'SKU'){
                    String skuCode = rowValue[fieldNumberMap.get('SKU code')].trim();
                    skuCodeList.add(skuCode);
                    String subChannelSubCode = rowValue[fieldNumberMap.get('SUB_CHANNEL_SUB_CODE')].trim();
                    subChannelSubCodeList.add(subChannelSubCode);
                }
                if(templateType == 'CustomerGrp'){
                    String skuCode = rowValue[fieldNumberMap.get('SKU code')].trim();
                    skuCodeList.add(skuCode);
                }
            }        
            List<CHCRM_Sub_Channel_Account__c> subChannelList = [SELECT ID , CHCRM_Sub_Channel_Account_Code__c FROM CHCRM_Sub_Channel_Account__c WHERE CHCRM_Sub_Channel_Account_Code__c in:subChannelCodeList];
            Set<Id> subChannelIdSet = new Set<Id>();
            for(CHCRM_Sub_Channel_Account__c sub: subChannelList){
                subChannelIdSet.add(sub.Id);
                subChannelAccountMap.put(sub.CHCRM_Sub_Channel_Account_Code__c , sub.Id);
            }
            List<CHCRM_Key_Account_Plan__c> kapList = [SELECT Id , CHCRM_Sub_Channel_Account__c ,CHCRM_Sub_Channel_Account__r.CHCRM_Sub_Channel_Account_Code__c ,CHCRM_Year__c , CHCRM_Sub_Channel_Account__r.CHCRM_Account__r.CHCRM_Key_Account_Flg__c FROM CHCRM_Key_Account_Plan__c 
                                                       WHERE CHCRM_Sub_Channel_Account__c IN:subChannelIdSet AND CHCRM_Status__c != 'Withdraw'];
            Map<String , List<CHCRM_Key_Account_Plan__c>> kapMap = new Map<String , List<CHCRM_Key_Account_Plan__c>>();
            for(CHCRM_Key_Account_Plan__c kap : kapList){
                if(kapMap.containsKey(kap.CHCRM_Sub_Channel_Account__r.CHCRM_Sub_Channel_Account_Code__c)){
                    kapMap.get(kap.CHCRM_Sub_Channel_Account__r.CHCRM_Sub_Channel_Account_Code__c).add(kap);
                }else{
                    kapMap.put(kap.CHCRM_Sub_Channel_Account__r.CHCRM_Sub_Channel_Account_Code__c , new List<CHCRM_Key_Account_Plan__c>{kap});
                }
            }
            
            List<CHCRM_Sub_Channel_Sub_Account__c> subChaneelSubAccountList = [SELECT CHCRM_Sub_Channel_Sub_Account_Code__c,
                                                                               		  Id
                                                                                 FROM CHCRM_Sub_Channel_Sub_Account__c 
                                                                                WHERE CHCRM_Sub_Channel_Sub_Account_Code__c IN:subChannelSubCodeList];
            Map<String , Id> subChannelSubAccountMap = new Map<String,Id>();
            for(CHCRM_Sub_Channel_Sub_Account__c subAccount : subChaneelSubAccountList){
                subChannelSubAccountMap.put(subAccount.CHCRM_Sub_Channel_Sub_Account_Code__c , subAccount.Id);
            }
            Map<String , Id> pbvMap = new Map<String , Id>();
            if(templateType == 'PBV'){
                List<CHCRM_PBV_Detail__c> pbvs = [SELECT ID ,
                                                            Name 
                                                       FROM CHCRM_PBV_Detail__c 
                                                      WHERE Name in:productBrandNameList];            
                for(CHCRM_PBV_Detail__c pbv : pbvs){
                    pbvMap.put(pbv.Name,
                               pbv.Id);
                }
            }
            Map<String , Id> skuMap = new Map<String , Id>();
            if(templateType == 'CustomerGrp' || templateType == 'SKU' ){
                List<CHCRM_SKU_Detail__c> skus = [SELECT ID ,CHCRM_SKU_Code__c FROM CHCRM_SKU_Detail__c WHERE CHCRM_SKU_Code__c in:skuCodeList];            
                for(CHCRM_SKU_Detail__c sku : skus){
                    skuMap.put(sku.CHCRM_SKU_Code__c,sku.Id);
                }
            }
            
            List<CHCRM_KAP_Sales_Target__c> resultUpsertList = new List<CHCRM_KAP_Sales_Target__c>();
            //second row start 
            for(Integer i = 1; i < scope.size(); i++){
                List<String> rowValue = scope[i].split(',');
                if(!checkIsNotBlank(rowValue)){
                    continue;
                }
                CHCRM_KAP_Sales_Target__c salesTarget = new CHCRM_KAP_Sales_Target__c();
                String errorMessage = '';
                
                String subChannelName = rowValue[fieldNumberMap.get('SUB_CHANNEL_ACCOUNT_CODE')].trim();
                String blankMsg = 'SUB_CHANNEL_ACCOUNT_CODE 不能为空;';
                String notMappingMsg = '根据 SUB_CHANNEL_ACCOUNT_CODE 匹配不到 Sub Channel Account!';
                if(String.isBlank(subChannelName)){
                    errorMessage = errorMessage 
                        			+ blankMsg;
                }                
                if(subChannelAccountMap.containsKey(subChannelName)){
                     salesTarget.CHCRM_Sub_Channel_Account__c = subChannelAccountMap.get(subChannelName);   
                }else{
                    errorMessage = errorMessage 
                        		   + notMappingMsg;
                }
                Boolean hasKap = false;
                String year = rowValue[fieldNumberMap.get('Year')].trim();   
                if(kapMap.containsKey(subChannelName)){
                    List<CHCRM_Key_Account_Plan__c> kapMapList = kapMap.get(subChannelName);                                 
                    if(!kapMapList.isEmpty()){            
                        for(CHCRM_Key_Account_Plan__c kap : kapMapList){
                            //if(kap != null && year == kap.Year__c && kap.CHCRM_Sub_Channel_Account__r.CHCRM_Account__r.CHCRM_Key_Account_Flg__c){
                            if(kap != null && year == kap.CHCRM_Year__c){
                                salesTarget.CHCRM_Key_Account_Plan__c = kap.Id;
                                hasKap = true;
                                continue;
                            }
                        }
                    }
                }                
                /*if(!hasKap){
                    errorMessage = errorMessage + '根据 SUB_CHANNEL_ACCOUNT_CODE 与 Year 匹配不到唯一的KAP;'; 
                }*/                      
                if('PBV' == templateType){
                    String productBrandName = rowValue[fieldNumberMap.get('Product Brand Variant')].trim();
                    String errMessage = '根据 Product Brand Variant 查询不到唯一的记录;';
                    String notBlankMsg = 'Product Brand Variant 不能为空;';
                    if(!String.isBlank(productBrandName)){
                        Id pbvId = pbvMap.get(productBrandName);
                        if(String.isNotBlank(pbvId)){
                            salesTarget.CHCRM_PBV__c = pbvId;
                        }else{
                            errorMessage = errorMessage 
                                           + errMessage;
                        }
                    }else{
                        errorMessage = errorMessage + notBlankMsg;
                    }                
                }            
                if(templateType == 'SKU' 
                   || templateType == 'CustomerGrp'){
                    String skuCode = rowValue[fieldNumberMap.get('SKU code')].trim();
                    if(String.isBlank(skuCode)){
                        errorMessage = errorMessage + 'SKU code 不能为空;';
                    }else{
                        Id skuId = skuMap.get(skuCode);
                        if(String.isNotBlank(skuId)){
                            salesTarget.CHCRM_SKU_Detail__c = skuId;
                        }else{
                            errorMessage = errorMessage + '根据 SKU code 查询不到唯一的记录;';
                        } 
                    }
                }
                if(templateType == 'PBV' 
                   || templateType == 'SKU'){
                    checkSubChannelSubAccount(errorMessage, 
                                              salesTarget,
                                              subChannelSubAccountMap,
                                              rowValue,
                                              fieldNumberMap); 
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
                            salesTarget.put(mapping.field , value ); 
                        }else if(mapping.fieldType == 'Decimal'){
                            try{
                                salesTarget.put(mapping.field , Decimal.valueOf(value).setscale(2,System.RoundingMode.UP)); 
                            }catch(Exception e){
                                errorMessage = errorMessage + (mapping.columnName + '应当填写数字类型;');
                            }                            
                        }                   
                    }                           
                }
                //记录通过校验 可以插入到系统中
                if(String.isBlank(errorMessage)){
                    if(templateType == 'PBV'){
                        salesTarget.CHCRM_Category__c = 'PBV'; 
                    }else if(templateType == 'SKU' || templateType == 'CustomerGrp'){
                        salesTarget.CHCRM_Category__c = 'SKU';  
                    }
                    resultUpsertList.add(salesTarget);
                }else{
                    //错误处理
                    hasError = true;
                    
                    if(templateType == 'PBV'){
                        String subChannelSubAccountName = rowValue[fieldNumberMap.get('SUB_CHANNEL_SUB_CODE')].trim();
                        String productBrandName = rowValue[fieldNumberMap.get('Product Brand Variant')].trim();
                        pbvCsvHeader = pbvCsvHeader +subChannelName+','+year+','+ subChannelSubAccountName+ ',' +productBrandName+','+errorMessage+'\n';
                    }else if(templateType == 'SKU'){
                        String skuCode = rowValue[fieldNumberMap.get('SKU code')].trim();
                        String subChannelSubAccountName = rowValue[fieldNumberMap.get('SUB_CHANNEL_SUB_CODE')].trim();
                        skuCsvHeader = skuCsvHeader + subChannelName +','+year+',' + subChannelSubAccountName + ','+skuCode+','+errorMessage+'\n';
                    }else if(templateType == 'CustomerGrp'){
                        String skuCode = rowValue[fieldNumberMap.get('SKU code')].trim();
                        customGrpHeader = customGrpHeader + subChannelName +','+ year + ',' + skuCode + ','+errorMessage+'\n';
                    }
                }
            }
            if(resultUpsertList.size() >0){
                insert resultUpsertList;
            }
        }catch(Exception e){
            exceptionList.add(e.getStackTraceString());
        }
    }
    
    global void Finish(Database.BatchableContext batchableContext){
        // get current User
        User curUser = [SELECT Id ,Email,Name FROM User WHERE Id =:UserInfo.getUserId() limit 1];
        //init mail Object        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //find CHCRM_Sales_Plan_Upload__c by Id
        CHCRM_Sales_Plan_Upload__c salesUpload = [SELECT Id , CHCRM_Status__c ,CHCRM_Comments__c , CHCRM_Notification_Email__c 
                                                  From CHCRM_Sales_Plan_Upload__c WHERE Id =:uploadId];
        String emailBody = 'Dear '+ curUser.Name + ' <p/>';
        //error deal
        if(hasError){
            //init Attachment
            Attachment attachment = new Attachment();
            String nowFormat = System.now().format('YYYY-MM-DD HH:mm:ss');
            attachment.Name = templateType + nowFormat +'_Error_List.csv';
            attachment.ParentId = uploadId;
            attachment.Description = curUser.Name +' Upload '+templateType+ 'Error Message';
            attachment.ContentType = 'text/plain; charset=UTF-8';
            //add csv to Attachment
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob;
            if(templateType == 'PBV'){
                csvBlob = Blob.valueOf('\uFEFF'+pbvCsvHeader);
            }else if(templateType == 'SKU'){
                csvBlob = Blob.valueOf('\uFEFF'+skuCsvHeader);                
            }else{
                csvBlob = Blob.valueOf('\uFEFF'+customGrpHeader); 
            }
            attachment.Body = csvBlob;
            string csvname= 'Data_Error_List.csv';
            //add csv to mail 
            //set csv fileName
            csvAttc.setFileName(csvname);
            //set csv content
            csvAttc.setBody(csvBlob);
            //set UTF-8
            csvAttc.setContentType('text/csv; charset=UTF-8');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            emailBody = emailBody +  '存在异常的数据没有导入成功，详情请参考附件！<p/>';
            salesUpload.CHCRM_Status__c = 'Failure'; 
            insert attachment;
        }
        if(exceptionList.size() > 0 ){
            salesUpload.CHCRM_Status__c = 'Failure';
            emailBody = emailBody + '发生了系统级别异常，请联系管理员！<p/>';
            String comments = '';
            //add exception message to upload record
            for(String exceptionMsg : exceptionList){
                emailBody = emailBody + exceptionMsg + ';<p/> ';
                comments = comments + exceptionMsg + ';';
            }
            //add error message to comments
            salesUpload.CHCRM_Comments__c = comments;
        }
        //set error mail content
        if(!hasError && exceptionList.size() == 0){
            emailBody = emailBody +  '所有的数据已经成功导入系统中！';
            salesUpload.CHCRM_Status__c = 'Completed';            
        }
        salesUpload.CHCRM_Notification_Email__c = emails;
        //update upload record
        update salesUpload;
        //add current user email
        emailList.add(curUser.Email);
        mail.setToAddresses(emailList);
        mail.setSubject('销售目标导入 结果通知');        
        mail.setBccSender(false);
        mail.setUseSignature(false);
        //set email body
        mail.setHtmlBody(emailBody);
        //send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
    
    private static Boolean checkIsNotBlank(List<String> rowValue){
        if(String.isBlank(rowValue[0].trim()) && String.isBlank(rowValue[1].trim()) && String.isBlank(rowValue[2].trim())){
            return false;   
        }
        return true;
    }
    
    
    private static Map< String, Integer > getHeaderMap(List<String> header){
        Map < String, Integer > fieldNumberMap = new Map < String, Integer >();
        for(Integer i = 0; i < header.size(); i++){
            fieldNumberMap.put(header[i].trim(), i);
        }
        return fieldNumberMap;
    }
    
    private static Map<String , CHCRM_UploadFileMapping> getMappingMap(List<CHCRM_UploadFileMapping> csvHeaderMappingList){
        Map<String , CHCRM_UploadFileMapping> mappingMap = new Map<String , CHCRM_UploadFileMapping>();
        for(CHCRM_UploadFileMapping item : csvHeaderMappingList){
            mappingMap.put(item.columnName , item);
        }
        return mappingMap;
    }
    
    private static void checkSubChannelSubAccount(String errorMessage , CHCRM_KAP_Sales_Target__c salesTarget 
                                                  ,Map<String , Id> subChannelSubAccountMap , List<String> rowValue ,
                                                  Map <String, Integer > fieldNumberMap){
        String subChannelSubAccountName = rowValue[fieldNumberMap.get('SUB_CHANNEL_SUB_CODE')].trim();
        if(String.isBlank(subChannelSubAccountName)){
            errorMessage = errorMessage + 'SUB_CHANNEL_SUB_CODE 不能为空;';
        }else{
            Id subId = subChannelSubAccountMap.get(subChannelSubAccountName);
            if(String.isNotBlank(subId)){
                salesTarget.CHCRM_Sub_Channel_Sub_Account__c = subId;
            }else{
                errorMessage = errorMessage + '根据 SUB_CHANNEL_SUB_CODE 查询不到唯一的记录;';
            }
        }
    }
    
}