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
public with sharing class GCM_Test_GCM_Email_Automatic_Response_1
{
/****************************************************************************************************
 * Create Cases That Trigger Automatic Email Response
 ****************************************************************************************************/   
    @isTest static void validateEmailResponse() {
        Test.startTest();
        List<Map<String, String>> testDataList = new List<Map<String, String>>();
        Map<String, String> testData = null;
        
        // GCM MX Fuels Consumer Mailbox
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Ticket no tiene Web ID Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 1
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre No aparece mi factura generada Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);
        
        // GCM MX Fuels Consumer Mailbox 2
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Error al generar la factura Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 3
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Ticket aparece como “Folio ya facturado” Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 4
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Error en datos (Estación, Folio, Web ID) Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 5
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Fuera del periodo de facturación Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 6
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre No me permite generar factura Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 7
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Solicitud de cancelación de factura Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 8
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Error de timbrado Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
        testDataList.add(testData);

        // GCM MX Fuels Consumer Mailbox 9
        testData = new Map<String, String>();
        testData.put('Origin', 'contactanos@bp.com');
        testData.put('Description', 'Pre Error en el método de pago de mi ticket Post');
        testData.put('SuppliedEmail', 'factura.gasolineriabp.com@bp.com');
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
        Test.stopTest();
    }
}