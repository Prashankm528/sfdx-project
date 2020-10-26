/***********************************************************************************************
* @author           Xc
* @date             2020/06/23
* @group            CHCRM
* @description      handle account related business logic

* history
* 2020/06/23  Xc   Created 
* 2020/07/10 WuTong add Account assign Territory2
************************************************************************************************/
public with sharing class CHCRM_AccountProcess {

/*
    public void checkDuplicate() {

    }

    public void populateFields(List<Account> newAccounts,Map<Id,Account> oldMap) {
        List<String> cityIdList = new List<String>();
        for(Account acc : newAccounts) {
            if(Trigger.isUpdate) {
                if(acc.CHCRM_Ship_City__c != oldMap.get(acc.Id).CHCRM_Ship_City__c) {
                    cityIdList.add(acc.CHCRM_Ship_City__c);
                }
                if(acc.CHCRM_Reg_City__c != oldMap.get(acc.Id).CHCRM_Reg_City__c) {
                    cityIdList.add(acc.CHCRM_Reg_City__c);
                }
                if(acc.CHCRM_Biz_City__c != oldMap.get(acc.Id).CHCRM_Biz_City__c) {
                    cityIdList.add(acc.CHCRM_Biz_City__c);
                }
            } else if(Trigger.isInsert) {
                if(String.isNotBlank(acc.CHCRM_Ship_City__c)) {
                    cityIdList.add(acc.CHCRM_Ship_City__c);
                }
                if(String.isNotBlank(acc.CHCRM_Reg_City__c)) {
                    cityIdList.add(acc.CHCRM_Reg_City__c);
                }
                if(String.isNotBlank(acc.CHCRM_Biz_City__c)) {
                    cityIdList.add(acc.CHCRM_Biz_City__c);
                }
            }
        }
        //populated all province fields
        if(!cityIdList.isEmpty()) {
            this.pupulateProvince(newAccounts,cityIdList);
        }

    }


    public void pupulateProvince(List<Account> accounts,List<String> idList) {
        Map<String,String> idProvinceNameMap = new Map<String,String>();
        for(CHCRM_Geography__c geo : [SELECT Id,CHCRM_Province__r.Name FROM CHCRM_Geography__c WHERE ID IN :idList]) {
            idProvinceNameMap.put(geo.Id,geo.CHCRM_Province__r.Name);
        }

        for(Account acc : accounts) {
            if(idProvinceNameMap.containsKey(acc.CHCRM_Ship_City__c)) {
                acc.CHCRM_Ship_Province__c = idProvinceNameMap.get(acc.CHCRM_Ship_City__c);
            }
            if(idProvinceNameMap.containsKey(acc.CHCRM_Reg_City__c)) {
                acc.CHCRM_Reg_Province__c = idProvinceNameMap.get(acc.CHCRM_Reg_City__c);
            }
            if(idProvinceNameMap.containsKey(acc.CHCRM_Biz_City__c)) {
                acc.CHCRM_Biz_Province__c = idProvinceNameMap.get(acc.CHCRM_Biz_City__c);
            }
        }
    }*/
    
    //Account assign Territory2
    public void assignAccountToTerritory2(List<Account> newAccountList){
        System.debug('assignAccountToTerritory Start!');
        List<ObjectTerritory2Association> territory2List = new List<ObjectTerritory2Association>();
        Territory2 greaterChinaId = [select id from Territory2 where DeveloperName = 'Greater_China'];
        if(greaterChinaId == null){
            System.debug('System have no Greater China ! ');return;
        }
        for(Account acc : newAccountList){
            ObjectTerritory2Association territory2 = new ObjectTerritory2Association();
            territory2.Territory2Id = greaterChinaId.Id;
            territory2.ObjectId = acc.Id;
            territory2.AssociationCause = 'Territory2Manual';
            territory2List.add(territory2);
        }
        if(!territory2List.isEmpty()) {
            insert territory2List;
        }
        
    }
}