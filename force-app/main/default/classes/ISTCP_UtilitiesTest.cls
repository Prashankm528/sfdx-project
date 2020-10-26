@isTest
public with sharing class ISTCP_UtilitiesTest {

    @TestSetup
    static void makeData(){
        ISTCP_Feature__c enabledFeature = new ISTCP_Feature__c(Name = 'test enabled feature');
        ISTCP_Feature__c disabledFeature = new ISTCP_Feature__c(Name = 'test disabled feature');
        insert new List<ISTCP_Feature__c>{enabledFeature, disabledFeature};
        insert new  ISTCP_Feature_Access__c(ISTCP_Feature__c = enabledFeature.Id, ISTCP_User__c = UserInfo.getUserId());


        Account acc = new Account(Name = 'test account');
        insert acc;
        ISTCP_BP_Number__c bpNumber = new ISTCP_BP_Number__c(Name = 'testBPNumber', ISTCP_Account__c = acc.Id, ISTCP_Active_Flag__c = true, ISTCP_NAGP_Endur_Id__c = 'testEndurId');
        insert bpNumber;
        ISTCP_BP_Number_Entitlement__c entitlement = new ISTCP_BP_Number_Entitlement__c(ISTCP_BP_Number__c = bpNumber.Id, ISTCP_User__c = UserInfo.getUserId());
        insert entitlement;
    }
    
    @IsTest
    static void isFeatureAccessible() {
        System.assertEquals(true, ISTCP_Utilities.isFeatureAccessible('test enabled feature', null), 'Feature should be accessible but it is not');
        System.assertEquals(false, ISTCP_Utilities.isFeatureAccessible('test disabled feature', null), 'Feature should NOT be accessible but it is');

        System.assertEquals(true, ISTCP_Utilities.isFeatureAccessible('test enabled feature', UserInfo.getUserId()), 'Feature should be accessible but it is not');
        System.assertEquals(false, ISTCP_Utilities.isFeatureAccessible('test disabled feature', UserInfo.getUserId()), 'Feature should NOT be accessible but it is');
    }

    @IsTest
    static void getBPNumberEntitlements(){
        List<ISTCP_BP_Number_Entitlement__c> bpNumberEntitlements = ISTCP_Utilities.getBPNumberEntitlements(UserInfo.getUserId(), true);
        System.assertEquals('testEndurId', bpNumberEntitlements[0].ISTCP_BP_Number__r.ISTCP_NAGP_Endur_Id__c, 'testEndurId is not associated to any BP Number record of the current user');
        bpNumberEntitlements = ISTCP_Utilities.getBPNumberEntitlements(UserInfo.getUserId(), false);
        System.assertEquals(1, bpNumberEntitlements.size());
    }

    @IsTest
    static void getType(){
        
        Object obj;
        System.assertEquals('', ISTCP_Utilities.getType(obj));
        obj = (Object) new Account();
        System.assertEquals('Account', ISTCP_Utilities.getType(obj));
        obj = true;
        System.assertEquals('Boolean', ISTCP_Utilities.getType(obj));
        obj = [SELECT Id FROM ApexClass WHERE Name = 'ISTCP_UtilitiesTest'].Id;
        System.assertEquals('Id', ISTCP_Utilities.getType(obj));
        obj = 'some string';
        System.assertEquals('String', ISTCP_Utilities.getType(obj));
        obj = Blob.valueof('some string');
        System.assertEquals('Blob', ISTCP_Utilities.getType(obj));
        obj = Date.today();
        System.assertEquals('Date', ISTCP_Utilities.getType(obj));
        obj = System.now();
        System.assertEquals('Datetime', ISTCP_Utilities.getType(obj));
        obj = Time.newInstance(1, 2, 3, 4);
        System.assertEquals('Time', ISTCP_Utilities.getType(obj));
        obj = 1;
        System.assertEquals('Integer', ISTCP_Utilities.getType(obj));
        obj = 2147483648L;
        System.assertEquals('Long', ISTCP_Utilities.getType(obj));
        obj = 1.2;
        System.assertEquals('Decimal', ISTCP_Utilities.getType(obj));
        obj = new List<Object>{obj};
        System.assertEquals('List', ISTCP_Utilities.getType(obj));
    }

    @IsTest
    static void generateJSONwithValues(){
        Object obj = 10;
        Map<String, Object> parameters = new Map<String, Object> {
            'booleanField' => true,
            'stringField' => 'text',
            'dateField' => Date.newInstance(1960, 2, 17),
            'dateTimeField' => DateTime.newInstance(1997, 1, 31, 7, 8, 16),
            'timeField' => Time.newInstance(1, 2, 3, 4),
            'integerField' => 123,
            'longField' => 2147483648L,
            'decimalField' => 1.5,
            'objectField' => obj
        };

        String jsonString =
        '{'
            + '"result" : ['
                + '{"booleanField" : "$value"},'
                + '{"stringField" : "$value"},'
                + '{"dateField" : "$value"},'
                + '{"dateTimeField" : "$value"},'
                + '{"timeField" : "$value"},'
                + '{"integerField" : "$value"},'
                + '{"longField" : "$value"},'
                + '{"decimalField" : "$value"},'
                + '{"objectField" : "$value"},'
                + '{"numberField" : 123},'
                + '{"floatField" : 1.5},'
                + '{"falseField" : false},'
                + '{"trueField" : true},'
                + '{"nullField" : null}'
            + ']'
        + '}';

        System.assertNotEquals(null, ISTCP_Utilities.generateJSONwithValues(jsonString, parameters));
    }
}