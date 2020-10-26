/*
*  @author            Santosh Verma
*  @date              08th Nov, 2019
*  @description       Added User creation and changed Oppty data to incorporate OpptyTeam's code coverage 
*                   - This is been called from ICRM_OpportunityTriggerHandlerTest class
*/

public class ICRM_TESTInsertFutureUser {
    /* Class to assign PS to user */ 

@future
    public static void insertUser() {
        /* ps check */ 
        PermissionSet PSdetail   =  [SELECT Id,name FROM PermissionSet where name ='ICRM_M_O' limit 1] ; 
       system.debug('PSId@@ = '+PSdetail.id); 
       system.debug('PsName@@ = '+PSdetail.name);  
        
         // user  
      user    ABUser = [SELECT Id, Username FROM User WHERE Username like  'test123@xyz.com%' LIMIT 1];
        system.debug('abuser@@ = '+abuser);
    
        //required permission set assigned to user -     
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = PSdetail.Id, AssigneeId = aBUser.id);   
      upsert psa;
     
        system.debug('PSAID@@ = '+psa.Id); 
       system.debug('PSAUserId@@ = '+Psa.AssigneeId);
    } 
    
}