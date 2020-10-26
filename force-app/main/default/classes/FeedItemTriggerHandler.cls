public class FeedItemTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<FeedItem> newRecords;
    final Map<Id, FeedItem> oldRecords;
    
    public FeedItemTriggerHandler(List<FeedItem> newRecords, Map<Id, FeedItem> newMap, Map<Id, FeedItem> oldRecords) {
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
        
        

        CAPL_ReviewFeedItemTriggerHandler.deleteCreateRecordEventRecord(newRecords);
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
        
        CAPL_ReviewFeedItemTriggerHandler.limitPointsForPosts(newRecords);
        
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}        

    }
    
}