/************************************************************************************************************
* Description : Controller for custom lightning commponent named "Inactive_Product_Warning" for showing
*               warning if there is inactive product on Opportunity.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-01   1.0                 Maros Zilka         Initial version
* 2016-DEC-07   1.1                 Maros Zilka         Added support for returning multiple inactive products
* 2016-DEC-08   1.2                 Maros Zilka         Added support for SF1 mobile card (visualforce page)
*
*************************************************************************************************************/

public with sharing class CASFO_InactiveProductWarningController {

    private final Opportunity oppty;

    public CASFO_InactiveProductWarningController(ApexPages.StandardController stdController) {
        this.oppty = (Opportunity)stdController.getRecord();
    }

    /************************************************************************
    * getShow
    * ------------------------
    * Method used by visualforce page to deternine whether there is need to
    * show warning on opportunity.  
    ************************************************************************/

    public Boolean getShow() {
        List<Revenue__c> revenues = [
            SELECT Product__r.Name, Product__r.IsActive
            FROM Revenue__c
            WHERE Opportunity__r.Id = :oppty.Id
            AND Product__r.IsActive = FALSE
            AND Opportunity__r.IsClosed = FALSE
        ];
        
        if (revenues.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
    
    /************************************************************************
    * getInactiveProducts
    * ------------------------
    * Method to find out whether there are some inactive products on
    * opportunity and opportunitity is in open stage. Used by visualforce
    ************************************************************************/
    
    public Set<String> getInactiveProducts() {
        Set<String> inactiveProductsSet = new Set<String>();

        List<Revenue__c> revenues = [
            SELECT Product__r.Name, Product__r.IsActive
            FROM Revenue__c
            WHERE Opportunity__r.Id = :oppty.Id
            AND Product__r.IsActive = FALSE
            AND Opportunity__r.IsClosed = FALSE
        ];

        for (Revenue__c revenue : revenues) {
            inactiveProductsSet.add(revenue.Product__r.Name);
        }

        return inactiveProductsSet;
    }

    /************************************************************************
    * showWarning
    * ------------------------
    * Method to find out whether there are some inactive products on
    * opportunity and opportunitity is in open stage.
    ************************************************************************/

    @AuraEnabled
    public static List<String> showWarning(Id opportunityId) {
        List<String> inactiveProductsList = new List<String>();
        Set<String> inactiveProductsSet = new Set<String>();

        List<Revenue__c> revenues = [
            SELECT Product__r.Name, Product__r.IsActive
            FROM Revenue__c
            WHERE Opportunity__r.Id = :opportunityId
            AND Product__r.IsActive = FALSE
            AND Opportunity__r.IsClosed = FALSE
        ];

        for (Revenue__c revenue : revenues) {
            inactiveProductsSet.add(revenue.Product__r.Name);
        }

        //AuraEnabled does not support Sets...
        inactiveProductsList.addAll(inactiveProductsSet);

        return inactiveProductsList;
    }
}