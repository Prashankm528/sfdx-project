/*****************************************************************************************
*       Date:           01JUL19
*       Author:         Quentin Lebastard - IBM
*       Description:    Trigger Handler for initiating specific TKT Case Assignment Rule
*       Modifications:  09JUL19 Michal Vavra - IBM: Refactoring (based on C4E feedback)
*****************************************************************************************/
public with sharing class TKT_CaseAssignmentHandler extends BPG_Trigger_Handler_Utilities {
    private static final String TKT_CASE_RECORD_TYPE_DEV_NAME = 'TKT_Ticketing';
    
    @TestVisible
    private static String ticketingAssignmentRuleName = 'BPG_Case_Assignment_Rules';
    
    @TestVisible
    private static Id ticketingCaseRecordTypeId = Case.SObjectType.getDescribe()
        .getRecordTypeInfosByDeveloperName().get(TKT_CASE_RECORD_TYPE_DEV_NAME).getRecordTypeId();
    
    /*****************************************************************************************
	*       Date:           01JUL19
	*       Author:         Quentin Lebastard - IBM
	*       Description:    Method used to trigger assignment rules on Cases coming from the community portal
	*       Modifications:  09JUL19 Michal Vavra - IBM: Refactoring (based on C4E feedback)
	*****************************************************************************************/
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
        Set<Id> caseIdSet = new Set<Id>();
        for (SObject newRecord : n) {
            Case c = (Case) newRecord;
            if (c.RecordTypeId == ticketingCaseRecordTypeId && isOriginApplicableForCaseAssignmentRule(c)) {
                caseIdSet.add(c.Id);
            }
        }
        
        if (!caseIdSet.isEmpty()) {        
            List<AssignmentRule> assignmentRule = [
                SELECT id
                FROM AssignmentRule
                WHERE SobjectType = 'Case'
                AND Active = true
                AND Name = :ticketingAssignmentRuleName
                LIMIT 1
            ];
            
            if (assignmentRule.isEmpty()) {
                System.debug(LoggingLevel.ERROR ,'No assignment rule found');
                final String noAssignmentRuleErrorMessage = 
                    'No Assignment Rule with name "' + ticketingAssignmentRuleName + '"" found for Case object';
                for (SObject newRecord : n) {
                    newRecord.addError(noAssignmentRuleErrorMessage);
                }
            } else {
                Database.DMLOptions ticketingAssignmentRuleOption = new Database.DMLOptions();
                ticketingAssignmentRuleOption.assignmentRuleHeader.assignmentRuleId = assignmentRule[0].id;
                
                List<Case> caseList = new List<Case>();
                for (Case c : [SELECT Id FROM Case WHERE Id IN :caseIdSet]) {                
                    c.setOptions(ticketingAssignmentRuleOption);
                    caseList.add(c);
                }
                update caseList;                
            }
        }
    }
    
    /*****************************************************************************************
	*       Date:           09JUL19
	*       Author:         Michal Vavra - IBM
	*       Description:    Returns true when Case.Origin field is applicable for Case Assignemnt Rule to be run
	*****************************************************************************************/
    private static Boolean isOriginApplicableForCaseAssignmentRule(Case c) {
        return c.Origin == 'Internal Form' || 
            c.Origin == 'External Form' || 
            c.Origin == 'New Customer Form';
    }
}