public without sharing class ISTCP_UserPreferenceController {

    /**
    * @description Queries contact to get contact info for current user.
    * @author Ravi Potla | 6/20/2020 
    * @return List<Contact>
    **/
    @AuraEnabled(cacheable = true)
    public static List<Contact> fetchAccPrefrenceValue() {
        User user = [Select contactId from User where Id =: UserInfo.getUserId()];
        Contact[] contact = [Select id, ISTCP_Account_Notification_Preferences__c, ISTCP_System_Notification_Preferences__c, ISTCP_BP_Announcements_Notifications__c from contact where Id =: user.contactId];
        return contact;
    }

    /**
    * @description Save user notifications preferences to contact.
    * @author Ravi Potla | 6/20/2020 
    * @return 
    **/
    @AuraEnabled
    public static void saveAccNotificationInfo(String preference, String source) {

        User user = [Select contactId from User where Id =: UserInfo.getUserId()];
        Contact con = new Contact(Id = user.contactId);
        if(source == 'AccNotification'){
            con.ISTCP_Account_Notification_Preferences__c = preference;
        }
        if(source == 'SysNotification'){
            con.ISTCP_System_Notification_Preferences__c = preference;
        }
        if(source == 'BPNotification'){
            con.ISTCP_BP_Announcements_Notifications__c = preference;
        }
        update con;
    }

}