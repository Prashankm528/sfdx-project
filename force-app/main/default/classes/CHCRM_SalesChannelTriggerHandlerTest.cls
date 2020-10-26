/* @author            WuTong
*  @date              07/06/2020
*  @description       Test CHCRM_SalesChannelTriggerHandler
*
*
*  history
*  2020/07/06  WuTong  Created 
*/

@isTest
private with sharing class CHCRM_SalesChannelTriggerHandlerTest {
    @testSetup
    static void initData(){
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test To B Direct Customer';
        accountList.add(acc1);
        Account acc2 = new Account();
        acc2.Name = 'Test Distributor';
        accountList.add(acc2);
        Account acc3 = new Account();
        acc3.Name = 'Test Service Direct Customer';
        accountList.add(acc3);
        Account acc4 = new Account();
        acc4.Name = 'Test DSP';
        accountList.add(acc4);
        insert accountList;        
    }
    
    private static testMethod void testbeforeInsert1(){
        CHCRM_Sales_Channel__c channel = new CHCRM_Sales_Channel__c();
        Account account = [Select Id ,Name FROM Account where Name = 'Test To B Direct Customer'];
        channel.CHCRM_TOB_Direct_Customer__c = account.Id;
        insert channel;
        CHCRM_Sales_Channel__c resultChannel = [Select Id , CHCRM_Direct_Customer__c From CHCRM_Sales_Channel__c where id =:channel.Id ];
        System.assertEquals(account.Id, resultChannel.CHCRM_Direct_Customer__c);
    }
    
    
    private static testMethod void testbeforeInsert2(){
        CHCRM_Sales_Channel__c channel = new CHCRM_Sales_Channel__c();
        Account account = [Select Id ,Name FROM Account where Name = 'Test Distributor'];
        channel.CHCRM_Distributor__c = account.Id;
        insert channel;
        CHCRM_Sales_Channel__c resultChannel = [Select Id , CHCRM_Direct_Customer__c From CHCRM_Sales_Channel__c where id =:channel.Id ];
        System.assertEquals(account.Id, resultChannel.CHCRM_Direct_Customer__c);
    }
    
    
    private static testMethod void testbeforeInsert3(){
        CHCRM_Sales_Channel__c channel = new CHCRM_Sales_Channel__c();
        Account account = [Select Id ,Name FROM Account where Name = 'Test Service Direct Customer'];
        channel.CHCRM_Service_Direct_Customer__c = account.Id;
        insert channel;
        CHCRM_Sales_Channel__c resultChannel = [Select Id , CHCRM_Direct_Customer__c From CHCRM_Sales_Channel__c where id =:channel.Id ];
        System.assertEquals(account.Id, resultChannel.CHCRM_Direct_Customer__c);
    }
    
    
    private static testMethod void testbeforeInsert4(){
        CHCRM_Sales_Channel__c channel = new CHCRM_Sales_Channel__c();
        Account account = [Select Id ,Name FROM Account where Name = 'Test Service Direct Customer'];
        channel.CHCRM_DSP__c = account.Id;
        insert channel;
        CHCRM_Sales_Channel__c resultChannel = [Select Id , CHCRM_Direct_Customer__c From CHCRM_Sales_Channel__c where id =:channel.Id ];
        System.assertEquals(account.Id, resultChannel.CHCRM_Direct_Customer__c);
    }
    
    
    private static testMethod void testbeforeUpdate(){
        CHCRM_Sales_Channel__c channel = new CHCRM_Sales_Channel__c();
        Account account = [Select Id ,Name FROM Account where Name = 'Test Service Direct Customer'];
        channel.CHCRM_DSP__c = account.Id;
        insert channel;
        CHCRM_Sales_Channel__c editChannel = [SELECT ID , CHCRM_JDE_Code__c FROM CHCRM_Sales_Channel__c WHERE ID =:channel.Id];
        editChannel.CHCRM_JDE_Code__c = 'Test update Channel';
        update editChannel;
        CHCRM_Sales_Channel__c resultChannel = [Select Id , CHCRM_Direct_Customer__c From CHCRM_Sales_Channel__c where id =:channel.Id ];
        System.assertEquals(account.Id, resultChannel.CHCRM_Direct_Customer__c);
    }
    


}