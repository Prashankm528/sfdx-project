/**
*___________________________________________________
*@Name:     CDM_SendCDMFormsToRPA
*@Author:   Chandra Kanchi
*@Created:  June 26, 2019
*@Used_By:  Public 
*___________________________________________________
*@Description: This class has been used for custom rest api class which is using for send to RPA cdm eform recrods data
                 which are all approved records.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@RestResource(urlMapping='/CDMEforms/*')
global with sharing class CDM_SendCDMFormsToRPA {

    
     /**
    *————————————————————————————————————————————————————
    * @Description
    * get cdm eform records send to RPA.
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/ 
    @HttpGet
  static global CDM_StaticUtils.CDMEformRec getCDMFormRecords() {
        Map<String,CDM_Credit_Debit_Note__c> cdmEformsMap = new Map<String,CDM_Credit_Debit_Note__c>();
        Map<String,List<CDM_Split_Amount__c>> amountRecordsMap = new Map<String,List<CDM_Split_Amount__c>>(); 
        List<Sobject> cdmRecords = CDM_StaticUtils.dynamicQueryListType('CDM_Credit_Debit_Note__c', ' WHERE  (CDM_Form_Status__c = \'' + String.escapeSingleQuotes('Approved') + '\')', ' ORDER BY CreatedDate DESC ');
        if(cdmRecords!=null)
        cdmEformsMap = new Map<String,CDM_Credit_Debit_Note__c>((List<CDM_Credit_Debit_Note__c>)cdmRecords); 
        Map<String,RecordType> RtMap = new Map<String,RecordType>([SELECT id,Name,developerName FROM RecordType WHERE SobjectType = 'CDM_Credit_Debit_Note__c']);
        if(!cdmEformsMap.isEmpty()) {
            for(CDM_Split_Amount__c s: [SELECT id,CDM_Credit_Debit_Note__c,CDM_D_C__c,CDM_GL_Account__c,CDM_Profit_Center__c,CDM_Sub_Item_Text__c ,
                                        CDM_Sub_Gross_Amount__c,CDM_Sub_Net_Amount__c,CDM_Sub_Tax_Code__c,CDM_Sub_Tax_Amount__c,CDM_Cost_Center__c,CDM_Sub_Tax_Rate__c
                                        FROM CDM_Split_Amount__c WHERE CDM_Credit_Debit_Note__c =: cdmEformsMap.keyset()]) {
                                            system.debug(s);            
                                            if(s.CDM_Credit_Debit_Note__c != null)  {
                                                if(amountRecordsMap.containsKey(s.CDM_Credit_Debit_Note__c))
                                                    amountRecordsMap.get(s.CDM_Credit_Debit_Note__c).add(s);
                                                else
                                                    amountRecordsMap.put(s.CDM_Credit_Debit_Note__c , new List<CDM_Split_Amount__c>{s});
                                            }
                                        }
         Map<ID,AggregateResult> cdmcount = getChildCdmCount(); 
            
        List<CDM_StaticUtils.CDMEforms> cdmList = new List<CDM_StaticUtils.CDMEforms>();
        CDM_StaticUtils.CDMEformRec cdmRecList = new CDM_StaticUtils.CDMEformRec();
            
        for(CDM_Credit_Debit_Note__c cdm :  (List<CDM_Credit_Debit_Note__c>)cdmEformsMap.values()) {
           // System.debug(cdm);
            CDM_StaticUtils.CDMEforms rec = new  CDM_StaticUtils.CDMEforms();
            rec.Name = cdm.Name;
            rec.Id = cdm.Id;
            rec.RequesterName = cdm.CreatedBy.Name;
            rec.RequesterEmail = cdm.CreatedBy.Email;
            rec.RequesterPhone = cdm.CreatedBy.Phone;
            rec.CreatedDate = cdm.CreatedDate;
            rec.ApprovalStatus = cdm.CDM_Approval_Status__c;
            rec.Approver = cdm.CDM_Approver__r.Name;
            rec.CompanyCode = cdm.CDM_Company_Code__c;
            rec.Country = cdm.CDM_Country__c;
            rec.CustomerNumber = cdm.CDM_Customer_Number__c;
            rec.DocumentDate = cdm.CDM_Document_Date__c;
            rec.GroupCompany = cdm.CDM_Group_Company__c;
            rec.InvoiceNumber = cdm.CDM_Invoice_Number__c;
            rec.BlineDate = cdm.CDM_Bline_Date__c;
            rec.TaxReportDate = cdm.CDM_Tax_Report_Date__c;
            rec.OperationDate = cdm.CDM_Operation_Date__c;
            rec.PostingDate = cdm.CDM_Posting_Date__c;
            rec.Description = cdm.CDM_Description__c;
            rec.FIDocumentDate = cdm.CDM_FI_Document_Date__c;
            rec.FIDocumentNumber = cdm.CDM_FI_Document_number__c;
            rec.GrossAmount  = cdm.CDM_Gross_Amount__c;
            rec.InvoiceDate = cdm.CDM_Invoice_Date__c;
            rec.Location = cdm.CDM_Location__c;
            rec.LocType = cdm.CDM_Loc_Type__c;
            rec.NetAmount = cdm.CDM_Net_Amount__c;
            rec.PaymentBlock = cdm.CDM_Payment_Block__c;
            rec.ProfitCenter = cdm.CDM_Profit_Center__c;
            rec.ProjectCode = cdm.CDM_Project_Code__c;
            rec.Quantity = cdm.CDM_Quantity__c;
            rec.RemarksIfAny = cdm.CDM_Remarks_if_any__c;
            rec.SignatoryRequired = cdm.CDM_Signatory_Required__c;
            rec.Source = cdm.CDM_Source__c;
            rec.SplitRequired = cdm.CDM_Split_Required__c;
            rec.TaxAmount = cdm.CDM_Tax_Amount__c;
            rec.TaxCode = cdm.CDM_Tax_Code__c;
            rec.PaymentMethod = cdm.CDM_Payment_Method__c;
            rec.PaymentTerm = cdm.CDM_Payment_Term__c;
            if(cdm.RecordtypeId != null)
            rec.RequestType =RtMap.get(cdm.RecordtypeId).name;
            rec.UnitPrice = cdm.CDM_Unit_Price__c;
            rec.WhatCode = cdm.CDM_What_Code__c;
            rec.WhoCode = cdm.CDM_Who_Code__c;
            rec.GLAccount =  cdm.CDM_GL_Account__c;
            rec.WhyCode = cdm.CDM_Why_Code__c;
            rec.CostCenter = cdm.CDM_Cost_Center__c;
            
            rec.vAdminFeeCreditAmount = cdm.CDM_Admin_Fee_Credit_Amount__c;
            rec.vAircraftRegistration = cdm.CDM_Aircraft_Registration__c;
            rec.FlightNumber = cdm.CDM_Flight_Number__c;
            rec.Material = cdm.CDM_Material_Number__c + ' '+ cdm.CDM_Material_Description__c;
            rec.Include_AdminFee = cdm.CDM_Include_50_Admin_Fee__c;
            rec.MaterialDescription = cdm.CDM_Material_Description__c;
            rec.MaterialNumber = cdm.CDM_Material_Number__c;
            rec.MaterialType1 = cdm.CDM_Material_Type1__c;
            rec.MaterialType2 = cdm.CDM_Material_Type2__c;
            rec.Billto = cdm.CDM_Billto__c;
            rec.Plant = cdm.CDM_Plant__c;
            rec.SalesDocType = cdm.CDM_Sales_Doc_Type__c;
            rec.ChannelCode = cdm.CDM_ChannelCode__c;
            rec.CustomerPONumber = cdm.CDM_Customer_PO_Number__c;
            rec.DistributionChannel = cdm.CDM_Distribution_Channel__c;
            rec.Division = cdm.CDM_Division__c;
            rec.Payer = cdm.CDM_Payer__c;
            rec.SalesOrganisation = cdm.CDM_Sales_Organisation__c;
            rec.Ship_To_Party = cdm.CDM_Ship_To_Party__c;
            rec.TaxEndUse = cdm.CDM_Tax_End_Use__c;
            rec.CustomerVatNumber = cdm.CDM_Customer_Vat__c;
            rec.BillingDate = cdm.CDM_Billing_Date__c;
            rec.ItemText = removeSpecialSymbol(cdm.CDM_Item_Text__c);//cdm.CDM_Item_Text__c!=null? cdm.CDM_Item_Text__c.replace(',', ';') : cdm.CDM_Item_Text__c;
            rec.TaxRate = cdm.CDM_Tax_Rate__c;
            rec.RequesterComments = cdm.CDM_Country__c == 'France'?removeSpecialSymbol(cdm.CDM_Requester_Comments_FR__c): removeSpecialSymbol(cdm.CDM_Requester_Comments__c); 
            rec.vCurrency = cdm.CurrencyIsoCode;
            rec.CompanyName = cdm.CDM_Company_Name__c; 
            rec.ProcessingError = cdm.CDM_Processing_Error__c;
            rec.FormStatus = cdm.CDM_Form_Status__c;
            //rec.DefaultGLAccount = cdm.CDM_Default_GL_Account__c; 
            //rec.DefaultCostCentre = cdm.CDM_Default_Cost_Centre__c; 
            //rec.DefaultProfitCentre = cdm.CDM_Default_Profit_Centre__c; 
            rec.BulkUpload = cdm.CDM_Bulk_Upload__c; 
            rec.BusinessDetails = cdm.CDM_Business_Details__c; 
            rec.CreditDebitNoteParent = cdm.CDM_Credit_Debit_Note_Parent__r.Name;
            if(cdm.CDM_Credit_Debit_Note_Parent__c!=null) {
               // cdmcount
                rec.CDMRecordType = 'Child'; 
               
             } else { 
                   
                    if(cdmcount.containsKey(cdm.id)) {
                     rec.CDMRecordType = 'Parent';
                    rec.CountOfChildCDM = Integer.valueOf(cdmcount.get(cdm.id).get('childCount')); 
                    }
              }      
            rec.DedicatedtoDocumenttype = cdm.CDM_Dedicated_to_Document_type__c; 
            rec.DueDate = cdm.CDM_Due_Date__c;  
            rec.OrderNumber = cdm.CDM_Order_Number__c;
            rec.OrderDate = cdm.CDM_Order_Date__c;
            rec.GLDocumentNumber = cdm.GL_Document_Number__c;
            rec.Amounts = new List<CDM_StaticUtils.Amounts>();
            if(!amountRecordsMap.isEmpty()) {
            List<CDM_StaticUtils.Amounts> amount = new List<CDM_StaticUtils.Amounts>();
                if(amountRecordsMap.containsKey(cdm.Id))
                for(CDM_Split_Amount__c sa : amountRecordsMap.get(cdm.Id)) {
                    CDM_StaticUtils.Amounts saRec = new CDM_StaticUtils.Amounts();
                    saRec.GLAccount = sa.CDM_GL_Account__c;   
                    saRec.ProfitCenter = sa.CDM_Profit_Center__c;
                    saRec.SubGrossAmount = sa.CDM_Sub_Gross_Amount__c!=null?sa.CDM_Sub_Gross_Amount__c.setscale(2):sa.CDM_Sub_Gross_Amount__c;
                    saRec.SubNetAmount = sa.CDM_Sub_Net_Amount__c!=null?sa.CDM_Sub_Net_Amount__c.setscale(2): sa.CDM_Sub_Net_Amount__c;
                    saRec.SubTaxCode = sa.CDM_Sub_Tax_Code__c;
                    saRec.SubTaxAmount = sa.CDM_Sub_Tax_Amount__c!=null? sa.CDM_Sub_Tax_Amount__c.setscale(2) : sa.CDM_Sub_Tax_Amount__c;
                    saRec.CostCenter = sa.CDM_Cost_Center__c;
                    saRec.SubItemText = removeSpecialSymbol(sa.CDM_Sub_Item_Text__c);
                    saRec.SubTaxRate = sa.CDM_Sub_Tax_Rate__c;
                    saRec.D_C = sa.CDM_D_C__c;
                    amount.add(saRec);
                }
               rec.Amounts =  amount;      
            }
            
          cdmList.add(rec); 
            }
       cdmRecList.CDMEforms =  cdmList;
       return cdmRecList;
        }
   
    return null;
}

public static Map<ID,AggregateResult> getChildCdmCount() {
    Map<ID,AggregateResult> results = new Map<id,AggregateResult>([SELECT CDM_Credit_Debit_Note_Parent__c 
                                                                   Id, COUNT(Id) childCount FROM CDM_Credit_Debit_Note__c 
                                                                   WHERE CDM_Credit_Debit_Note_Parent__c != NULL
                                                                  GROUP BY CDM_Credit_Debit_Note_Parent__c]);
    system.debug(results);
    return results;
 }
 public static string removeSpecialSymbol(String itext) {
     return itext!=null? itext.replace(',', ';').replaceAll('\r\n|\n|\r|\t',' ') : itext;
 }

}