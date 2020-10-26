/****************************************************************************************************
*  Date          : 6-AUG-2019
*  Author        : Roselin Hephzibah
*  Description   : Email to Case controller.
*  Modifications : 
****************************************************************************************************/

public with sharing class GCM_E2C_Controller {

/****************************************************************************************************
  Picks the email pattern in the case description and update it in SuppliedEmail field in case.
 ****************************************************************************************************/
 
    @InvocableMethod
    public static void updateCase(List<Case> caseList){
        List<case> updateCaseList = new List<Case>();
        List<Id> caseIdList = new List<Id>(); 
        try{
            
            for(Case cas : caseList) {
                String text = cas.description;
                
                //Regex to find email address in Case Description
                String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';       
                Pattern myPattern = Pattern.compile(regex );    
                Matcher myMatcher = myPattern.matcher(text);
                
                if (myMatcher.find()) {                 
                    //update the SuppliedEmail field in case with the found email address
                    case c = new case();
                    c.id = cas.Id;
                    c.SuppliedEmail = myMatcher.group();
                    updateCaseList.add(c);
                }
                system.debug(updateCaseList);
                
                caseIdList.add(cas.Id);
                
            }
            
            //Update the Case
            if(!updateCaseList.isEmpty()){
                update updateCaseList;
            }
        }catch (Exception exceptionObject) {
            BPG_Error_Logger errorLogger = new BPG_Error_Logger(exceptionObject, 'Class', 'GCM_E2C_Controller', 'updateCase', caseIdList, 'GCM_Business_Administrator');
        }
    }
}