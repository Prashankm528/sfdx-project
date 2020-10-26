/**
* @author      Avinash Jain
* @date      16/09/2019
* @description    handles trigger events on Letter Of credit object       
*/

public With Sharing class GCP_TFD_LetterOfCreditTriggerHandler {
    
    Public  void onAfterInsert(List<GCP_TFD_Letter_of_Credit__c> newrecords){
        /**
* @description Variable declaration 
* */
        id qeueuid = [select Id,name from Group where Type =:GCP_TFD_Constant.Queue and name =:System.Label.TFD_LC_Team].id;
        id recordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.GCP_TFD_LC_Request).getRecordTypeId();
        String DealReferenceStartLetter;
        String Region;
        Boolean checkBd1 = true; 
        Boolean checkBd2 = true;
        //List<user> users = new list<user>();
        List<string> ntidslist = new list<string>();
        List<string> useridslist = new list<string>();
        List<GCP_TFD_Letter_of_Credit__c> LetterOfcreditList = new List<GCP_TFD_Letter_of_Credit__c>(); 
        List<GCP_TFD_Letter_of_Credit__c> lctoupdateincatch = new List<GCP_TFD_Letter_of_Credit__c>(); 
        List<Account> AccountList = new List<Account>();
        List<GCP_ETY_Credit_Entity__c> AccountList1 = new List<GCP_ETY_Credit_Entity__c>();
        List<GCP_TFD_Letter_of_Credit__c> TriggerLetterOfcreditList = new List<GCP_TFD_Letter_of_Credit__c>();
        List<GCP_TFD_Letter_of_Credit__c> LetterOfcreditList1 = new List<GCP_TFD_Letter_of_Credit__c>();
        List<GCP_TFD_Letter_of_Credit__c> LetterOfcreditList2 = new List<GCP_TFD_Letter_of_Credit__c>();
        List<GCP_TFD_BankDetails__c> BankdetailsList = new List<GCP_TFD_BankDetails__c>();
        List<GCP_TFD_Related_Bank_Details__c> RelatedbankdetailsList = new List<GCP_TFD_Related_Bank_Details__c>();
        List<string> icoslist = new List<string>();
        Set<id> Beneficiaryids = new Set<id>();
        List<case> CaseList = new List<case>(); 
        Set<id> Accountids = new set<id>();
        List<id> LetterOfcreditID = new List<id>(); 
        List<case> casestoinsert = new List<case>();
        List<case> casestoupdate = new List<case>();
        List<case> allcases = new list<case>();
        /**
* @description Loop to get icos number list, debtor account ids and open credit ids 
* */
        //Setting save point...
        savepoint sp = database.setSavepoint();
        try
        {
            for(GCP_TFD_Letter_of_Credit__c Lc:newrecords){
                icoslist.add(String.valueOf(Lc.GCP_TFD_Counterparty_ICOS__c));
                icoslist.add(String.valueOf(Lc.GCP_TFD_BP_LE_ICOS__c));
                icoslist.add(String.valueOf(Lc.GCP_TFD_Bank_ICOS__c));
                icoslist.add(String.valueOf(Lc.GCP_TFD_Presenting_Bank_ICOS__c));
                Beneficiaryids.add(Lc.GCP_TFD_In_favour_of_Beneficiary__c);
                Beneficiaryids.add(Lc.GCP_TFD_To_Account__c);
                LetterOfcreditID.add(Lc.id);
                
            }
            
            /**
             * @description code populates Bp account and bank account field wit the help of icos Ids 
             * */
            AccountList = [select id,BPI_ICOS_ID__c,(select id from Credit_Entities__r where (recordtype.name = :Gcp_Tfd_Constant.BPLE_RECORD_TYPE_NAME OR recordtype.name = :Gcp_Tfd_Constant.CPARTY_RECORD_TYPE_NAME)) from Account where BPI_ICOS_ID__c in:icoslist];
            for(GCP_TFD_Letter_of_Credit__c Lc: [select id,GCP_TFD_To_Account__c,GCP_TFD_Bank_ICOS__c,
                                                 GCP_TFD_In_favour_of_Beneficiary__c,GCP_TFD_BPLE__c,
                                                 GCP_TFD_Counterparty_ICOS__c,GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Deal_Reference__c,
                                                 GCP_TFD_Invoice_Number__c,GCP_TFD_Presenting_Bank_ICOS__c,GCP_TFD_Presenting_Bank_Lookup__c from GCP_TFD_Letter_of_Credit__c 
                                                 where id in:newrecords])
            {
                system.debug('Lc :'+Lc);
                Lc.OwnerId = qeueuid;
                //Updating Region field on LC...
                if(Lc.GCP_TFD_Deal_Reference__c != Null){
                    DealReferenceStartLetter = String.valueOf(Lc.GCP_TFD_Deal_Reference__c).substring(0,1);
                    if(DealReferenceStartLetter == GCP_TFD_Constant.U){
                        Lc.GCP_TFD_Region__c = GCP_TFD_Constant.GOA;
                    }
                    if(DealReferenceStartLetter == GCP_TFD_Constant.E){
                        Lc.GCP_TFD_Region__c = GCP_TFD_Constant.GOE;
                    }
                    if(DealReferenceStartLetter == GCP_TFD_Constant.A){
                        Lc.GCP_TFD_Region__c = GCP_TFD_Constant.GOEH;
                    }
                }
                for(Account acc:AccountList){
                    for(GCP_ETY_Credit_Entity__c cr:acc.Credit_Entities__r){
                        if(String.valueOf(Lc.GCP_TFD_Bank_ICOS__c) == acc.BPI_ICOS_ID__c){
                            Lc.GCP_TFD_To_Account__c = cr.id;
                            Accountids.add(cr.id);
                        }
                        if(String.valueOf(Lc.GCP_TFD_BP_LE_ICOS__c) == acc.BPI_ICOS_ID__c){
                            Lc.GCP_TFD_BPLE__c = cr.id;
                            Accountids.add(cr.id);
                        }
                        if(String.valueOf(Lc.GCP_TFD_Counterparty_ICOS__c) == acc.BPI_ICOS_ID__c){
                            Lc.GCP_TFD_In_favour_of_Beneficiary__c = cr.id;
                        }
                        if(String.valueOf(Lc.GCP_TFD_Presenting_Bank_ICOS__c) == acc.BPI_ICOS_ID__c){
                            Lc.GCP_TFD_Presenting_Bank_Lookup__c = cr.id;
                        }
                    }
                }
                lc.GCP_TFD_Run_Update_Trigger__c = FALSE;
                LetterOfcreditList2.add(Lc);
            }
            Update LetterOfcreditList2;
            /**
    * @description code populates Related rights Section on the discounting record. 
    * *//*
            
            AccountList1 = [select id,(select id,GCP_TFD_Type__c,GCP_TFD_Details__c,GCP_TFD_Credit_Account__c from Related_Rights__r),
                            (Select id,GCP_TFD_Guarantee_Details__c,GCP_TFD_Guarantee_Required__c,GCP_TFD_Insurance_Details__c,
                             GCP_TFD_Insurance_Required__c,GCP_TFD_SBLC_Details__c,GCP_TFD_SBLC_Required__c,GCP_TFD_Bank_CounterParty_ICOS__c,GCP_TFD_Bank_s_Pro_Rata_Share__c,GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Insured_Percentage__c from Open_Credits__r) 
                            from GCP_ETY_Credit_Entity__c where id in: DebtorAccountids];
            for(GCP_ETY_Credit_Entity__c acc:AccountList1){
                for(GCP_TFD_OpenCredit__c oc: acc.Open_Credits__r){
                    for(GCP_TFD_RelatedRights__c rr : acc.Related_Rights__r){  
                        oc.GCP_TFD_Related_Rights__c = GCP_TFD_Constant.Yes;
                        if(rr.GCP_TFD_Type__c == GCP_TFD_Constant.SBLC){
                            oc.GCP_TFD_SBLC_Details__c = rr.GCP_TFD_Details__c;
                        }
                        if(rr.GCP_TFD_Type__c == GCP_TFD_Constant.Insurance){
                            oc.GCP_TFD_Insurance_Details__c = rr.GCP_TFD_Details__c;
                        }
                        if(rr.GCP_TFD_Type__c == GCP_TFD_Constant.Guarantee){
                            oc.GCP_TFD_Guarantee_Details__c = rr.GCP_TFD_Details__c;
                        }
                    }
                    if(oc.GCP_TFD_Insured_Percentage__c == NULL){
                        oc.GCP_TFD_Insured_Percentage__c = oc.GCP_TFD_Bank_s_Pro_Rata_Share__c;
                    }
                    LetterOfcreditList.add(Lc);
                }
            }
            Update LetterOfcreditList;
    */
            /**
    * @description code Creates the case record related to the discounting record. 
    * */
            if(trigger.isupdate)
            {
                TriggerLetterOfcreditList = [select id,GCP_TFD_BPLE__c,GCP_TFD_Invoice_Number__c,GCP_TFD_Credit_Number__c,
                                            GCP_TFD_Issuing_Bank_Formula__c,GCP_TFD_Deal_Reference__c,GCP_TFD_Bank_ICOS__c,
                                            GCP_TFD_ELCY_Reference_Number__c,GCP_TFD_In_favour_of_Beneficiary__c,
                                            GCP_TFD_Deal_Done_Date__c,GCP_TFD_To_Account__c,GCP_TFD_Counterparty_ICOS__c,
                                            GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Contract_Number__c,GCP_TFD_NTID__c,
                                            GCP_TFD_LC_Type_Collateral__c,GCP_TFD_Related_Case__c,GCP_TFD_INCO_Term__c,
                                            GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c, GCP_TFD_To_Account__r.GCP_ETY_Account__c,
                                            GCP_TFD_Presenting_Bank_Lookup__c,GCP_TFD_Presenting_Bank_ICOS__c
                                            from GCP_TFD_Letter_of_Credit__c where id in: newrecords]; 
               
            }
            else
            {
                TriggerLetterOfcreditList = [select id,GCP_TFD_BPLE__c,GCP_TFD_Invoice_Number__c,GCP_TFD_Credit_Number__c,
                                            GCP_TFD_Issuing_Bank_Formula__c,GCP_TFD_Deal_Reference__c,GCP_TFD_Bank_ICOS__c,
                                            GCP_TFD_ELCY_Reference_Number__c,GCP_TFD_In_favour_of_Beneficiary__c,
                                            GCP_TFD_Deal_Done_Date__c,GCP_TFD_To_Account__c,GCP_TFD_Counterparty_ICOS__c,
                                            GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Contract_Number__c,GCP_TFD_NTID__c,
                                            GCP_TFD_LC_Type_Collateral__c,GCP_TFD_Related_Case__c,GCP_TFD_INCO_Term__c,
                                            GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c,GCP_TFD_To_Account__r.GCP_ETY_Account__c,
                                            GCP_TFD_Presenting_Bank_Lookup__c,GCP_TFD_Presenting_Bank_ICOS__c
                                            from GCP_TFD_Letter_of_Credit__c where id in: newrecords 
                                            and recordtype.name=:system.label.GCP_TFD_Import_LC];    
            }
            for(GCP_TFD_Letter_of_Credit__c Lc: TriggerLetterOfcreditList)
            {
                if(lc.GCP_TFD_NTID__c != NULL)
                {
                    ntidslist.add(lc.GCP_TFD_NTID__c);
                }
                //users = [select id from user where ntid__c = :lc.GCP_TFD_NTID__c LIMIT 1];
            }
            if(!ntidslist.isempty())
            {
                for (user u:[select id from user where ntid__c in :ntidslist])
                {
                    useridslist.add(u.id);
                }    
            }
            for(GCP_TFD_Letter_of_Credit__c Lc: TriggerLetterOfcreditList)
            {            
                case Newcase = new case();
                if(lc.GCP_TFD_Related_Case__c != NULL)
                {
                    Newcase.Id = lc.GCP_TFD_Related_Case__c;
                }
                if(trigger.isinsert)
                {
                    Newcase.recordtypeid = recordtype;    
                }                
                if(lc.GCP_TFD_NTID__c == NULL)
                {
                    Newcase.ownerId = qeueuid;    
                }
                else
                {
                    if(useridslist.isEmpty())
                    {
                        Newcase.ownerId = qeueuid;
                    }
                    else
                    {
                        Newcase.ownerId = useridslist[0];
                    }
                }
                //Newcase.OwnerId = qeueuid;
                Newcase.GCP_TFD_Issuing_Bank__c = lc.GCP_TFD_Issuing_Bank_Formula__c;
                Newcase.GCP_TFD_LC_Type_Collateral__c = lc.GCP_TFD_LC_Type_Collateral__c;
                Newcase.GCP_TFD_LC_Tracker_Number__c = lc.GCP_TFD_Credit_Number__c;
                //Newcase.GCP_TFD_Bank_ICOS__c = String.valueOf(Lc.GCP_TFD_Counterparty_ICOS__c);
                Newcase.GCP_TFD_Bank_ICOS__c = String.valueOf(Lc.GCP_TFD_Bank_ICOS__c);
                Newcase.GCP_TFD_BPLE_ICOS__c = Lc.GCP_TFD_BP_LE_ICOS__c;
                Newcase.GCP_TFD_Couterparty_ICOS__c = Lc.GCP_TFD_Counterparty_ICOS__c; 
                Newcase.AccountId = Lc.GCP_TFD_To_Account__r.GCP_ETY_Account__c;
                if(trigger.isinsert)
                {
                    Newcase.Status = GCP_TFD_Constant.open;    
                }               
                Newcase.GCP_DAP_Inco_Terms__c = Lc.GCP_TFD_INCO_Term__c;
                Newcase.Origin = GCP_TFD_Constant.OCP;
                Newcase.GCP_TFD_Deal_Reference_Number__c=Lc.GCP_TFD_Deal_Reference__c;
                Newcase.GCP_DAP_Counterparty__c = Lc.GCP_TFD_In_favour_of_Beneficiary__c;
                Newcase.Subject = GCP_TFD_Constant.GenerateSchedule + Lc.GCP_TFD_Contract_Number__c;
                Newcase.GCP_DAP_BPLE__c = Lc.GCP_TFD_BPLE__c;
                Newcase.GCP_TFD_Bank__c = Lc.GCP_TFD_To_Account__c;
                Newcase.GCP_TFD_NAME_OF_BANK__c = Lc.GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c;
                Newcase.GCP_TFD_LC_Reference_Number__c = Lc.GCP_TFD_ELCY_Reference_Number__c;
                Newcase.GCP_TFD_LC_Type__c = GCP_TFD_Constant.GcpImport;
                Newcase.GCP_TFD_LC_Deal_Done_Date__c = LC.GCP_TFD_Deal_Done_Date__c;
                Newcase.GCP_TFD_Contract_Number__c = LC.GCP_TFD_Invoice_Number__c;
                if(Lc.GCP_TFD_Deal_Reference__c != Null){
                    DealReferenceStartLetter = String.valueOf(Lc.GCP_TFD_Deal_Reference__c).substring(0,1);
                    if(DealReferenceStartLetter == GCP_TFD_Constant.U){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOA;
                    }
                    if(DealReferenceStartLetter == GCP_TFD_Constant.E){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOE;
                    }
                    if(DealReferenceStartLetter == GCP_TFD_Constant.A){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOEH;
                    }
                }
                CaseList.add(Newcase);  
            }
            map<id,case> casemap = new map<id,case>();
            for(case c:CaseList)
            {
                system.debug('c.id :'+c.id);
				system.debug('recordtype name is : '+c.recordtypeid);
                if(c.id != NULL)
                {
                    casestoupdate.add(c);
                }
                else if(c.id == NULL && c.recordtypeid == recordtype)
                {
                    casestoinsert.add(c);
                }
             }
            system.debug('casestoupdate :'+casestoupdate);
            insert casestoinsert;
            update casestoupdate;
            allcases.addAll(casestoinsert);
            allcases.addAll(casestoupdate);
            for(case c:allcases)
            {
                casemap.put(c.id,c);
            }
            for(GCP_TFD_Letter_of_Credit__c Lc: [select id,GCP_TFD_BPLE__c,GCP_TFD_To_Account__c,
                                                 CurrencyIsoCode/*,GCP_TFD_Bench_Name__c,
                                                 GCP_TFD_Bench_Name_Formula__c*/ 
                                                 from GCP_TFD_Letter_of_Credit__c where id in:LetterOfcreditID])
            {
                for(id caseid : casemap.keyset())
                {
                    Lc.GCP_TFD_Related_case__c = caseid;
                    //Region = casemap.get(caseid).GCP_TFD_Region__c;
                    //Lc.GCP_TFD_Region__c = Region;
                    LetterOfcreditList1.add(Lc);
                }
            }
            Update LetterOfcreditList1;
            /**
    * @description code creates 2 related bank details for both bp and bank accounts. 
    * */
         //   BankdetailsList = [select id,GCP_TFD_Account_Holder__c,CurrencyIsoCode,GCP_TFD_Bench_Name__c from GCP_TFD_BankDetails__c where GCP_TFD_Account_Holder__c in:Accountids];
         //   for(GCP_TFD_Letter_of_Credit__c Lc: [select id,GCP_TFD_BPLE__c,GCP_TFD_To_Account__c,CurrencyIsoCode/*,GCP_TFD_Bench_Name__c,GCP_TFD_Bench_Name_Formula__c*/ from GCP_TFD_Letter_of_Credit__c where id in:LetterOfcreditID]){
         //       for(id caseid : casemap.keyset()){
          //          if(casemap.get(caseid).BP_Legal_Entity__c == Lc.GCP_TFD_BPLE__c && casemap.get(caseid).Bank_CounterParty_Entity__c == Lc.GCP_TFD_To_Account__c){
          /*              GCP_TFD_Related_Bank_Details__c RBD1 = new GCP_TFD_Related_Bank_Details__c();
                        GCP_TFD_Related_Bank_Details__c RBD2 = new GCP_TFD_Related_Bank_Details__c();  
                        Lc.GCP_TFD_Related_case__c = caseid;
                        Region = casemap.get(caseid).GCP_TFD_Region__c;
                       // Lc.GCP_TFD_Region__c = Region;
                        LetterOfcreditList1.add(Lc);
                        RBD1.GCP_TFD_Credit_Account__c = Lc.GCP_TFD_BPLE__c;
                        RBD1.GCP_TFD_Linked_Case__c = caseid;
                        for(GCP_TFD_BankDetails__c bd : BankdetailsList){
                            if(Lc.CurrencyIsoCode == bd.CurrencyIsoCode/* && Lc.GCP_TFD_Bench_Name_Formula__c == bd.GCP_TFD_Bench_Name__c){
             /*                   if(Lc.GCP_TFD_To_Account__c == bd.GCP_TFD_Account_Holder__c){
                                    checkBd1 = false;
                                    RBD2.GCP_TFD_Linked_Bank_Detail__c = bd.id; 
                                }
                                if(Lc.GCP_TFD_BPLE__c == bd.GCP_TFD_Account_Holder__c){
                                   checkBd2 = false;
                                    RBD1.GCP_TFD_Linked_Bank_Detail__c = bd.id; 
                                } 
                            }
                        }
                        RBD2.GCP_TFD_Credit_Account__c = Lc.GCP_TFD_To_Account__c;
                        RBD2.GCP_TFD_Linked_Case__c = caseid;
                        RelatedbankdetailsList.add(RBD1);
                        RelatedbankdetailsList.add(RBD2);
                    } 
                }
            }
            if(checkBd1 == false && checkBd2 == false ){
                Insert RelatedbankdetailsList;
            } 
            Update LetterOfcreditList1;*/
        }
        catch(exception e)
        {
            system.debug('Exception Catched :' +e.getMessage());
            database.rollback(sp);
            /*
            //Updating GCP_TFD_Run_Update_Trigger__c as false if something fails
            // and come to catch block on update trigger...
            if(trigger.isupdate)
            {
                for(GCP_TFD_Letter_of_Credit__c lc:newrecords)
                {
                    lc.GCP_TFD_Run_Update_Trigger__c = FALSE;
                    lctoupdateincatch.add(lc);
                }
                update lctoupdateincatch;
            }
            */
        }
    } 
}