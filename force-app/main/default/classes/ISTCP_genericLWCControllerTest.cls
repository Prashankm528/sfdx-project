/**
 * @description       : Unit tests for ISTCP.
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : sebas.canseco@slalom.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-09-2020   sebas.canseco@slalom.com   Initial Version
**/
@isTest
public with sharing class ISTCP_genericLWCControllerTest {

    /**
    * @description Tests ISTCP_genericLWCController class.
    **/
    @IsTest
    static void testValidresponse(){
        Map<String,Object> params = new Map<String,Object>();
        params.put('searchValue','test searchValue');
        params.put('BPNum','test bpNumber');
        params.put('Period','test period');
        params.put('Year','test year');
        params.put('ReportType','test report type');
        params.put('DocumentType','test document type');
        params.put('Start','12/3/2019');
        params.put('End','12/3/2020');
        params.put('PageSize','10');
        params.put('PageNum','1');
        
        Map<String,Object> JSON_runtimeInvocations = new Map<String,Object>();
        JSON_runtimeInvocations.put('DataService','getTestItems');
        JSON_runtimeInvocations.put('UIDataService','getTestItems_Table');
        JSON_runtimeInvocations.put('PreProcessor','ISTCP_TMGenericPreProcessor');
        JSON_runtimeInvocations.put('PostProcessor','ISTCP_TMGenericPostProcessor');
        
        //call the controller method based on the above
        String resp = String.valueof(ISTCP_genericLWCController.getData(params, JSON_runtimeInvocations));
        system.debug(resp);
        
        system.assert(resp.length() > 0);
    }
    
    /**
    * @description Tests ISTCP_mockAPIresponse class.
    **/
    @isTest
    static void testMockresponse(){
        List<String> bpNumbers = new List<String>{'A','B'};
        List<String> endurIds = new List<String>{'12345'};
        
        //String resp1 = ISTCP_mockAPIresponse.getTestItems(bpNumbers,10,1);
        String resp2 = ISTCP_mockAPIresponse.getInvoices(bpNumbers,10,1);
        String resp3 = ISTCP_mockAPIresponse.findInvoice();
        String resp4 = ISTCP_mockAPIresponse.getDFDM(bpNumbers,10,1);
        String resp5 = ISTCP_mockAPIresponse.getDFPRM(bpNumbers,10,1);
        String resp6 = ISTCP_mockAPIresponse.getREPPositionsRisks(bpNumbers,10,1);
        String resp7 = ISTCP_mockAPIresponse.getREPCredits(bpNumbers,10,1);
        String resp8 = ISTCP_mockAPIresponse.getREPSchedules(bpNumbers,10,1);
        String resp9 = ISTCP_mockAPIresponse.getTradeConfigurations(endurIds);
        String resp10 = ISTCP_mockAPIresponse.getMarkToMarkets(bpNumbers,10,1);
        ISTCP_mockAPIresponse.dummy();
        
        //System.assert(resp1!=null);
        System.assert(resp2!=null);
        System.assert(resp3!=null);
        System.assert(resp4!=null);
        System.assert(resp5!=null);
        System.assert(resp6!=null);
        System.assert(resp7!=null);
        System.assert(resp8!=null);
        System.assert(resp9!=null);
        System.assert(resp10!=null);
    }
    
    /**
    * @description Tests ISTCP_TMTransformMessage class.
    **/
    @IsTest
    static void testTMTransformMessage(){
        ISTCP_TMTransformMessage tm = new ISTCP_TMTransformMessage('Test');
        System.assert(tm!=null);
    }
}