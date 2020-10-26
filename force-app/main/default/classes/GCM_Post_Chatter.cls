/****************************************************************************************************
 * Date          : 04-MAR-2020
 * Author        : Sunny Yap
 * Description   : Invocable class for Post Chatter.
 * Modifications : 04-MAR-2020 Initial
 ****************************************************************************************************/

global with sharing class GCM_Post_Chatter {
/****************************************************************************************************
 * post
 ****************************************************************************************************/
    @InvocableMethod(label = 'GCM Post Chatter')
    public static void post(List<InputData> inputDataList) {
        String mentionId = null;
        String subjectId = null;
        String message = null;
        for (InputData thisInputData : inputDataList) {
            mentionId = thisInputData.mentionId;
            subjectId = thisInputData.subjectId;
            message = thisInputData.message;
        }
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.Id = mentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        // Substitute URL
        String baseURL = URL.getOrgDomainUrl().toExternalForm();
        baseURL = baseURL.replace('https://', '').split('\\.')[0].removeEnd('--c');
        baseURL = baseURL.toLowerCase() + '.lightning.force.com'+ '/' + subjectId;
        message = message.replace('{Link}', baseURL); 
        textSegmentInput.text = message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = subjectId;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    
    global class InputData 
    {
        
        @InvocableVariable(required = true description='Subject Id' label='Subject Id')
        global String subjectId;

        @InvocableVariable(required = true description='Mention Id' label='Mention Id')        
        global String mentionId;
        
        @InvocableVariable(required = true description='Message' label='Message')        
        global String message;
        
        
/****************************************************************************************************
 * InputData Constructor
 ****************************************************************************************************/
        public InputData() {}

/****************************************************************************************************
 * InputData Constructor
 ****************************************************************************************************/       
        public InputData(String subjectId, String mentionId, String message) {
            this.subjectId = subjectId;
            this.mentionId = mentionId;
            this.message = message;
        }
    }
}