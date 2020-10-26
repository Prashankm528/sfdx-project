/****************************************************************************************************
 *  Date          : 06-Aug-2019
 *  Author        : Roselin Hephzibah
 *  Description   : Test class for GCM_E2C_Controller
 * Modifications  : 
 ****************************************************************************************************/
@isTest
public with sharing class GCM_E2C_Controller_Test {

/****************************************************************************************************
  TestMethod for updateCase() in GCM_E2C_Controller.
 ****************************************************************************************************/
    public static testMethod void testUpdateCase() {
        // Create Case
        List<Case> caseList = new List<Case>();
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'Test Case';
        c.Description = 'Test Case test123@gmail.com';
        insert c;
        caseList.add(c);
        GCM_E2C_Controller.updateCase(caseList);
        
        List<Case> caseResult = [select SuppliedEmail from Case where Id = :c.Id];
        System.assert(caseResult.size() > 0, 'Case Found');
        System.assert(caseResult[0].SuppliedEmail != null, 'Case From Email Set');
    }
}