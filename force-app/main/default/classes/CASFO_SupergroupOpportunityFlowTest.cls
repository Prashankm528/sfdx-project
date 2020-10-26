/***************************************************************************************************
* Description : Unit Tests record type conversion flow of opportunity
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-FEB-21   1.0                 Maros Zilka     	Initial version
*
***************************************************************************************************/

@isTest
public class CASFO_SupergroupOpportunityFlowTest {
	
    @isTest
    static void recordTypeChangeOnCheckbox() {
        RecordType generalOppoRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'General'];
        RecordType sgOppoRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'FWS_SG'];
        
        Account a = new Account();
        
        a.Name = 'Test Acc';
        
        insert a;
        
        Opportunity oppo = new Opportunity();
        
		oppo.RecordTypeId = generalOppoRecordType.Id;
        oppo.Name = 'Test';
        oppo.CASFO_FWS_supergroup_opportunity__c = false;
        oppo.StageName = 'Lead';
        oppo.CloseDate = Date.today();
        oppo.AccountId = a.Id;
        
        insert oppo;
        
        oppo.CASFO_FWS_supergroup_opportunity__c = true;
        
        update oppo;
        
        oppo = [SELECT Id, RecordTypeId FROM Opportunity WHERE Name = 'Test'];
        
        System.assert(oppo.RecordTypeId == sgOppoRecordType.Id, 'Opportunity should have FWS SG record type.');
        
        oppo.CASFO_FWS_supergroup_opportunity__c = false;
        
        update oppo;
        
        oppo = [SELECT Id, RecordTypeId FROM Opportunity WHERE Name = 'Test'];
        
        System.assert(oppo.RecordTypeId == generalOppoRecordType.Id, 'Opportunity should have general record type.');
    }
}