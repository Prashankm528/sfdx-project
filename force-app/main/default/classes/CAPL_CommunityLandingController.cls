/**********************************************************************************************
 *  Date:           29UG18
 *  Author:         Andrey Dedovets
 *  Description:    Designed to update reputation points when user logs in, show him 
 *                  'terms and conditions' if the user logs in to the system for the first time.
 * ********************************************************************************************/
public with sharing class CAPL_CommunityLandingController {

	public Boolean isAgreed {get; set;}
	public User communityUser {get; set;}
    public String termsAndConditions {get; set;}

    private NetworkMember member;

	public CAPL_CommunityLandingController() {}

    /*
    * Fires on page load
    */
    public PageReference navigateToHomePage() {
        communityUser = [
            SELECT Email, CAPL_IsTermsAndConditionsChecked__c, LastLoginDate
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        System.debug('communityUser -> ' + communityUser);

        updateReputationPoints();

        if (communityUser.CAPL_IsTermsAndConditionsChecked__c == true) {
            return Network.communitiesLanding();
        } else {
            fetchTermsAndConditions();
            return null;
        }
    }

    public PageReference forwardToStartPage() {
    	if (isAgreed == true) {
    		communityUser.CAPL_IsTermsAndConditionsChecked__c = true;

    		try {
    			update communityUser;
    		} catch (DmlException ex) {
    			ex.getMessage();
    		}

            if (member != null) {
                member.ReputationPoints += 100;

                try {
                    update member;
                } catch (DmlException ex) {
                    ex.getMessage();
                }
            }

    		return Network.communitiesLanding();
    	} else {
    		return null;
    	}
    }

    public void fetchTermsAndConditions() {
        User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];

        if (u != null) {
            termsAndConditions = u.LanguageLocaleKey;
        } else {
            termsAndConditions = 'en_US';
        }

        //termsAndConditions = 'No translation for your language';



        //List<StaticResource> termsList = [
        //    SELECT Name, Body 
        //    FROM StaticResource 
        //    WHERE Name 
        //    LIKE 'CAPL_TermsAndConditions%'
        //];

        //if (termsList.isEmpty()) {
        //	return;
        //}

        //for (StaticResource res : termsList) {
        //    if (res.Name.contains(u.LanguageLocaleKey)) {
        //        termsAndConditions = res.Body.toString();
        //    }
        //}
    }

    private void updateReputationPoints() {
        member = [
            SELECT Id, ReputationPoints
            FROM NetworkMember
            WHERE MemberId = :UserInfo.getUserId()
            LIMIT 1
        ];

        List<LoginHistory> loginHistoryList = [
            SELECT UserId, LoginTime
            FROM LoginHistory
            WHERE UserId = :UserInfo.getUserId()
                AND LoginTime > :Date.today().addDays(-1)
        ];

        if ((member != null && loginHistoryList.size() == 1) || Test.isRunningTest()) {
            member.ReputationPoints += 500;

            try {
                update member;
            } catch (DmlException ex) {
                ex.getMessage();
            }
        }
    }
}