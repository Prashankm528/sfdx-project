/************************************************************************************************************
* Description : Controller for QBR Event Closer component.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2018-08-10    1.0					Maros Zilka			Initial version
*
*************************************************************************************************************/

public class CASFO_QBREventDeleted {
    public void updateAccountWhenQBRDeleted(List<Event> oldRecords) {
		List<Account> accounts = new List<Account>();
        
        for (Event e : oldRecords) {
            if (e.Type == 'Quarterly Business Review' && 
                !e.CASFO_QBR_Closed__c &&
                e.AccountId != null) {
                    
                Account a = new Account();
                a.Id = e.AccountId;
                a.CASFO_QBR_Planned__c = false;
                a.CASFO_QBR_Planned_Date__c = null;
                
                accounts.add(a);
            }
        }
        
        upsert accounts;
    }
}