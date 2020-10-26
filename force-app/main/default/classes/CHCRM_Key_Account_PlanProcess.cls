/***********************************************************************************************
* @author           WuTong
* @date             2020/08/25
* @group            CHCRM
* @description      create this class for CHCRM_Key_Account_Plan_Trigger
* @test class       CHCRM_Key_Account_Plan_TriggerHandlerTest
* history
* 2020/08/25  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_Key_Account_PlanProcess {
    
    public static void checkKAPIsUniquene(List<CHCRM_Key_Account_Plan__c> newList){
        Set<Id> subChannedSet = new Set<Id>();
        for(CHCRM_Key_Account_Plan__c kap : newList){
            subChannedSet.add(kap.CHCRM_Sub_Channel_Account__c);
        }
        List<CHCRM_Key_Account_Plan__c> isNotWithdrawKapList = [SELECT Id , CHCRM_Year__c , CHCRM_Sub_Channel_Account__c FROM CHCRM_Key_Account_Plan__c 
                                                                WHERE CHCRM_Sub_Channel_Account__c IN:subChannedSet AND CHCRM_Status__c != 'Withdraw'];
        if(!isNotWithdrawKapList.isEmpty()){
            Map<String, List<CHCRM_Key_Account_Plan__c>> kapMap = new Map<String , List<CHCRM_Key_Account_Plan__c>>();
            for(CHCRM_Key_Account_Plan__c noWithdrawKap : isNotWithdrawKapList){
                String key = noWithdrawKap.CHCRM_Sub_Channel_Account__c+noWithdrawKap.CHCRM_Year__c;
                if(!kapMap.containsKey(key)){
                    kapMap.put(key , new List<CHCRM_Key_Account_Plan__c>{noWithdrawKap});
                }else{
                    kapMap.get(key).add(noWithdrawKap);
                }
            }
            for(CHCRM_Key_Account_Plan__c kap : newList){
                List<CHCRM_Key_Account_Plan__c> kapList = kapMap.get(kap.CHCRM_Sub_Channel_Account__c+kap.CHCRM_Year__c);
                if(kapList != null && !kapList.isEmpty()){
                    kap.addError('添加Key Account Plan失败， 因为当前Sub Channel Account已存在'+kap.CHCRM_Year__c+'年的Key Account Plan.');
                }
            }
        }
    }
    
    public static void bindleSalesTarget(List<CHCRM_Key_Account_Plan__c> newList){
        Set<Id> subChannelAccountSet = new Set<Id>();
        Set<String> yearSet = new Set<String>();
        for(CHCRM_Key_Account_Plan__c kap : newList){
            subChannelAccountSet.add(kap.CHCRM_Sub_Channel_Account__c);
            yearSet.add(kap.CHCRM_Year__c);
        }
        List<CHCRM_Sub_Channel_Account__c> subChannelAccountList = [SELECT Id , CHCRM_Account__c , CHCRM_Account__r.CHCRM_Key_Account_Flg__c, 
                                                                    (SELECT Id , CHCRM_Sub_Channel_Sub_Account_Code__c FROM CHCRM_Sub_Channel_Sub_Accounts__r)
                                                                    FROM CHCRM_Sub_Channel_Account__c WHERE Id IN:subChannelAccountSet];
        subChannelAccountSet = new Set<Id>();
        for(CHCRM_Sub_Channel_Account__c subChannel : subChannelAccountList){
            //if(subChannel.CHCRM_Account__r.CHCRM_Key_Account_Flg__c){
                subChannelAccountSet.add(subChannel.Id);
            //}
        }
        if(!subChannelAccountSet.isEmpty()){
            List<CHCRM_KAP_Sales_Target__c> salesTargetList = [SELECT Id , CHCRM_Key_Account_Plan__c, CHCRM_Year__c,
                                                               CHCRM_Sub_Channel_Sub_Account__c , CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Sub_Channel_Account__c
                                                               FROM CHCRM_KAP_Sales_Target__c 
                                                               WHERE CHCRM_Sub_Channel_Account__c IN:subChannelAccountSet 
                                                               AND CHCRM_Year__c IN:yearSet
                                                               AND CHCRM_Key_Account_Plan__c = ''
                                                              ];
            if(!salesTargetList.isEmpty()){
                Map<Id , List<CHCRM_KAP_Sales_Target__c>> salesTargetMap = new Map<Id , List<CHCRM_KAP_Sales_Target__c>>();
                for(CHCRM_KAP_Sales_Target__c salesTarget : salesTargetList){
                    String subChannelAccountId = salesTarget.CHCRM_Sub_Channel_Sub_Account__r.CHCRM_Sub_Channel_Account__c;
                    if(salesTargetMap.containsKey(subChannelAccountId)){
                        salesTargetMap.get(subChannelAccountId).add(salesTarget);
                    }else{
                        salesTargetMap.put(subChannelAccountId , new List<CHCRM_KAP_Sales_Target__c>{salesTarget});
                    }
                }
                System.debug('salesTargetMap :'+ salesTargetMap);
                List<CHCRM_KAP_Sales_Target__c> bindleList = new List<CHCRM_KAP_Sales_Target__c>();
                for(CHCRM_Key_Account_Plan__c kap : newList){
                    if(salesTargetMap.containsKey(kap.CHCRM_Sub_Channel_Account__c)){
                        for(CHCRM_KAP_Sales_Target__c salesTarget : salesTargetMap.get(kap.CHCRM_Sub_Channel_Account__c)){
                            if(salesTarget.CHCRM_Year__c == kap.CHCRM_Year__c){
                                salesTarget.CHCRM_Key_Account_Plan__c = kap.Id;
                                bindleList.add(salesTarget);
                            }
                        }
                    }
                }
                if(!bindleList.isEmpty()){
                    update bindleList;
                }
            }
        }
    }
    
    
}