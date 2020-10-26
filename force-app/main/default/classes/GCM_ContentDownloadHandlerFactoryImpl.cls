/********************************************************************************
 * Date           : 31-MAR-2020
 * Author         : Roselin Hephzibah
 * Description    : ContentDownloadHandlerFactoryImpl 
 * Modifications  : 31-MAR-2020 Roselin - Initial
                    20-MAY-2020 Roselin - Modified to query staging table based on Content Document Id
 ********************************************************************************/ 
public with sharing class GCM_ContentDownloadHandlerFactoryImpl implements Sfc.ContentDownloadHandlerFactory {
/*********************************************************************************
 * getContentDownloadHandler - Update GCM ANZ Bot Attachment record when BOT downloads the file.
 *********************************************************************************/ 
    public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext context) {
        system.debug('download context'+ context);
        Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
        try{
            List<Profile> profileList = [Select Id, Name from Profile Where Id =: UserInfo.getProfileId() and Name like 'GCM%'];
            system.debug('Profile List'+profileList );
            String userEmail = UserInfo.getUserEmail();
            String loggedInUserName = UserInfo.getUserName();
            if(!profileList.isEmpty() && ((String.isNOTBlank(userEmail) && userEmail.equalsIgnoreCase('gbssfcustomerbotuser@bp.com')) || (String.isNOTBlank(loggedInUserName) && loggedInUserName.startsWithIgnoreCase('gbssfcustomerbot')))) {
                system.debug('Inside BOT download '+ids);
                List<ID> contentVersionIds = new List<ID>();
                if(!ids.isEmpty()){
                    for(Id attachId : ids){
                        Id aId = attachId;
                        contentVersionIds.add(aId);
                    }
                }
                system.debug('Ids 18 digit***'+contentVersionIds);
                
                List<ContentVersion> contentversionList = [Select Id, ContentDocumentID from Contentversion Where Id in: ids];
                system.debug('ContentVersion'+contentversionList);
                List<Id> conDocIds = new List<Id>();
                for(ContentVersion cv: contentversionList){
                    conDocIds.add(cv.ContentDocumentID);
                }
                system.debug('Conetnt doc ids****'+conDocIds);
                List<GCM_ANZ_Bot_Attachment__c> attachList = [Select Id, Name, GCM_Content_Document_Id__c, GCM_Downloaded__c from GCM_ANZ_Bot_Attachment__c Where GCM_Content_Document_Id__c IN: conDocIds and GCM_Downloaded__c =: false]; 
                if(!attachList.isEmpty()){
                    List<GCM_ANZ_Bot_Attachment__c> attachUpdateList = new List<GCM_ANZ_Bot_Attachment__c>();
                    for(GCM_ANZ_Bot_Attachment__c aba: attachList){
                        aba.GCM_Downloaded__c = true;
                        attachUpdateList.add(aba);
                    }
                    if(!attachUpdateList.isEmpty()){
                        system.debug('update list'+attachUpdateList);
                        Database.SaveResult[] srList = Database.update(attachUpdateList, false);
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully updated***' + sr.getId());
                                contentDownloadHandler.isDownloadAllowed = true;
                                return contentDownloadHandler;
                            } else {
                                contentDownloadHandler.isDownloadAllowed = true;
                                return contentDownloadHandler;
                            }
                        }
                        
                        system.debug('update list***'+attachUpdateList);
                    }
                }
            }
        }Catch(Exception e){
            contentDownloadHandler.isDownloadAllowed = true;
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(e, 'Class', 'GCM_ContentDownloadHandlerFactoryImpl', 'getContentDownloadHandler', new Id[]{}, 'GCM_Application_Administrator');
        }
        contentDownloadHandler.isDownloadAllowed = true;
        return contentDownloadHandler;
    }  
    
}