public class ContentVersionTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<ContentVersion> newRecords;
    final Map<Id, ContentVersion> newRecordsMap;
    final Map<Id, ContentVersion> oldRecords;
    
    public ContentVersionTriggerHandler(List<ContentVersion> newRecords, Map<Id, ContentVersion> newMap, Map<Id, ContentVersion> oldRecords) {
        this.newRecords = newRecords;
        this.newRecordsMap = newMap;
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

    public void beforeDelete() {
        if(bypassTrigger){return;}
    }
    
    public void after() {
        if(bypassTrigger){return;}
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}
        
        CAPL_CreateSharableLinkTriggerHandler.createSharableLink(newRecordsMap);
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}        
    }
    
}