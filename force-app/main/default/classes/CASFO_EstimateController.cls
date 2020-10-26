/************************************************************************************************************
* Description : Controller for custom lightning commponent named "Estimate" for adding
*               estimates to Opportunities.
*
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-NOV-22   1.0                 Maros Zilka         Initial version
*
*************************************************************************************************************/

public with sharing class CASFO_EstimateController {

    /************************************************************************
    * getStage
    * ------------------------
    * Method to get opportunity stage and decide if Estimate can be inserted   
    ************************************************************************/
    @AuraEnabled
    public static Boolean getStage(Id opportunityId) {
        Opportunity o = [SELECT Name, StageName FROM Opportunity WHERE Id = :opportunityId];
        if (o.StageName == 'Lead' || o.StageName == 'Opportunity' || o.StageName == 'Trial') {
            return true;
        } else {
            return false;
        }
    }

    /************************************************************************
    * getOpportunity
    * ------------------------
    * Method used for retrieving Opportunities name.  
    ************************************************************************/
    @AuraEnabled
    public static Opportunity getOpportunity(Id opportunityId) {
        return [SELECT Name FROM Opportunity WHERE Id = :opportunityId];
    }

    /************************************************************************
    * getCommit
    * ------------------------
    * Method used for retrieving Opportunitie's Commit_to_Planning__c.  
    ************************************************************************/
    @AuraEnabled
    public static Boolean getCommit(Id opportunityId) {
        return [SELECT Commit_to_Planning__c FROM Opportunity WHERE Id = :opportunityId].Commit_to_Planning__c;
    }

    /************************************************************************
    * getEstimate
    * ------------------------
    * This method returns Estimate if it is set so we can set up default
    * values accordingly.
    ************************************************************************/
    @AuraEnabled
    public static Revenue__c getEstimate(Id opportunityId) {
        List<Revenue__c> revenues;

         revenues = [SELECT Opportunity__c, Type__c, 
                    Product__c, Product__r.ProductCode,
                    CurrencyIsoCode, Margin__c,
                    Revenue__c, Volume__c
                    FROM Revenue__c WHERE Opportunity__r.Id = :opportunityId
                    AND Product__r.ProductCode = :'EST' LIMIT 1];

        if (revenues.size() < 1) {
            return null;
        } else {
            return revenues[0];
        }
    }

    /************************************************************************
    * hasRevenues
    * ------------------------
    * This method return TRUE if there are Revenues (instead of Estimate)
    * set up on Opportunity.
    ************************************************************************/
    @AuraEnabled
    public static boolean hasRevenues(Id opportunityId) {
        List<Revenue__c> revenues;

        revenues = [SELECT Product__r.ProductCode FROM Revenue__c WHERE Opportunity__r.Id = :opportunityId];

        if (revenues.isEmpty()) {
            return false;
        }

        if (revenues.size() == 1 && revenues[0].Product__r.ProductCode == 'EST') {
                return false;
        }

        return true;
    }

    /************************************************************************
    * getShowSellOut
    * ------------------------
    * This method return TRUE if we should show sell-out option in Type
    * field based on users sales org and role.
    ************************************************************************/
    @AuraEnabled
    public static boolean getShowSellOut() {
        String salesOrg = [SELECT Sales_Organisation__c FROM User WHERE Id = :UserInfo.getUserId()].Sales_Organisation__c;
        String userRole =  [SELECT UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId()].UserRole.DeveloperName;

        return (
            salesOrg == 'PL01' &&
            (
                userRole == 'Castrol_CEE_Auto_SAPD_Sales_Executive' ||
                userRole == 'Castrol_CEE_Auto_SAPD_Team_Lead' ||
                userRole == 'Castrol_CEE_A_I_Distributor_Sales_Manager' ||
                userRole == 'Castrol_CEE_DBM_A_I_Distributor_Sales'
            )
        );
    }

    /************************************************************************
    * saveEstmiate
    * ------------------------
    * This method is called when user clicks on Save button.
    * It handles creating and inserting Estimate Revenue
    * as well as deleting any other revenues on Opportunity.
    ************************************************************************/
    @AuraEnabled
    public static String saveEstimate(Id opportunityId, String typeVal, Decimal revenueVal, Decimal marginVal, Decimal volumeVal) {
        List<Revenue__c> allRevenues;
        List<Revenue__c> delRevenues = new List<Revenue__c>();
        Opportunity oppo;

        List<Product2> estProduct;
        Revenue__c estRevenue = new Revenue__c();
        
        estProduct = [SELECT Id FROM Product2 WHERE ProductCode = :'EST' LIMIT 1];

        if (estProduct.isEmpty()) {
            return 'Initial estimate Product does not exist. Could not create Estimate.';
        }

        oppo = [SELECT Id, CurrencyIsoCode FROM Opportunity WHERE Id = :opportunityId];

        //Get all existing revenues and decide which needs to be deleted
        allRevenues = [SELECT Opportunity__c, Type__c, Product__c,
                      Product__r.ProductCode, Margin__c, Revenue__c,
                      Volume__c FROM Revenue__c WHERE Opportunity__r.Id = :opportunityId];

        //If there are already some revenues find estimate and save it, others add to list for deletion
        if (allRevenues.size() > 0) {
            for(Revenue__c revenue : allRevenues) {
                if (revenue.Product__r.ProductCode == 'EST') {
                    estRevenue = revenue;
                } else {
                    delRevenues.add(revenue);
                }
            }

            if (delRevenues.size() > 0) {
                delete delRevenues;
            }
        }

        //Set new values for estimate revenue
        if (estRevenue.Opportunity__c == null) {
            estRevenue.Opportunity__c = opportunityId;
        }
        estRevenue.Product__c = estProduct[0].Id;
        estRevenue.Type__c = typeVal;
        estRevenue.CurrencyIsoCode = oppo.CurrencyIsoCode;
        estRevenue.Revenue__c = revenueVal;
        estRevenue.Margin__c = marginVal;
        estRevenue.Volume__c = volumeVal;
        estRevenue.Is_Estimate__c = 1;

        upsert estRevenue;

        return 'SUCCESS';
    }
}