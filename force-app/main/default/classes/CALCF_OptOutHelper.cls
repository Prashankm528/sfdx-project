/************************************************************************************************************
*Description : This class contains logic for opting out contacts.
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-FEB-28   1.0                 Frantisek Kolacny   Initial version 
* 2017-Aug-14   1.1                 Frantisek Kolacny   Survey_Opt_Out__c added for synchronization
* 2017-Aug-22   1.2                 Grant Whitfield     CASSFO-1955 : Now using 'without sharing' keyword and
*                                                       using deduplication id to limit search on contacts to Castrol
*************************************************************************************************************/
public without sharing class CALCF_OptOutHelper {

	/************************************************************************************************************
	* If OptOUT is requested by setting "Survey_Opt_Out_Requested__c = true" call this method to 
	* synchronize opt out with all others contacts sharing the same email address. 
	*************************************************************************************************************/

	
	@future
    public static void newOptOutRequested(String contactId){
    	
    	list<contact> contactEmail = [SELECT Email, Next_Surveyable_Date__c 
                                        FROM Contact 
                                        WHERE Id =: contactId];   	   	  	
    	list<contact> sameEmailCon = [SELECT Id, Next_Surveyable_Date__c, Survey_Opt_Out_Requested__c 
                                        FROM Contact 
                                        WHERE Email =:contactEmail.get(0).Email
                                        AND Contact_Deduplication_Id__c != ''];
    	
    	lcf_settings__c settings = lcf_settings__c.getInstance();
    	integer doNotSurvey = integer.valueof(settings.Opt_Out_Period__c);
    	
    	list<contact> contactsToUpdate = new list<contact>();
    	for(contact con : sameEmailCon){
    		con.Next_Surveyable_Date__c = Datetime.now().addDays(doNotSurvey).Date();
    		con.Survey_Opt_Out_Requested__c = false;
    		contactsToUpdate.add(con);
    	}    
    	 
    	update contactsToUpdate;
    	
    }
	
	/************************************************************************************************************
	* If new record is created call this method to synchronize opt out with all others contacts sharing
	* the same email address. 
	*************************************************************************************************************/
	@future
    public static void newRecordCreated(String contactId){
    	
    	list<contact> contacts = [SELECT Id, Email, Next_Surveyable_Date__c, Last_Surveyed_Date__c 
                                    FROM Contact WHERE Id =: contactId];                          
        
    	Contact myContact = contacts.get(0);
    	
        //For some reason the SOQL for two aggregate results from one query was not working,
        // hence two queries.
    	AggregateResult[] nextDateResults = [SELECT MAX(Next_Surveyable_Date__c) next_date 
                                                FROM Contact 
                                                WHERE Email =:myContact.Email
                                                AND Contact_Deduplication_Id__c != ''
                                                GROUP BY Email];
        AggregateResult[] lastDateResults = [SELECT MAX(Last_Surveyed_Date__c) last_date 
                                                FROM Contact 
                                                WHERE Email =:myContact.Email
                                                AND Contact_Deduplication_Id__c != ''
                                                GROUP BY Email];
    	
        //Initialising variable holding the values to check for null pointer
    	Datetime myDate;
    	Datetime myLastDate;

    	if(nextDateResults.size() != 0 && nextDateResults[0].get('next_date') != null){
        	Object maxDate = nextDateResults[0].get('next_date');
        	myDate = (Datetime)maxDate;
    	}
    	
    	if(lastDateResults.size() != 0 && lastDateResults[0].get('last_date') != null){
            Object lastDate = lastDateResults[0].get('last_date');
            myLastDate = (Datetime)lastDate;
    	}
    	
    	list<contact> sameEmailCon = [SELECT Id, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                        FROM Contact 
                                        WHERE Email =:myContact.Email
                                        AND Contact_Deduplication_Id__c != ''];
    	list<contact> contactToUpdate = new list<contact>();
    	
    	boolean isSomeContactOptedOut = false; 

    	for(Contact con : sameEmailCon){
            //Check if the Next_Surveyable_Date__c is null, if not update it with all contacts
    	    if(myDate != null) {
    		    con.Next_Surveyable_Date__c     = myDate.Date();
    	    }
    		if(myLastDate != null){
                //Check if the Last_Surveyed_Date__c is null, if not update it with all contact
                con.Last_Surveyed_Date__c       = myLastDate.Date();
    		}
            //Update this helper flag to null, this helps the process builder know which contacts to
            //synchronize. Only contacts with Last_Survey_Date_Helper__c == true are considered in the
            //Process Builder
            con.Last_Survey_Date_Helper__c  = false;
            
            if(con.Survey_Opt_Out__c == true){
            	isSomeContactOptedOut = true;
            }
    		contactToUpdate.add(con);    		
    	}
    	
    	if(isSomeContactOptedOut == true){
    		for(Contact con : contactToUpdate){
    			con.Survey_Opt_Out__c = true;
    		}
    	}
    	
    	update contactToUpdate;

    	
    }

	/************************************************************************************************************
	* If email address is created call this method to synchronize opt out with all others contacts sharing
	* the same email address. 
	*************************************************************************************************************/
	@future
    public static void emailAddressChanged(String contactId){
    	
    	list<contact> contacts = [SELECT Id, Email, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out_Requested__c 
                                    FROM Contact 
                                    WHERE Id =: contactId];
    	Contact myContact = contacts.get(0);
    	
    	list<contact> sameEmailCon = [SELECT Id, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                        FROM Contact 
                                        WHERE Email =:myContact.Email
                                        AND Contact_Deduplication_Id__c != ''];
                                        
        list<contact> optedOutContacts = [SELECT Id, Next_Surveyable_Date__c, Last_Surveyed_Date__c, Survey_Opt_Out__c
                                        FROM Contact 
                                        WHERE Email =:myContact.Email 
                                        AND Survey_Opt_Out__c = true
                                        AND Contact_Deduplication_Id__c != ''];
                                        
        list<contact> contactToUpdate = new list<contact>();
        
        // First check if any of contacts is currently opred out.
        if(optedOutContacts.size() != 0){
        	
        	for(Contact con : sameEmailCon){
    			con.Survey_Opt_Out__c = true;
    		}
    		
    		update sameEmailCon;
        }        
    	
    	AggregateResult[] results = [SELECT MAX(Next_Surveyable_Date__c)next_date, MAX(Last_Surveyed_Date__c)last_date
                                        FROM Contact 
                                        WHERE Email =:myContact.Email
                                        AND Contact_Deduplication_Id__c != ''];
    	
    	if(results.size() == 0 || results[0].get('next_date') == null || results[0].get('last_date') == null){
    		return;
    	}
    	
    	Object maxDate = results[0].get('next_date');
    	Datetime myDate = (Datetime)maxDate;

        Object lastDate = results[0].get('last_date');
        Datetime myLastDate = (Datetime)lastDate;
    	    	
    	for(Contact con : sameEmailCon){
    		con.Next_Surveyable_Date__c = myDate.Date();
            con.Last_Surveyed_Date__c = myLastDate.Date();            
    		contactToUpdate.add(con);    		
    	}
  	
    	update contactToUpdate;
    	
    }
}