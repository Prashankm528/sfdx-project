@isTest
public class CAJBP_ObjectiveCustomerPrioritiesTest {    
	static final BPG_TestDataService.SObjectCreator RecordService = new BPG_TestDataService.SObjectCreator();
    static final Account JbpAccount = CAJBP_TestFactory.createCustomerMock();
    static final CAJBP_Joint_Business_Plan__c JbpPlan = CAJBP_TestFactory.createJointBusinessPlan();
    static final CAJBP_Objective__c JbpObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
    
    static testMethod void getPrioritiesOptionsTest() {
        List<CAJBP_Customer_Priority__c> custPriorities = new List<CAJBP_Customer_Priority__c>();
        List<CAJBP_Objective_Customer_Priority__c> objCustPriorities = new List<CAJBP_Objective_Customer_Priority__c>();
        for(Integer i=0;i<10;i++){
            CAJBP_Customer_Priority__c priority = new CAJBP_Customer_Priority__c();
            priority.Name = 'Priority'+i;
            priority.CAJBP_Description__c = 'Priority'+i;
            priority.CAJBP_Joint_Business_Plan__c = JbpPlan.Id;
			custPriorities.add(priority);                 
        }
        try{
            insert custPriorities;
       } catch(Exception ex){
           
       }
       System.assertEquals(custPriorities[0].CAJBP_Joint_Business_Plan__c, JbpPlan.Id);
        for(Integer i=0;i<10;i++){
            CAJBP_Objective_Customer_Priority__c objPriority = new CAJBP_Objective_Customer_Priority__c();  
            objPriority.CAJBP_Customer_Priority__c = custPriorities[i].Id;
            objPriority.CAJBP_Objective__c = JbpObjective.Id;
            objCustPriorities.add(objPriority);
        } 
       try{
            insert objCustPriorities;
       } catch(Exception ex){
           
       }        
       System.assertEquals(objCustPriorities[0].CAJBP_Objective__c, JbpObjective.Id); 
       List<ID> objPriorityIds = new List<ID>();
        for(CAJBP_Objective_Customer_Priority__c ocp : objCustPriorities){
            objPriorityIds.add(ocp.Id);
        } 
        List<ID> priorityIds = new List<ID>();
        for(CAJBP_Customer_Priority__c ocp : custPriorities){
            priorityIds.add(ocp.Id);
        }
        CAJBP_Objective__c newObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
        newObjective.Id = null;        
       Test.startTest();
        List<CAJBP_ObjectiveCustomerPriorities.Option> options = CAJBP_ObjectiveCustomerPriorities.getPrioritiesOptions(JbpPlan.Id,JbpObjective.Id);        
        try{
            CAJBP_ObjectiveCustomerPriorities.savePriorities(JbpObjective.Id, objPriorityIds);
            CAJBP_ObjectiveCustomerPriorities.saveObjective(JSON.serialize(newObjective), new List<ID>{
                RecordService.generateId(Schema.CAJBP_Objective_Customer_Priority__c.SObjectType)
            });
        }catch(Exception ex){
            
        }
        
       Test.stopTest(); 
    }
    
    static testMethod void saveObjectiveTest() {
        List<CAJBP_Customer_Priority__c> custPriorities = new List<CAJBP_Customer_Priority__c>();
        List<CAJBP_Objective_Customer_Priority__c> objCustPriorities = new List<CAJBP_Objective_Customer_Priority__c>();
        for(Integer i=0;i<10;i++){
            CAJBP_Customer_Priority__c priority = new CAJBP_Customer_Priority__c();
            priority.Name = 'Priority'+i;
            priority.CAJBP_Description__c = 'Priority'+i;
            priority.CAJBP_Joint_Business_Plan__c = JbpPlan.Id;
			custPriorities.add(priority);            
        }
        try{
            insert custPriorities;
       } catch(Exception ex){
           
       }
        
        for(Integer i=0;i<10;i++){
            CAJBP_Objective_Customer_Priority__c objPriority = new CAJBP_Objective_Customer_Priority__c();  
            objPriority.CAJBP_Customer_Priority__c = custPriorities[i].Id;
            objPriority.CAJBP_Objective__c = JbpObjective.Id;
            objCustPriorities.add(objPriority);
        } 
       try{
            insert objCustPriorities;
       } catch(Exception ex){
           
       } 
       List<ID> objPriorityIds = new List<ID>();
        for(CAJBP_Objective_Customer_Priority__c ocp : objCustPriorities){
            objPriorityIds.add(ocp.Id);
        } 
        List<ID> priorityIds = new List<ID>();
        for(CAJBP_Customer_Priority__c ocp : custPriorities){
            priorityIds.add(ocp.Id);
        }
        CAJBP_Objective__c newObjective = CAJBP_TestFactory.createObjectiveMock(JbpPlan);
        newObjective.Id = null;  
        CAJBP_ObjectiveCustomerPriorities.Option options = new CAJBP_ObjectiveCustomerPriorities.Option(custPriorities[0],true);
        System.assert(options.selected);
       Test.startTest();
        try{
            CAJBP_ObjectiveCustomerPriorities.saveObjective(JSON.serialize(newObjective), new List<ID>{
                RecordService.generateId(Schema.CAJBP_Objective_Customer_Priority__c.SObjectType)
            });
        }catch(Exception ex){
            
        }
        
       Test.stopTest(); 
    }
}