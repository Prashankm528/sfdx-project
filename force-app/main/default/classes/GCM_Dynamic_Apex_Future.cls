/****************************************************************************************************
 * Date          : 11-FEB-2020
 * Author        : Sunny Yap
 * Description   : Invocable class for Dynamic Apex that runs asynchoronously.
 *                 This is needed because callouts cannot be invoked from triggers.
 * Modifications : 11-FEB-2020 Initial
 ****************************************************************************************************/

public with sharing class GCM_Dynamic_Apex_Future {
/****************************************************************************************************
 * Run Lookup Apex Code Based On Reference, Record Id Passed In + Invoke The Apex Code
 ****************************************************************************************************/
    @future(callout=true)
    public static void run(String reference, Id recordId) {
        String code = null;
        List<GCM_Automation__c> codes = [select GCM_Code__c from GCM_Automation__c where Name = :reference];
        for (GCM_Automation__c thisCode : codes) {
        	code = thisCode.GCM_Code__c;
		}
        
        if (code != null) {
        	code = code.replace('{!Id}', recordId);
            String returnValue = GCM_Dynamic_Apex.run(code);
        }
    }
}