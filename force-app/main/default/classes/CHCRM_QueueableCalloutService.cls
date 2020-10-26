/***********************************************************************************************
* @author           Xc
* @date             2020/09/16
* @group            CHCRM
* @description      handle call out

* history
* 2020/09/16  Xc  Created 
************************************************************************************************/
public with sharing class CHCRM_QueueableCalloutService implements Queueable,Database.AllowsCallouts {
    private List<Id> calloutIdList;
    private String token;
    private String type;

    public CHCRM_QueueableCalloutService(List<Id> pIdList, String pToken, String pType) {
        this.calloutIdList = pIdList;
        this.token = pToken;
        this.type = pType;
    }

    public void execute(QueueableContext context) {
        System.debug('*** calloutIdList' + calloutIdList);
        if(!calloutIdList.isEmpty() && calloutIdList.size() > 0) {
            Integer counter = 0;
            for(Integer i = calloutIdList.size(); i > 0; i--) {
                if(counter > 49) {
                    break;
                }
                Id objId = calloutIdList.get(0);
                String objName = objId.getSObjectType().getDescribe().getName();
    
                if(objName == 'CHCRM_HQ_Monthly_Assgmnt_Obj__c') {
                    CHCRM_IntegrationUtility.sendMonthlyObjectives(objId,token);
                } else if (objName == 'CHCRM_HQ_Monthly_Assgmnt__c') {
                    CHCRM_IntegrationUtility.sendMonthlyAssignments(objId,token);
                } else if (objName == 'Event') {
                    if(type == 'delete') {
                        System.debug('@@@-->Delete Event');
                        CHCRM_IntegrationUtility.sendDelEvent(objId,token);
                    } else {
                        CHCRM_IntegrationUtility.sendEvent(objId,token);
                    }
                } else if (objName == 'Contact') {
                    CHCRM_IntegrationUtility.sendContacts(objId,token);
                } else if (objName == 'CHCRM_WSP_Yearly_Stats__c') {
                    CHCRM_IntegrationUtility.sendWorkshopYearlyStats(objId,token);
                } else if (objName == 'CHCRM_WSP_Yearly_SalesRef__c') {
                    CHCRM_IntegrationUtility.sendWorkshopSalesReferences(objId,token);
                }
                calloutIdList.remove(0);
                counter++;
            }
            if(!Test.isRunningTest()) {
                System.enqueueJob(new CHCRM_QueueableCalloutService(calloutIdList,token,type));
            }
        }
    }
}