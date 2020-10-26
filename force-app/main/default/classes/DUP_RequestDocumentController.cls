/*****************************************************************************************
*       Date:        7OCT2019
*       Author:      Naglis Jonas Kazlauskas - IBM
*       Description: Controller for visualforce Request counterparties template
*****************************************************************************************/

public with sharing class DUP_RequestDocumentController {
    
    private List<DUP_Document_Store__c> documentStoresList;
    public Id RecordId { get; set;}
    public Id RequestId { get; set;}
    private boolean printLabel = false;
    private List<String> changedNames;
   	
    public List<DUP_Document_Store__c> getDocumentStoresList(){
        String counterpartyEmail; 
        List<User> counterpartyUser = [SELECT Email 
                                       FROM User
                                       WHERE Id =: RecordId];
        if(counterPartyUser.size() > 0) {
            counterpartyEmail = counterpartyUser[0].Email;
        } else {
            counterpartyEmail = [SELECT Email 
                                 FROM Contact
                                 WHERE Id =: RecordId].Email;
        }
      
        documentStoresList = [SELECT Name, 
                              	DUP_Document_Name__c,
                              	DUP_Counterparty_Contact_Name__r.DUP_First_Name__c,  
                                DUP_Certified_True_Copy__c,
                                DUP_Reject_Comments__c,
                                DUP_Description__c
                              FROM DUP_Document_Store__c
                              WHERE DUP_Document_Request__c =: requestId
                              	AND DUP_Counterparty_Contact_Name__r.DUP_Email__c =: counterpartyEmail
                                AND DUP_Document_Status__c != 'Uploaded'
                                AND DUP_Document_Status__c != 'Reviewed' 
                                AND DUP_Requested__c = true
                              ORDER BY Name ASC
                             ];
        
        for (DUP_Document_Store__c ds : documentStoresList) {
            if(ds.DUP_Certified_True_Copy__c == true){
                printLabel = true;
                ds.DUP_Document_Name__c = makeCertified(ds.DUP_Document_Name__c);
            }
        }
        return documentStoresList;
    }
    
    private static String makeCertified(String dupName){
        List<String> chars = dupName.split('');
        chars[0] = chars[0].toLowerCase();
        String finalString =  'Certified true ' + String.join(chars, '');
        return finalString;
    }
    
    public boolean getBooleanValue(){
        boolean booleanValue = false;
        if(printLabel == true){
            booleanValue = true;
        }
        return booleanValue;
    }
    
}