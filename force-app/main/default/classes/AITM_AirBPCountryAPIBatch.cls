/***************************************************************
* @author           Neeti 
* @date             01/July/2020
* @group            AirBP
* @description      Batch class for Mulesoft Airbp Location API Callout

* history
* 16/June/2020     Saravana Surendran      Created 
* 30/Sep/2020      Saravana Surendran      Modifeid the userdetails query to handle datamigration user 
**********************************************************/
public with Sharing class AITM_AirBPCountryAPIBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public List <AITM_Location__c > locList = new List < AITM_Location__c > ();
    public List <AITM_Delivery_Point__c > delList = new List < AITM_Delivery_Point__c > ();
    public List<AITM_Pricing_Basis__C> pbListToInsert = new List<AITM_Pricing_Basis__C>();
    
    
    public Set<string> countryIdSet = new Set<string>();
    public map<string,User> ntIDMap = new map<string,User>();
    public map<string,id> pbIDMap = new map<string,id>();
    
    /**
* @description constructor
* @param null  
* @return null
*/
    
    public AITM_AirBPCountryAPIBatch() {
        
        for(User uDetail: [Select Id, Username, Name, Email, IsActive, NTID__c FROM User where (UserRole.Name='AirBP' OR NTID__c  =: System.Label.AITM_LocationOwner ) AND IsActive=True LIMIT  1000]){
            string s = uDetail.NTID__c;
            if(s != null){
                ntIDMap.put(s.toLowerCase() , uDetail);
            }
            
        }
        
        for(AITM_Pricing_Basis__c pb: [select id,AITM_Pricing_Basis_Code__c,name from AITM_Pricing_Basis__c where name =: System.Label.AITM_Not_Represented  or AITM_Not_Represented__c = false LIMIT 10000]){
            pbIDMap.put(pb.name,pb.id);
        }
    }
    
    /**
* @description start method of the batch
* @param BatchableContext  
* @return List collection
*/
    
    public Iterable<sObject> start(Database.batchableContext BC){
        List<sObject> newList=[SELECT Id, AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c, Label FROM AITM_API_Modified_Country_List__mdt where AITM_Country_Id__c NOT IN ('NonAirBPOp', 'FirstRec','') AND AITM_Record_Updated__c = FALSE LIMIT 1000];
        
        if(test.isRunningTest()){
            newList=[SELECT Id, AITM_Country_Id__c, AITM_LastModifiedDate__c, AITM_Record_Updated__c, Label FROM AITM_API_Modified_Country_List__mdt where  AITM_Country_Id__c NOT IN ('NonAirBPOp', 'FirstRec','')  limit 1];
        }
        
        return newList;
    }
    
    /**
* @description execute method of the batch
* @param BatchableContext and List of country Id 
* @return null
*/
    
    public void execute(Database.BatchableContext bc, List < AITM_API_Modified_Country_List__mdt > scope) {
        
        if (scope.size() > 0) {
            for (AITM_API_Modified_Country_List__mdt queryObject: scope) {
                
                AITM_Location_API_Callouts callObject = new AITM_Location_API_Callouts();
                HTTPResponse hResp1;
                if(queryObject.AITM_Country_Id__c != null){
                    try{
                        String s = '';
                        hResp1 = callObject.getCountryListCallout(queryObject.AITM_Country_Id__c);
                        s = hResp1.getBody();
                        if(hResp1.getStatusCode() == 200 && !s.contains('Invalid CountryID')) {
                            
                            AITM_CountryAPIWrapperClass aw = new AITM_CountryAPIWrapperClass();
                            
                            Map < AITM_Location__c, List < AITM_Delivery_Point__c >> mapDP = new Map < AITM_Location__c, List < AITM_Delivery_Point__c >> ();
                            mapDP = aw.convertList(s,ntIDMap,pbIDMap);
                            countryIdSet.add(queryObject.AITM_Country_Id__c);
                            for (AITM_Location__c loc: mapDP.keySet()) {
                                locList.add(loc);
                                delList.addAll(mapDP.get(loc));
                            }
                            
                                                        
                            
                            finalmethodCall();
                        }
                        else
                        {
                            AITM_Log.createErrorMessage('validateMulesoftResponse'+'id:'+queryObject.AITM_Country_Id__c+'Response:'+ hResp1, 'id:'+queryObject.AITM_Country_Id__c,'Response:'+ hResp1, 'getCountryListCallout','', 'Error',null);  
                        }
                        
                    }
                    catch(Exception e){ AITM_Log.createErrorMessage('validateMulesoftResponse'+'id:'+queryObject.AITM_Country_Id__c+'Response:'+ hResp1, 'id:'+queryObject.AITM_Country_Id__c,'Response:'+ hResp1, 'getCountryListCallout','', 'Error',null);
                                      }
                }
                else{
                    AITM_Log.createErrorMessage('validateMulesoft API Parameter country Id '+queryObject.AITM_Country_Id__c , 'id'+queryObject.AITM_Country_Id__c,'Response:No', '','', 'Error',null);  
                    
                }
            }
            
        }
        
    }
    
    /**
* @description method to upsert the location list and deliverypoint list
* @param BatchableContext  
* @return null
*/ 
    
    public void finalMethodCall(){
        Schema.SObjectField externalKeyLoc = AITM_Location__c.Fields.AITM_SCM_Location_Unique_ID__c;
        Schema.SObjectField externalKeyPb = AITM_Pricing_Basis__c.Fields.AITM_Pricing_Basis_Code__c;
        Schema.SObjectField externalKeyDp = AITM_Delivery_Point__c.Fields.AITM_Dealer_ID__c;
        set<id> SuccessId = new set<id>();
        set<string> locationuniqSet= new set<string>();
        List<AITM_Log__c> logsToInsert = new List<AITM_Log__c>();        
               
        
        Database.UpsertResult[] locationResult =Database.upsert(locList,externalKeyLoc,false);
        // Database.UpsertResult[] pbResult =Database.upsert(pbListToInsert,externalKeyPb,false);
        Database.UpsertResult[] dpResult =Database.upsert(delList,externalKeyDp,false);
        
                
        
        for(Integer i=0;i<dpResult.size();i++){
            if(dpResult.get(i).isSuccess()){                 SuccessId.add(dpResult.get(i).getId());
                                            
                                           }
            else{
                // DML operation failed
                Database.Error error = dpResult.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                //locList.get(i);//failed record from the list                
                locationuniqSet.add(delList.get(i).AITM_Location__r.AITM_SCM_Location_Unique_ID__c);
                logsToInsert.add(AITM_Log.draftErrorMessage('validateMulesoftResponse-Upsert Delivery Point'+delList.get(i).AITM_Dealer_ID__c+'-'+error.getMessage()));
                
            }
            
            
        }
        
        for(Integer i=0;i<locationResult.size();i++){
            if (locationResult.get(i).isSuccess()){
                SuccessId.add(locationResult.get(i).getId());
                if(locationuniqSet.contains(locList.get(i).AITM_SCM_Location_Unique_ID__c )){  countryIdSet.remove(locList.get(i).AITM_Country_Id__c);
                                                                                            }
                
            }
            else{
                // DML operation failed
               
                Database.Error error = locationResult.get(i).getErrors().get(0);
                //locList.get(i);//failed record from the list
                // AITM_Log.createErrorMessage(error.getMessage(), 'validateMulesoftResponse-Upsert Location','','', locList.get(i).AITM_SCM_Location_Unique_ID__c, 'DML Error','');
	            logsToInsert.add(AITM_Log.draftErrorMessage('validateMulesoftResponse-Upsert Location'+locList.get(i).AITM_SCM_Location_Unique_ID__c+'-'+error.getMessage()));
                
                countryIdSet.remove(locList.get(i).AITM_Country_Id__c);
            }
        }
        
        
        
        
        if(logsToInsert != null){
            insert logsToInsert;
        }     
        
        
        
        
    }
    /**
* @description method to upsert the location list
* @param BatchableContext  
* @return null
*/  
    public void finish(Database.BatchableContext BC) {
        
        
        if(countryIdSet.size() > 0){
            AITM_MetaDataUtility mdUtility = new AITM_MetaDataUtility();
            mdUtility.updateMetadata(countryIdSet, TRUE);
        }
        
    }
    
    
}