/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description		handles Account triggers for CAJBP project
 * 
 * history
 * 25/07/2018	Jan Majling			Created
 * 03/10/2018	Jan Majling			Refactored to set records in constructor 
 */
public with sharing class CAJBP_AccountTriggerHandler {
	private static final String JBP_STATE_CLOSED = 'Closed';
	private static final Set<String> ALLOWED_TYPES = new Set<String>{
		'ZMHI',
		'ZMSP'
	};
	private final List<Account> newRecords;
	private final List<Account> oldRecords;
	private final Map<Id, Account> newMap;
	private final Map<Id, Account> oldMap;

	/**
	 * @description constructor
	 * @param newRecords of type List<Account>
	 * @param oldMap of type Map<Id,Account>
	 */
	public CAJBP_AccountTriggerHandler(List<Account> newRecords, Map<Id,Account> oldMap) {
		this.newRecords = newRecords;
		this.oldMap = oldMap;
	}
	/**
	 * @description gets changed Accounts and uppdates their JBPs
	 */
	public void handleAfterUpdate() {
		List<CAJBP_Joint_Business_Plan__c> jbpsToUpdate = new List<CAJBP_Joint_Business_Plan__c>();
		Set<Id> changedAccountIds = new Set<Id>();
		List<Account> accountsWithJBPs;

		for (Account account : this.newRecords) {
			Account oldAccount = this.oldMap.get(account.Id);
			// get only changed accounts with allowed type
			if(ALLOWED_TYPES.contains(account.Type) && (
				(account.Name != oldAccount.Name) ||
				(account.Type != oldAccount.Type)
			)) {
				changedAccountIds.add(account.Id);
			}
		}

		accountsWithJBPs = new List<Account>(
			[SELECT Id, (SELECT Id FROM Joint_Business_Plans__r)
			FROM Account WHERE Id IN :changedAccountIds AND
				Id IN (SELECT CAJBP_Account__c FROM CAJBP_Joint_Business_Plan__c
			WHERE CAJBP_State__c <> :JBP_STATE_CLOSED)]
		);

		for (Account account : accountsWithJBPs) {
			jbpsToUpdate.addAll(account.Joint_Business_Plans__r);
		}

		if(!accountsWithJBPs.isEmpty()) {
			update jbpsToUpdate;
		}
	}
}