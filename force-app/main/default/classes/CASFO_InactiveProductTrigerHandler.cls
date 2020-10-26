/************************************************************************************************************
* Description : Apex class to handle sending Chatter feeds. To be used by the Apex
*               triggers CASFO_OpportunityInactiveProductTrigger.trigger and CASFO_ProductInactiveProductTrigger.trigger   
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2016-DEC-07   1.0                 Maros Zilka         Initial version 
*
*************************************************************************************************************/

public class CASFO_InactiveProductTrigerHandler {
    public static void sendChatter(Map<Id, Product2> oldProductsMap, Map<Id, Product2> newProductsMap) {
        //List of products which changed stage from active to inactive.
        List<Product2> products = new List<Product2>();

        for (Product2 p : newProductsMap.values()) {
            if (oldProductsMap.get(p.Id).IsActive && !p.IsActive) {
                products.add(p);
            }
        }

        //Get all revenues where product is inactive and opportunity is open
        List<Revenue__c> revenues = [
            SELECT Opportunity__r.Name, Opportunity__r.Id, Opportunity__r.StageName,
            Opportunity__r.OwnerId, Product__r.Name
            FROM Revenue__c
            WHERE Product__r.Id IN :products
            AND Opportunity__r.IsClosed = FALSE
        ];

        if (revenues.isEmpty()) {
            return;
        }

        chatterFeed(revenues);
    }

    public static void sendChatter(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> newOpportunityMap) {
        //List of opportunities which changed stage from closed to open.
        List<Opportunity> opportunities = new List<Opportunity>();

        for (Opportunity o : newOpportunityMap.values()) {
            if (oldOpportunityMap.get(o.Id).IsClosed && !o.IsClosed) {
                opportunities.add(o);
            }
        }

        //Get all revenues where product is inactive and opportunity is open
        List<Revenue__c> revenues = [
            SELECT Opportunity__r.Name, Opportunity__r.Id, Opportunity__r.StageName,
            Opportunity__r.OwnerId, Product__r.Name
            FROM Revenue__c
            WHERE Opportunity__r.Id IN :opportunities
            AND Product__r.IsActive = FALSE
        ];

        if (revenues.isEmpty()) {
            return;
        }

        chatterFeed(revenues);
    }

    public static void chatterFeed(List<Revenue__c> revenues) {

        //Prepare for chatter feed
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (Revenue__c revenue : revenues) {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            //Owner mention
            mentionSegmentInput.id = revenue.Opportunity__r.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            //Text segment
            textSegmentInput.text = ' ' + Label.Opportunity_Inactive_Product_War + '\n' + '- ' + revenue.Product__r.Name;
            messageBodyInput.messageSegments.add(textSegmentInput);

            //Set body
            feedItemInput.body = messageBodyInput;

            //FeedElementType
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

            //Subjec
            feedItemInput.subjectId = revenue.Opportunity__r.Id;
            
            

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
        }

        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }
}