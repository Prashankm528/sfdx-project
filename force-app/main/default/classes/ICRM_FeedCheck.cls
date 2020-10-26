/**
* @author Santosh Verma
* @date 11/09/2019
* @description - This class is created to check the feed enabled for the objects 
* 
*/public with sharing class ICRM_FeedCheck {
    
    static boolean EventFC;
    static boolean TaskFC;
    
Public static boolean checkEventfeed(){
    /* test feed for Event object */ 
  EventFC =  Schema.SObjectType.Event.isFeedEnabled();
    	system.debug('EventFC=' + EventFC);
    return EventFC;
}
    
Public static boolean checkTaskfeed(){
    /* test feed for Task object */ 
  TaskFC =  Schema.SObjectType.Task.isFeedEnabled();
    	system.debug('TaskFC=' + TaskFC);
    return TaskFC;
}
}