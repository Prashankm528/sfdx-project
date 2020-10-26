/**
* @author      	  Jagan
* @date           04/10/2019
* @description    Batch class to update case status as close on below scenarios:
				  when case object created date + 1year
				  When Letter of credit object field GCP_TFD_Issuance_Date__c + 1year(For LC Import)
*/
Global With Sharing Class GCP_TFD_Batch_AutomatedCaseClose implements database.Batchable<SObject>{
    Set<Id> set1=New Set<Id>();
	/*
    * @description start method for Batch class
	*/   
    Global database.QueryLocator start(database.Batchablecontext bc)
    {
        List<string> status = new List<string>();
        status.add(GCP_TFD_Constant.CASE_STATUS_IN_NEGOTIATION);
        Status.add(GCP_TFD_Constant.CASE_STATUS_SENT_FOR_EXT_SIGNATURE);
        String Query;
        Query ='Select id,status from Case where status in:status';
        Return database.getQueryLocator(Query);
        
    }
    /**
* @description execute method for Batch class
*/
    Global void execute(database.Batchablecontext bc,List<Case> caseList)
    {
        for(case ca:CaseList)
        {
            set1.add(ca.id);
        }        
        Set<id> caseid = new set<id>();
        //Querying Export and Import LC's and OC records...
        List<GCP_TFD_Letter_of_Credit__c> LCImport=[select id,GCP_TFD_Issuance_Date__c,GCP_TFD_Related_Case__c,GCP_TFD_Related_Case__r.createddate from GCP_TFD_Letter_of_Credit__c where GCP_TFD_Related_Case__c in:set1 and recordtype.name=:System.label.GCP_TFD_Import_LC];
        List<GCP_TFD_Letter_of_Credit__c> LCExport=[select id,GCP_TFD_Issuance_Date__c,GCP_TFD_Related_Case__c,GCP_TFD_Related_Case__r.createddate from GCP_TFD_Letter_of_Credit__c where GCP_TFD_Related_Case__c in:set1 and recordtype.name=:System.label.GCP_TFD_Export_LC];
        List<GCP_TFD_OpenCredit__c> OCList = [select id,GCP_TFD_Related_Case__r.createddate from GCP_TFD_OpenCredit__c where GCP_TFD_Related_Case__c in:set1];
        //Querying Import records...
        for(GCP_TFD_Letter_of_Credit__c LCI:LCImport)
        {
            if((LCI.GCP_TFD_Issuance_Date__c.AddDays(+365)) <= System.today())                
            {
                caseid.add(LCI.GCP_TFD_Related_Case__c);
            }
        }
        //Querying Export records...
        for(GCP_TFD_Letter_of_Credit__c LCE : LCExport)
        {
            if(LCE.GCP_TFD_Related_Case__r.createddate + 365 <= System.today())
            {
                caseid.add(LCE.GCP_TFD_Related_Case__c);
            }
        }
        //Querying OC records...
        for(GCP_TFD_OpenCredit__c OC : OCList)
        {
            if(OC.GCP_TFD_Related_Case__r.createddate + 365 <= System.today())
            {
                caseid.add(OC.GCP_TFD_Related_Case__c);
            }
        }
        //Updating Case status as closed...
        For(case cs : caselist){
            if(caseid.contains(cs.id)){
                cs.status=GCP_TFD_Constant.closed;
            }
        }
        Update caselist;       
    }        
    /**
* @description finish method for Batch class
*/
    Global void finish(database.Batchablecontext bc)
    {
    }
    
}