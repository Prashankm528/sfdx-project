/* @author            WuTong
*  @date              07/06/2020
*  @description       Test CHCRM_AccountTriggerHandler   
*/

@isTest
private with sharing class CHCRM_AccountTriggerHandlerTest {
    
/*    
    @testSetup
    static void initData(){
       CHCRM_Geography__c province = new CHCRM_Geography__c();
       province.Name = 'Test Pprovince';
       insert province;
       CHCRM_Geography__c geo = new CHCRM_Geography__c();
       geo.CHCRM_Active__c = true;
       geo.CHCRM_Province__c = province.Id;
       geo.Name = 'Test';
       insert geo;
    }
    
    
    private static testMethod void testbeforeInsert(){
        CHCRM_Geography__c geo = [SELECT ID , CHCRM_Province__r.Name FROM CHCRM_Geography__c WHERE Name = 'Test'];
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Test CHCRMworkAccount');
        acc.Name = 'Test Account';
        acc.CHCRM_Ship_City__c = geo.Id;
        acc.CHCRM_Reg_City__c = geo.Id;
        acc.CHCRM_Biz_City__c = geo.Id;
        insert acc;
        Account result = [SELECT ID , CHCRM_Ship_Province__c , CHCRM_Reg_Province__c , CHCRM_Biz_Province__c FROM Account where id =:acc.Id];
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Ship_Province__c);
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Reg_Province__c);
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Biz_Province__c);
    }
    
    
    private static testMethod void testbeforeUpdate(){
        CHCRM_Geography__c geo = [SELECT ID , CHCRM_Province__r.Name FROM CHCRM_Geography__c WHERE Name = 'Test'];
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Test CHCRMworkAccount');
        acc.Name = 'Test Account';
        insert acc;
        Account updateAcc = new Account();
        updateAcc.Id = acc.Id;
        updateAcc.CHCRM_Ship_City__c = geo.Id;
        updateAcc.CHCRM_Reg_City__c = geo.Id;
        updateAcc.CHCRM_Biz_City__c = geo.Id;
        update updateAcc;
        Account result = [SELECT ID , CHCRM_Ship_Province__c , CHCRM_Reg_Province__c , CHCRM_Biz_Province__c FROM Account where id =:acc.Id];
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Ship_Province__c);
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Reg_Province__c);
        System.assertEquals(geo.CHCRM_Province__r.Name, result.CHCRM_Biz_Province__c);
    }
*/
    
    private static testMethod void testAssignAccountToTerritory2(){
        Account acc = CHCRM_TestSetup.createWorkshopAccount('Test CHCRMworkAccount');
        acc.Name = 'Test Account';
        insert acc;
        ObjectTerritory2Association result = [SELECT ID , AssociationCause , SobjectType FROM ObjectTerritory2Association WHERE ObjectId =:acc.Id];
        System.assertEquals('Territory2Manual', result.AssociationCause);
        System.assertEquals('Account', result.SobjectType);
    }
    
    
}