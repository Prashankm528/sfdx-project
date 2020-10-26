/**
* @author vanja durdevic
* @company bluewolf, an ibm company
* @date 9/2017
*
* Paydiant API
* exposes Paydiant API methods
*/
public class REIDP_PAApi {
    /* static methods */
    
    /* converts unixtimestamp string to DateTime object */
    public static DateTime toDateTime(String unixTimestamp) {
        return DateTime.newInstance(Long.valueOf(unixTimestamp));
    }
    
    public static KeyVal findKeyVal(String desiredKey, List<KeyVal> keyValList) {
        if(keyValList != null) {
            for(KeyVal entry : keyValList) {
                if(entry.key == desiredKey) return entry;
            }
        }
        return null;
    }
    
    public static REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo retrieveUser(String email) {
        return REIDP_PARetrieveCustomerLookUpInfo.retrieveUser(email);
    }
    
    public static DateTime getCustomerModifiedTime(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c)
    {
        return toDateTime(REIDP_PARetrieveCustomerByUri.getModifiedTime(c.customerUri, c.issuingPartnerUri, c.partnerUri));
    }
    
    public static Boolean setUserWalletState(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c, Boolean active) {
        return REIDP_PAUpdateCustomerActivation.setWalletState(c.customerUri, c.issuingPartnerUri, c.partnerUri, active);
    }
    
    public static Boolean deleteCard(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c, String cardUri) {
        return REIDP_PADeleteCustomerCardInfo.deleteCard(cardUri, c.customerUri, c.issuingPartnerUri, c.partnerUri);
    }
    
    public static Boolean deleteCustomer(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c) {
        return REIDP_PADeleteCustomer.deleteCustomer(c.customerUri, c.issuingPartnerUri, c.partnerUri);
    }
    
    public static List<Card> getCustomerCards(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c) {
        return REIDP_PARetrieveCustomerCardInfo.getCustomerCards(c.customerUri, c.issuingPartnerUri, c.partnerUri);
    }
    
    public static QuestionsWrap getCustomerSecurityQuestions(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c) {
        return REIDP_PARetrieveCustomerMFAQuestions.getSecurityQuestions(c.customerUri, c.issuingPartnerUri, c.partnerUri);
    }
    
    public static List<Question> getAvailableSecurityQuestions(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c) {
        return REIDP_PARetrieveMFAQuestions.getSecurityQuestions(c.customerUri, c.issuingPartnerUri, c.partnerUri);
    }
    
    public static List<CustomerTransaction> getCustomerTransactions(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c, Integer pageNum,
                                                                    REIDP_PARetrieveCustomerTransactions.SearchParams searchParams) 
    {
        return REIDP_PARetrieveCustomerTransactions.getCustomerTransactions(c.customerUri, c.issuingPartnerUri, c.partnerUri, pageNum, searchParams); 
    }
    
    public static Boolean submitNewSecurityQuestions(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c, List<REIDP_PAApi.QuestionAnswer> questions) {
        return REIDP_PAUpdateCustomerMFAQuestions.updateSecurityQuestions(c.customerUri, c.issuingPartnerUri, c.partnerUri, questions);
    }
    public static Boolean authenticateSecurityQuestions(REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo c, List<REIDP_PAApi.QuestionAnswer> questions) {
        
        return REIDP_PAAuthenticateCustomerMFA.authenticateSecurityQuestions(c.customerUri, c.issuingPartnerUri, c.partnerUri, questions);
    }
    
    /* end of static methods */   
    
    
    /* classes */
    public class Device {
        @AuraEnabled
        public String customerUri;
        @AuraEnabled
        public String issuingPartnerUri;
        @AuraEnabled 
        public String partnerUri;
        @AuraEnabled
        public String deviceType;
        @AuraEnabled
        public String deviceUri;
        @AuraEnabled
        public String deviceUniqueId;
        @AuraEnabled
        public String deviceDescription;
        @AuraEnabled
        public boolean active;
        @AuraEnabled
        public boolean locked;  
        @AuraEnabled
        public String lastLoginDate{
            set {
                this.lastLoginDate = value;
                if(value != null)
                    this.lastLoginDateDT = REIDP_PAApi.toDateTime(value);
            }   
        }
        @AuraEnabled
        public DateTime lastLoginDateDT;
        
        
        @AuraEnabled
        public String createDate{
            set {
                this.createDate = value;
                if(value != null)
                    this.createDateDT = REIDP_PAApi.toDateTime(value);
            }   
        }
        @AuraEnabled
        public DateTime createDateDT;
    }
    
