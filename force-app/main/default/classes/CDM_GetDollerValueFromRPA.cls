/**
*___________________________________________________
*@Name:     CDM_GetDollerValueFromRPA 
*@Author:   Chandra Kanchi
*@Created:  Feb 26, 2020
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for send supporting notes to RPA
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@RestResource(urlMapping='/CDMGetDollerValue/*')
global with sharing class CDM_GetDollerValueFromRPA {
     /**
    *————————————————————————————————————————————————————
    * @Description
    * get doller value from RPA.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    @HttpPost
  static global String getDollerValueFromRPA() {
   
    system.debug(RestContext.request.requestBody.toString());
    CDM_StaticUtils.DoffaDollerValue requestBody = (CDM_StaticUtils.DoffaDollerValue) JSON.deserialize(RestContext.request.requestBody.toString(), CDM_StaticUtils.DoffaDollerValue.class);
    if(requestBody!=null) {
        set<String> recIds = new set<String>();
        Map<String,CDM_StaticUtils.AuthorityDollerAmount> resMap = new Map<String,CDM_StaticUtils.AuthorityDollerAmount>();
     
        for(CDM_StaticUtils.AuthorityDollerAmount dVal : requestBody.DoffaDollerValue)
            if(String.isNotBlank(dVal.RecordId))
                resMap.put(dVal.RecordId,dVal);
            //  system.debug('resMap '+ resMap );
         List<CDM_Credit_Debit_Note__c> cdmLst  = new List<CDM_Credit_Debit_Note__c>();
         if(!resMap.isEmpty()) {
         
              decimal amount;
              for(CDM_Credit_Debit_Note__c cdn : [SELECT id,CDM_Debit_Approval_Amount__c,CDM_Credit_Approval_Amount__c,CDM_Approval_Unlimited_Amount__c,CDM_Approver__r.CDM_Approver_User__r.Id,
                                                  CDM_Form_Status__c,CDM_Split_Required__c,CDM_Total_Sub_Gross_Amount__c,createdbyId,CDM_Approver__r.CDM_Approver_User__r.Email,CDM_Net_Amount__c,
                                                 recordtype.Name,CDM_Bulk_Upload__c,CDM_Gross_Amount__c,CDM_Requester_Comments__c,CDM_Country__c FROM CDM_Credit_Debit_Note__c 
                                                   WHERE id=: resMap.keyset()]) {
                 if(resMap.containsKey(cdn.id)) {
                      if(cdn.CDM_country__c == 'Netherlands' && cdn.CDM_Bulk_Upload__c == 'Yes')
                      {
                          amount = cdn.CDM_Net_Amount__c;
                      }
                     else
                      amount = cdn.CDM_Split_Required__c == 'Yes' && cdn.CDM_Total_Sub_Gross_Amount__c!= null? cdn.CDM_Total_Sub_Gross_Amount__c :cdn.CDM_Gross_Amount__c;                              
                      CDM_StaticUtils.AuthorityDollerAmount dollVal = resMap.get(cdn.id);
                      system.debug(dollVal);
                     //Change: If LuisError is true, update the respective value on CDM record...
                     if(dollVal.LuisError == false || dollVal.LuisError == NULL)
                     {
                         if(dollVal.dollerValue != '0' && String.isNotBlank(dollVal.dollerValue) && dollVal.UnlimitedAmount == false) {
                         if(cdn.recordType.Name == 'Credit Note') {
                           
                             cdn.CDM_Credit_Approval_Amount__c = getAppendZeros(resMap.get(cdn.id).dollerValue);
                             if(amount > cdn.CDM_Credit_Approval_Amount__c) {
                              
                                cdn.CDM_Dofa_Review_Status__c = 'Rejected';
                                 cdn.CDM_Form_Status__c = 'Rejected';
                                 cdn.CDM_Dofa_Rejection_Details__c = 'Your Credit/Debit request has been rejected as the selected approver does not have the appropriate level of delegation in DofA to approve this Credit/Debit request. Please select different approver or alternatively contact DofA controller to review amount and/or supporting notes for your current selection before resubmitting.';
                             }    
                         }  
                         if(cdn.recordType.Name == 'Debit Note') {
                         
                             cdn.CDM_Debit_Approval_Amount__c = getAppendZeros(resMap.get(cdn.id).dollerValue); 
                             if(amount > cdn.CDM_Debit_Approval_Amount__c) {
                             
                                cdn.CDM_Dofa_Review_Status__c = 'Rejected';
                                cdn.CDM_Form_Status__c = 'Rejected';
                                cdn.CDM_Dofa_Rejection_Details__c = 'Your Credit/Debit request has been rejected as the selected approver does not have the appropriate level of delegation in DofA to approve this Credit/Debit request. Please select different approver or alternatively contact DofA controller to review amount and/or supporting notes for your current selection before resubmitting.';
                                 
                             }    
                         }     
                      } else {
                           if(dollVal.UnlimitedAmount)
                               cdn.CDM_Approval_Unlimited_Amount__c = true;
                            }   
                      
                     }
                     //Logic to update Value on CDM record if LuisError is true...
                     else
                     {
                         cdn.CDM_Luis_Failed__c = true;	
                         if(dollVal.dollerValue != '0' && String.isNotBlank(dollVal.dollerValue) && dollVal.UnlimitedAmount == false)
                         {
                             if(cdn.recordType.Name == 'Credit Note') {                           
                                 cdn.CDM_Credit_Approval_Amount__c = getAppendZeros(resMap.get(cdn.id).dollerValue);
                             }
                             if(cdn.recordType.Name == 'Debit Note') {                         
                                 cdn.CDM_Debit_Approval_Amount__c = getAppendZeros(resMap.get(cdn.id).dollerValue); 
                             }
                         }                             
                     }
                  
                  cdmLst.add(cdn);
              }
            }
            Update cdmLst;  
             
              return 'Doller Values Updated Successfully';
       }
      

     }
  
    return 'Something went wrong';
   }
   
   
   public static void cdmSubmitForApproval(List<Id> cdmLst) {
        List<Approval.ProcessSubmitRequest> proSubLst = new List<Approval.ProcessSubmitRequest>();//Approval.process(proReqList);
        for(CDM_Credit_Debit_Note__c cdn: [SELECT id,createdbyid,CDM_Approval_Unlimited_Amount__c,CDM_Net_Amount__c,CDM_Luis_Failed__c,
                                                CDM_Approver__r.CDM_Approver_User__r.Id,CDM_Total_Sub_Gross_Amount__c,CDM_Split_Required__c,CDM_Credit_Approval_Amount__c,CDM_Debit_Approval_Amount__c,CDM_Country__c,
                                                CDM_Approver__r.CDM_Approver_User__r.Email,CDM_Approver__r.CDM_Approver_User__r.Name,recordtype.Name,CDM_Gross_Amount__c,CDM_Requester_Comments__c FROM CDM_Credit_Debit_Note__c 
                                                WHERE id=: cdmLst]) {
            //Change - If Luis is not able to make decision. send it to different approval process...
            if(cdn.recordType.Name == 'Credit Note') {
              	Decimal sumAmt = (cdn.CDM_Split_Required__c == 'Yes' && cdn.CDM_Total_Sub_Gross_Amount__c!=null)? cdn.CDM_Total_Sub_Gross_Amount__c : cdn.CDM_Net_Amount__c;
               	if(cdn.CDM_Luis_Failed__c){
              		proSubLst.add(setProcessSubmitRequestToAccTeam(cdn));
            	}
               	else
               	{
               		if(sumAmt  <= cdn.CDM_Credit_Approval_Amount__c || cdn.CDM_Approval_Unlimited_Amount__c) 
                   	proSubLst.add(setProcessSubmitRequest(cdn));    
               	}
            }        
            if(cdn.recordType.Name == 'Debit Note') {
               	Decimal sumAmt = (cdn.CDM_Split_Required__c == 'Yes' && cdn.CDM_Total_Sub_Gross_Amount__c!=null)? cdn.CDM_Total_Sub_Gross_Amount__c : cdn.CDM_Net_Amount__c;
                if(cdn.CDM_Luis_Failed__c){
               		proSubLst.add(setProcessSubmitRequestToAccTeam(cdn));
            	}
                else{
                	if(sumAmt  <= cdn.CDM_Debit_Approval_Amount__c || cdn.CDM_Approval_Unlimited_Amount__c) 
               	    proSubLst.add(setProcessSubmitRequest(cdn));                     
                }                    
            }                                                  
           
         }
         if(!proSubLst.isEmpty())        
            List<Approval.ProcessResult> result1 = Approval.process(proSubLst); 
   
   }
   
   public static decimal getNumberVal(String str) {
       if(String.isNotBlank(str)) 
       {
           if(str.contains('.'))
           {
               Pattern p = Pattern.compile('-?\\d+(,\\d+)*?\\.?\\d+?'); 
               List<String> numbers = new List<String>();
               Matcher m = p.matcher(str);
               while (m.find()) {  
                   numbers.add(m.group());
               }		
               return decimal.valueof(numbers[0]);       
           }
           else
           {
               Pattern p = Pattern.compile('[^0-9]| (.)'); 
           	   String val = p.matcher(str).replaceAll('');
               return String.isBlank(val)? 0: decimal.valueOf(val);    
           }
       }
       else return 0; 
   } 
   
   public static decimal getAppendZeros(String str) {
       if(String.isNotBlank(str)) {
            Matcher matcher = Pattern.compile('[a-zA-Z]').matcher(str);
            Boolean result= matcher.find();
            decimal digitVal = getNumberVal(str);
            System.debug('digitVal is : '+digitVal);
            System.debug('result is : '+result);
            if(result) {
               System.debug('Matching string'+ matcher.group(0));
               str = matcher.group(0);
               system.debug('str>>>>>>>>$$$$>'+str);
               if(str.equalsIgnoreCase('K'))
                   return digitVal * 1000;
               if(str.equalsIgnoreCase('M'))
                   return digitVal * 1000000;
                    
            } else
                 return digitVal;
       
       } else return 0; 
       return 0;
   } 
   
   public static Messaging.SingleEmailMessage setEmailMessages(CDM_Credit_Debit_Note__c cdn, emailTemplate emailTemplate) {
     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
       message.setTargetObjectId(cdn.createdbyId); 
       message.setSenderDisplayName('CDM Dofa Reviewer'); 
       message.setReplyTo('no-reply@company.com');
       message.setSaveAsActivity(false); 
      // message.setWhatId(cdn.Id);
       message.setTemplateID(emailTemplate.Id); 
       message.toAddresses = new String[] {cdn.CDM_Approver__r.CDM_Approver_User__r.Email};
   
      return message;
   }
   
     public static Approval.ProcessSubmitRequest setProcessSubmitRequest(CDM_Credit_Debit_Note__c cdn) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments(cdn.CDM_Requester_Comments__c);
        req.setObjectId(cdn.id);
        req.setNextApproverIds(new String[]{cdn.CDM_Approver__r.CDM_Approver_User__r.Id});
        return req;
     
     }
     
    //Method to trigger approval process to Accenture team when Luis is not able to make decision...
    public static Approval.ProcessSubmitRequest setProcessSubmitRequestToAccTeam(CDM_Credit_Debit_Note__c cdn) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments(cdn.CDM_Requester_Comments__c);
        req.setObjectId(cdn.id);
        //Querying Queue name...
        Id queueid = [select id from group where Type = 'Queue' AND DeveloperName = 'CDM_DOFA_Reviewer'].Id;
        req.setNextApproverIds(new String[]{queueid});
        return req;
    }
   }