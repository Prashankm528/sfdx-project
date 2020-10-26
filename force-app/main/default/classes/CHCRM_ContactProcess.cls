/***********************************************************************************************
* @author           DK
* @date             2020/08/20
* @group            CHCRM
* @description      handle contact business logic

* history
* 2020/08/20  DK  Created 
************************************************************************************************/
public with sharing class CHCRM_ContactProcess{
    public void syncDataToSurounding(List<Contact> contacts) {
        List<Id> conIdList = new List<Id>();
        for(Contact c : contacts) {
            conIdList.add(c.Id);
            //CHCRM_IntegrationUtility.sendContacts(contact.Id,'admin');
        }
        System.enqueueJob(new CHCRM_QueueableCalloutService(conIdList,'admin',''));
    }
}