/*****************************************************************************************
*	    Date:		    24April2020
*       Author:         Narasimha Datla 
*       Description:    Test class for CASFO_PrivacyStatementControllerClass
****************************************************************************************/
@isTest
public class CASFO_PrivacyStatementControllerTest 
{
    static User testCastrolUser;
    
    @testSetup 
    static void setupTestdata() 
    {
        testCastrolUser = SFO_TestDataService.createCastrolSalesUser(SFO_TestDataService.CastrolSalesUserProfile.Id, SFO_TestDataService.CastrolSalesAlpineFwsSalesRole.Id);
        testCastrolUser.Email = 'testUSer1243423@Testemal98345.com';
        testCastrolUser.Sales_Organisation__c = 'US01';
        testCastrolUser.isActive = True;
        insert testCastrolUser;	
    }
    
    @isTest
    private static void getSalesOrgTest()
    {
        String  salesOrganisation;
        testCastrolUser = [Select Id,Sales_Organisation__c From User Where Email = 'testUSer1243423@Testemal98345.com'];
        
        Test.startTest();
        system.runAs(testCastrolUser)
        {
            salesOrganisation = CASFO_PrivacyStatementControllerClass.getSalesOrg();
        }
        Test.stopTest();
        
        system.assertEquals('US01',salesOrganisation,'salesOrganisation value should be equal to US01');
    }
    
    @isTest
    private static void getProfileTest()
    {
		String  profileName;
        testCastrolUser = [Select Id From User Where Email = 'testUSer1243423@Testemal98345.com'];
        Profile userProfile = [Select Id,Name From Profile Where Id =: SFO_TestDataService.CastrolSalesUserProfile.Id];
        
        Test.startTest();
        system.runAs(testCastrolUser)
        {
            profileName = CASFO_PrivacyStatementControllerClass.getProfile();
        }
        Test.stopTest();
        
        system.assertEquals(userProfile.Name,profileName,'profileName value should be equal to '+ userProfile.Name);
    }
    
    @isTest
    private static void isOpenTextPilotCountryTest()
    {
        Boolean isOpenTextPilotCountry;
        SFO_OpenText_Country__mdt openTextCountry = [Select Id,DeveloperName From SFO_OpenText_Country__mdt limit 1];

        Test.startTest();
			isOpenTextPilotCountry = CASFO_PrivacyStatementControllerClass.isOpenTextPilotCountry(openTextCountry.DeveloperName);
        Test.stopTest();

        system.assert(isOpenTextPilotCountry,'isOpenTextPilotCountry should retuen boolean value True For '+ openTextCountry.DeveloperName);
    }
}