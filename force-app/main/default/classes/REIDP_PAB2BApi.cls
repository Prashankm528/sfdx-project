/**
* @author Nazim Aliyev
* @company bluewolf, an ibm company
* @date 2/2018
*
* Paydiant API
* exposes Paydiant B2B API methods
*/

public class REIDP_PAB2BApi {
    
	private static String merchantCode {
        private get {
            if(REIDP_Constants.isSandbox)
                return 'bpna';
            else
                return 'bpna';
        }
    }
    
    private static String parentCode {
        private get {
            if(REIDP_Constants.isSandbox)
                return 'BPNA.PAP.01';
            else
                return 'BPNA.PAP.01';
        }
    }
    
    public static AcceptanceLocation getStoreAcceptanceLocationConfig(String storeCode) {
        REIDP_PARetrieveAcceptanceLocationConfig.Response resp = REIDP_PARetrieveAcceptanceLocationConfig.getAcceptanceLocationConfig(storeCode,merchantCode,parentCode);
        if(resp.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS) {
            return resp.acceptanceLocationConfiguration.acceptanceLocation;
        }
        throw new AuraHandledException((resp.status.errors != null && resp.status.errors.size() > 0) ? resp.status.errors[0].errorMessage
                                      																 : 'Something went wrong, please try again.');
    }
    
    @AuraEnabled
    public static Boolean updateMerchantLocation(AcceptanceLocation acceptanceLocation) {
        REIDP_PAUpdateMerchantLocationRequest.Response resp = REIDP_PAUpdateMerchantLocationRequest.updateMerchantLocation(merchantCode, acceptanceLocation);
        if(resp.status.statusCode == REIDP_PAApiResponse.StatusCode.SUCCESS) {
            return true;
        }
        throw new AuraHandledException((resp.status.errors != null && resp.status.errors.size() > 0) ? resp.status.errors[0].errorMessage
                                       																 : 'Something went wrong, please try again.');
    }
    
    public class AcceptanceLocation {
        @AuraEnabled
        public String storeCode;
        @AuraEnabled
        public String secondaryIdentifier;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String address1;
        @AuraEnabled
        public String address2;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String zipCode;
        @AuraEnabled
        public String countryCode;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String timezone;
        @AuraEnabled
        public Integer utcOffset;
        @AuraEnabled
        public Boolean usesDaylightSaving;
        @AuraEnabled
        public String utcOffsetUnit;
        @AuraEnabled
        public String latitude;
        @AuraEnabled
        public String longitude;
        @AuraEnabled
        public String currency_SF_RESERVED_FIX;
        @AuraEnabled
        public String language;
        @AuraEnabled
        public List<Object> hoursOfOperations;
        @AuraEnabled
        public String paymentSpecification;
        @AuraEnabled
        public List<REIDP_PAApi.KeyVal> additionalInformation ;
    }
}