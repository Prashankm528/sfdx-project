public class FeedCommentTriggerHandler {
    // used for testing triggers when the
    // setup DML would interfere with the tests
    @testVisible static Boolean bypassTrigger = false;
    final Set<Id> newIds;
    final List<FeedComment> newRecords;
    final Map<Id, FeedComment> oldRecords;
    
    public FeedCommentTriggerHandler(List<FeedComment> newRecords, Map<Id, FeedComment> newMap, Map<Id, FeedComment> oldRecords) {
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

    public void beforeDelete() {
        if(bypassTrigger){return;}
        
    }
    
    public void after() {
        if(bypassTrigger){return;}
    }
    
    public void afterInsert() {
        if(bypassTrigger){return;}
        
        CAPL_ReviewFeedCommentTriggerHandler.limitPointsForComments(newRecords);
    }
    
    public void afterUpdate() {
        if(bypassTrigger){return;}        

    }
    
}