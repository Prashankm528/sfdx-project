/****************************************************************************************************
 *  Date          : 17-JAN-2020
 *  Author        : Sunny Yap
 *  Description   : Checks the hands on exercise results.
 *  Modifications : 17-JAN-2020 SYAP - Initial
 *                  08-FEB-2020 SYAP - Integration with BP Trailhead Tracker
 * 					17-FEB-2020 SYAP - Added the ability to automatically register users in
 * 									   the BP Trailhead Tracker.
 * 				    15-MAY-2020 SYAP - Added Trail Attribute 
 ****************************************************************************************************/

public with sharing class GCM_Check_Assessment {
public String message{get; set;}

/****************************************************************************************************
 * Runs SOQL Queries
 * If Queries Return > 0 Records Pass
 ****************************************************************************************************/
  public void checkResults() {
    try {
        String successMessage = '';
        this.message = '';
        String code = ApexPages.currentPage().getParameters().get('code');
        if (code != null) {
            List<GCM_Goal__c> goals = [
                select
                    GCM_SOQL__c,
                    GCM_Message__c,
                    GCM_Achievement__r.GCM_Message__c,
                    GCM_Achievement__r.GCM_Email__c,
                    GCM_Achievement__r.GCM_Badges__c,
                    GCM_Achievement__r.GCM_Points__c,
                	GCM_Achievement__r.GCM_Category__c,
                	GCM_Achievement__r.GCM_Trail__c
                from
                    GCM_Goal__c
                where
                    GCM_Achievement__r.Name = :code
                order by GCM_Sequence__c
            ];
            for (GCM_Goal__c goal : goals) {
                String soql = goal.GCM_SOQL__c;
                soql = soql.replace('{!UserId}', UserInfo.getUserId());
                List<SObject> objects = Database.query(soql);
                if (objects.size() == 0) {
                    this.message = goal.GCM_Message__c;
                    return;
                }
                else {
                    successMessage = goal.GCM_Achievement__r.GCM_Message__c;
                    
                    // Integration
                    String address = goal.GCM_Achievement__r.GCM_Email__c;
                    if (address != null) {
                        String payload = '';
                        payload += goal.GCM_Achievement__r.GCM_Category__c + ',';
                        payload += UserInfo.getUserEmail() + ',';
                        payload += code + ',';
                        payload += goal.GCM_Achievement__r.GCM_Badges__c + ',';
                        payload += goal.GCM_Achievement__r.GCM_Points__c + ',';
                        payload += 'GCM';
                        if (goal.GCM_Achievement__r.GCM_Trail__c != null) payload += ',' + goal.GCM_Achievement__r.GCM_Trail__c;
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[] {address};
                        email.setToAddresses(toAddresses);
                        email.setSubject('BP SALESFORCE TRAINING');
                        email.setPlainTextBody(payload);
                        email.setHtmlBody(payload);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }                    
                }
            }
            this.message = successMessage;
        }
    }
    catch (Exception exceptionObject) {
      BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_Check_Assessment', 'checkResults', (List<Id>) null, 'GCM_Application_Administrator');
    }
  }
}