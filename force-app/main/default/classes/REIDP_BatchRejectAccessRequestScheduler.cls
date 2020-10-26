/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 3/2019
*
*/
global class REIDP_BatchRejectAccessRequestScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        REIDP_BatchRejectAccessRequests batchAutoRejectAccessRequests = new REIDP_BatchRejectAccessRequests ();
        database.executebatch(batchAutoRejectAccessRequests);
    }
}