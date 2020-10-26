/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Abstract Paydiant API Response class
 * 
 * should be extended if implementing a Paydiant API response object
 * 
 */

public abstract class REIDP_PAApiResponse {
    /* static methods */
    public static Object deserializeResponse(String jsonString, System.Type returnType) {
        JSONParser parser = JSON.createParser(jsonString);
        parser.nextToken();
        parser.nextToken();
        parser.nextToken();
		return parser.readValueAs(returnType);  
    }
    /* end of static methods */
    
    
    /* instance fields */
    public List<KeyVal> configurationDetails;
    public Status status;
    public REIDP_PAApiRequest.msgHeader messageHeader;
    /* end of instance fields */
    
    
    /* other classes */        
    public class KeyVal {
        public String key;
        public String value;
    }
    
    public class Status {
        public StatusCode statusCode;
        public String statusDescription;
        public PaymentStatus paymentStatus;
        public List<Error> errors;
    }
    
    public enum StatusCode {
        SUCCESS,
            PARTIAL_SUCCESS,
            PENDING_COMPLETION,
            FAILED,
            INVALID_DATA,
            FATAL_ERROR,
            TIMEOUT,
            INVALID_OPERATION,
            REQUIRED_DATA_MISSING,
            NOT_FOUND,
            ALREADY_EXISTS,
            INVALID_ARGUMENTS
            }
    
    public enum ErrorCode {ERR101, ERR102, ERR103, ERR104, ERR105, ERR106, ERR107}
    
    public class PaymentStatus {
        public String code;
        public String description;
    }
    
    public class Error {
        public ErrorCode errorCode;
        public String errorMessage;
    }
    /* end of other classes */
}