/**
* @Who     Palash Awasthi
* @when    31-07-2019
* @what    This class handles trigger activities related to Case object and ICRM project
*          
**/
public  class ICRM_CaseTriggerHandler extends BPG_Trigger_Handler_Utilities{
/*Case trigger: pattern drive */     
    private String recName = 'Ticketing';
    private String Internal_Form = 'Internal Form'; 
    private String Exist_Cust_Form = 'Existing Customer Form';
    private String New_Cust_Form = 'New Customer Form';
    private String External_Form = 'External Form';
    
/**
* @description method to update contact before Case insert  with sharing
*/
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
/*Process record before insert  */ 
        String processcontactfornoninternal = 'No';
        String processcontactforinternal = 'No';
        List<Case> CaseListinternal = new List<Case>();
        List<Case> CaseListnoninternal = new List<Case>();
        List<Case> castCaseRecs = new List<Case>();
        List<String> TKTcaseEmailListfornoninternal = new List<String>();
        List<String> TKTcaseLastNameList = new List<String>();
        List<String> TKTcaseEmailListforinternal = new List<String>();
       
        castCaseRecs = n;
// Pickup Cases not associated with any Contacts
        System.debug('NEW CASES ARE--'+castCaseRecs);
        for(Case c : castCaseRecs){
// Process contact record only when Case_Origin is Internal Form, External Form, or New Customer Form   
            If((c.Origin == this.Internal_Form)||(c.Origin == this.Exist_Cust_Form)||(c.Origin == this.New_Cust_Form)||(c.Origin == this.External_Form)){  
            string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname();
            System.debug('recordTypename is--'+recordtypename);

// Process only Ticketing recordtype             
            if(recordtypename == this.recName && c.ContactId == NULL){
                
                if(c.origin == this.Internal_Form)
                {
                String customeremail = c.TKT_Customer_Email_Address__c;
                
               
               TKTcaseEmailListforinternal.add( customeremail);
               processcontactforinternal = 'Yes';
                
                CaseListinternal.add(c);
                }
                else
                {
                TKTcaseEmailListfornoninternal.add(c.SuppliedEmail);
                TKTcaseLastNameList.add(c.TKT_Last_Name__c);
                processcontactfornoninternal = 'Yes'; 
                CaseListnoninternal.add(c);
                }
            }
        }
      }
  //  System.debug('EFFECTIVE caseList is--'+CaseList);
   // System.debug('EFFECTIVE TKTcaseEmailList is = '+TKTcaseEmailList);
    System.debug('TKTcaseLastNameList is-- '+TKTcaseLastNameList);
 //   System.debug('processcontact-- '+ processcontact);
//processcontact = 'Yes' then process the below login  this represents process contact for existing and new customer form
     If(processcontactfornoninternal == 'Yes'){
        processcontact(TKTcaseEmailListfornoninternal, TKTcaseLastNameList, CaseListnoninternal, false);

    }
    if(processcontactforinternal == 'Yes')
    {
    processcontact(TKTcaseEmailListforinternal, TKTcaseLastNameList, CaseListinternal, true);

    
    }
    } 
    
    /**
* @description method to update cases with contact
*/
    public void processcontact(List<String> TKTcaseEmailList, List<String> TKTcaseLastNameList, List<Case> CaseList, Boolean internalflag)
    {
    //Map of Contacts: key is lastName and Email, value is List of Contacts with same email and lastname combination
        Map<String,List<Contact>> ConMap = new Map<String,List<Contact>>();
        List<Contact> ContactListforcase ;
        if(!internalflag)
        {
        ContactListforcase = [SELECT id,LastName,Email FROM Contact WHERE Email IN:TKTcaseEmailList AND LastName IN:TKTcaseLastNameList AND RecordType.DeveloperName = 'ICRM_Contact'];
        
       }
       else
       {
       ContactListforcase = [SELECT id,LastName,Email FROM Contact WHERE Email IN:TKTcaseEmailList AND RecordType.DeveloperName = 'ICRM_Contact'];
       }
        for(Contact con:ContactListforcase)
        {
            String conkey ;
            if(!internalflag)
            {
            conkey = con.LastName.touppercase()+';'+con.Email.touppercase();
            }
            else
            {
            conkey = con.Email.touppercase();
            }
            // get the contact
            if(ConMap.containsKey(conkey))
            {
                ConMap.get(conkey).add(con);
            }
            else
            {
                List<Contact> similarKeyContactList = new List<Contact>();
                similarKeyContactList.add(con);
                ConMap.put(conkey, similarKeyContactList);
            }
        }
        System.debug('Con map is '+ConMap);
        
        //Iterate Cases to get the matching key from contacts
        for(Case caseObj : CaseList){  
            
    // Check for caseObj - TKT_Last_Name__c blank 

              
            String caseKey ;
            if(!internalflag)
            {
           String lastname = caseObj.TKT_Last_Name__c;
           if(lastname == null)
           {
           lastname = ' ';
           }
           String email = caseObj.SuppliedEmail;
           if(email == null)
           {
           email = ' ';
           }
           System.debug('email is '+email);
           
            caseKey = lastname.touppercase()+';'+email.touppercase() ;
             System.debug('casekey '+caseKey);
            }
            else
            {
            String caseemail = caseObj.TKT_Customer_Email_Address__c;
            System.debug('Case email is '+ caseemail);
            if(caseemail == null)
            {
            caseemail = '    ';
            }
            caseKey = caseemail.touppercase() ;
            }
            List<Contact> ContactList = new List<Contact>();
            if(ConMap.containsKey(caseKey)){
                
                ContactList =  ConMap.get(caseKey);
                if(ContactList.size() == 1)
                {
                    caseObj.ContactId = ConMap.get(caseKey)[0].id ;
                }
            }
        
    }
    }
    
     
  
}