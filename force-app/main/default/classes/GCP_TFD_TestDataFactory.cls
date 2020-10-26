/**
* @author         Sid
* @date           2/10/2019
* @description    Class to create test data for all the test classes
* @Assumptions    NA 
*/
public With Sharing class GCP_TFD_TestDataFactory
{
    /**
* @description Method to create standard account for Test class
* @Parameter passed is the Name of the account and the Icos ID
*/
    public static account createAccountforOC(String name,String icos,Boolean IsBp)
    {
        account acc= new account();
        acc.name = name;
        acc.ICRM_BP_Entity__c = IsBp;
        acc.BPI_ICOS_ID__c = icos;
        insert acc;
        return acc;
    }
     /**
* @description Method to create Credit Entity for Test class
* @Parameter passed is the account object
*/
    public static GCP_ETY_Credit_Entity__c createCreditEntityforOC(account a,id recordtype)
    {
        GCP_ETY_Credit_Entity__c CE = new GCP_ETY_Credit_Entity__c();
        CE.GCP_ETY_Account__c = a.id;
        CE.RecordTypeId = recordtype;
        insert CE;
        return CE;
    }
     /**
* @description Method to create Related rights for Test class
* @Parameter passed is the credut entity object, type and detail
*/
    public static GCP_TFD_RelatedRights__c createRelatedRightsforOC(GCP_ETY_Credit_Entity__c Ce,String type, String Detail)
    {
        GCP_TFD_RelatedRights__c RR = new GCP_TFD_RelatedRights__c();
        RR.GCP_TFD_Credit_Account__c = Ce.id;
        RR.GCP_TFD_Type__c = type;
        RR.GCP_TFD_Details__c = Detail;
        insert RR;
        return RR;
    }
     /**
* @description Method to create Bank detail for Test class
* @Parameter passed is the credit entity object, benchname and region
*/
    public static GCP_TFD_BankDetails__c createBankDetailforOC(GCP_ETY_Credit_Entity__c Ce,String Banchname, String Region)
    {
        GCP_TFD_BankDetails__c BD = new GCP_TFD_BankDetails__c();
        BD.GCP_TFD_Account_Holder__c = Ce.id;
        BD.GCP_TFD_Bench_Name__c = Banchname;
        BD.CurrencyIsoCode='USD';
        BD.GCP_TFD_Active__c = True;
        BD.GCP_TFD_Region__c = Region;
        insert BD;
        return BD;
    }
     /**
* @description Method to create Open credit for Test class
* @Parameter passed is the Icos ids for bank, bple and debtor ,cotract number and benchname
*/
    public static GCP_TFD_OpenCredit__c createOC(String BPLEicos,String Bankicos, String debtorIcos,String contract, String Benchname)
    {
        GCP_TFD_OpenCredit__c OC = new GCP_TFD_OpenCredit__c();
        oc.GCP_TFD_BP_LE_ICOS__c = BPLEicos;
        oc.GCP_TFD_Bank_Counterparty_ICOS__c=Bankicos;
        oc.GCP_TFD_Counterparty_ICOS__c =debtorIcos;
        OC.GCP_TFD_Contract_Number__c = contract;
        OC.GCP_TFD_Bench_Name__c = Benchname;
        OC.CurrencyIsoCode='USD';
        Insert OC;
        return OC;
    }
     /**
* @description Method to Update open credit for Test class
* @Parameter passed is the open credit object and contract number
*/
    public static GCP_TFD_OpenCredit__c UpdateOC(GCP_TFD_OpenCredit__c OC,String Contract)
    {
        OC.GCP_TFD_Contract_Number__c = Contract;
        Update OC;
        return OC;
    }
    /**
* @description Method to Update Related rights for Test class
* @Parameter passed is the related rights object and type
*/
    public static GCP_TFD_RelatedRights__c UpdateRR(GCP_TFD_RelatedRights__c RR,String Type)
    {
        RR.GCP_TFD_Type__c = Type;
        Update RR;
        return RR;
    }
    /**
* @description Method to Create User for Test class
* @Parameter passed is the the number of users to be created and the profile
*/
    public static List<User> CreateUser(Integer J,Profile p)
    {
        List<user> userlist = new List<user>();
        for(integer i=0;i<J;i++){
            user u = new user();
            u.LastName = 'Test' +i;
            u.FirstName  ='Test';
            u.Alias ='test';
            u.email ='TestGCPTFD' + i +'@abc.com';
            u.Username = 'TestGCPTFD' + i +'@abc.com';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.CurrencyIsoCode = 'USD';
            u.TimeZoneSidKey ='America/Los_Angeles';
            u.ProfileId = p.id;
            userlist.add(u);    
        }
        Insert userlist;
        Return userlist;
    }
    /**
* @description Method to Create permissionSet for Test class
* @Parameter passed is the List of users and the permissionSet ID
*/
    public static List<PermissionSetAssignment> CreatePSA(List<user> userlist,id ps)
    {
        List<PermissionSetAssignment> psalist = new List<PermissionSetAssignment>();
        for(integer i=0;i<5;i++){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userlist[i].id;
            psa.PermissionSetId = ps;
            psalist.add(psa);
        }
        insert psalist;
        return psalist;
    }
    /**
* @description Method to Update Generate button on case for Test class
*/
    public static case Updatecasegeneratebutton()
    {
        case cs = new case();
        cs.GCP_TFD_Generate_Document__c= false;
        insert cs;
        return cs;
    }
    public static case Updatecasegenericbutton()
    {
        case cs = new case();
        cs.GCP_TFD_Generate_Document__c= false;
        cs.GCP_TFD_Is_Generic_Template__c = true;
        insert cs;
        return cs;
    }
    /**   
      * @description       This method creates LC record
      * @param             NA 
      * @return            LC record     
      * @throws            NA      
      */
    /*
    public static GCP_TFD_Letter_of_Credit__c createLc()
    {
        GCP_TFD_Letter_of_Credit__c lc = new GCP_TFD_Letter_of_Credit__c();    
        lc.GCP_TFD_Bank_ICOS__c = '1234';
        lc.GCP_TFD_Deal_Reference__c = 'U123';
        insert lc;
        return lc;
    }
*/
    /**   
      * @description       This method creates Case record
      * @param             NA 
      * @return            case record     
      * @throws            NA      
      */
    public static case createCase()
    {
        case cs = new case();
        //cs.GCP_TFD_Generate_Document__c= false;
        cs.GCP_TFD_Total_Price__c = 300;
        insert cs;
        return cs;
    }
    public static case createGCPCase()
    {
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LC Request').getRecordTypeId();
        case cs = new case();
        //cs.GCP_TFD_Generate_Document__c= false;
        cs.GCP_TFD_Total_Price__c = 300;
        cs.recordtypeId = recTypeId;
        insert cs;
        return cs;
    }
    /**   
      * @description       This method creates parcel records
      * @param             name, amount, CaseId      
      * @return            parcel record     
      * @throws            NA      
      */
    public static GCP_TFD_LC_Parcel__c createParcel(String referenceNumber, decimal amount, 
                                                    string caseId,string lcid, string parcelstatus)
    {
        GCP_TFD_LC_Parcel__c parcel = new GCP_TFD_LC_Parcel__c();
        parcel.GCP_TFD_Reference_Number__c = referenceNumber;
        parcel.GCP_TFD_Amount__c = amount;
        parcel.GCP_TFD_Quantity__c = 100;
        parcel.GCP_TFD_Related_Case__c = caseId;
        parcel.Letter_of_Credit__c = lcid;
        parcel.GCP_TFD_Claim_Status__c = parcelstatus;
        insert parcel;
        return parcel;
    }
    public static GCP_TFD_LC_Parcel__c createParcelNew(String referenceNumber, decimal amount, 
                                                    string caseId,string lcid, string parcelstatus, string auditFlag, string dealStatus, String securityName)
    {
        GCP_TFD_LC_Parcel__c parcel = new GCP_TFD_LC_Parcel__c();
        parcel.GCP_TFD_Reference_Number__c = referenceNumber;
        parcel.GCP_TFD_Amount__c = amount;
        parcel.GCP_TFD_Quantity__c = 100;
        parcel.GCP_TFD_Related_Case__c = caseId;
        parcel.Letter_of_Credit__c = lcid;
        parcel.GCP_TFD_Claim_Status__c = parcelstatus;
        parcel.GCP_TFD_Audit__c = auditFlag;
        parcel.GCP_TFD_Deal_Status__c = dealStatus;
        parcel.GCP_TFD_Payment_Security_Name__c = securityName;
        insert parcel;
        return parcel;
    }
     /**   
      * @description       This method creates case for batch(test) class GCP_TFD_BatchAutomatedCaseCloserLC_Test
      * @param             Count      
      * @return            Case records    
      * @throws            NA      
      */
    public static List<case> CreateCaseForbatchLcCaseCloser(Integer count)
    {
        List<case> caselist= new List<case>();
        for(integer i = 0;i<count;i++){
            case cs=new case();
            cs.CreatedDate = System.today() - 368;
            System.debug('CreatedDate' +cs.CreatedDate);
            cs.status='In negotiation';
            caselist.add(cs);
        }
        Insert caselist;
        return caselist;
        
    }
    /**   
      * @description       This method creates LC Import for batch(test) class GCP_TFD_BatchAutomatedCaseCloserLC_Test
      * @param             Count,  lcimport , caselist
      * @return            LC Import records    
      * @throws            NA      
      */
    public static List<GCP_TFD_Letter_of_Credit__c> CreateLCImportForbatchLcCaseCloser(Integer count,id lcimport, List<case> caselist)
    {
        List<GCP_TFD_Letter_of_Credit__c> ListLCImport=new List<GCP_TFD_Letter_of_Credit__c>();
            for(integer i=0;i<count;i++){
            GCP_TFD_Letter_of_Credit__c Lc=new GCP_TFD_Letter_of_Credit__c();
            Lc.GCP_TFD_Issuance_Date__c = system.today() - 368;
            Lc.RecordTypeId =lcimport;
            Lc.GCP_TFD_Related_Case__c = caselist[i].id;
            ListLCImport.add(Lc);
        }     
        Insert ListLCImport;
        return ListLCImport;
    }
     /**   
      * @description       This method creates LC Export for batch(test) class GCP_TFD_BatchAutomatedCaseCloserLC_Test
      * @param             Count,  lcimport , caselist
      * @return            LC Import records    
      * @throws            NA      
      */
    public static List<GCP_TFD_Letter_of_Credit__c> CreateLCExporForbatchLcCaseCloser(Integer count,id lcExport, List<case> caselist)
    {
        List<GCP_TFD_Letter_of_Credit__c> ListLCExport=new List<GCP_TFD_Letter_of_Credit__c>();
            for(integer i = 0;i<5;i++){
            GCP_TFD_Letter_of_Credit__c Lc=new GCP_TFD_Letter_of_Credit__c();
            Lc.RecordTypeId =lcExport;
            Lc.GCP_TFD_Related_Case__c = caselist[i].id;
            ListLCExport.add(Lc);
        }     
        Insert ListLCExport;
        return ListLCExport;
    }
     /**   
      * @description       This method creates OC record for batch(test) class GCP_TFD_BatchAutomatedCaseCloserLC_Test
      * @param             Count, caselist
      * @return            OC record creaion    
      * @throws            NA      
      */
    public static List<GCP_TFD_OpenCredit__c> CreateOCForbatchLcCaseCloser(Integer count, List<case> caselist)
    {
        List<GCP_TFD_OpenCredit__c> OCLIST=new List<GCP_TFD_OpenCredit__c>();
            for(integer i = 0;i<5;i++){
            GCP_TFD_OpenCredit__c Lc=new GCP_TFD_OpenCredit__c();
            Lc.GCP_TFD_Related_Case__c = caselist[i].id;
            OCLIST.add(Lc);
        }     
        Insert OCLIST;
        return OCLIST;
    }
    /**   
      * @description       This method creates LC record for LC trigger handler
      * @param             Icos ids and deal ref no
      * @return            LC record creaion    
      * @throws            NA       
      */
        public static GCP_TFD_Letter_of_Credit__c createLC(String BPLEicos,String Bankicos, String debtorIcos,String DelRefNo)
    {
        Id recTypeId = Schema.SObjectType.GCP_TFD_Letter_of_Credit__c.getRecordTypeInfosByName().get('Import LC').getRecordTypeId();
        GCP_TFD_Letter_of_Credit__c LC = new GCP_TFD_Letter_of_Credit__c();
        Lc.GCP_TFD_BP_LE_ICOS__c = BPLEicos;
        Lc.GCP_TFD_Counterparty_ICOS__c=debtorIcos;
        Lc.GCP_TFD_Bank_ICOS__c =Bankicos;
        LC.GCP_TFD_Deal_Reference__c = DelRefNo;
        LC.CurrencyIsoCode='USD';
        Lc.recordtypeid = rectypeID;
        Insert LC;
        return LC;
    }
    /**   
      * @description       This method Update LC record for LC trigger handler
      * @param             Icos ids and deal ref no and LC record
      * @return            LC record Updation    
      * @throws            NA      
      */
        public static GCP_TFD_Letter_of_Credit__c UpdateLC(String DelRefNo,GCP_TFD_Letter_of_Credit__c Lc)
    {
        Lc.GCP_TFD_Deal_Reference__c = DelRefNo;
        Update LC;
        return LC;
    }
}