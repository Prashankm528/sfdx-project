/***************************************************************************************************
* Description : Will populate Business Unit and Sales Div/Channel fields based on CSDDivCode which 
*               should be integrated from ERP systems.
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-APR-15   1.0                 Maros Zilka         Initial version
*
***************************************************************************************************/

public with sharing class SFO_UpdateAccountBUFromCSDDivCode {
    private static final String UNKOWN_BU = 'Unkown';

    private List<Account> newList;
    private Map<String, CSD_Division_Code_Mapping__c> mapping;
    private String divChannelCode;

    public SFO_UpdateAccountBUFromCSDDivCode(List<Account> newList) {
        this.newList = newList;
        this.mapping = CSD_Division_Code_Mapping__c.getAll();
    }

    public void setAccountBUFromCSDDivCode() {
        for (Account a : newList) {
            divChannelCode = a.CSD_DistChannelDivCode__c;

            if (!String.isBlank(divChannelCode)) {
                a.Business_Unit__c = (mapping.containsKey(divChannelCode) ? mapping.get(divChannelCode).Salesforce_Value__c : UNKOWN_BU);
                
                a.Sales_Division_Code__c = divChannelCode.left(2);
                a.Sales_Distribution_Channel__c = divChannelCode.right(2);
            }
        }
    }
}