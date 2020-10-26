/*****************************************************************************************
*   Date: 16/12/2019 
*   Author: Subin M Nair   
*   Description: The class which appends Thread Id to emails going out from DAP cases
*   Test Class : GCP_DAP_EmailMessage_Trigger_HandlerTest
*******************************************************************************************/
public with sharing class GCP_DAP_EmailMessage_Trigger_Handler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        List<EmailMessage> emailList = new List<EmailMessage>();
        emailList = n;
        Case parentCase = new Case();
        system.debug('The Outgoing email is : '+emailList);
        Id DAPRecordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('GCP_DAP_Deal_Request').getRecordTypeId();
        if(emailList.size()>0 && emailList[0].parentId != null)
        parentCase = [Select Id,RecordtypeId from Case where Id =:emailList[0].parentId];
        system.debug('queries record type id is : '+DAPRecordtypeId);
        system.debug('dynamic id value is : '+parentCase.recordtypeid);
        if(emailList.size()>0 && emailList[0].incoming == false && parentCase != null && DAPRecordtypeId == parentCase.recordtypeid)
        {
            String caseId = String.valueOf(emailList[0].parentId).substring(0, 15);
            String orgId = String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
            String threadId = 'ref:_'+orgId.substring(0,5)+orgId.substring(orgId.lastIndexOf('0')+1)+'._'+caseId.substring(0,5)+ caseId.substring(caseId.lastIndexOf('0')+1)+':ref';
            system.debug('The generated thread is is : '+threadId);
            
            for(EmailMessage em : emailList)
            {
                String initialEmail;
                String stringAfterBody;
                String stringBeforeBody;
                
                if(em.subject != null && !(em.subject.contains(threadId)))
                {
                    em.subject = em.subject + ' : '+threadId;
                }
            }
        }
    }
}