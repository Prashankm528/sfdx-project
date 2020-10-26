/***********************************************************************************************
* @author           Xc
* @date             2020/03/27
* @group            CHCRM
* @description      handle CHCRM Event(Visit Detail) related business logic
* @Test Class       CHCRM_VisitDetailTriggerHandlerTest
* history
* 2020/05/22  Xc  Created 
************************************************************************************************/
public with sharing class CHCRM_VisitDetailProcess {

    public final String CHCRM_REGION_CER = 'CER';
    public final String CHCRM_REGION_CWR = 'CWR';
    public final String CHCRM_REGION_CNR = 'CNR';
    public final String CHCRM_REGION_CSR = 'CSR';
    public final String CHCRM_REGION_CER_VALUE = System.Label.CHCRM_Event_Region_CER;
    public final String CHCRM_REGION_CWR_VALUE = System.Label.CHCRM_Event_Region_CWR;
    public final String CHCRM_REGION_CNR_VALUE = System.Label.CHCRM_Event_Region_CNR;
    public final String CHCRM_REGION_CSR_VALUE = System.Label.CHCRM_Event_Region_CSR;


    public void poupulateRegion(List<CHCRM_Event__c> newVistDetails) {
        Set<String> ownerIdSet = new Set<String>();
        Map<String,String> userIdRegionMap = new Map<String,String>();

        for(CHCRM_Event__c detail : newVistDetails) {
            ownerIdSet.add(detail.OwnerId);
        }

        for(User u : [SELECT Id,UserRole.DeveloperName FROM User WHERE Id IN:ownerIdSet]) {
            String tempRegion = '';
            if(String.isNotBlank(u.UserRole.DeveloperName)) {
                if(u.UserRole.DeveloperName.contains(CHCRM_REGION_CER)) {
                    tempRegion = CHCRM_REGION_CER_VALUE;
                } else if(u.UserRole.DeveloperName.contains(CHCRM_REGION_CWR)) {
                    tempRegion = CHCRM_REGION_CWR_VALUE;
                } else if(u.UserRole.DeveloperName.contains(CHCRM_REGION_CNR)) {
                    tempRegion = CHCRM_REGION_CNR_VALUE;
                } else if(u.UserRole.DeveloperName.contains(CHCRM_REGION_CSR)) {
                    tempRegion = CHCRM_REGION_CSR_VALUE;
                } else {
                    tempRegion = '';
                }
            }
            userIdRegionMap.put(u.Id,tempRegion);
        }

        for(CHCRM_Event__c detail : newVistDetails) {
            if(userIdRegionMap.containsKey(detail.OwnerId)) {
                detail.CHCRM_Region__c = userIdRegionMap.get(detail.OwnerId);
            } else {
                detail.CHCRM_Region__c = '';
            }
        }
    }
}