/****************************************************************************************************
 *  Date          : 18-SEP-2020
 *  Author        : Sunny Yap
 *  Description   : Test class for GCM_Email_Automatic_Response Process Builder
 *                  Only 10 nodes supported per class due to outbound email governor limit,
 *                  up to 10 emails per execution.
 * Modifications  : 
 * 18-SEP-2020    : SYAP - Initial
 ****************************************************************************************************/
@isTest(isParallel=true)
public with sharing class GCM_Test_GCM_Email_Automatic_Response_2
{
/****************************************************************************************************
 * Create Cases That Trigger Automatic Email Response
 ****************************************************************************************************/   
    @isTest static void validateEmailResponse() {
        List<Map<String, String>> testDataList = new List<Map<String, String>>();
        Map<String, String> testData = null;
        
        // GCM MX Fuels Consumer Mailbox 10
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Problema de cuenta o contraseña Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 11
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre La estación no cuenta con sistema de facturación Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Dealer Consumer
        testData = new Map<String, String>();
        testData.put('Origin', 'atencion@bp.com');
        testData.put('Description', 'Pre Test Post');
        testData.put('SuppliedEmail', 'test@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Billing Mailbox
        testData = new Map<String, String>();
        testData.put('Origin', 'FacturacionMex@bp.com');
        testData.put('Description', 'Pre Test Post');
        testData.put('SuppliedEmail', 'test@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Coco Recon Mailbox
        testData = new Map<String, String>();
        testData.put('Origin', 'ReconciliationMX@bp.com');
        testData.put('Description', 'Pre Test Post');
        testData.put('SuppliedEmail', 'test@bp.com');
        testDataList.add(testData);

        // GCM MX AR Mailbox Auto Response
        testData = new Map<String, String>();
        testData.put('Origin', 'CuentasporCobrarMex@bp.com');
        testData.put('Description', 'Pre Test Post');
        testData.put('SuppliedEmail', 'test@bp.com');
        testDataList.add(testData);

        // GCM MX Credit Mailbox Auto Response
        testData = new Map<String, String>();
        testData.put('Origin', 'CreditoMex@bp.com');
        testData.put('Description', 'Pre Test Post');
        testData.put('SuppliedEmail', 'test@bp.com');
        testDataList.add(testData);

        // Create Cases
        List<Case> cases = new List<Case>();
        for (Map<String, String> record : testDataList) {
            Case request = new Case();
            request.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GCM_Fuels_Dealer').getRecordTypeId();
            request.Origin = record.get('Origin');
            request.Description = record.get('Description');
            request.SuppliedEmail = record.get('SuppliedEmail');
            request.GCM_ByPassValidation_Timestamp__c = Datetime.now();
            cases.add(request);
        }
        List<Database.SaveResult> results = Database.insert(cases); 
        System.assert(results.size() == testDataList.size(), 'Cases Created');
    }
}