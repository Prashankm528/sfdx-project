/*****************************************************************************************
*   Date: 05/12/2019 
*   Author: Subin M Nair   
*   Description: The controller class that dynamically creates the filter for Power BI report
*   Test Class : GCP_DAP_PowerBIReportFilterContTest

*   Date: 20/04/2020 
*   Author: Subin M Nair   
*   Description: Modifications to support Parameterized reports
*   Test Class : GCP_DAP_PowerBIReportFilterContTest
*******************************************************************************************/
public with sharing class GCP_DAP_PowerBIReportFilterController extends BPG_PowerBIReportFilter{

public enum FilterType { RELATIONSHIP, CREDITENTITY }

    
    protected override String getReportRecordTypeId() 
    {
        return Schema.getGlobalDescribe().get('BPG_PBI_Report__c').getDescribe().getRecordTypeInfosByDeveloperName().get('GCP_DAP_PBI_Report').getRecordTypeId();
        //return GCP_DAP_RecordTypes.PBI_REPORT_RECORD_TYPE_ID;
    }

    protected override String getFilterRecordTypeId() 
    {
        return Schema.getGlobalDescribe().get('BPG_PBI_Report_Filter__c').getDescribe().getRecordTypeInfosByDeveloperName().get('GCP_DAP_PBI_Report_Filter').getRecordTypeId();
        //return GCP_DAP_RecordTypes.PBI_REPORT_FILTER_RECORD_TYPE_ID;
    }
    
    private Map<String, FilterType> filterTypeMap 
    {
        get {
                if (filterTypeMap == null) 
                {

                    filterTypeMap = new Map<String, FilterType>();
                    for (FilterType enumValue : FilterType.values())
                    {
                        filterTypeMap.put(String.valueOf(enumValue).toUpperCase(), enumValue);
                    }
                }
                return filterTypeMap;
            }
        set;
    } 
    
    private String relationshipValues {
        get {
            if (relationshipValues == null) {

                for (GCP_ETY_Relationship__c rel : [SELECT Name, GCP_ETY_Relationship_ID__c FROM GCP_ETY_Relationship__c WHERE Id = :recordId])
                {
                    system.debug('Inside for loop of relationship');
                    if (rel.GCP_ETY_Relationship_ID__c != null) 
                    {
                        relationshipValues=String.valueOf(rel.GCP_ETY_Relationship_ID__c);
                    }
                }
            }
            return relationshipValues;
        }
        set;
    }
    
    private String creditValues {
        get {
            if (creditValues == null) {

                for (GCP_ETY_Credit_Entity__c credit : [SELECT Name,GCP_ETY_CRS_ID__c  FROM GCP_ETY_Credit_Entity__c WHERE Id = :recordId])
                {
                    system.debug('Inside for loop of credit entity');
                    if (credit.GCP_ETY_CRS_ID__c != null) 
                    {
                        creditValues=String.valueOf(credit.GCP_ETY_CRS_ID__c);
                    }
                }
            }
            return creditValues;
        }
        set;
    }
    //to support multiple parameterized filters
   /* private String creditAMTValues {
        get {
            if (creditAMTValues == null) {

                for (GCP_ETY_Credit_Entity__c credit : [SELECT Name,GCP_ETY_iCos_ID__c  FROM GCP_ETY_Credit_Entity__c WHERE Id = :recordId])
                {
                    system.debug('Inside for loop of credit entity');
                    if (credit.GCP_ETY_iCos_ID__c != null) 
                    {
                        creditAMTValues=String.valueOf(credit.GCP_ETY_iCos_ID__c);
                    }
                }
            }
            return creditAMTValues;
        }
        set;
    }*/

   protected override BPG_PowerBIFilter getFilter(BPG_PBI_Report_Filter__c filterRecord)
   {
        system.debug('filterRecord value is : '+filterRecord);
        String values;
        Boolean isParam = false;
        switch on getFilterType(filterRecord.BPG_Type__c) 
        {
            when Relationship 
            {
                system.debug('I am coming from Relationship switch');
                values = relationshipValues;
                if(filterRecord.BPG_Operator__c == 'rp')
                isParam = true; //set flag to True if the report is using parameterized filters
                system.debug('Values are : '+values);
            }
            when CreditEntity 
            {
                system.debug('I am coming from Credit Entity switch');
                if(filterRecord.BPG_Column_Name__c == 'ID')
                values = creditValues;
                //to support multiple parameterized filters
                /*else if(filterRecord.BPG_Column_Name__c == 'AMT')
                values = creditAMTValues;*/
                if(filterRecord.BPG_Operator__c == 'rp')
                isParam = true; //set flag to True if the report is using parameterized filters
                system.debug('Values are : '+values);
                system.debug('isParam is : '+filterRecord.BPG_Operator__c);
            }
            when else 
            {
                values = null;
            }
        }
        
        if (values==null) 
        {
            return null;
        }
        filterRecord.BPG_Value__c = values;
        BPG_PowerBIFilter filter = new BPG_PowerBIFilter(filterRecord,isParam); //new constructor introduced in BPG_PowerBIFilter class
        return filter;
    }

    private FilterType getFilterType(String name) 
    {

        return String.isBlank(name) ? null : filterTypeMap.get(name.toUpperCase());
    }
}