/****************************************************************************************************
 * Date          : 18-JUN-2020
 * Author        : Sunny Yap
 * Description   : Test class for PCI Verification.
 * Modifications : 10-JUN-2020 Initial
 ****************************************************************************************************/
@isTest(isParallel=true)

public with sharing class GCM_PCI_Check_Test {
/******************************************************************************************
  Test Verify Card Number
 ******************************************************************************************/
    @isTest static void testVerifyPCI() {
        Test.startTest();
        
        System.assert(GCM_PCI_Check.verifyCardNumber('378282246310005'), 'American Express');
        System.assert(GCM_PCI_Check.verifyCardNumber('378734493671000'), 'American Express Corporate');
        System.assert(GCM_PCI_Check.verifyCardNumber('30569309025904'), 'Diners Club'); 
        System.assert(GCM_PCI_Check.verifyCardNumber('6011111111111117'), 'Discover'); 
        System.assert(GCM_PCI_Check.verifyCardNumber('3530111333300000'), 'JCB'); 
        System.assert(GCM_PCI_Check.verifyCardNumber('5555555555554444'), 'Master Card'); 
        System.assert(GCM_PCI_Check.verifyCardNumber('4012888888881881'), 'Visa');        
        Test.stopTest();
    }
}