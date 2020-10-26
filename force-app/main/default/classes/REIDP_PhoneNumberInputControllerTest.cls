/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 03/09/2018
*
**/

@isTest
public with sharing class REIDP_PhoneNumberInputControllerTest {
    
    @isTest
    public static void testGetCountryCallingCodes() {
        
        Test.startTest();
        List<REIDP_PhoneNumberInputController.CountryCode> result = REIDP_PhoneNumberInputController.getCountryCallingCodes(); 
        Test.stopTest();
        
        System.assert(result.size() > 0);
        
    }
    
    @isTest
    public static void testGetDefaultCountryCode() {
        
        Test.startTest();
        REIDP_PhoneNumberInputController.CountryCode result = REIDP_PhoneNumberInputController.getDefaultCountryCode(); 
        Test.stopTest();
        
        System.assertEquals('91_in', result.value);
        System.assertEquals('+91', result.label);
        System.assertEquals(true, result.selected);
        
    }
}