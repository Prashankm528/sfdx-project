/*****************************************************************************************
*   Date:         26/11/2018
*   Author:       Sumeet Kumar (Accenture)  
*   Description:  Global Credit Portal Inbound email handler class to create Cases and populates the Case 
    fields from content of the email.
*   Changes:
*   Version 1.1
*   Date: 16/05/2019
*   Author:       Ravisankar Siddam(TCS)
*   Description:  Added the logic to create case owner if the distribution list is mentioned in the CC Addresses as opposed to To Addresses
*   Date: 29/07/2019
*   Author:   Subin M Nair(TCS)
*   Description:  Fixed the existing email to case issue PBI#628347
*   Date: 23/10/2019
*   Author:   Subin M Nair(TCS)
*   Description:  Fixed the existing duplicate email issue PBI#767244 and Updating description for cases created 
    via protected email PBI#790728          
*   Date: 12/11/2019
*   Author:   Pooja Deokar(TCS)
*   Description:  Fixed the Display image in email preview issue PBI#762666
*   Date: 20/11/2019
*   Author:   Subin M Nair(TCS)
*   Description:  Adding new fix for duplicate email issue BUG#831059
*   Date: 18/12/2019
*   Author:   Subin M Nair(TCS)
*   Description:  Adding new fix for Protected email issue BUG#880829
****************************************************************************************/
global with sharing class GCP_DAP_EmailMessageHandler implements Messaging.InboundEmailHandler {
    static Boolean protectedFlag = false;
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String CaseId1;
        
        //Exception handling to avoid error messages bouncing back to sender
        Savepoint sp = Database.setSavepoint();
        try {
            system.debug('Incominggggggggg : '+email);
            //Assign the Case Record types into a map to get the Record type Id based on it's name- Starts.
            
            List<RecordType> rtypes = [Select Name, Id From RecordType
                                       where sObjectType='Case' and isActive=true];
            Map<String,String> CaseRecordTypes = New Map<String,String>{};
                for (RecordType rt : rtypes) {
                    CaseRecordTypes.put(rt.Name,rt.Id);
                }
            //Get the Queue Name
            String queueName;
            String QueueId;
            String CaseDistributionList;
            List<String> distributionlist = new List<String>();
            try{
            
                if(email.toAddresses != NULL)
                {
                 for (GCP_SYS_Queue_Email_Mapping__c q : [select id,GCP_ETY_Queue_Name__c,GCP_ETY_Case_Distribution_List__c from GCP_SYS_Queue_Email_Mapping__c where                                    
                                                      GCP_ETY_Distribution_List__c = :email.toAddresses limit 1]) 
                 {            
                    
                    if (q.GCP_ETY_Queue_Name__c != NULL){
                        queueName = q.GCP_ETY_Queue_Name__c;
                        CaseDistributionList = q.GCP_ETY_Case_Distribution_List__c;
                        distributionlist.add(q.GCP_ETY_Case_Distribution_List__c);
                    }
                 }
                
                }
              

                if(distributionlist.isEmpty() && email.ccAddresses != NULL)
                {
                 system.debug('Distribution List Empty and cc Address is eing used');
                 for (GCP_SYS_Queue_Email_Mapping__c q : [select id,GCP_ETY_Queue_Name__c,GCP_ETY_Case_Distribution_List__c from GCP_SYS_Queue_Email_Mapping__c where
                                                      GCP_ETY_Distribution_List__c = :email.ccAddresses limit 1]) 
                 {
                 
                    if (q.GCP_ETY_Queue_Name__c != NULL){
                        queueName = q.GCP_ETY_Queue_Name__c;
                        CaseDistributionList = q.GCP_ETY_Case_Distribution_List__c;
                    }
                 }

                 }

         
                 for (Group grp : [select Id from Group where Type = 'Queue' and DeveloperName =: queueName limit 1]) {
                    if(grp.id !=Null)   {
                        QueueId = grp.Id;
                        
                    }
                 }    
    
            } Catch(Exception e){
        system.debug('Exception Details : '+e);
                // QueueId remains Null
            }
            
                  
            
            //Check if the subject has the thread Id


            String[] splitcaseThread1stRef = email.subject.split('\\[ ref:');
            //Check if the email body has the thread Id
            system.debug('thread id is : '+splitcaseThread1stRef);
            system.debug('thread id size is : '+splitcaseThread1stRef.size());

            String[] caseThreadInBody = new String[]{};
                if(email.htmlBody != null)
                try{
                    caseThreadInBody = email.htmlBody.split('ref:');}
            catch(exception e){
      system.debug('Exception Details : '+e);
            }
            if(splitcaseThread1stRef.size() > 1){


//find the caseId by matching subject ThreadId

system.debug('inside thread id if');

                String[] splitcaseThread2ndRef = splitcaseThread1stRef[1].split(':ref \\]');
                if(splitcaseThread2ndRef.size() > 0){
                    String caseThreadId = splitcaseThread2ndRef[0];
                    try {
                        system.debug('caseThreadId = '+caseThreadId);
                        caseId1 = Cases.getCaseIdFromEmailThreadId(caseThreadId);
                        system.debug('Case Id 1 = '+caseId1);
                    }
                    catch (Exception e) {
          //not valid format, caseId remains null
          system.debug('Exception Details : '+e);
                    }
                }
            }else if(caseThreadInBody.size() > 1){
                


//find the caseId by matching Email body's ThreadId
                


              String[] threadId = caseThreadInBody[1].split(':ref');
                if(threadId.size() > 0){
                    String caseThreadId = threadId[0];
                    system.debug('caseThreadId = '+caseThreadId);
                    try {
                        caseId1 = Cases.getCaseIdFromEmailThreadId(caseThreadId);
                    }
                    catch (Exception e) {
          system.debug('Exception Details : '+e);
          //not valid format, caseId remains null
          }
                }
            } 
            //Run the Case creation process  
            if (caseId1 == NULL){
                //Populate the case fields and insert a new Case record into Salesforce. Starts here.
                Case c = New Case();
                List<String> emailBody = new List<String>();
                //Assigning the email body into a list of string for each line of the email
                if(email.plainTextBody!= null)
                emailBody = email.plainTextBody.split('\n');
                List<String> emailBodyLoop;
                Map<integer,string> EmailBodyString = New Map<integer,string>{};
                    String BP_LE;
                String CounterParty;
                Boolean AdditionalData = False;
                Boolean Value = False;
                Boolean BPLegalEntity = False;
                Boolean ValueUSD = False;
                
                
                
                //Check the format of the email template
                for (integer i=0;i<emailbody.size();i++){
                    if(emailbody[i]=='Additional Data'){system.debug('Inside additional data');AdditionalData = True;} 
                    if(emailbody[i]=='BP Legal Entity'){BPLegalEntity = True;} 
                    if(emailbody[i]=='Value'){Value = True;} 
                    if(emailbody[i]=='Value ($)'){ValueUSD = True;} 
                    if(emailbody[i]=='Value ($)'){
                        break;
                    }
                }
                //Parse Email Plain Text body and assign values to Case fields if the email is in desired format. 
                
                If (AdditionalData && Value && BPLegalEntity && ValueUSD)    {
                    for (integer i=0;i<=emailbody.size();i++){
                        if(emailbody[i]=='Assumed Gross Margin *' && (emailbody[i+2]=='Payment Terms *' || emailbody[i+1]=='')){
                            Try{ 
                                if(emailbody[i+2]=='Payment Terms *')
                                c.GCP_DAP_Assumed_Gross_Margin__c = integer.valueof(emailbody[i+1]);
                                else if(emailbody[i+1]=='')
                                c.GCP_DAP_Assumed_Gross_Margin__c = integer.valueof(emailbody[i+2]);
                            }
                            Catch(Exception e) {
                                system.debug('Exception Details : '+e);
                                //Assumed Gross Margin will have blank value.
                            }
                        }
                        else if(emailbody[i]=='Payment Terms *' && (emailbody[i+2]=='Delivery Dates' || emailbody[i+1]=='')){
                            Try{ 
                                if(emailbody[i+2]=='Delivery Dates')
                                c.GCP_DAP_Payment_Terms__c = emailbody[i+1];
                                else if(emailbody[i+1]=='')
                                c.GCP_DAP_Payment_Terms__c = emailbody[i+2];
                            }
                            Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Delivery Dates' && (emailbody[i+2]=='Inco Terms' || emailbody[i+1]=='')){
                            Try{ 
                                if(emailbody[i+2]=='Inco Terms')
                                c.GCP_DAP_Delivery_Dates__c = emailbody[i+1];
                                else if (emailbody[i+1]=='')
                                c.GCP_DAP_Delivery_Dates__c = emailbody[i+2];
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Inco Terms' && (emailbody[i+2]=='Port' || emailbody[i+1]=='')){
                            Try{ 
                            if(emailbody[i+2]=='Port')
                            c.GCP_DAP_Inco_Terms__c = emailbody[i+1];
                            else if (emailbody[i+1]=='')
                            c.GCP_DAP_Inco_Terms__c = emailbody[i+2];   
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Port' && (emailbody[i+2]=='Other' || emailbody[i+1]=='')){
                            Try {
                                if(emailbody[i+2]=='Other')
                                c.GCP_DAP_Port__c = emailbody[i+1];
                            else if(emailbody[i+1]=='')
                                c.GCP_DAP_Port__c = emailbody[i+2];
                                }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Other'){
                            Try { 
                            if(emailbody[i+1]=='')
                            c.GCP_DAP_Other_Email_Notes__c = emailbody[i+2];
                            else c.GCP_DAP_Other_Email_Notes__c = emailbody[i+1];
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='BP Trading Company' && (emailbody[i+2]=='Counterparty LE' || emailbody[i+1]=='')){
                            Try { 
                            if(emailbody[i+2]=='Counterparty LE')
                            c.GCP_DAP_BP_Trading_Company__c = emailbody[i+1];
                            else if(emailbody[i+1]=='')
                            c.GCP_DAP_BP_Trading_Company__c = emailbody[i+2];
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='NG Counterparty' && (emailbody[i+2]=='Start Date' || emailbody[i+1]=='')){
                            Try{ 
                            if(emailbody[i+2]=='Start Date')
                            c.GCP_DAP_NG_Counterparty__c = emailbody[i+1];
                            else if(emailbody[i+1]=='')
                            c.GCP_DAP_NG_Counterparty__c = emailbody[i+2];
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Start Date' && (emailbody[i+2]=='End Date' || emailbody[i+1]=='')){
                            Try {
                                if(emailbody[i+2]=='End Date')
                                c.GCP_DAP_Start_Date__c = convertSFDCdate(emailBody[i+1]);
                                else if(emailbody[i+1]=='')
                                c.GCP_DAP_Start_Date__c = convertSFDCdate(emailBody[i+2]);
                                }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='End Date' && (emailbody[i+2]=='Price ($)' || emailbody[i+1]=='')){
                            Try {
                                if(emailbody[i+2]=='Price ($)')
                                c.GCP_DAP_End_Date__c = convertSFDCdate(emailBody[i+1]);
                                else if(emailbody[i+1]=='')
                                c.GCP_DAP_End_Date__c = convertSFDCdate(emailBody[i+2]);
                                }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        
                        else if(emailbody[i]=='Price ($)' && (emailbody[i+2]=='Peak Volume' || emailbody[i+1]=='')){
                            Try {
                                if(emailbody[i+2]=='Peak Volume')
                                c.GCP_DAP_Price__c = integer.valueof(emailBody[i+1].replace(',',''));
                                else if(emailbody[i+1]=='')
                                c.GCP_DAP_Price__c = integer.valueof(emailBody[i+2].replace(',',''));
                                }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                        }
                        else if(emailbody[i]=='Peak Volume' && (emailbody[i+2]=='Value ($)' || emailbody[i+1]=='')){
                            Try{ 
                            if(emailbody[i+2]=='Value ($)')
                            {
                            c.GCP_DAP_Peak_Volume__c = integer.valueof(emailBody[i+1].replace(',',''));
                            }
                            else if(emailbody[i+1]=='')
                            {
                            c.GCP_DAP_Peak_Volume__c = integer.valueof(emailBody[i+2].replace(',','')); 
                            }
                            c.GCP_DAP_Units_of_Measurement_Peak_Volume__c = 'BBL';
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                            
                        }
                        else if(emailbody[i]=='Value ($)'){
                            Try{
                            if(emailbody[i+1]=='')
                            c.GCP_DAP_Value__c = integer.valueof(emailBody[i+2].replace(',',''));
                            else 
                            c.GCP_DAP_Value__c = integer.valueof(emailBody[i+1].replace(',',''));
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                            
                        }
                        else if(emailbody[i]=='BP Legal Entity' && (emailbody[i+2]=='BP Trading Company' || emailbody[i+1]=='')){
                            Try { 
                            if(emailbody[i+2]=='BP Trading Company')
                            BP_LE = emailBody[i+1];
                            else if(emailbody[i+1]=='')
                            BP_LE = emailBody[i+2]; 
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                            
                        }
                        else if(emailbody[i]=='Counterparty LE' && (emailbody[i+2]=='NG Counterparty' || emailbody[i+1]=='')){
                            Try{ 
                            if(emailbody[i+2]=='NG Counterparty')
                            CounterParty = emailBody[i+1];
                            else if(emailbody[i+1]=='')
                            CounterParty = emailBody[i+2];
                            }
                             Catch(Exception e){
                                system.debug('Exception Details : '+e);
                                //Assign Null Value
                                }
                            
                        }
                        else if(emailbody[i].contains('peak valuation')){
                           system.debug('Email body of i inside remainins limit : '+emailbody[i]);
                           system.debug('Email body of i+1 inside remainins limit : '+emailbody[i+1]);
                            List<String> stringPeakValuation = New List<String>();
                            stringPeakValuation = emailbody[i].split(' ');
                            
                            for(integer j =0;j<stringPeakValuation.size();j++){
                                if(stringPeakValuation[j]=='peak' && stringPeakValuation[j+1]=='valuation')
                                {    
                                    Try {c.GCP_DAP_Peak_Valuation__c = integer.valueof(stringPeakValuation[j+3].replace(',',''));}
                                     Catch(Exception e){
                                    system.debug('Exception Details : '+e);
                                    //Assign Null Value
                                }
                                    
                                }
                                else if(stringPeakValuation[j]=='remaining' && stringPeakValuation[j+1]=='limit')
                                {
                                    Try{c.GCP_DAP_Remaining_Limit__c = integer.valueof(stringPeakValuation[j+3].replace(',',''));}
                                     Catch(Exception e){
                                    system.debug('Exception Details : '+e);
                                    //Assign Null Value
                                }
                                }
                            }
                        }
                        List<String> tempString = New List<String>();
                        tempString = emailbody[i].split(' ');
                        system.debug('the new emailbody is : '+ emailbody[i]);
                        system.debug('tempString is : '+ tempString);
                        if(emailbody[i].contains('USD.') && tempString.size()==2)
                        {
                            List<String> stringRemainingLimit = New List<String>();
                            stringRemainingLimit = emailbody[i].split(' ');
                            system.debug('stringRemainingLimit[0] us : '+stringRemainingLimit[0]);
                            Try {c.GCP_DAP_Remaining_Limit__c = integer.valueof(stringRemainingLimit[0].replace(',',''));}
                                     Catch(Exception e){
                                    system.debug('Exception Details : '+e);
                                    //Assign Null Value
                                }
                        }
                        system.debug('Value of line '+i+' ='+emailbody[i]);
                        if(emailbody[i]=='Value ($)'){
                            break;
                        }
                    }
                    List<GCP_ETY_Credit_Entity__c> TempBPLE  = [SELECT Id from GCP_ETY_Credit_Entity__c where Name=:BP_LE AND RecordType.Name='GCP ETY BPLE' AND GCP_ETY_Is_Deleted__c = false];
                    if(TempBPLE.size()==1){
                        c.GCP_DAP_BPLE__c = TempBPLE[0].id;
                    }
                    List<GCP_ETY_Credit_Entity__c> TempCounterParty = [SELECT Id from GCP_ETY_Credit_Entity__c where Name=:CounterParty AND RecordType.Name='GCP ETY Counterparty' AND GCP_ETY_Is_Deleted__c = false]; 
                    if(TempCounterParty.size()==1){
                        c.GCP_DAP_Counterparty__c=TempCounterParty[0].Id;
                    } 
                } 
                //system.debug('Current description isssss : '+email.plainTextBody.left(32000));
                if(email.plainTextBody != null)
                c.Description = email.plainTextBody.left(32000);
                else if (email.plainTextBody == null && email.HTMLBody.contains('has sent you a protected message.') && email.HTMLBody.contains('img src="https://outlook.office365.com/Encryption/lock.png"'))
                {
                c.Description = 'Protected Email data cannot be decrypted within Salesforce.';
                protectedFlag = true;
                }
                else c.Description = 'No Description available';
                c.Subject = email.subject;
                c.RecordTypeId = CaseRecordTypes.get('GCP DAP - Deal Request');
                if(QueueId != NULL){
                    c.OwnerId = QueueId;
                }
                c.GCP_DAP_Assumed_Gross_Margin_Currency__c = 'USD';
                c.GCP_DAP_Peak_Valuation_Currency__c ='USD';
                c.GCP_DAP_Price_Currency__c = 'USD';
                c.GCP_DAP_Remaining_Limit_Currency__c = 'USD';
                c.GCP_DAP_Value_Currency__c = 'USD';
                c.Origin = 'Email';
                system.debug('From Address='+email.fromAddress);
                c.GCP_DAP_Trader__c = string.ValueOf(email.fromAddress);
                //c.GCP_DAP_Trader__c = email.fromAddress;
				c.GCP_DAP_Requester_Email__c = email.fromAddress;
                c.GCP_DAP_Distribution_List__c = CaseDistributionList;
                insert c;
                createEmailMessage(email,c.id);
            }
            //For email related to existing case, attach the email message with case.
            Else {createEmailMessage(email,CaseId1);}
        } catch(exception e2){
            Database.rollback(sp);
            Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
            Integer bodyLen = F.getLength();            
            bodyLen = bodyLen - 5000;
            Case cs = new Case();
            
            cs.Subject = email.subject;
            if (cs.Subject.length() > 255)  
            { cs.Subject = cs.Subject.substring(0,255);}
            //Assign the Case Record types into a map to get the Record type Id based on it's name- Starts.
            List<RecordType> rtypes = [Select Name, Id From RecordType
                                       where sObjectType='Case' and isActive=true];
            Map<String,String> CaseRecordTypes = New Map<String,String>{};
                for (RecordType rt : rtypes) {
                    CaseRecordTypes.put(rt.Name,rt.Id);
                }
            cs.RecordTypeId = CaseRecordTypes.get('GCP DAP - Deal Request');  
            cs.Description = '\n\n' + e2.getMessage();
            cs.Description += '\n\n' + e2.getStackTraceString();
            
            String queueName;
            String QueueId;
            String CaseDistributionList;
            List<String> distributionlistex = new List<String>();
            try{
    
                if(email.toAddresses != NULL)
                {
                 for (GCP_SYS_Queue_Email_Mapping__c q : [select id,GCP_ETY_Queue_Name__c,GCP_ETY_Case_Distribution_List__c from GCP_SYS_Queue_Email_Mapping__c where                                    
                                                      GCP_ETY_Distribution_List__c = :email.toAddresses limit 1]) 
                 {
                    
                    if (q.GCP_ETY_Queue_Name__c != NULL){
                        queueName = q.GCP_ETY_Queue_Name__c;
                        CaseDistributionList = q.GCP_ETY_Case_Distribution_List__c;
                        distributionlistex.add(q.GCP_ETY_Case_Distribution_List__c);
                    }
                 }
                
                }                

                if(distributionlistex.isEmpty() && email.ccAddresses != NULL)
                {
                 for (GCP_SYS_Queue_Email_Mapping__c q : [select id,GCP_ETY_Queue_Name__c,GCP_ETY_Case_Distribution_List__c from GCP_SYS_Queue_Email_Mapping__c where
                                                      GCP_ETY_Distribution_List__c = :email.ccAddresses limit 1]) 
                 {
                    
                    if (q.GCP_ETY_Queue_Name__c != NULL){
                        queueName = q.GCP_ETY_Queue_Name__c;
                        CaseDistributionList = q.GCP_ETY_Case_Distribution_List__c;
                    }
                 }

                 }
            
                 for (Group grp : [select Id from Group where Type = 'Queue' and DeveloperName =: queueName limit 1]) {
                    if(grp.id !=Null)   {
                        QueueId = grp.Id;
                        
                    }
   
                }
                
            } Catch(Exception e){
        system.debug('Exception Details : '+e);
                // QueueId remains Null
            }
            
            if (QueueId!=NULL){cs.OwnerId =  QueueId;}
            
            insert cs;
            
            EmailMessage em = new EmailMessage();
            
            if (email.toAddresses != null) {
                String toAddresses = '';
                for (String ta : email.toAddresses) {
                    toAddresses += ta + ';';
                }
                if (toAddresses != '') {
                    toAddresses = toAddresses.substring(0, toAddresses.length()-1);
                }
                em.ToAddress = toAddresses;
            }
            
            if (email.ccAddresses != null) {
                String ccAddresses = '';
                for (String cc : email.ccAddresses) {
                    ccAddresses += cc + ';';
                }
                if (ccAddresses != '') {
                    ccAddresses = ccAddresses.substring(0, ccAddresses.length()-1);
                }        
                em.CcAddress = ccAddresses;
            }
            em.FromAddress = email.fromAddress;
            em.FromName = email.fromName;
            em.Incoming = true;
            em.MessageDate = system.now();
            em.ParentId = cs.Id;
            em.Subject = email.subject;
            if (email.Subject.length() > 255)  
            {  em.Subject = email.subject.substring(0,255);}
            //Check max size of body
            Boolean flgTruncatedBody = false;
            //HTML
            if (email.htmlBody != null && email.htmlBody.length() > bodyLen) {
                em.HtmlBody = '--Message Truncated - See Attachment for full message--<br/><br/>';
                em.HtmlBody += email.htmlBody.substring(0,bodyLen-100);                
                flgTruncatedBody = true;
            }
            else {
                em.HtmlBody = email.htmlBody;
            }
            
            //Plain Text
            if (email.plainTextBody != null && email.plainTextBody.length() > bodyLen) {
                em.TextBody = '--Message Truncated - See Attachment for full message--\n\n';
                em.TextBody += email.plainTextBody.substring(0,bodyLen-100);  
                flgTruncatedBody = true;
            }
            else {
                em.TextBody = email.plainTextBody;
            }
            insert em;
            
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null) {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = em.Id;
                    attachments.add(attachment);
                }
            }
            if(email.binaryAttachments != null) {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    Attachment attachment = new Attachment();                        
                    attachment.Name = bAttachment.fileName;
                    attachment.Body = bAttachment.body;
                    attachment.ParentId = em.Id;
                    attachments.add(attachment);
                }
            }
            
            //If body truncated, add as attachment
            if (flgTruncatedBody && em.HTMLBody != null) {
                Attachment attachment = new Attachment();
                attachment.Name = 'Full HTML Email Body.html';
                attachment.Body = Blob.valueOf(email.htmlBody);
                attachment.ParentId = em.Id;
                attachments.add(attachment);
            }
            else if (flgTruncatedBody && em.TextBody != null) {
                Attachment attachment = new Attachment();
                attachment.Name = 'Full Plain Text Email Body.txt';
                attachment.Body = Blob.valueOf(email.plainTextBody);
                attachment.ParentId = em.Id;
                attachments.add(attachment);
            }
            
            
            if(!attachments.isEmpty() && protectedFlag == false)
                insert attachments;                
            
        }
        //Populate the case fields and insert a new Case record into Salesforce. Ends here.
        return result; 
    }
    //Method to convert the date format into salesforce date format  
    static date convertSFDCdate(string InputDate){
        
        date SfdcDate;
        //Split the email date by space
        List <String> temp_start_date = InputDate.split(' ');
        //if the day is single then prefix it with 0
        if(temp_start_date[0].length() ==1){
            temp_start_date[0]= '0'+temp_start_date[0];
        }
        //Change the month format from MMM to MM
        if (temp_start_date[1].toUpperCase()=='DEC'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 12, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='NOV'){
            
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 11, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='OCT'){
            
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 10, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='SEP'){
            
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 09, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='AUG'){
            
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 08, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='JUL'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 07, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='JUN'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 06, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        else if (temp_start_date[1].toUpperCase()=='MAY'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 05, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }else if (temp_start_date[1].toUpperCase()=='APR'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 04, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }else if (temp_start_date[1].toUpperCase()=='MAR'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 03, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }else if (temp_start_date[1].toUpperCase()=='FEB'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 02, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }else if (temp_start_date[1].toUpperCase()=='JAN'){
            Date d = Date.newInstance(integer.valueof(temp_start_date[2]), 01, integer.valueof(temp_start_date[0]));
            SfdcDate = d;
        }
        
        return SfdcDate;
    }
    //Method to create email message and associate that with task
   public static void createEmailMessage(Messaging.InboundEmail email,Id caseId)
    {
        Boolean flag = false;
        List<EmailMessage> emailList = [Select Id,TextBody,htmlbody,FromAddress,createddate,createdby.name from EmailMessage where ParentId =: caseId order by createddate desc];
        
        String truncateEmailBody;
        String truncateincomingBody;
        if(emailList.size()>0)
        truncateEmailBody = emailList[0].textbody.substringBefore('--------------- Original Message ---------------');
        if(email.plainTextBody != null)
        truncateincomingBody = email.plaintextbody.substringBefore('--------------- Original Message ---------------');
       
        if(truncateEmailBody != null & truncateincomingBody != null && truncateEmailBody.compareTo(truncateincomingBody)==0)
        {
            flag = true;
        }
        if(flag == false)
        {
            EmailMessage em = new EmailMessage();
            if (email.toAddresses != null) {
                String toAddresses = '';
                for (String ta : email.toAddresses) {
                    toAddresses += ta + ';';
                }
                if (toAddresses != '') {
                    toAddresses = toAddresses.substring(0, toAddresses.length()-1);
                }
                em.ToAddress = toAddresses;
            }
            if (email.ccAddresses != null) {
                String ccAddresses = '';
                for (String cc : email.ccAddresses) {
                    ccAddresses += cc + ';';
                }
                if (ccAddresses != '') {
                    ccAddresses = ccAddresses.substring(0, ccAddresses.length()-1);
                }        
                em.CcAddress = ccAddresses;
            }
            em.FromAddress = email.fromAddress;
            em.FromName = email.fromName;
            em.Incoming = true;
            em.MessageDate = system.now();
            em.ParentId = CaseId;
            em.Subject = email.subject;
            //Get Length of EmailMessage body field - 32K by default but may be increased to 128K by SF on request
            Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
            Integer bodyLen = F.getLength(); 
            system.debug('THE Max length is='+bodyLen);
            //Add buffer to max body length to ensure users don't hit max length error immediately when replying to a truncated email
            bodyLen = bodyLen - 5000;
            //Check max size of body
            Boolean flgTruncatedBody = false;
            //HTML
            
            
            if (email.htmlBody != null && email.htmlBody.length() > bodyLen) {
                em.HtmlBody = '--Message Truncated - See Attachment for full message--<br/><br/>';
                em.HtmlBody += email.htmlBody.substring(0,bodyLen-100);                
                flgTruncatedBody = true;
            }
            else {
                em.HtmlBody = email.htmlBody;
            }
            //Plain Text
            if (email.plainTextBody != null && email.plainTextBody.length() > bodyLen) {
                em.TextBody = '--Message Truncated - See Attachment for full message--\n\n';
                em.TextBody += email.plainTextBody.substring(0,bodyLen-100);  
                flgTruncatedBody = true;
            }
            else {
                em.TextBody = email.plainTextBody;
            }
            insert em;   
            
            //Insert the attachments
            List<Attachment> attachments = new List<Attachment>();        
            //Map used to insert attachment with Screenshot
            Map< String, ContentVersion > mapAttachments = new Map< String, ContentVersion >();
            map<ID,ID> mapContentDocumentID = new Map<ID,ID>();
            if(email.textAttachments != null) {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = em.Id;
                    attachments.add(attachment);
                }
            }
             if(email.binaryAttachments != null) {
                List<ContentVersion> cvList = new List<ContentVersion>();
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
               
                for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                    
                    for(integer i = 0; i < binAttach.headers.size(); i++) {
                        //Header Value
                        String headerValue = binAttach.headers[i].value;
                        if(headerValue.startsWith('<')) {                       
                            headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                            mapAttachments.put(headerValue, new ContentVersion(Title = binAttach.fileName, VersionData = binAttach.body, 
                                                            PathOnClient = '/' + binAttach.fileName));
                        }
                        else if(headerValue.startsWith('attachment;')){
                            Attachment attachment = new Attachment();                        
                            attachment.Name = binAttach.fileName;
                            attachment.Body = binAttach.body;
                            attachment.ParentId = em.Id;
                            attachments.add(attachment);
                        }
                    }   
                }
                if(!mapAttachments.isEmpty())
                {
                    insert mapAttachments.values();
                    
                    cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :mapAttachments.values()];
                    for (ContentVersion cv : cvList) {
                            mapContentDocumentID.put(cv.id,cv.id);
                           
                            ContentDocumentLink cl = new ContentDocumentLink();
                            cl.ContentDocumentId = cv.ContentDocumentId;
                            cl.LinkedEntityId = em.id; 
                            cl.ShareType = 'V';
                            cl.Visibility = 'AllUsers';
                            cdlList.add(cl);
                                                
                            if(attachments.isEmpty()){
                                ContentDocumentLink c2 = new ContentDocumentLink();
                                c2.ContentDocumentId = cv.ContentDocumentId;
                                c2.LinkedEntityId = CaseId; 
                                c2.ShareType = 'V';
                                c2.Visibility = 'AllUsers';
                                cdlList.add(c2);
                            }
                           
                    }
                    if(!cdlList.isEmpty())
                        insert cdlList;
                }   
            }
            //If body truncated, add as attachment
            if (flgTruncatedBody && em.HTMLBody != null) {
                Attachment attachment = new Attachment();
                attachment.Name = 'Full HTML Email Body.html';
                attachment.Body = Blob.valueOf(email.htmlBody);
                attachment.ParentId = em.Id;
                attachments.add(attachment);
            }
            else if (flgTruncatedBody && em.TextBody != null) {
                Attachment attachment = new Attachment();
                attachment.Name = 'Full Plain Text Email Body.txt';
                attachment.Body = Blob.valueOf(email.plainTextBody);
                attachment.ParentId = em.Id;
                attachments.add(attachment);
                
            }
            if(!attachments.isEmpty() && protectedFlag == false)
                insert attachments;  
                
                //Process inline images and update the HTML Body
                for(String headerValue : mapAttachments.keySet()) {
                    //Reference Link
                           
                    String refLink = URL.getSalesforceBaseUrl().toExternalForm()+'/sfc/servlet.shepherd/version/download/'+mapAttachments.get(headerValue).Id;
                    system.debug('refLink ==='+refLink );
                    //update   the email body with reference link
                    em.HtmlBody = em.HtmlBody.replaceAll('cid:' + headerValue, refLink);
                }
            update em; 
        } 
    }
}