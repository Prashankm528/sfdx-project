/***********************************************************************************************
* @author           Wipro
* @date             18/05/2020
* @description      testing class for DUP_CommunityMainViewCtrlLWC.apxc
************************************************************************************************/
@isTest
public class DUP_CommunityMainViewLWCTest {
    
    @TestSetup
    static void makeData(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'BP Base' Limit 1];
        String PositiveUserEmail = 'positive@controllertest.com';
        
        List<User> positiveUser = DUP_DataFactory.createUser(1, pf, PositiveUserEmail);
        insert positiveUser;
        
        system.runAs(positiveUser[0]){
            List<DUP_Counterparty_Contact__c> newCounterpartyContactList = DUP_DataFactory.createCounterPartyContact(positiveUser);
            insert newCounterpartyContactList;
            
            List<DUP_BP_Entity_Details__c> entityList = DUP_DataFactory.createBPEntity(1);
            insert entityList;
            
            List<DUP_Document_Request__c> newDocumentRequestList = DUP_DataFactory.createDocumentRequest(1,entityList);
            insert newDocumentRequestList;
            
            List<DUP_Document_Request__c> documentRequestToBePopulatedWithStores = new List<DUP_Document_Request__c>();
            documentRequestToBePopulatedWithStores.add(newDocumentRequestList[0]);
            List<DUP_Document_Store__c> newDocumentStoreList = DUP_DataFactory.createDocumentStore(documentRequestToBePopulatedWithStores,
                                                                                                   newCounterpartyContactList, 5);
            insert newDocumentStoreList;
        }
    }
    
    /**
* @description 	getDocumentStore positive test - gets document store where status is requested & correct user id
* @param
* @return
*/
    @isTest static void getDocumentStoreTestPositive(){
        List<DUP_Counterparty_Contact__c> contact = [select id from DUP_Counterparty_Contact__c limit 1];
        List<DUP_Document_Store__c> stores = [select id,DUP_Document_Status__c from DUP_Document_Store__c limit 1];
        List<DUP_Document_Request__c> requestList = [select id,DUP_Status_Upload__c from DUP_Document_Request__c limit 1];
        User positiveUser = [SELECT Id, 
                             Email
                             FROM User 
                             WHERE Email ='positive@controllertest.com' 
                            ];
        
        system.runAs(positiveUser){
            stores[0].DUP_Document_Status__c = 'Requested';
            stores[0].DUP_Counterparty_Contact_Name__c = contact[0].id;
            update stores;
            requestList[0].DUP_Status_Upload__c = 'DUP_Review_Upload';
            update requestList;
            
            new DUP_CommunityMainViewCtrlLWC();
            requestList = DUP_CommunityMainViewCtrlLWC.getRelatedRequests();
        }
        system.assertEquals(1,requestList.size());  
    }
    
}