    public Class Card {
        @AuraEnabled
        public String createDate{
            set {
                this.createDate = value;
                if(value != null)
                    this.createDateDT = REIDP_PAApi.toDateTime(value);
            }   
        }
        @AuraEnabled
        public DateTime createDateDT;
        
        @AuraEnabled
        public String modifiedDate{
            set {
                this.modifiedDate = value;
                if(value != null)
                    this.modifiedDateDT = REIDP_PAApi.toDateTime(value);
            }   
        }
        @AuraEnabled
        public DateTime modifiedDateDT;
        
        @AuraEnabled
        public String pan;
        @AuraEnabled
        public String nickName;
        
        
        @AuraEnabled
        public String paymentNetworkTypeUri{
            set {
                if(value != null) {
                    String cType = value.substringAfterLast('#');
                    if(cType == 'MASTER')
                        cType = 'Mastercard';
                    else if(cType == 'NectarLoyalty')
                        cType = 'Nectar Loyalty';
                    
                    this.cardType = cType;
                }
            }
        }
        
        @AuraEnabled
        public String cardType;
        
        @AuraEnabled
        public String accountUri{
            set {
                this.accountUri = value;
                this.cardUri = value;
            }
        }
        
        @AuraEnabled
        public String cardUri;
        
        
        
        public List<KeyVal> additionalData;
    }
    
    public class KeyVal {
        public String key;
        public String value;
    }
    
    public class QuestionsWrap {
        @AuraEnabled
        public List<REIDP_PAApi.Question> questions;
        @AuraEnabled
        public Integer numberOfQuestionsToAnswer;
    }
    
    public class Question {
        @AuraEnabled
        public String question;
        @AuraEnabled
        public Boolean mandatory;
        @AuraEnabled
        public String answer;
        @AuraEnabled
        public Boolean newQuestion;
    }
    
    public class QuestionAnswer {
        @AuraEnabled
        public String question{public get;public set;}
        @AuraEnabled
        public String answer{public get;public set;}
    }
    
    public class CustomerTransaction {
        @AuraEnabled
        public String paydiantTransactionRefId;
        @AuraEnabled
        public String merchantTransactionReferenceId;
        @AuraEnabled
        public String terminalId;
        @AuraEnabled
        public String receiptId;
        @AuraEnabled
        public Receipt receipt;
        @AuraEnabled
        public StoreInfo location;
        @AuraEnabled
        public List<PaymentInfo> payments;
        @AuraEnabled
        public String transactionDate{
            set {
                this.transactionDate = value;
                if(value != null)
                    this.transactionDateDT = REIDP_PAAPI.toDateTime(value);
            }
        }
        
        @AuraEnabled
        public DateTime transactionDateDT;
        @AuraEnabled
        public String transactionStatus;
    }
    
    public class StoreInfo {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;        
    }
    
    public class PaymentInfo {
        @AuraEnabled
        public String maskedCardNumber;
        @AuraEnabled
        public String paymentAccountNetworkName;
        @AuraEnabled
        public String currencyCode;
    }
    
    
    public class Receipt {
        @AuraEnabled
        public String paydiantTransactionReferenceId;
        @AuraEnabled
        public List<Item> items;
        @AuraEnabled
        public Double totalAmount;
        @AuraEnabled
        public String receiptId;
        @AuraEnabled
        public String terminalId;
        
    }
    
    public class Item {
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String itemCount;
        @AuraEnabled
        public Double unitPrice;
    }
    
    public class CardNotFoundException extends Exception{}
    /* end of classes */
}