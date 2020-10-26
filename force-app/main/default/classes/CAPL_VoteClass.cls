/**********************************************************************************************
 *  Date:           29UG18
 *  Author:         Andrey Dedovets
 *  Description:    Designed as alternative to the 'like' functionality for the CAPL_Video__c and 
 *                  Knowledge__kav objects. User can like the article/video. Also the is a functionality
 *                  to add user reputation points.
 * ********************************************************************************************/
public with sharing class CAPL_VoteClass {

	private static final String VIDEO_OBJECT = 'CAPL_Video__c';
	private static final String KNOWLEDGE_ARTICLE_OBJECT = 'Knowledge__kav';

	/*
    * used to fetch number of likes of CAPL_Video__c or Knowledge__kav record
    */

    @AuraEnabled
    public static Integer fetchNumberOfLikes(String recordId) {
    	String objName = fetchObjectName(recordId);

    	List<CAPL_Vote__c> likesList = new List<CAPL_Vote__c>();

    	if (VIDEO_OBJECT == objName) {
    		likesList = [
	            SELECT Id
	            FROM CAPL_Vote__c
	            WHERE VotedOn__c = :recordId
	        ];
    	} else
    	if (KNOWLEDGE_ARTICLE_OBJECT == objName) {
    		likesList = [
	            SELECT Id
	            FROM CAPL_Vote__c
	            WHERE VotedOnArticle__c = :recordId
	        ];
    	}

        return likesList.size();
    }

    /*
    * used to like CAPL_Video__c or Knowledge__kav record
    */

    @AuraEnabled
    public static Boolean likeRecord(String recordId) {
    	String objName = fetchObjectName(recordId);

    	List<CAPL_Vote__c> likesList = fetchLikes(recordId);

        if (!likesList.isEmpty()) {
            return false;
        }

        CAPL_Vote__c vote = new CAPL_Vote__c(
            VotedBy__c = UserInfo.getUserId()
        );

        if (VIDEO_OBJECT == objName) {
        	vote.VotedOn__c = recordId;
        } else
    	if (KNOWLEDGE_ARTICLE_OBJECT == objName) {
    		vote.VotedOnArticle__c = recordId;
    	}

        Database.SaveResult result = Database.insert(vote);

        List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        if (networks.isEmpty()) {
		        return false;
		}

        Id networkId = networks.get(0).Id;

        if (result.isSuccess()) {
            List<NetworkMember> membersList = [
                SELECT Id, ReputationPoints
                FROM NetworkMember
                WHERE MemberId = :UserInfo.getUserId()
                AND NetworkId = :networkId
            ];

            if (!membersList.isEmpty()) {
                membersList.get(0).ReputationPoints += 1000;
            }

            try {
                update membersList.get(0);
            } catch (DmlException ex) {
                ex.getMessage();
            }

            return true;
        } else {
            return false;
        }

    }

    /*
    * used to see wheather user liked CAPL_Video__c or Knowledge__kav record or not
    */

    @AuraEnabled
    public static Boolean isLikedRecord(String recordId) {
        List<CAPL_Vote__c> likesList = fetchLikes(recordId);

        if (!likesList.isEmpty()) {
            return true;
        } else {
            return false;
        }
    }

    /*
    * used to fetch object name using id
    */

    private static String fetchObjectName(String recordId) {
    	Id recId = recordId;

    	System.debug(recId.getSObjectType().getDescribe().getName());

    	return recId.getSObjectType().getDescribe().getName();
    }

    /*
    * used to fetch num of likes for particular user
    */

    private static List<CAPL_Vote__c> fetchLikes(String recordId) {
    	String objName = fetchObjectName(recordId);

    	List<CAPL_Vote__c> likesList = new List<CAPL_Vote__c>();

    	if (VIDEO_OBJECT == objName) {
    		likesList = [
	            SELECT Id
	            FROM CAPL_Vote__c
	            WHERE VotedOn__c = :recordId
	            	AND VotedBy__c = :UserInfo.getUserId()
	        ];
    	} else
    	if (KNOWLEDGE_ARTICLE_OBJECT == objName) {
    		likesList = [
	            SELECT Id
	            FROM CAPL_Vote__c
	            WHERE VotedOnArticle__c = :recordId
	            	AND VotedBy__c = :UserInfo.getUserId()
	        ];
    	}

    	return likesList;
    }
}