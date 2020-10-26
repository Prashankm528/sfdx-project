/*****************************************************************************************
*   Date:      26/11/2018
*   Author:    Sumeet Kumar (Accenture)  
*   Description:   Test Class for Class GCP_DAP_EmailMessageHandler
*   Changes: 1.1   
    Date:24/05/2019
    Author: Sumeet Kumar (Accenture)
    Description- Splitted the Method 5 into 2 parts to run for 6 months in each time
    
    Author: RaviSankar Siddam(TCS)
    Description: Added Additional lines to increase Code coverage

*   Date: 12/11/2019
*   Author:   Pooja Deokar(TCS)
*   Description:  Added unitTest10 method to increase code coverage afted Fixed the Display image in email preview issue PBI#762666
****************************************************************************************/
@isTest
private with sharing class GCP_DAP_EmailMessageHandlerTest {
    
    //Below method tests where email is not in defined format 
    static testMethod void unitTest1(){
         // create a new header and email and envelope object
        List<Messaging.InboundEmail.Header> headerList = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header head = new Messaging.InboundEmail.Header();
        head.name = 'Received';
        head.value='test1@bp.com';
        headerList.add(head);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'test@bp.com';
        List<String> addresses = new String[2];
        addresses[0] = 'test1@bp.com';
        List<String> ccaddresses = new String[2];
        ccaddresses[0] = 'test1@bp.com';
        
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.ccAddresses = ccaddresses;
        email.plainTextBody = 'email body\n2225256325\nTitle limit of 0 USD.';
        email.headers = headerList;
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
        
        
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        
        Test.startTest();
        //Test records created
        
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(1, lstCases.size()); 
        
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(1, lstEMs.size());
        Test.stopTest();
    }
    
    static testMethod void unitTest2(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<String> addresses = new String[2];
        addresses[0] = 'test@bp.com';
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        Test.startTest();
        //Insert Account
        List<RecordType> rtypes = [Select DeveloperName, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> AccountRecordTypes = New Map<String,String>{};
            for (RecordType rt : rtypes) {
                AccountRecordTypes.put(rt.DeveloperName,rt.Id);
            }
        Account ac1 = new account();
        ac1.name='Pacific International Lines (Private) Limited';
        ac1.RecordTypeId = AccountRecordTypes.get('ICRM_Legal_Entity');
        insert ac1;
        
        Account ac2 = new account();
        ac2.name='BP Singapore Pte. Limited';
        ac2.RecordTypeId = AccountRecordTypes.get('ICRM_Legal_Entity');
        insert ac2;
        
        
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.plainTextBody = 'The result was NOT OK TO TRADE, showing a peak valuation of 2,632,000 USD and remaining limit of 0 USD\n\nAdditional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\ntest\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Feb 2018\n\nEnd Date\n\n1 Mar 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\nValue ($)\n\n886,000\n\nThe credit instructions for this counterparty are:';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(1, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(1, lstEMs.size());
        Test.stopTest();
        
    }
    
    static testMethod void unitTest3(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'robandstacey2018@gmail.com';
        List<String> addresses = new String[2];
        addresses[0] = 'someInboundaddress@email.com';
        
        // setup the data for the email
        email.subject = 'Test  [ ref:_00D1q8cHI._5001q1DZ7D:ref ]';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.plainTextBody = 'Additional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\ntest\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Apr 2018\n\nEnd Date\n\n1 May 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\nValue ($)\n\n886,000\n\nThe credit instructions for this counterparty are:';
        email.htmlBody = '';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            Test.startTest();
        
        // add a Text attachment            
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(1, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(1, lstEMs.size());
        Test.stopTest();
    }
    
    static testMethod void unitTest4(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'test@bp.com';
        List<String> addresses = new String[2];
        addresses[0] = 'someInboundaddress@email.com';
        Test.startTest();
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.plainTextBody = 'email body\n2225256325\nTitle [ ref:_00D1q8cHI._5001q1DZ7D:ref ]';
        email.htmlBody = 'email body\n2225256325\nTitle [ ref:_00D1q8cHI._5001q1DZ7D:ref ]';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(1, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(1, lstEMs.size());
        Test.stopTest();
    }
    
    //Below method will check test the month logic from Jan to Feb
    static testMethod void unitTest5(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'test@bp.com';
        List<String> addresses = new String[2];
        addresses[0] = 'someInboundaddress@email.com';
        
        
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        List<String> months = new List<String> {'JAN','FEB','MAR','APR','MAY','JUN'};
            
            // setup the data for the email
            email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.ccAddresses = addresses;
        for (integer i=0;i<months.size();i++){
            email.plainTextBody = 'Additional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Dec 2018\n\nEnd Date\n\n1 '+months[i]+' 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\nValue ($)\n\n886,000\n\nThe credit instructions for this counterparty are:';
            // add an Binary attachment
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
                
                // add a Text attachment            
                Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            
                
        }
        Test.startTest();
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
            TESTGCPInboundEmail.handleInboundEmail(email,env);
        
        List<Case> lstCases = [select Id from Case];
        
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        Test.stopTest();
        system.assertEquals(1, lstCases.size()); 
        system.assertEquals(1, lstEMs.size());
        
    }
    
    //Below method will check test the month logic from Jul to Dec
    static testMethod void unitTest6(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'test@bp.com';
        List<String> addresses = new String[2];
        addresses[0] = 'someInboundaddress@email.com';
        
        
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        List<String> months = new List<String> {'JUL','AUG','SEP','OCT','NOV','DEC'};
            
            // setup the data for the email
            email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.ccAddresses = addresses;
        for (integer i=0;i<months.size();i++){
            email.plainTextBody = 'Additional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Dec 2018\n\nEnd Date\n\n1 '+months[i]+' 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\nValue ($)\n\n886,000\n\nThe credit instructions for this counterparty are:';
            // add an Binary attachment
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
                
                // add a Text attachment            
                Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
              
        }
        Test.startTest();
         GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env); 
        List<Case> lstCases = [select Id from Case];
         
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        Test.stopTest();
        system.assertEquals(1, lstCases.size());
        system.assertEquals(1, lstEMs.size());
        
    } 
    //Chck for the size limit of email body
    
    static testMethod void unitTest7(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        env.toAddress = 'test@bp.com';
        List<String> addresses = new String[2];
        addresses[0] = 'test@bp.com';
        
        Test.startTest();
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        //assigning large value to email body
        email.plainTextBody = 'hello';
        email.htmlBody = Null;
        for (integer i=0;i<=400;i++)
        {
            email.htmlbody +='111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';  
        }
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            
            TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.htmlBody ='Hello';
        for (integer i=0;i<=400;i++)
        {
            email.plainTextBody +='111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';  
        }
        
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.subject=email.plainTextBody;
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(3, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(3, lstEMs.size());
        Test.stopTest();
    }
    
    static testMethod void unitTest8(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<String> addresses = new String[2];
        addresses[0] = 'test@bp.com';
        List<String> toaddress = new String[2];
        toaddress[0] = 'someaddress@email.com';        
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        Test.startTest();
        //Insert Account
        List<RecordType> rtypes = [Select DeveloperName, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> AccountRecordTypes = New Map<String,String>{};
            for (RecordType rt : rtypes) {
                AccountRecordTypes.put(rt.DeveloperName,rt.Id);
            }
        Account ac1 = new account();
        ac1.name='Pacific International Lines (Private) Limited';
        ac1.RecordTypeId = AccountRecordTypes.get('ICRM_Legal_Entity');
        insert ac1;
        
        Account ac2 = new account();
        ac2.name='BP Singapore Pte. Limited';
        ac2.RecordTypeId = AccountRecordTypes.get('ICRM_Legal_Entity');
        insert ac2;
        
        
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = toaddress;
        email.ccAddresses = addresses;
        email.plainTextBody = 'The result was NOT OK TO TRADE, showing a peak valuation of 2,632,000 USD and remaining limit of 0 USD\n\nAdditional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\ntest\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Feb 2018\n\nEnd Date\n\n1 Mar 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\nValue ($)\n\n886,000\n\nThe credit instructions for this counterparty are:';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(1, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(1, lstEMs.size());
        Test.stopTest();
        
    } 

    static testMethod void unitTest9(){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        env.toAddress = 'test@bp.com';
        List<String> toaddress = new String[2];
        toaddress[0] = 'someaddress@email.com';        
        List<String> addresses = new String[2];
        addresses[0] = 'test@bp.com';
        
        Test.startTest();
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = toaddress;
        email.ccAddresses = addresses;        
        //assigning large value to email body
        email.plainTextBody = 'hello';
        email.htmlBody = Null;
        for (integer i=0;i<=400;i++)
        {
            email.htmlbody +='111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';  
        }
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            
            TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.htmlBody ='Hello';
        for (integer i=0;i<=400;i++)
        {
            email.plainTextBody +='111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';  
        }
        
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.subject=email.plainTextBody;
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(3, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(3, lstEMs.size());
        Test.stopTest();
    } 
    
    static testMethod void unitTest10(){
        // create a new email and envelope object
        List<Messaging.InboundEmail.Header> headerList = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header head = new Messaging.InboundEmail.Header();
        head.name = 'Received';
        head.value='test1@bp.com';
        headerList.add(head);
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        env.toAddress = 'test@bp.com';
        List<String> toaddress = new String[2];
        toaddress[0] = 'someaddress@email.com';        
        List<String> addresses = new String[2];
        addresses[0] = 'test@bp.com';
        
        Test.startTest();
        //Insert Data for Queue-Email Group Mapping
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = toaddress;
        email.ccAddresses = addresses;        
        //assigning large value to email body
        email.plainTextBody = 'hello';
        email.htmlBody = Null;
        email.headers = headerList;
        for (integer i=0;i<=400;i++)
        {
            email.htmlbody +='111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';  
        }
        
        //add headers
       Messaging.InboundEmail.Header hditem= new Messaging.InboundEmail.Header(); 
       email.headers=new Messaging.InboundEmail.Header[3]; 
       
       hditem.name='imageheader'; 
       hditem.value='<aaaa-bbb-ccc-dddd-eeee>'; 
       email.headers[0]=hditem;
       hditem.name='Return-Path'; 
       hditem.value='testabc'; 
       email.headers[1]=hditem;
       hditem.name = 'Received';
       hditem.value='test1@bp.com';
       email.headers[2]=hditem;
       
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        
        Messaging.InboundEmail.Header hditem1= new Messaging.InboundEmail.Header(); 
        attachment.headers=new Messaging.InboundEmail.Header[2];       
        hditem1.name='imageheader'; 
        hditem1.value='<aaaa-bbb-ccc-dddd-eeee>'; 
        attachment.headers[0]=hditem1;
        Messaging.InboundEmail.Header hditem2= new Messaging.InboundEmail.Header(); 
        hditem2.name='attachment'; 
        hditem2.value='attachment'; 
        attachment.headers[1]=hditem2;
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
            
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.htmlBody ='Hello';
        for (integer i=0;i<=100;i++)
        {
            email.plainTextBody +='11111111111111111111111111111111111111111111111111111\n';  
        }
        
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.subject=email.plainTextBody;
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        List<Case> lstCases = [select Id from Case];
        //system.assertEquals(3, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        //system.assertEquals(3, lstEMs.size());
        Test.stopTest();
        system.assertEquals(3, lstCases.size()); 
        system.assertEquals(3, lstEMs.size());
    } 
    static testMethod void unitTest11(){
        GCP_SYS_Queue_Email_Mapping__c emailMapping = New GCP_SYS_Queue_Email_Mapping__c();
        emailMapping.GCP_ETY_Distribution_List__c='test@bp.com';
        emailMapping.GCP_ETY_Queue_Name__c ='GCP_DAP_NAGP_Deal_Requests';
        emailMapping.GCP_ETY_Case_Distribution_List__c = 'NAGP';
        insert emailMapping;
         // create a new header and email and envelope object
        List<Messaging.InboundEmail.Header> headerList = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header head = new Messaging.InboundEmail.Header();
        head.name = 'Received';
        head.value='test1@bp.com';
        headerList.add(head);
        Case cs = new Case();
        cs.subject='test';
        insert cs;
        Case cs1 = new Case();
        cs1.subject='test';
        insert cs1;
        EmailMessage em1 = new EmailMessage();
        em1.fromAddress = 'subin@bp.com';
        em1.toAddress = 'subin.nair@bp.com';
        em1.parentId=cs1.id;
        em1.textbody='email body\n222885256325\nTitle';
        insert em1;
        EmailMessage em2 = new EmailMessage();
        em2.fromAddress = 'subin@bp.com';
        em2.toAddress = 'subin.nair@bp.com';
        em2.parentId=cs1.id;
        em2.textbody='email body\n22252156325\nTitle';
        insert em2;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        List<String> addresses = new String[2];
        addresses[0] = 'test1@bp.com';
        List<String> ccaddresses = new String[2];
        ccaddresses[0] = 'test1@bp.com';
        
        // setup the data for the email
        email.subject = 'Test [ ref:_00D0Y1fRsz._5004G22sIqx:ref ]';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = addresses;
        email.ccAddresses = ccaddresses;
        email.htmlBody = 'email body\n2225256325\nTitle';
        email.plainTextBody = 'The result was NOT OK TO TRADE, and showing a peak valuation of 2,632,000 USD and remaining limit of 0 USD\n\nAdditional Data\n\nValue\n\nAssumed Gross Margin *\n\n5\n\nPayment Terms *\n\n30\n\nDelivery Dates\n\n2 Dec\n\nInco Terms\n\ntest\n\nPort\n\nSingapore\n\nOther\n\n(if any)\n\nBP Legal Entity\n\nBP Singapore Pte. Limited\n\nBP Trading Company\n\nBPS-MARINE - BP Singapore Pte. Limited\n\nCounterparty LE\n\nPacific International Lines (Private) Limited\n\nNG Counterparty\n\nPACIFIC INTL LINES SG\n\nStart Date\n\n2 Feb 2018\n\nEnd Date\n\n1 Mar 2019\n\nPrice ($)\n\n443.00\n\nPeak Volume\n\n2,000\n\n12,010 USD.\n\nValue ($)\n\n88,000\n\nThe credit instructions for this counterparty are:';
        //add headers
       Messaging.InboundEmail.Header hditem= new Messaging.InboundEmail.Header(); 
       email.headers=new Messaging.InboundEmail.Header[3]; 
       
       hditem.name='imageheader'; 
       hditem.value='<aaaa-bbb-ccc-dddd-eeee>'; 
       email.headers[0]=hditem;
       hditem.name='Return-Path'; 
       hditem.value='testabc'; 
       email.headers[1]=hditem;
       hditem.name = 'Received';
       hditem.value='test1@bp.com';
       email.headers[2]=hditem;
       
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        
        Messaging.InboundEmail.Header hditem1= new Messaging.InboundEmail.Header(); 
        attachment.headers=new Messaging.InboundEmail.Header[2];       
        hditem1.name='imageheader'; 
        hditem1.value='<aaaa-bbb-ccc-dddd-eeee>'; 
        attachment.headers[0]=hditem1;
        Messaging.InboundEmail.Header hditem2= new Messaging.InboundEmail.Header(); 
        hditem2.name='attachment'; 
        hditem2.value='attachment'; 
        attachment.headers[1]=hditem2;
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     
            
            // add a Text attachment            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };  
        
        Test.StartTest();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'test@bp.com';
        GCP_DAP_EmailMessageHandler TestGCPInboundEmail = New GCP_DAP_EmailMessageHandler();
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        email.subject=email.plainTextBody;
        TESTGCPInboundEmail.handleInboundEmail(email,env);
        Test.stopTest();
        
        List<Case> lstCases = [select Id from Case];
        system.assertEquals(4, lstCases.size()); 
        List<EmailMessage> lstEMs = [select Id from EmailMessage];
        system.assertEquals(4, lstEMs.size());
    }
    
}