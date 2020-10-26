/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrieveCustomerTransactionHistory Paydiant API method
 **/
public class REIDP_PARetrieveCustomerTransactions extends REIDP_PAApiMethod {
 	static Integer numOfRows = 10;
    
    /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    } 
    /* end of required */
    
    /* static methods */
    public static List<REIDP_PAApi.CustomerTransaction> getCustomerTransactions(String customerUri, String issuingPartnerUri, 
                                                                                String partnerUri, Integer pageNum,
                                                                                SearchParams searchParams) 
    {
        REIDP_PARetrieveCustomerTransactions method = new REIDP_PARetrieveCustomerTransactions();
        
        method.args.issuingPartnerUri = issuingPartnerUri;
        method.args.customerUri = customerUri;
        method.args.partnerUri = partnerUri;
       	
        if(searchParams != null) {
            method.args.startDate = searchParams.startDate;
            method.args.endDate = searchParams.endDate;
            method.args.maxNumberOfRows = String.valueOf(numOfRows);
            if(searchParams.status != null && searchParams.status != '')
            	method.args.transactionStatuses.add(searchParams.status); 
        }
     
        if(pageNum != null) {
            if(pageNum <= 0) pageNum = 1;
			method.args.startIndex = String.valueOf((pageNum - 1) * numOfRows);
        }
        else
            method.args.startIndex = '0';
          
        Response res = method.send();
        
        return res.customerTransactions;      
    }
 	/* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveCustomerTransactions() {
        super('customers/transactions/search', 'POST');
        this.requestName = 'retrieveCustomerTransactionsHistoryRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        System.debug('raw thing looks like----- ' + jsonString);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveCustomerTransactions.Response.class);
        return this.response;
    }
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String customerUri;
        public String partnerUri;
        public String issuingPartnerUri;
        public String startDate;
		public String endDate;
        public String startIndex;
        public List<String> transactionStatuses = new List<String>();
        public String maxNumberOfRows;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
        public List<REIDP_PAApi.CustomerTransaction> customerTransactions;
    }
    
    /* other classes */
    
    public class SearchParams {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        
    }
   
    //public enum TransactionStatus {
    //    ACTIVE, BLOCKED, CANCELED,
    //        COMPLETE, CLOSED, EXPIRED, FAILED,
    //        FULL_REVERSAL, FULL_REVERSAL_PENDING,
    //        INPROGRESS, OPEN, PARTIAL_PAYMENT, 
    //        PENDING, PENDING_REFUND_RECEIPT,
    //        PROCESSING, RECEIPT_PENDING,
    //        START, TIMEOUT, UNCLAIMED,
    //        VOID, VOID_PENDING, VOID_TRANSACTION
    //}
    /* end of other classes */
}