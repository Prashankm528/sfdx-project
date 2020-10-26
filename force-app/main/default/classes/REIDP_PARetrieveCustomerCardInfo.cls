/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrieveCustomerCardInfo Paydiant API method
 **/
public class REIDP_PARetrieveCustomerCardInfo extends REIDP_PAApiMethod {
 /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    }
    /* end of required */
    
    /* static methods */
    public static List<REIDP_PAApi.Card> getCustomerCards(String customerUri, String issuingPartnerUri, String partnerUri) {
       REIDP_PARetrieveCustomerCardInfo method = new REIDP_PARetrieveCustomerCardInfo();
       method.args.issuingPartnerUri = issuingPartnerUri;
       method.args.customerUri = customerUri;
       method.args.partnerUri = partnerUri;
       method.args.includeMetaData = true;
       
       
       Response res = method.send();
       for(REIDP_PAApi.Card card : res.cards) {
           REIDP_PAApi.KeyVal found = REIDP_PAApi.findKeyVal('MASKED_CARD_NUMBER', card.additionalData);
           if(found == null)
            card.pan = 'PAN not available';
           else
		   	card.pan = found.value;
           found = REIDP_PAApi.findKeyVal('NICK_NAME', card.additionalData);
           if(found == null)
            card.nickName = 'Unnamed card';
           else
          	 card.nickName = found.value;
           
           card.additionalData = null;
       }
        
        
        
        return res.cards;
       
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveCustomerCardInfo() {
        super('customers/cards/search/', 'POST');
        this.requestName = 'retrieveCustomerCardInfoRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveCustomerCardInfo.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public Boolean includeMetaData;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
        public List<REIDP_PAApi.Card> cards;
    }
    
    /* other classes */
    
    /* end of other classes */
}