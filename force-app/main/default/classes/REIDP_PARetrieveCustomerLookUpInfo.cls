/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Class implements retrieveCustomerLookUpInfo Paydiant API method
 **/
public class REIDP_PARetrieveCustomerLookUpInfo extends REIDP_PAApiMethod {    
    /* required when extending REIDP_PAApiMethod */
    public Request args = new Request();
    public Response response;
    public override String buildArgsJSON() {
        return JSON.serializePretty(this.args, true);
    }
    /* end of required */
    
    /* static methods */
    public static CustomerLookUpInfo retrieveUser(String email) {
        REIDP_PARetrieveCustomerLookUpInfo method = new REIDP_PARetrieveCustomerLookupInfo();
        method.args.email = email;
        method.send();
        return method.getOneResult();
    }
    /* end of static methods */
    
    
    /* constructors */
    public REIDP_PARetrieveCustomerLookUpInfo() {
        super('customers/lookup/', 'POST');
        this.requestName = 'retrieveCustomerLookUpInfoRequest';
    }
    /* end of constructors */

    /* instance methods */
    public Response send() {
        String jsonString = super.sendAndReturnRaw().getBody();
        System.debug('got raw customer info: ' + jsonString);
        this.response = (Response) REIDP_PAApiResponse.deserializeResponse(jsonString, REIDP_PARetrieveCustomerLookUpInfo.Response.class);
        return this.response;
    }
	
    public Integer resultCont() {
        return response.customerLookUpInfo.size();
    }
	
	
	
    public CustomerLookupInfo getOneResult() {
        if(response.customerLookUpInfo.size() > 0) {
            return response.customerLookUpInfo[0];
        } else {
            throw new UserNotFoundException('User with email specified was not found');
        }
    }
	
    public List<CustomerLookUpInfo> getAllResults() {
        return response.customerLookUpInfo;
    } 
    /* end of instance methods */

    
	/* request */
    public class Request extends REIDP_PAApiRequest {                 
        public String email;
        public String firstName;
        public String lastName;
        public String phone;
        public String partnerUri;
        public String issuingPartnerUri;
    }
    

    
    /* response */
    public class Response extends REIDP_PAApiResponse  {
        public List<CustomerLookUpInfo> customerLookUpInfo;
    }

    
    
    /* exceptions */
    public class UserNotFoundException extends Exception{}
    /* end of exceptions */
  

    
   
    
    
    /* other classes */
     
     /* model */
     public class CustomerLookUpInfo {
        public List<REIDP_PAApi.Device> devices;
        public List<AdditionalCustomerInformation> additionalCustomerInformation;
        public String customerUri;
        public String issuingPartnerUri;
        public String partnerUri;
        public String createDate;
        public String issuingPartnerShortName;
        public boolean active;
        public boolean locked;
        public String email;
        public String emailPending;
        public String customerId;
        public String username;
        public String firstName;
        public String lastName;
        public String address1;
        public String address2;
        public String city;
        public String country;
        public String state;
        public String zip;
        public String phone;
        public String passwordChangedDate;
        public String passcodeChangedDate;
        public String securityQuestionsChangedDate;
        public String lastLoginDate;
        public boolean emailVerified;
        public String emailVerifiedDate;
    }
    
    
    public class AdditionalCustomerInformation {
        public String key;
        public String value;
    }
    
   
    
    // just informational for now
    public enum DeviceType {Android, I_PHONE, iPhone}
    /* end of other classes */
}