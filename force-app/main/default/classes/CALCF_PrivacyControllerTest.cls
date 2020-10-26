/*****************************************************************************************
*	    Date:		    24April2020
*       Author:         Narasimha Datla 
*       Description:    Test class for CALCF_PrivacyController
****************************************************************************************/
@isTest
public class CALCF_PrivacyControllerTest 
{
    @isTest
    private static void CALCF_PrivacyControllerTest(){
        Test.setCurrentPageReference(new PageReference('Page.testPage')); 
        System.currentPageReference().getParameters().put('lan', 'EN');
        System.currentPageReference().getParameters().put('brand', 'BP');
       
        Test.startTest();
        	CALCF_PrivacyController privacyController = new CALCF_PrivacyController();
 		Test.stopTest();           
        
        system.assertEquals('EN',privacyController.language,'Language value should be equal to EN');
        system.assertEquals('BP',privacyController.brand,'brand value should be equal to BP');

    }
}