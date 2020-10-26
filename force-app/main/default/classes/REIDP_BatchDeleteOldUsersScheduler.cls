/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 1/2019
*
*/
global class REIDP_BatchDeleteOldUsersScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        REIDP_BatchDeleteOldUsers batchOldAcc = new REIDP_BatchDeleteOldUsers();
        database.executebatch(batchOldAcc);
    }
}