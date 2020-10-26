/**
* @author      Avinash Jain
* @date      20/08/2019
* @description    Batch class to update UserPermissionsSupportUser field on user object
*/
Global With Sharing class GCP_TFD_UpdateServiceConsole implements database.Batchable<sobject>{
     List<string> permissionSetsName =  System.Label.GCP_TFD_PermissionSets.split(',');
    /**
* @description Start method for batch class
*/
    global database.QueryLocator start(database.BatchableContext BC)
    {
        String Query;
        if(Test.isRunningTest()){
            Query ='Select id,assigneeId,PermissionSet.Name,Assignee.UserPermissionsSupportUser from PermissionSetAssignment where PermissionSet.Name in:permissionSetsName limit 200';
        }
        else
        {
            Query ='Select id,assigneeId,PermissionSet.Name,Assignee.UserPermissionsSupportUser from PermissionSetAssignment';
        }
        return database.getQueryLocator(Query);
    }
    /**
* @description Execute method for batch class
*/
    global void execute(database.BatchableContext BC,List<PermissionSetAssignment> PermissionSetAssignmentList)
    {
        List<user> UserToUpdate = new List<user>();
        Set<id> userid = new Set<id>();
       
        for(PermissionSetAssignment psa : PermissionSetAssignmentList){
            if(permissionSetsName.contains(psa.PermissionSet.Name)){
                if(!psa.Assignee.UserPermissionsSupportUser){
                    userid.add(psa.assigneeId);
                }
            }
        }
        User u;
        for(id i:userid){
            u = new user();
            u.id = i;
            u.UserPermissionsSupportUser = TRUE;
            UserToUpdate.add(u);
        }
        Update UserToUpdate;
    }
    /**
* @description finish method for batch class
*/
    global void finish(database.BatchableContext BC)
    {
        
    }
}