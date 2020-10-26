/**
* @author      Avinash Jain
* @date      28/08/2019
* @description    Controller for the Lightning component GCP_TFD_Generate_Document       
*/

public With Sharing class GCP_TFD_UpdateGenerateButton {	
    @AuraEnabled
    /**
* @description controlle method for generate document lightning Component
* @Parameter passed is the case record id
*/
    Public static void updategeneratebutton(id recid){
        List<case> caselist =[select id,GCP_TFD_Generate_Document__c,status from case where id =:recid];
        try
        {
        	if(!caselist.isempty())
            {
                case c = new case();
                c.id = caselist[0].id;
                c.GCP_TFD_Generate_Document__c = true;
                update c;    
            }    
        }
        catch(exception e)
        {
            system.debug('Exception Catched :'+e.getMessage());
        }
    }
    
    
    /**
	 * @Method to fetch case fields
	 * @Parameter passed is the case record id
	 */
    @AuraEnabled
    public static case getCase(id caseId)
    {
        return [select Id,GCP_TFD_Approver_Cherck__c,GCP_TFD_Approver_Last_Name__c,RecordType.Developername from case where id=:caseId];
    }
    
    
    /**
	 * @description controller method to update is generic field
	 * @Parameter case record id
     */
    @AuraEnabled
    Public static void updateisgenericfield(id recid,string isGeneric){
        List<case> caselist =[select id,GCP_TFD_Is_Generic_Template__c from case where id =:recid];
        try
        {
        	if(!caselist.isempty())
            {
                case c = new case();
                c.id = caselist[0].id;
                if(isGeneric == 'Yes')
                c.GCP_TFD_Is_Generic_Template__c = True;
                else
                c.GCP_TFD_Is_Generic_Template__c = False;    
                update c;    
            }    
        }
        catch(exception e)
        {
            system.debug('Exception Catched :'+e.getMessage());
        }
    }
}