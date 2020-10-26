/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 02/2018
 * 
 */
public class REIDP_PlatformEventTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<REIDP_Platform_Event__e> newRecords;
    final Map<Id, REIDP_Platform_Event__e> oldRecords;
    
    // buffer for collecting Platform Events for inspection in tests
    @testVisible private static List<REIDP_Platform_Event__e> gotEvents = new List<REIDP_Platform_Event__e>();
    
    public REIDP_PlatformEventTriggerHandler(List<REIDP_Platform_Event__e> newRecords, Map<Id, REIDP_Platform_Event__e> newMap, Map<Id, REIDP_Platform_Event__e> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        if(newMap != null)
	        this.newIds = newMap.keySet();
    }
    
    public void before() {
        if(bypassTrigger){return;}
        
    }
    
    public void beforeInsert() {
        if(bypassTrigger){return;}

        
    }
    
    public void beforeUpdate() {
        if(bypassTrigger){return;}

        
        
    }
    
    public void after() {
        if(bypassTrigger){return;}
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}

        
        // if test context, store just inserted events for inspection
        // from test class
        if(Test.isRunningTest()) {
           gotEvents = newRecords;
        }
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}
      
    }
    
}