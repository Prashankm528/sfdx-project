/**
* @author         Sid
* @date           2/10/2019
* @description    Controller class for trigger on LC Parcels Object
* @Logic          If Case is removed from Parcel record, amount field on case should be re-calculated and 
*                 Status of parcel record should be reset.
* @Assumptions    NA 
*/

/* Change History: 
 * Date : 11/13/2019
 * Change done by: Sid
 * Description : Instead of removal of case, check if GCP_TFD_Audit__c is updated as 'D' and then
 *               amount field on case should be re-calculated and status of parcel record should be reset. 
 * 
 */
 /* Change History: 
 * Date : 24/08/2020
 * Change done by: Subin
 * Description : Once the LCP is updated, the Deal Value and Claim Volume will be recalculated. Added method updateCaseDetails for the same. 
 * 
 */
 
 /* Change History: 
 * Date : 22/09/2020
 * Change done by: Subin
 * Description : Modified the condition based on which a parcel is deleted or cancelled. 
 * 
 */
public with sharing class GCP_TFD_LcParcelsTriggerHandler 
{
    /**   
      * @description       This method checks if case is removed from parcel record and update amount field on case accordingly.
      * @param             trigger.newmap,tirgger.oldmap             
      * @return            Void     
      * @throws            NA      
      */
    public static void updateCaseAmount(map<Id,GCP_TFD_LC_Parcel__c> newparcelsmap,Map<Id,GCP_TFD_LC_Parcel__c> oldparcelsmap, Boolean IsUpdate)
    {
        //Variable Declaration...
        List<GCP_TFD_LC_Parcel__c> parcelsgotupdated = new List<GCP_TFD_LC_Parcel__c>();
        List<GCP_TFD_LC_Parcel__c> parcelstoupdate = new List<GCP_TFD_LC_Parcel__c>();
        List<Id> parcelstodelete = new List<Id>();
        List<GCP_TFD_LC_Parcel__c> parcelsgotdeleted = new List<GCP_TFD_LC_Parcel__c>();
        List<Id> caseids = new list<id>();
        List<Id> parcelids = new list<id>();
        map<id,List<GCP_TFD_LC_Parcel__c>> caseidtoparcelsmap = new map<id,List<GCP_TFD_LC_Parcel__c>>();
        map<id,decimal> caseidtoamountmap = new map<id,decimal>();
        map<id,decimal> caseidtovolumemap = new map<id,decimal>();
        list<case> casestoupdate = new list<case>();
        GCP_TFD_LC_Parcel__c oldparcel;
        //Variable Declaration End.
        List<GCP_TFD_LC_Parcel__c> parcelstoremovecase = new List<GCP_TFD_LC_Parcel__c>();
        try
        {
            savepoint sp = database.setSavepoint();
            //Logic to check if GCP_TFD_Audit__c is updated as 'D' on Parcel record...
            for(GCP_TFD_LC_Parcel__c parcel:newparcelsmap.values())
            {
                system.debug('Old parcel is : '+oldparcelsmap);
                if(IsUpdate && oldparcelsmap != null && oldparcelsmap.get(parcel.id) != null)
                oldparcel = oldparcelsmap.get(parcel.id);
            
                if(((!IsUpdate) && parcel.GCP_TFD_Audit__c == 'D' || (parcel.GCP_TFD_Deal_Status__c != null && parcel.GCP_TFD_Deal_Status__c != 'Complete' && parcel.GCP_TFD_Deal_Status__c != 'Completed') || (parcel.GCP_TFD_Payment_Security_Name__c != null && parcel.GCP_TFD_Payment_Security_Name__c != 'SBLC' && parcel.GCP_TFD_Payment_Security_Name__c != 'LC' && parcel.GCP_TFD_Payment_Security_Name__c != 'PREPAY') || parcel.GCP_TFD_Parcel_Status__c == 'Unscheduled' || parcel.GCP_TFD_Parcel_Status__c == 'Deleted' || parcel.GCP_TFD_Parcel_Status__c == 'Planned') || ((IsUpdate && parcel.GCP_TFD_Audit__c == 'D' || (parcel.GCP_TFD_Deal_Status__c != null && parcel.GCP_TFD_Deal_Status__c != 'Complete' && parcel.GCP_TFD_Deal_Status__c != 'Completed') || (oldparcel.GCP_TFD_Deal_Buy_Sell_Ind__c=='B' && parcel.GCP_TFD_Deal_Buy_Sell_Ind__c=='S') || (oldparcel.GCP_TFD_Deal_Buy_Sell_Ind__c=='S' && parcel.GCP_TFD_Deal_Buy_Sell_Ind__c=='B') || (parcel.GCP_TFD_Payment_Security_Name__c != null && parcel.GCP_TFD_Payment_Security_Name__c != 'SBLC' && parcel.GCP_TFD_Payment_Security_Name__c != 'LC' && parcel.GCP_TFD_Payment_Security_Name__c != 'PREPAY') || parcel.GCP_TFD_Parcel_Status__c == 'Unscheduled' || parcel.GCP_TFD_Parcel_Status__c == 'Deleted' || parcel.GCP_TFD_Parcel_Status__c == 'Planned')))
                { 
                    if(parcel.GCP_TFD_Claim_Status__c == GCP_TFD_Constant.PARCEL_STATUS_NEW)
                    {
                        system.debug('Inside list parcel');
                        parcelstodelete.add(parcel.Id);     
                        system.debug('parcelstodelete :'+parcelstodelete);
                    }
                    else
                    {
                        parcelsgotupdated.add(parcel);
                        if(parcel.GCP_TFD_Related_Case__c != NULL)
                        {
                            caseids.add(parcel.GCP_TFD_Related_Case__c);    
                        }                        
                        parcelids.add(parcel.id);
                    }
            }
            }
            if(!parcelids.isempty())
            {
                //Removing case record from parcel records...
                for(GCP_TFD_LC_Parcel__c par :[select id, GCP_TFD_Related_Case__c from GCP_TFD_LC_Parcel__c
                                               where id in :parcelids])
                {
                    par.GCP_TFD_Related_Case__c = NULL;
                    parcelstoremovecase.add(par);
                }  
                update parcelstoremovecase;
            }                
            //Doing actual logic only if parcelsgotupdated is not blank...
            system.debug('parcelsgotupdated is : '+parcelsgotupdated);
            if(!parcelsgotupdated.isempty())
            {
                //Fetching all the parcel records related to the case and storing in map of caseid to list of parcels...
                for(GCP_TFD_LC_Parcel__c par:[select GCP_TFD_Amount__c,GCP_TFD_Related_Case__c,GCP_TFD_Quantity__c
                                              from GCP_TFD_LC_Parcel__c where 
                                              GCP_TFD_Related_Case__c in :caseids])
                {
                    //If map contains the caseid, just add a new parcel in the value...
                    if(caseidtoparcelsmap.containskey(par.GCP_TFD_Related_Case__c))
                    {
                        caseidtoparcelsmap.get(par.GCP_TFD_Related_Case__c).add(par);
                    }
                    //if not present, create new record in map...
                    else
                    {
                        caseidtoparcelsmap.put(par.GCP_TFD_Related_Case__c, new list<GCP_TFD_LC_Parcel__c> {par});
                    }
                }
                //Check if there are no parcel records associated to the case... update case amount as 0.
                if(caseidtoparcelsmap.isempty())
                {
                    case cs;
                    for(id caseid :caseids)
                    {
                        cs = new case();
                        cs.id = caseid;
                        cs.GCP_TFD_Total_Price__c = 0;
                        cs.GCP_TFD_Claim_Volume__c = 0;
                        casestoupdate.add(cs);
                    }
                }
                //Now looping over each case and calculate the amount...
                for(id caseid:caseidtoparcelsmap.keyset())
                {
                    decimal amount = 0;
                    decimal volume = 0;
                    for(GCP_TFD_LC_Parcel__c parcel :caseidtoparcelsmap.get(caseid))
                    {
                        amount = amount+parcel.GCP_TFD_Amount__c;
                        volume = volume+parcel.GCP_TFD_Quantity__c;
                    }
                    caseidtoamountmap.put(caseid,amount);
                    caseidtovolumemap.put(caseid,volume);
                }
                //Finally, update the case records...
                case cs;
                for(id caseid:caseidtoamountmap.keyset())
                {
                    cs = new case();
                    cs.id = caseid;
                    cs.GCP_TFD_Total_Price__c = caseidtoamountmap.get(caseid);
                    cs.GCP_TFD_Provisional_Claim_Amount__c = caseidtoamountmap.get(caseid);
                    cs.GCP_TFD_Claim_Volume__c = caseidtovolumemap.get(caseid);
                    casestoupdate.add(cs);
                }
                update casestoupdate;
                //Updating Parcel records with status as new...
                for(GCP_TFD_LC_Parcel__c par:[select GCP_TFD_Claim_Status__c from GCP_TFD_LC_Parcel__c
                                              where id in :parcelids])
                {
                    par.GCP_TFD_Claim_Status__c = GCP_TFD_Constant.PARCEL_STATUS_CLAIM_CANCELLED;
                    parcelstoupdate.add(par);                    
                }
                update parcelstoupdate;
            }
            system.debug('parcelstodelete :'+parcelstodelete);
            //Deleting the parcel if Status is 'New' and Audit is 'D'...
            for(GCP_TFD_LC_Parcel__c par :[select id from GCP_TFD_LC_Parcel__c where id in :parcelstodelete])
            {
                parcelsgotdeleted.add(par);
            }
            delete parcelsgotdeleted;
        }
        catch(exception e)
        {
            system.debug('Exception catched :'+e.getMessage());    
        }       
    }
    
    public static void updateCaseDetails(map<Id,GCP_TFD_LC_Parcel__c> newparcelsmap)
    {
        Decimal totalamount=0;
        Decimal totalvolume=0;
        List<Id> caseids = new List<id>();
        List<Case> csList = new List<Case>();
        List<Case> caseUpdateList = new List<Case>();
        try
        {           
            for(GCP_TFD_LC_Parcel__c parcel:newparcelsmap.values())
            {
                if(parcel.GCP_TFD_Related_Case__c != null)  
                {
                    caseids.add(parcel.GCP_TFD_Related_Case__c);
                }
                system.debug('Case Ids are : '+caseids);
            }
            for(GCP_TFD_LC_Parcel__c lcp:[select id,GCP_TFD_Amount__c,GCP_TFD_Quantity__c,GCP_TFD_Related_Case__c,GCP_TFD_Claim_Status__c from GCP_TFD_LC_Parcel__c where GCP_TFD_Related_Case__c in :caseids])
            {
                if(lcp.GCP_TFD_Amount__c != null && lcp.GCP_TFD_Claim_Status__c == 'Claimed')
                totalamount = totalamount+lcp.GCP_TFD_Amount__c;
                if(lcp.GCP_TFD_Quantity__c != null && lcp.GCP_TFD_Claim_Status__c == 'Claimed')
                totalvolume = totalvolume+lcp.GCP_TFD_Quantity__c;
                system.debug('Inside Total Amount is : '+totalamount);
                system.debug('Inside Total Volume is : '+totalvolume);
            }
            system.debug('Total Amount is : '+totalamount);
            system.debug('Total Volume is : '+totalvolume);
            if(caseids.size()>0)
            csList = [Select Id,GCP_TFD_Provisional_Claim_Amount__c,GCP_TFD_Claim_Volume__c,GCP_TFD_Total_Price__c from Case where Id in :caseids];
            if(csList.size()>0)
            {
                for(Case cs:csList)
                {
                    cs.GCP_TFD_Provisional_Claim_Amount__c = totalamount;
                    cs.GCP_TFD_Total_Price__c = totalamount;
                    cs.GCP_TFD_Claim_Volume__c = totalvolume;
                    caseUpdateList.add(cs);
                }
            }
            Update caseUpdateList;
        }
        catch(exception e)
        {
            system.debug('Exception catched :'+e.getMessage());    
        }
    }
}