/**
 * @description       : Set of utility methods for ISTCP
 * @group             : 
 * @last modified on  : 07-29-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
public with sharing class ISTCP_Utilities {
    
    /**
    * @description Gets the data type of a given object
    * @param Object o 
    * @return string 
    **/
    public static string getType(Object o) {
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

    /**
    * @description Checks whether the current user has access to the provided feature or not.
    * @author sebas.canseco@slalom.com | 6/12/2020 
    * @param String featureName 
    * @return Boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean isFeatureAccessible(String featureName, String userId) {
        if (userId == null) {
            userId = UserInfo.getUserId();
        }
        ISTCP_Feature_Access__c[] featureAccess = [SELECT ISTCP_Feature__r.Name FROM ISTCP_Feature_Access__c WHERE ISTCP_User__c =: userId
                                            AND ISTCP_Feature__r.Name =: featureName];
        if (!featureAccess.isEmpty()) {
            return true;
        }
        return false;
    }

    /**
    * @description Returns custom metadata ISTCP_File_Type__mdt that the user has access to via ISTCP_Feature_Access__c records.
    * @author sebas.canseco@slalom.com | 07-23-2020 
    * @return List<ISTCP_File_Type__mdt> 
    **/
    @AuraEnabled(cacheable = true)
    public static List < ISTCP_File_Type__mdt > getDocumentTypes() {
        Set<String> filetypeSet = new Set<String>();
        
        for (ISTCP_Feature_Access__c access : [SELECT ISTCP_Feature__r.Name FROM ISTCP_Feature_Access__c WHERE ISTCP_User__c =: UserInfo.getUserId()]) {
            filetypeSet.add(access.ISTCP_Feature__r.Name);
        }
        
        ISTCP_File_Type__mdt[] fileTypeMappings = [SELECT MasterLabel FROM ISTCP_File_Type__mdt WHERE Parent_Type__c in: filetypeSet];
        
        return fileTypeMappings;
    }

    /**
    * @description Queries BP Number Entitlement for current user, optionally returning only BP Numbers having NAGP Endur Ids.
    * @author sebas.canseco@slalom.com | 7/20/2020 
    * @return List<ISTCP_BP_Number_Entitlement__c>
    **/
    @AuraEnabled(cacheable=true)
    public static List<ISTCP_BP_Number_Entitlement__c> getBPNumberEntitlements(String userId, Boolean mapByEndurId) {
        if (userId == null) {
            userId = UserInfo.getUserId();
        }

        Map<String, String> results = new Map<String, String>();
        if (mapByEndurId == true) {
            return [SELECT ISTCP_BP_Number__r.Name, ISTCP_BP_Number__r.ISTCP_NAGP_Endur_Id__c FROM ISTCP_BP_Number_Entitlement__c 
                                                            WHERE ISTCP_User__c =: userId AND ISTCP_BP_Number__r.ISTCP_NAGP_Endur_Id__c != null];
            
        } else {
            return [SELECT ISTCP_BP_Number__r.Name, ISTCP_BP_Number__r.ISTCP_NAGP_Endur_Id__c FROM ISTCP_BP_Number_Entitlement__c 
                                                            WHERE ISTCP_User__c =: userId];
        }
    }

    /**
    * @description Replaces values starting with $ on provided jsonString.
    * @author sebas.canseco@slalom.com | 07-23-2020 
    * @param String jsonString 
    * @param Map<String Object> parameters 
    * @return String 
    **/
    public static String generateJSONwithValues(String jsonString, Map<String, Object> parameters) {
        JSONGenerator gen = JSON.createGenerator(true);
        JSONParser parser = JSON.createParser(jsonString);
        String currentField;

        while (parser.nextToken() != null) {
            System.System.debug('Parsing request definition >>>>>');
            System.debug('getCurrentToken:' + parser.getCurrentToken());
            System.debug('getCurrentName:' + parser.getCurrentName());
            System.debug('currentField:' + currentField);
            System.debug('getText:' + parser.getText());
            
            switch on parser.getCurrentToken() {
                when START_OBJECT {
                    gen.writeStartObject();
                }
                when END_OBJECT {
                    gen.writeEndObject();
                }
                when START_ARRAY {
                    gen.writeStartArray();
                }
                when END_ARRAY {
                    gen.writeEndArray();
                }
                when FIELD_NAME {
                    currentField = parser.getCurrentName();
                    gen.writeFieldName(parser.getCurrentName());
                }
                when VALUE_STRING {
                    String value = parser.getText();
                    if (value.startsWith('$')) {
                        if (parameters.containsKey(currentField)) {
                            Object obj = parameters.get(currentField);
                            switch on ISTCP_Utilities.getType(obj) {
                                when 'Boolean' {
                                    gen.writeBoolean(Boolean.valueOf(obj));
                                }
                                when 'String' {
                                    gen.writeString(String.valueOf(obj));
                                }
                                when 'Date' {
                                    gen.writeDate(Date.valueOf(obj));
                                }
                                when 'Datetime' {
                                    gen.writeDateTime(Datetime.valueOf(obj));
                                }
                                when 'Time' {
                                    gen.writeTime((Time)obj);
                                }
                                when 'Integer' {
                                    gen.writeNumber(Integer.valueOf(obj));
                                }
                                when 'Long' {
                                    gen.writeNumber((Long)obj);
                                }
                                when 'Decimal' {
                                    gen.writeNumber((Decimal)obj);
                                }
                                when 'List' {
                                    // TO DO
                                }
                                when else {
                                    gen.writeObject(obj);
                                }
                            }
                        } else {
                            // This token wasn't provided as part of parameters so we pass null as Mulesoft 
                            // will remove null attributes to pass request without them to SharePoint
                            gen.writeNull();
                        }
                    } else {
                        gen.writeString(value);
                    }
                }
                when VALUE_NUMBER_INT {
                    gen.writeNumber(parser.getIntegerValue());
                }
                when VALUE_NUMBER_FLOAT {
                    gen.writeNumber(parser.getDecimalValue());
                }
                when VALUE_FALSE {
                    gen.writeBoolean(parser.getBooleanValue());
                }
                when VALUE_TRUE {
                    gen.writeBoolean(parser.getBooleanValue());
                }
                when VALUE_NULL {
                    gen.writeNull();
                }
                when VALUE_EMBEDDED_OBJECT {
                    // TO DO
                }
                when NOT_AVAILABLE {
                    // TO DO
                }
            }
        }

        System.debug('generated json: ' + gen.getAsString());
        return gen.getAsString();
    }
}