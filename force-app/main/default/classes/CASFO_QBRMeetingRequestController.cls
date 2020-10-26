/************************************************************************************************************
* Description : Controller for QBR meeting requester lightning component. Handles lsiting and searching of
* accounts and saving requests on accounts and sending chatter post.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-08-10    1.0					Maros Zilka			Initial version
* 2019-06-24    1.1					Adam Janicko	    Changed BU to MSP
*
*************************************************************************************************************/

public with sharing class CASFO_QBRMeetingRequestController {
    
    @AuraEnabled
    public static List<Account> getAccounts(Boolean fav, Boolean bu) {
        List<User> users = [SELECT Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId()]; 
        
        String key;
        String fields = 'SELECT Id, Name, CASFO_QBR_Requested__c, CASFO_QBR_Planned__c, Type, ' +
                        'CASFO_QBR_Completed_Date__c, OwnerId, Owner.Name, ' +
                        'Classification__c, CASFO_QBR_Favorite__c, ' +
            			'Business_Unit__c ' +
                        'FROM Account WHERE RecordType.Name = \'Customer\' ' +
            			'AND CASFO_QBR_Completed_Date__c != LAST_90_DAYS ';
        
        if (fav) {
            	key = 	fields + 
                    	'AND CASFO_QBR_Favorite__c = true ';
        } else {
                key = 	fields + 
                    	'AND CASFO_QBR_Requested__c = FALSE ' +
                		'AND CASFO_QBR_Planned__c = FALSE ' +
                    	'AND Classification__c = \'PL Platinum\' ' +
                    	'AND Type = \'ZMSP\' ';	
        }
        
        //due to BU rework to multiselect picklist needed a change. Hopefully it will work, but since there are no unit tests we won't know. Probably not used anyway.
       	List<String> userBusinessUnits = null;
        if(bu && users[0].Business_Unit__c != null) {
            userBusinessUnits = users[0].Business_Unit__c.split(';');
            
            if(!userBusinessUnits.isEmpty()) {
                key += 'AND Business_Unit__c IN :userBusinessUnits ';
            }
        }
        
        if (fav) {
            key += 'ORDER BY Name ASC';
        } else {
            key += 'ORDER BY Name ASC LIMIT 50';
        }
        
        System.debug(key);
        return (List<Account>) Database.query(key);
    }
    
    @AuraEnabled
    public static List <Account> searchAccounts(String key) {
        ID recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        String searchKey = 'FIND \'' + String.escapeSingleQuotes(key) + '*\' IN ALL FIELDS ' +
        			'RETURNING Account (Id, Name, CASFO_QBR_Requested__c, CASFO_QBR_Planned__c, ' +
        			'CASFO_QBR_Completed_Date__c, OwnerId, Owner.Name, ' +
             		'Business_Unit__c, Classification__c, Account_ERP_ID__c, Type, ' +
            		'CASFO_QBR_Favorite__c WHERE RecordType.Name = \'Customer\') LIMIT 10';
        
        List<List<sObject>> soslAccountResult = Search.query(searchKey);
        return (List<Account>) soslAccountResult[0];
    }
    
    @AuraEnabled
    public static void requestAccounts(List<Account> accounts) {
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (Account account : accounts) {
            
            account.CASFO_QBR_Requester__c = UserInfo.getUserId();
            account.CASFO_QBR_Requested_Date__c = DateTime.now();
            account.CASFO_QBR_Requested__c = TRUE;
            
            // Chatter Post
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            mentionSegmentInput.id = account.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput.text = ' Quarterly Business Review Meeting was requested for ' + account.Name;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = account.Id;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
        }

        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);       
        update accounts; 
    }
}