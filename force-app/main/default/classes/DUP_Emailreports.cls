/****************************************************************************************
*   Date:           17March2020
*   Author:         Babul Jha - Wipro
*   Description:    Class to email all repurts in DUP to the specified email id.     
****************************************************************************************/
global with sharing class DUP_Emailreports implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        string ToAddress = System.Label.DUP_Email_address_for_DUP_Reports;
        List<String> toaddress_list = new List<String>();
        Integer n = ToAddress.indexOf(';');
  		string email1 = ToAddress.substring(0,n);
        toaddress_list.add(email1);
  		string email2 = ToAddress.substring(n+1,ToAddress.length());
        toaddress_list.add(email2);
        

        List<report> reports = new List<report>();
        
        for(report r: [Select id, DeveloperName, Name from report where DeveloperName like 'DUP%']){
             if(r.DeveloperName.startsWith('DUP_') && !r.DeveloperName.startsWith('DUP_HomePage'))
            {
               reports.add(r) ;                
            }
        }
        System.debug('re'+reports);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List <Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        try{
            for(report r : reports) {
                ApexPages.PageReference tempReport = new ApexPages.PageReference('/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId='+r.Id);
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(r.Name+'.xls'); 
                 if(!Test.isRunningTest()){
                 attachment.setBody(tempReport.getContent());
                 }else{
                 attachment.setBody(Blob.valueof('TEST BODY'));
                 }
                attachment.setContentType('text/csv');
                attachments.add(attachment); 
            }
            message.setFileAttachments(attachments);
            
        }
        catch (ListException  e){
            system.debug( e.getMessage() );
        }
        
        message.setSubject('DUP KPI Reports'); 
        message.setPlainTextBody('Please find the attached reports, Thank You!');
        message.setToAddresses(toaddress_list);
        //message.setCCAddresses( new String[] {cc});
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        
    }
}