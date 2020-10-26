/**
*
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 04/2019
*
**/
global class REIDP_BatchWipeoutUserEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        REIDP_BatchWipeoutUserEmail batchWipeoutEmails = new REIDP_BatchWipeoutUserEmail();
        database.executebatch(batchWipeoutEmails);
    }
}