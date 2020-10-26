/**
* @author         Sid
* @date           1/10/2019
* @description    Controller class for GCP_TFD_Claim_Parcels Component
* @Assumptions    NA 
*/
public with sharing class GCP_TFD_Claim_Parcels_Controller 
{
    //Three methods to be developed here...
    //1 - To fetch all Parcel records.
    //2 - To fetch Picklist values.
    //3 - Do the logic on selected Parcel records...
    /**   
      * @description       This methods fetches all the parcel records related to LC record
      * @param             lcid             
      * @return            List of parcel Records     
      * @throws            NA      
      */
    @AuraEnabled
    public static list<GCP_TFD_LC_Parcel__c> fetchParcels(string lcid) 
    {
        return [select id,Name,GCP_TFD_Amount__c,GCP_TFD_Reference_Number__c,GCP_TFD_Discounted_Payment_Date__c from GCP_TFD_LC_Parcel__c where Letter_of_Credit__c = :lcId
                                                           and (GCP_TFD_Claim_Status__c = :GCP_TFD_Constant.PARCEL_STATUS_NEW
                                                                OR GCP_TFD_Claim_Status__c = '')];
    }
    /**   
      * @description       This methods fetches the picklist values for CoverLetter & Supporting Letter.
      * @param             lcid             
      * @return            List of parcel Records     
      * @throws            NA      
      */
    @AuraEnabled
    public static List<String> getselectOptions(sObject objObject, string fld) 
    {
        List <String> allOpts = new list<String>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        //Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =  fieldMap.get(fld).getDescribe().getPickListValues(); 
        // Add these values to the selectoption list.
        for(Schema.PicklistEntry a: values)
        {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    } 
    /**   
      * @description       This methods Does the below logic on click of finish button on the component
      *                    - Create a Case related to LC record.
      *                    - Associate all the parcel record to the case record.
      *                    - Update Amount field on case with the sum of all parcel records amount.
      * @param             List of parcel recordids,coverLetter, SupportingLetter             
      * @return            NONE     
      * @throws            NA      
      */
    @AuraEnabled
    public static string createCase(List<Id> parcelids,string CoverLetter, string SupportingLetter, date DiscountDate, string lcid)
    {
        //Setting Save point...
        Savepoint sp = Database.setSavepoint();
        try
        {
            //Getting case record type..
            Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GCP_TFD_Constant.LC_RECORD_TYPE_NAME).getRecordTypeId();
            //Getting required values from lc record...
            GCP_TFD_Letter_of_Credit__c lcrecord = [select GCP_TFD_Credit_Number__c,GCP_TFD_Bank_ICOS__c,
                                                    GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Contract_Number__c,
                                                    GCP_TFD_Deal_Reference__c,GCP_TFD_In_favour_of_Beneficiary__c,
                                                    GCP_TFD_BPLE__c,GCP_TFD_To_Account__c,
                                                    GCP_TFD_Issuing_Bank_Formula__c,GCP_TFD_Invoice_Number__c,
                                                    GCP_TFD_NTID__c,GCP_TFD_Counterparty_ICOS__c,
                                                    GCP_TFD_ELCY_Reference_Number__c,
                                                    GCP_TFD_Deal_Done_Date__c,
                                                    GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c,GCP_TFD_To_Account__r.GCP_ETY_Account__c 
                                                    from GCP_TFD_Letter_of_Credit__C
                                                    where id = :lcid];
            //Calculating fee on each parcel and updating on Case...
            Decimal totalamount=0;
            Decimal totalvolume=0;
            //decimal totalprovisionalamount=0;
            for(GCP_TFD_LC_Parcel__c lcp:[select id,GCP_TFD_Amount__c,GCP_TFD_Quantity__c,GCP_TFD_Discounted_Payment_Date__c from GCP_TFD_LC_Parcel__c where id in :parcelids])
            {
                if(lcp.GCP_TFD_Amount__c != NULL)
                totalamount = totalamount+lcp.GCP_TFD_Amount__c;
                if(lcp.GCP_TFD_Quantity__c != NULL)
                totalvolume = totalvolume+lcp.GCP_TFD_Quantity__c;
            }
            //Creating Case record...
            id queueid = [select Id,name from Group where Type =:GCP_TFD_Constant.Queue and name =:System.Label.TFD_LC_Team].id;
            Case cs = new case();
            cs.GCP_TFD_Cover_Letter__c = CoverLetter;
            cs.GCP_TFD_Supporting_Letter__c = SupportingLetter;
            cs.GCP_TFD_Total_Price__c = totalamount;
            cs.GCP_TFD_Claim_Volume__c = totalvolume;
            cs.GCP_TFD_Provisional_Claim_Amount__c = totalamount;
            cs.GCP_TFD_Deal_Reference_Number__c = lcrecord.GCP_TFD_Deal_Reference__c;
            cs.GCP_TFD_Contract_Number__c = lcrecord.GCP_TFD_Invoice_Number__c;
            cs.GCP_TFD_LC_Deal_Done_Date__c = lcrecord.GCP_TFD_Deal_Done_Date__c;
            //cs.GCP_TFD_LC_Reference_Number__c = lcrecord.GCP_TFD_Credit_Number__c;
            cs.GCP_TFD_LC_Reference_Number__c = lcrecord.GCP_TFD_ELCY_Reference_Number__c;
            cs.GCP_TFD_NAME_OF_BANK__c = Lcrecord.GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c;
            cs.AccountId = Lcrecord.GCP_TFD_To_Account__r.GCP_ETY_Account__c;
            if(lcrecord.GCP_TFD_Deal_Reference__c != Null)
            {
                if(String.valueOf(lcrecord.GCP_TFD_Deal_Reference__c).substring(0,1) == GCP_TFD_Constant.U)
                {
                    cs.GCP_TFD_Region__c = GCP_TFD_Constant.GOA;
                }
                if(String.valueOf(lcrecord.GCP_TFD_Deal_Reference__c).substring(0,1) == GCP_TFD_Constant.E){
                    cs.GCP_TFD_Region__c = GCP_TFD_Constant.GOE;
                }
                if(String.valueOf(lcrecord.GCP_TFD_Deal_Reference__c).substring(0,1) == GCP_TFD_Constant.A)
                {
                    cs.GCP_TFD_Region__c = GCP_TFD_Constant.GOEH;
                }
            }
            cs.RecordTypeId = recTypeId;
            if(lcrecord.GCP_TFD_NTID__c == NULL)
            {
                cs.ownerId = queueid;    
            }
            else
            {
                //Checking if corresponding NTID is existing on user object...
                List<user> users = [select id from user where ntid__c = :lcrecord.GCP_TFD_NTID__c LIMIT 1];
                if(users.isEmpty())
                {
                    cs.ownerId = queueid;
                }
                else
                {
                    cs.ownerId = users[0].Id;
                }
            }
            cs.Status = GCP_TFD_Constant.open;
            cs.Origin = GCP_TFD_Constant.OCP;
            cs.Subject = system.label.GCP_TFD_LC_CASE_SUBJECT + lcrecord.GCP_TFD_Credit_Number__c;
            cs.GCP_TFD_Bank_ICOS__c = lcrecord.GCP_TFD_Bank_ICOS__c;
            cs.GCP_TFD_BPLE_ICOS__c = lcrecord.GCP_TFD_BP_LE_ICOS__c;
            cs.GCP_TFD_Couterparty_ICOS__c = lcrecord.GCP_TFD_Counterparty_ICOS__c;
            cs.GCP_TFD_LC_Type__c = GCP_TFD_Constant.LC_TYPE_EXPORT;
            cs.GCP_DAP_Counterparty__c = lcrecord.GCP_TFD_In_favour_of_Beneficiary__c;
            cs.GCP_DAP_BPLE__c = lcrecord.GCP_TFD_BPLE__c;
            cs.GCP_TFD_Bank__c = lcrecord.GCP_TFD_To_Account__c;
            cs.GCP_TFD_Issuing_Bank__c = lcrecord.GCP_TFD_Issuing_Bank_Formula__c;
            cs.GCP_TFD_LC_Tracker_Number__c = lcrecord.GCP_TFD_Credit_Number__c;
            if(DiscountDate != null)
            cs.GCP_TFD_Discounted_Payment_Date__c = DiscountDate;
            insert cs;
            //Updating Parcel records with Case and update status of parcel records...
            GCP_TFD_LC_Parcel__c lcparcel;
            List<GCP_TFD_LC_Parcel__c> parcels = new list<GCP_TFD_LC_Parcel__c>();
            for(string s:parcelids)
            {
                lcparcel = new GCP_TFD_LC_Parcel__c();
                lcparcel.id = s;
                lcparcel.GCP_TFD_Claim_Status__c = GCP_TFD_Constant.PARCEL_STATUS_CLAIMED;
                lcparcel.GCP_TFD_Related_Case__c = cs.Id;
                if(DiscountDate != null)
                lcparcel.GCP_TFD_Discounted_Payment_Date__c = DiscountDate;
                parcels.add(lcparcel);
            }
            update parcels;
            //Updating Region field on LC record...
            GCP_TFD_Letter_of_Credit__c lcr = new GCP_TFD_Letter_of_Credit__c();
            lcr.id = lcid;
            lcr.GCP_TFD_Region__c = cs.GCP_TFD_Region__c;
            lcr.GCP_TFD_Related_Case__c = cs.id;
            update lcr;
            return cs.Id;   
        }
        catch(exception e)
        {
            database.rollback(sp);
            system.debug('Exception Catched:' +e.getMessage());
            return null;
        }
    }
}