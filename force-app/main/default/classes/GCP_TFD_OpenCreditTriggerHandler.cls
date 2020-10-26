/**
* @author      Avinash Jain
* @date      20/08/2019
* @description    handles trigger events on Open Credit object       
*/


public With Sharing class GCP_TFD_OpenCreditTriggerHandler
{
    /**
* @description handles After Insert trigger on opencredit object
* @Parameter passed is the trigger new list
*/ 
    Public  void onAfterInsert(List<GCP_TFD_OpenCredit__c> newrecords){
        /**
* @description Variable declaration 
* */
        id qeueuid = [select Id,name from Group where Type =:GCP_TFD_Constant.Queue and name =:System.Label.TFD_OC_Team].id;
        id recordtype = [select id from recordtype where name=:System.Label.OC_Recordtype].id;
        Id bpleRecTypeId = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.BPLE_RECORD_TYPE_NAME).getRecordTypeId();
        Id counterPartyRecTypeId = Schema.SObjectType.GCP_ETY_Credit_Entity__c.getRecordTypeInfosByName().get(GCP_TFD_Constant.CPARTY_RECORD_TYPE_NAME).getRecordTypeId();
        String ContractStartLetter;
        String Region;
        Boolean checkBd1 = true; 
        Boolean checkBd2 = true;
        String BenchNameOC;
        List<string> BenchNameBankdetail = new List<string>();
        List<GCP_TFD_OpenCredit__c> opencreditList = new List<GCP_TFD_OpenCredit__c>(); 
        List<Account> AccountList = new List<Account>();
        List<GCP_ETY_Credit_Entity__c> AccountList1 = new List<GCP_ETY_Credit_Entity__c>();
        List<GCP_TFD_OpenCredit__c> TriggeropencreditList = new List<GCP_TFD_OpenCredit__c>();
        List<GCP_TFD_OpenCredit__c> opencreditList1 = new List<GCP_TFD_OpenCredit__c>();
        List<GCP_TFD_OpenCredit__c> opencreditList2 = new List<GCP_TFD_OpenCredit__c>();
        List<GCP_TFD_BankDetails__c> BankdetailsList = new List<GCP_TFD_BankDetails__c>();
        List<GCP_TFD_Related_Bank_Details__c> RelatedbankdetailsList = new List<GCP_TFD_Related_Bank_Details__c>();
        List<string> icoslist = new List<string>();
        Set<id> DebtorAccountids = new Set<id>();
        List<case> CaseList = new List<case>(); 
        Set<id> Accountids = new set<id>();
        List<id> opencreditID = new List<id>(); 
        List<case> Casestoupdate = new List<case>(); 
        List<case> Casestoinsert = new List<case>(); 
        /**
* @description Loop to get icos number list, debtor account ids and open credit ids 
* */
        //Setting save point...
        savepoint sp = database.setSavepoint();
        try
        {
            for(GCP_TFD_OpenCredit__c oc:newrecords){
                if(oc.GCP_TFD_Bank_CounterParty_ICOS__c!=NULL){
                    icoslist.add(String.valueOf(oc.GCP_TFD_Bank_CounterParty_ICOS__c));}
                if(oc.GCP_TFD_BP_LE_ICOS__c!=NULL){
                    icoslist.add(String.valueOf(oc.GCP_TFD_BP_LE_ICOS__c));}
                if(oc.GCP_TFD_Counterparty_ICOS__c!=NULL){
                icoslist.add(String.valueOf(oc.GCP_TFD_Counterparty_ICOS__c));}
                
                opencreditID.add(oc.id);
            }
            System.debug('Icoslist contains' +icoslist);
            /**
    * @description code populates Bp account and bank account field wit the help of icos Ids 
    * */
            AccountList = [select id,BPI_ICOS_ID__c,(select id from Credit_Entities__r where 
                           (recordtypeid = :bpleRecTypeId OR recordtypeid = :counterPartyRecTypeId))
                           							 from Account where BPI_ICOS_ID__c in:icoslist];
            system.debug('AccountList :'+AccountList);
            for(GCP_TFD_OpenCredit__c oc: [select id,GCP_TFD_To_Account__c,GCP_TFD_Debtor__c,GCP_TFD_From__c,
                                           GCP_TFD_Counterparty_ICOS__c,GCP_TFD_Bank_CounterParty_ICOS__c,
                                           GCP_TFD_BP_LE_ICOS__c from GCP_TFD_OpenCredit__c where id in:newrecords]){
                oc.OwnerId = qeueuid;
                for(Account acc:AccountList){
                    for(GCP_ETY_Credit_Entity__c cr:acc.Credit_Entities__r){
                        if(String.valueOf(oc.GCP_TFD_Bank_CounterParty_ICOS__c) == acc.BPI_ICOS_ID__c){
                            oc.GCP_TFD_To_Account__c = cr.id;
                            Accountids.add(cr.id);
                        }
                        if(String.valueOf(oc.GCP_TFD_BP_LE_ICOS__c) == acc.BPI_ICOS_ID__c){
                            oc.GCP_TFD_From__c = cr.id;
                            Accountids.add(cr.id);
                        }
                        if(String.valueOf(oc.GCP_TFD_Counterparty_ICOS__c) == acc.BPI_ICOS_ID__c){
                            oc.GCP_TFD_Debtor__c = cr.id;
                            DebtorAccountids.add(oc.GCP_TFD_Debtor__c);
                        }
                    }
                }
                oc.GCP_TFD_Run_Update_Trigger__c = FALSE;
                opencreditList2.add(oc);
            }
            Update opencreditList2;
            system.debug('opencreditList2 :'+opencreditList2);
            /**
    * @description code populates Related rights Section on the discounting record. 
    * */
            
            AccountList1 = [select id,(select id,GCP_TFD_Type__c,GCP_TFD_Details__c,GCP_TFD_Credit_Account__c from Related_Rights__r where GCP_TFD_Active__c =:True),
                            (Select id,GCP_TFD_Guarantee_Details__c,GCP_TFD_Guarantee_Required__c,GCP_TFD_Insurance_Details__c,
                             GCP_TFD_Insurance_Required__c,GCP_TFD_SBLC_Details__c,GCP_TFD_SBLC_Required__c,GCP_TFD_Bank_CounterParty_ICOS__c,GCP_TFD_Bank_s_Pro_Rata_Share__c,GCP_TFD_BP_LE_ICOS__c,GCP_TFD_Insured_Percentage__c from Open_Credits__r) 
                            from GCP_ETY_Credit_Entity__c where id in: DebtorAccountids];
            system.debug('AccountList1 :'+AccountList1);
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
                    opencreditList.add(oc);
                }
            }
            Update opencreditList;
            system.debug('opencreditList :'+opencreditList);
            /**
    * @description code Creates the case record related to the discounting record. 
    * */
            
            TriggeropencreditList = [select id,GCP_TFD_From__c,GCP_TFD_From__r.GCP_ETY_Credit_Entity_Name__c,
                                     GCP_TFD_Purchase_Date__c,GCP_TFD_Purchase_Agreement__c,GCP_TFD_To_Account__c,
                                     GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c,GCP_TFD_Related_case__c,
                                     GCP_TFD_Bank_CounterParty_ICOS__c,GCP_TFD_BP_LE_ICOS__c,
                                     GCP_TFD_Debtor__c,GCP_TFD_Debtor__r.GCP_ETY_Credit_Entity_Name__c,
                                     GCP_TFD_To_Account__r.GCP_ETY_Account__c,
                                     GCP_TFD_Contract_Number__c from GCP_TFD_OpenCredit__c where id in: newRecords]; 
            system.debug('TriggeropencreditList :'+TriggeropencreditList);
            for(GCP_TFD_OpenCredit__c oc: TriggeropencreditList){
                case Newcase = new case();
                if(oc.GCP_TFD_Related_case__c != NULL)
                {
                    Newcase.Id = oc.GCP_TFD_Related_case__c;
                }
                Newcase.recordtypeid = recordType;
                Newcase.OwnerId = qeueuid;
                Newcase.GCP_TFD_Bank_ICOS__c = oc.GCP_TFD_Bank_CounterParty_ICOS__c;
                Newcase.GCP_TFD_BPLE_ICOS__c = oc.GCP_TFD_BP_LE_ICOS__c;
                Newcase.Status = GCP_TFD_Constant.open;
                Newcase.Origin = GCP_TFD_Constant.OCP;
                Newcase.GCP_DAP_Counterparty__c = oc.GCP_TFD_Debtor__c;
                Newcase.Subject = GCP_TFD_Constant.GenerateSchedule + oc.GCP_TFD_Contract_Number__c;
                Newcase.GCP_DAP_BPLE__c = oc.GCP_TFD_From__c;
                Newcase.GCP_TFD_Bank__c = oc.GCP_TFD_To_Account__c;
                Newcase.GCP_TFD_NAME_OF_BANK__c = oc.GCP_TFD_To_Account__r.GCP_ETY_Credit_Entity_Name__c;
                Newcase.GCP_TFD_OCP_Discounting_Ref__c = oc.GCP_TFD_Purchase_Agreement__c;
                Newcase.GCP_TFD_OCP_Discounting_Date__c = oc.GCP_TFD_Purchase_Date__c;
                Newcase.AccountId = oc.GCP_TFD_To_Account__r.GCP_ETY_Account__c;
                if(oc.GCP_TFD_Contract_Number__c != Null){
                    ContractStartLetter = oc.GCP_TFD_Contract_Number__c.substring(0,1);
                    if(ContractStartLetter == GCP_TFD_Constant.U){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOA;
                    }
                    if(ContractStartLetter == GCP_TFD_Constant.E){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOE;
                    }
                    if(ContractStartLetter == GCP_TFD_Constant.A){
                        Newcase.GCP_TFD_Region__c = GCP_TFD_Constant.GOEH;
                    }
                }
                CaseList.add(Newcase);  
            }
            for(case cs: caselist)
            {
                if(cs.id != NULL)
                {
                    Casestoupdate.add(cs);
                }
                else
                {
                    Casestoinsert.add(cs);
                }
            }
            Insert Casestoinsert;
            update Casestoupdate;
            system.debug('CaseList :'+CaseList);
            map<id,case> casemap = new map<id,case>();
            for(case c:CaseList){
                casemap.put(c.id,c);
            }
            /**
    * @description code creates 2 related bank details for both bp and bank accounts. 
    * */
            BankdetailsList = [select id,GCP_TFD_Account_Holder__c,CurrencyIsoCode,GCP_TFD_Bench_Name__c,GCP_TFD_Region__c from GCP_TFD_BankDetails__c where GCP_TFD_Account_Holder__c in:Accountids and GCP_TFD_Active__c =:True];
            for(GCP_TFD_OpenCredit__c oc: [select id,GCP_TFD_From__c,GCP_TFD_To_Account__c,CurrencyIsoCode,GCP_TFD_Bench_Name__c,GCP_TFD_Bench_Name_Formula__c from GCP_TFD_OpenCredit__c where id in:opencreditID]){
                system.debug('oc :'+oc);
                for(id caseid : casemap.keyset()){
                    system.debug('CaseId :'+caseId);
                    if(casemap.get(caseid).GCP_DAP_BPLE__c == oc.GCP_TFD_From__c && casemap.get(caseid).GCP_TFD_Bank__c == oc.GCP_TFD_To_Account__c){
                        system.debug('Entering inside');
                        GCP_TFD_Related_Bank_Details__c RBD1 = new GCP_TFD_Related_Bank_Details__c();
                        GCP_TFD_Related_Bank_Details__c RBD2 = new GCP_TFD_Related_Bank_Details__c();  
                        oc.GCP_TFD_Related_case__c = caseid;
                        Region = casemap.get(caseid).GCP_TFD_Region__c;
                        oc.GCP_TFD_Region__c = Region;
                        opencreditList1.add(oc);
                        RBD1.GCP_TFD_Credit_Account__c = oc.GCP_TFD_From__c;
                        RBD1.GCP_TFD_Linked_Case__c = caseid;
                        RBD2.GCP_TFD_Credit_Account__c = oc.GCP_TFD_To_Account__c;
                        RBD2.GCP_TFD_Linked_Case__c = caseid;
                        for(GCP_TFD_BankDetails__c bd : BankdetailsList){
                            BenchNameOC = oc.GCP_TFD_Bench_Name_Formula__c;
                            if(bd.GCP_TFD_Bench_Name__c!=NULL){
                            BenchNameBankdetail = bd.GCP_TFD_Bench_Name__c.split(';');
                            }
                            if(oc.CurrencyIsoCode == bd.CurrencyIsoCode  && BenchNameBankdetail.contains(BenchNameOC) && oc.GCP_TFD_Region__c == bd.GCP_TFD_Region__c){
                                if(oc.GCP_TFD_To_Account__c == bd.GCP_TFD_Account_Holder__c){
                                    //checkBd1 = false;
                                    RBD2.GCP_TFD_Linked_Bank_Detail__c = bd.id; 
                                    RelatedbankdetailsList.add(RBD2);
                                }
                                if(oc.GCP_TFD_From__c == bd.GCP_TFD_Account_Holder__c){
                                    //checkBd2 = false;
                                    RBD1.GCP_TFD_Linked_Bank_Detail__c = bd.id; 
                                    RelatedbankdetailsList.add(RBD1);
                                } 
                            }
                        }
                    }
                }
            }
            
            if(trigger.isinsert){
                Insert RelatedbankdetailsList;
            }
            Update opencreditList1;
        }
        catch(exception e)
        {
            system.debug('Exception Catched :'+e.getMessage());
            database.rollback(sp);
        }        
    } 
}