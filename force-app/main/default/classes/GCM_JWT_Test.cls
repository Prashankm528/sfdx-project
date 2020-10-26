/****************************************************************************************************
 * Date          : 24-SEP-2020
 * Author        : Sunny Yap
 * Description   : Test class for GCM_JWT
 * Modifications : 24-SEP-2020 SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_JWT_Test
{
/****************************************************************************************************
 * Test Encryption
 ****************************************************************************************************/
    @isTest static void testJWT() {
        Test.startTest();
        String jwt = GCM_JWT.getJWTToken('alias', 'aud', 'iss', 'sub', 'https://test.salesforce.com/services/oauth2/token');
        Test.stopTest();
    }
}