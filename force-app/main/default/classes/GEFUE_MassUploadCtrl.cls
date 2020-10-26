/*****************************************************************************************
*   Date:           27JULY20
*   Author:         Nilang Pandey – TCS (Tata Consultancy Services Ltd.)
*   Description:    Server-side controller for Mass Upload
*   Modifications:  
****************************************************************************************/
public with sharing class GEFUE_MassUploadCtrl {
    
    /**
    * Fetches file uploaded with csv data
    **/
    @AuraEnabled  
    public static List<GEFUE_Opportunity_Staging__c> fetchFiles(String recordId) {
        String csvDataStr = '';
        Set<Id> documentIds = new Set<Id>();
        List<GEFUE_Opportunity_Staging__c> lstOppStaging = new List<GEFUE_Opportunity_Staging__c>();
        List<ContentVersion> lstContVersion = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :recordId AND IsLatest = true];
        if (lstContVersion.size() > 0) {
            csvDataStr = lstContVersion[0].VersionData.toString();
            List<String> records = csvDataStr.split('\n(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
            List<List<String>> recordSets = new List<List<String>>();
            for (String record : records) {
                List<String> fields = record.split(',(?=(?:[^\\"]*\\"[^\\"]*\\")*[^\\"]*$)');
                List<String> values = new List<String>();
                for (String field : fields) {
                    if (String.isNotBlank(field)) {
                        field = field.trim();
                        if (field.substring(field.length() - 1, field.length()) == '"') {
                            field = field.substring(0, field.length() - 1);
                        }
                        if (field.substring(0, 1) == '"') {
                            field = field.substring(1, field.length());
                        }
                        // Replace Qualified Double Quotes
                        // With Single Double Quotes
                        field = field.replace('\"\"', '\"');
                    }
                    values.add(field);
                }
                recordSets.add(values);
            }
            
            if (recordSets.size() < 2) return null;
            
            List<String> lstHeaders = new List<String>();
            
            for (Integer i=0; i<recordSets.size(); i++) {
                if (i == 0) {
                    lstHeaders.add(recordSets[i][0]);
                    lstHeaders.add(recordSets[i][1]);
                    lstHeaders.add(recordSets[i][2]);
                    lstHeaders.add(recordSets[i][3]);
                    lstHeaders.add(recordSets[i][4]);
                    lstHeaders.add(recordSets[i][5]);
                    lstHeaders.add(recordSets[i][6]);
                    lstHeaders.add(recordSets[i][7]);
                    lstHeaders.add(recordSets[i][8]);
                } else if (i>0) {
                    GEFUE_Opportunity_Staging__c oppStage = new GEFUE_Opportunity_Staging__c();
                    oppStage.GEFUE_Package__c = recordSets[i][0];
                    oppStage.GEFUE_Account_Number__c = recordSets[i][1];
                    oppStage.GEFUE_Account_Name__c = recordSets[i][2];
                    oppStage.GEFUE_Site_Street__c = recordSets[i][3];
                    oppStage.GEFUE_Site_City__c = recordSets[i][4];
                    oppStage.GEFUE_Site_State__c = recordSets[i][5];
                    oppStage.GEFUE_DCA_NTI__c = recordSets[i][6];
                    oppStage.GEFUE_Stage__c = recordSets[i][7];
                    oppStage.GEFUE_Close_Date__c = recordSets[i][8];
                    oppStage.GEFUE_Terminal__c = recordSets[i][9];
                    oppStage.GEFUE_Terminal_Number__c = recordSets[i][10];
                    oppStage.GEFUE_Volume_Gas__c = recordSets[i][11].trim();
                    oppStage.GEFUE_Volume_Diesel__c = recordSets[i][12].trim();
                    oppStage.GEFUE_Image_Amount__c = recordSets[i][13].trim();
                    oppStage.GEFUE_CPG_Amount__c = recordSets[i][14].trim();
                    if (recordSets[i][15].trim() != '' && recordSets[i][15].trim() != NULL) {
                        oppStage.GEFUE_IRR__c = String.valueOf(Decimal.valueOf(recordSets[i][15].trim())/100);
                    } else {
                        oppStage.GEFUE_IRR__c = '';
                    }
                    oppStage.GEFUE_Status__c = System.Label.GEFUE_Not_Validated;
                    oppStage.GEFUE_Message__c = System.Label.GEFUE_Validate_This_Record;
                    lstOppStaging.add(oppStage);
                }
            }
            if (lstOppStaging.size() > 0) insert lstOppStaging;
        }
        return lstOppStaging;
    }
    
    /**
    * Updates Opportunity Staging records while inline edit saving
    **/
    @AuraEnabled
    public static List<GEFUE_Opportunity_Staging__c> inlineEditSave(List<GEFUE_Opportunity_Staging__c> oppStageRowsEdited, List<GEFUE_Opportunity_Staging__c>oppStageRows) {
        //System.debug('@@oppStageRowsEdited '+oppStageRowsEdited);
        for (GEFUE_Opportunity_Staging__c oppStagEdit : oppStageRowsEdited) {
            oppStagEdit.GEFUE_Status__c = System.Label.GEFUE_Not_Validated;
            oppStagEdit.GEFUE_Message__c = System.Label.GEFUE_Validate_This_Record;
        }
        update oppStageRowsEdited;
        Set<Id> setOppStagingId = new Set<Id>();
        for (GEFUE_Opportunity_Staging__c oppStageTemp : oppStageRows) {
            setOppStagingId.add(oppStageTemp.Id);
        }
        return fetchStagingRecordsInlineEdit(setOppStagingId);
    }
    

    /**
    * Validates all rows of Opportunity Staging table
    **/
    @AuraEnabled
    public static List<GEFUE_Opportunity_Staging__c> validateRows(List<GEFUE_Opportunity_Staging__c> oppStageRowstoValidate) {
        Map<Id, GEFUE_Opportunity_Staging__c> mapOppStagingValidate = new Map<Id, GEFUE_Opportunity_Staging__c>(oppStageRowstoValidate);
        Set<String> setAccNumber = new Set<String>();
        Set<String> setTerminalNumber = new Set<String>();
        List<Account> lstAccount = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber != NULL AND Business_Unit__c = 'Fuels North America'];
        for (Account acc : lstAccount) {
            setAccNumber.add(acc.AccountNumber);
        }
        List<GEFUE_Terminal__c> lstTerminals = [SELECT Id, GEFUE_Terminal_Number__c FROM GEFUE_Terminal__c WHERE GEFUE_Terminal_Number__c != NULL];
        for (GEFUE_Terminal__c term : lstTerminals) {
            setTerminalNumber.add(term.GEFUE_Terminal_Number__c);
        }
        
        for (GEFUE_Opportunity_Staging__c oppStageTemp : oppStageRowstoValidate) {
            Boolean requiredValuesNotBlank = validateRequiredFieldNotBlank(oppStageTemp);
            if (!requiredValuesNotBlank) {
                oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Required_Field_Error;
            } else {
                Boolean validDateFormat = validateDateFormat(oppStageTemp);
                if (!validDateFormat) {
                    oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                    oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Correct_Date_Format;
                } else {
                    Boolean accountNumberValid = validateAccountNumber(oppStageTemp, setAccNumber);
                    if (!accountNumberValid) {
                        oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                        oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Account_Number_Error_Message;
                    } else {
                        Boolean terminalNumberValid = validTerminalNumber(oppStageTemp, setTerminalNumber);
                        if (!terminalNumberValid) {
                            oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                            oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Terminal_Number_Error_Message;
                        } else {
                            Boolean stagesValid = validateStages(oppStageTemp);
                            if (!stagesValid) {
                                oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                                oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Stage_Error_Message;
                            } else {
                                Boolean volumeValid = validateVolumes(oppStageTemp);
                                if (!volumeValid) {
                                    oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                                    oppStageTemp.GEFUE_Message__c = 'Volume cannot be zero. Please give only a non-zero value or blank.';
                                } else {
                                    Boolean dcantiValid = validateDCANTI(oppStageTemp);
                                    if (!dcantiValid) {
                                        oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Error;
                                        oppStageTemp.GEFUE_Message__c = 'Please give proper value in DCA/NTI. Either DCA or NTI.';
                                    } else {
                                        oppStageTemp.GEFUE_Status__c = System.Label.GEFUE_Validated;
                                        oppStageTemp.GEFUE_Message__c = System.Label.GEFUE_Success_Validate;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        update oppStageRowstoValidate;
        return oppStageRowstoValidate;
    }
    
    /**
    * Queries and retrieves latest values on Opportunity Staging table
    **/
    public static List<GEFUE_Opportunity_Staging__c> fetchStagingRecordsInlineEdit(Set<Id> oppStagingId) {
        Map<String, Schema.SObjectField> fieldMap = GEFUE_Opportunity_Staging__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNames = fieldMap.keySet();
        List<String> fieldNamesStr = new List<String>(fieldNames);
        return Database.query('select ' + string.join(fieldNamesStr, ',') + ' from GEFUE_Opportunity_Staging__c WHERE Id IN :oppStagingId');
    }
    
    /**
    * Validates if required fields are not blank
    **/
    public static Boolean validateRequiredFieldNotBlank(GEFUE_Opportunity_Staging__c oppStage) {
        Boolean fieldsValid = true;
        if (String.isBlank(oppStage.GEFUE_Account_Number__c) || String.isBlank(oppStage.GEFUE_Account_Name__c) ||
            String.isBlank(oppStage.GEFUE_Site_Street__c) || String.isBlank(oppStage.GEFUE_Site_City__c) ||
            String.isBlank(oppStage.GEFUE_Site_State__c) || String.isBlank(oppStage.GEFUE_DCA_NTI__c) ||
            String.isBlank(oppStage.GEFUE_Stage__c) || String.isBlank(oppStage.GEFUE_Close_Date__c) ||
            String.isBlank(oppStage.GEFUE_Terminal__c) || String.isBlank(oppStage.GEFUE_Terminal_Number__c)) {
                fieldsValid = false;
            }
        return fieldsValid;
    }
    
    /**
    * Validates proper date format of Close Date
    **/
    public static Boolean validateDateFormat(GEFUE_Opportunity_Staging__c oppStage) {
        Boolean dateFormatValid = true;
        try {
            Date d = Date.valueOf(oppStage.GEFUE_Close_Date__c);
        } catch (Exception ex) {
            dateFormatValid = false;
        }
        return dateFormatValid;
    }
    
    /**
    * Validates if Account Number is present in Salesforce
    **/
    public static Boolean validateAccountNumber(GEFUE_Opportunity_Staging__c oppStagingToValidate, Set<String> setAccNumber) {
        Boolean validAccountNumber = true;
        if (oppStagingToValidate.GEFUE_Account_Number__c != NULL && oppStagingToValidate.GEFUE_Account_Number__c != '') {
            if (!setAccNumber.contains(oppStagingToValidate.GEFUE_Account_Number__c)) {
                validAccountNumber = false;
            }
        }
        return validAccountNumber;
    }
    
    /**
    * Validates if Terminal Number is present in Salesforce
    **/
    public static Boolean validTerminalNumber(GEFUE_Opportunity_Staging__c oppStagingToValidate, Set<String> setTerminalNumber) {
        Boolean validTerminalNumber = true;
        if (oppStagingToValidate.GEFUE_Terminal_Number__c != NULL && oppStagingToValidate.GEFUE_Terminal_Number__c != '') {
            if (!setTerminalNumber.contains(oppStagingToValidate.GEFUE_Terminal_Number__c)) {
                validTerminalNumber = false;
            }
        }
        return validTerminalNumber;
    }
    
    /**
    * Validates if mentioned Stage is correct
    **/
    public static Boolean validateStages(GEFUE_Opportunity_Staging__c oppStageValidate) {
        Set<String> setAllValidStages = new Set<String>{'lead', 'approve to brand', 'negotiation with customer', 'credit approval', 'supply approval', 'svb creation', 'contract execution', 'site branding', 'site live', 'closed - lost'};
        Boolean allStageValid = true;
        if (oppStageValidate.GEFUE_Stage__c != NULL && oppStageValidate.GEFUE_Stage__c != '') {
            if (!setAllValidStages.contains(oppStageValidate.GEFUE_Stage__c.toLowerCase())) {
                allStageValid = false;
            }
        }
        return allStageValid;
    }
    
    /**
    * Validates if the Volumes are non-zero
    **/
    public static Boolean validateVolumes(GEFUE_Opportunity_Staging__c oppStageValidate) {
        Boolean volumeValid = true;
        Boolean volumeValidGas = true;
        Boolean volumeValidDiesel = true;
        if (oppStageValidate.GEFUE_Volume_Diesel__c != '' && oppStageValidate.GEFUE_Volume_Diesel__c != NULL) {
            if (Decimal.valueOf(oppStageValidate.GEFUE_Volume_Diesel__c) == 0) {
                volumeValidDiesel = false;
            }
        }
        if (oppStageValidate.GEFUE_Volume_Gas__c != '' && oppStageValidate.GEFUE_Volume_Gas__c != NULL) {
            if (Decimal.valueOf(oppStageValidate.GEFUE_Volume_Gas__c) == 0) {
                volumeValidGas = false;
            }
        }
        if (!volumeValidDiesel || !volumeValidGas) {
            volumeValid = false;
        }
        return volumeValid;
    }

    /**
    * Validates if DCA/NTI values are properly inputted or not
    **/
    public static Boolean validateDCANTI(GEFUE_Opportunity_Staging__c oppDCANTIValidate) {
        Boolean validDCANTI = true;
        Set<String> setDCANTI = new Set<String>{'dca', 'nti'};
        if (oppDCANTIValidate.GEFUE_DCA_NTI__c != '' && oppDCANTIValidate.GEFUE_DCA_NTI__c != NULL) {
            if (!setDCANTI.contains(oppDCANTIValidate.GEFUE_DCA_NTI__c.toLowerCase())) {
                validDCANTI = false;
            }
        }
        return validDCANTI;
    }

    /**
    * Enqueues job to create package, site account, site opportunity and products
    **/
    @AuraEnabled
    public static String finalSubmitQueueable(List<GEFUE_Opportunity_Staging__c> lstOppStageFinal) {
        Set<String> setAccountNumber = new Set<String>();
        Set<String> setTerminalNumber = new Set<String>();
        for (GEFUE_Opportunity_Staging__c oppStageFinal : lstOppStageFinal) {
            setAccountNumber.add(oppStageFinal.GEFUE_Account_Number__c);
            setTerminalNumber.add(oppStageFinal.GEFUE_Terminal_Number__c);
        }
        
        ID jobID = System.enqueueJob(new GEFUE_CreateOpportunityQueueable(lstOppStageFinal, setAccountNumber, setTerminalNumber));
        return jobID;
    }
    
    /**
    * Checks job status and returns the current status
    **/
    @AuraEnabled
    public static String checkJobStatus(String jobId) {
        System.debug('@@jobId '+jobId);
        AsyncApexJob asyncJobTemp = [SELECT Id, Status, JobItemsProcessed, NumberofErrors, TotalJobItems FROM AsyncApexJob WHERE Id=:jobId];
        return asyncJobTemp.Status;
    }
    
    /**
    * To retrieve package id and redirect on submission
    **/
    @AuraEnabled
    public static String retrievePackageId(List<String> setOppStagingIds) {
        Set<String> setOppStageingIds = new Set<String>(setOppStagingIds);
        
        List<GEFUE_Opportunity_Staging__c> lstFinalOppStaging = [SELECT Id, GEFUE_Package__c, GEFUE_Opportunity_Id__c FROM GEFUE_Opportunity_Staging__c WHERE Id IN :setOppStageingIds];
        String siteOppPackId = '';
        String siteOppId = '';
        Boolean hasPackage = false;
        for(GEFUE_Opportunity_Staging__c oppStagingTemp : lstFinalOppStaging) {
            if (oppStagingTemp.GEFUE_Package__c != NULL && oppStagingTemp.GEFUE_Package__c != '') {
                siteOppPackId = oppStagingTemp.GEFUE_Opportunity_Id__c;
                hasPackage = true;
                break;
            }
            if (oppStagingTemp.GEFUE_Opportunity_Id__c != NULL && oppStagingTemp.GEFUE_Opportunity_Id__c != '') {
                siteOppId = oppStagingTemp.GEFUE_Opportunity_Id__c;
            }
        }
        if (hasPackage && siteOppPackId != '' && siteOppPackId != NULL) {
            Opportunity siteOpp = [SELECT Id, Name, GEFUE_Package__c FROM Opportunity WHERE Id = :siteOppPackId];
            return siteOpp.GEFUE_Package__c;
        }
        if (!hasPackage && siteOppId != '') {
            return siteOppId;
        }
        return '';
    }
}