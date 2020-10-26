/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Admin log
 * logs admin actions to salesforce
*/
public class REIDP_PAAdminLog {
    public static void adminLog(String function, String args) {
		adminLog(function, args, null);
    }
    
    public static void adminLog(String function, String args, String contactId) {
		insert new REIDP_Admin_Log__c(Admin__c = UserInfo.getUserId() ,Function__c=function, Arguments__c=args, Contact__c = contactId);
    }
}