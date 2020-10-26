/*
  @descrition Account_OLCM_records_sharing_Based_on_SalesOrgValue
  @Owner OLCM_Project_CMF
  @Date 20/08/2019
      
*/
public without sharing class Olcm_recordSharing {

/*
***********************************************************
@ Method to clear AccountShare Records before updating it
***********************************************************
*/    
    public static void ShareDelAcc(Map<id,Account> recordId,Map<String,Id> pubdel){     
     List<AccountShare> accountShareToDelete = [select Id,RowCause,AccountId,UserOrGroupId from AccountShare where AccountId in :recordId.keySet()  and UserOrGroupId in :pubdel.values() and RowCause='Manual'];
     if (accountShareToDelete.size() > 0) {
      delete accountShareToDelete;
      }      
        
    }      
    
    /*
****************************************************************************
@ Method to Share AccountShare Records on creating and updating _OLCM
****************************************************************************
*/  
    public static void ShareEditAcc(Id recordId,String salesvalue,List<group> gpid,Group gpval){
         String idvale;
       
        for(group gy:gpid){
            if(gy.Name.contains(salesvalue)){
                idvale=gy.id;
                break;
            }
            
        }
      
        if(idvale!=null &&idvale!=''){
            
            // Create new sharing object for the Account object.
            AccountShare accShr  = new AccountShare();
            
            // Set the ID of record being shared.
            accShr.AccountId = recordId;
            
            // Set the ID of user or group being granted access.
            accShr.UserOrGroupId = idvale;
            
            // Set the access level.
            accShr.AccountAccessLevel = 'Edit';
            accShr.CaseAccessLevel='read';
            
            accShr.OpportunityAccessLevel='read';
            
            Database.SaveResult sr = Database.insert(accShr,false);
            if(sr.isSuccess()){
                
            }
            else{
               system.debug('error values'+ sr.getErrors());
            }
            
        }
        else{
            
            
            
            // Create new sharing object for the Account object.
            AccountShare accShr  = new AccountShare();
            
            // Set the ID of record being shared.
            accShr.AccountId = recordId;
            
            // Set the ID of user or group being granted access.
            accShr.UserOrGroupId = gpval.id;
            
            // Set the access level.
            accShr.AccountAccessLevel = 'Edit';
             accShr.CaseAccessLevel='read';
            
            accShr.OpportunityAccessLevel='read';
            Database.SaveResult sr = Database.insert(accShr,false);
             if(sr.isSuccess()){
                
            }
            else{
               system.debug('error values'+ sr.getErrors());
            }
            
        }
    }
    
    
    
    
}