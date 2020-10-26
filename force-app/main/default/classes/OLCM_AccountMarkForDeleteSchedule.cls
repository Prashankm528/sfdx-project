/**
 * @author Jewelslyn Shama P
 * @company Tata Consultancy Services
 * @date 
 * 
 */

global with sharing class OLCM_AccountMarkForDeleteSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        OLCM_BatchAccountMarkForDelete accMarkForDelete = new OLCM_BatchAccountMarkForDelete ();
     	database.executebatch(accMarkForDelete,200);
    }
}