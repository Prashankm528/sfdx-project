public without sharing class DUP_CommunityMainViewCtrlLWC {
    public DUP_CommunityMainViewCtrlLWC() {

    }

    @AuraEnabled(cacheable=true)
    public static List<DUP_Document_Request__c> getRelatedRequests() {
        Id contactId = [Select id from DUP_Counterparty_Contact__c where dup_email__c=:UserInfo.getUserEmail() ].Id;
        List<DUP_Document_Store__c> docStores = [select id, DUP_Document_Request__c, DUP_Document_Request__r.Name 
            from DUP_Document_Store__c 
            where DUP_Document_Status__c = 'Requested' and DUP_Requested__c = true
            and DUP_Counterparty_Contact_Name__c=:contactId and DUP_Document_Request__r.DUP_Status_Upload__c = 'DUP_Review_Upload'];
        
        Map<Id,DUP_Document_Request__c> documentMap = new Map<Id,DUP_Document_Request__c>();
        
        for(DUP_Document_Store__c ds : docStores){
            DUP_Document_Request__c temp = new DUP_Document_Request__c();
            temp.Id = ds.DUP_Document_Request__c;
            temp.DUP_CounterParty_Name__c = ds.DUP_Document_Request__r.Name;
            if(documentMap.containsKey(ds.DUP_Document_Request__c)){
                temp.DUP_Items_Received__c = (documentMap.get(ds.DUP_Document_Request__c)).DUP_Items_Received__c + 1;
            }
            else{
                temp.DUP_Items_Received__c = 1;
            }
            documentMap.put(ds.DUP_Document_Request__c,temp);
        }

        return documentMap.values();
    }    
}