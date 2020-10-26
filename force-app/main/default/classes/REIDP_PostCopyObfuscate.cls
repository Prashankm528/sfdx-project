/**
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 4/2019
*
*/
global class REIDP_PostCopyObfuscate implements SandboxPostCopy {
    
    global void runApexClass(SandboxContext context) {
        
        REIDP_BatchDeleteCommunityUsers deleteCommunityUsers = new REIDP_BatchDeleteCommunityUsers();
        String batchprocessid  = Database.executebatch(deleteCommunityUsers);
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE ID =: batchprocessid ];
    }
    
}