/**
 * @author vanja durdevic
 * @company bluewolf, an ibm company
 * @date 9/2017
 *
 * Main Consumer details controller */
public class REIDP_PAConsumerDetailsController {
    @AuraEnabled
    public static ConsumerDetails getConsumerDetails(String accountId) {
        try {
            List<User> uList = [SELECT Id, Email FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);          
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PARetrieveCustomerLookUpInfo.retrieveUser(user.Email);
            
            System.debug('Customer info object: ' + customerInfo);
            DateTime modifiedTime = REIDP_PAApi.getCustomerModifiedTime(customerInfo);
            
            ConsumerDetails consumerDetails = new consumerDetails(user.Id, 
                                                                  customerInfo,
                                                                  modifiedTime
                                                                 );
            
            return consumerDetails;
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred.');
        }
    }
    
    @AuraEnabled
    public static void activateUserWallet(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
            Boolean success = REIDP_PAApi.setUserWalletState(customerInfo, true);
            
            if(!success)
                throw new ApplicationException('An error occurred while trying to activate wallet!'); 
            
            REIDP_PAAdminLog.adminLog('Activate Wallet', user.Email, user.ContactId);
        }
        catch(ApplicationException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred');
        }
    } 
    
    @AuraEnabled
    public static void deactivateUserWallet(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
            Boolean success = REIDP_PAApi.setUserWalletState(customerInfo, false);
            
            if(!success)
                throw new ApplicationException('An error occurred while trying to deactivate wallet!');
            
            REIDP_PAAdminLog.adminLog('Deactivate Wallet', user.Email, user.ContactId);
        }
        catch(ApplicationException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred');
        }
    } 
    
    @AuraEnabled
    public static List<REIDP_PAApi.Card> getConsumerCards(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
           	return REIDP_PAApi.getCustomerCards(customerInfo);
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred');
        }
    }
    
    @AuraEnabled
    public static void deleteConsumerCard(String accountId, String cardUri) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo c = 
                REIDP_PAApi.retrieveUser(user.Email);
            
           	Boolean ret = REIDP_PAApi.deleteCard(c, cardUri);
            if(!ret)
                throw new REIDP_PAApi.CardNotFoundException('Card not found!');
            
            REIDP_PAAdminLog.adminLog('Delete Card', 'user email: ' + user.Email + 'cardUri: ' + cardUri, user.ContactId);
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
		catch(REIDP_PAApi.CardNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteUserWallet(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo c = 
                REIDP_PAApi.retrieveUser(user.Email);
            
           	Boolean ret = REIDP_PAApi.deleteCustomer(c);
            if(!ret)
                throw new ApplicationException('An error occurred while trying to delete wallet!');
            REIDP_PAAdminLog.adminLog('Delete Wallet', user.Email, user.ContactId);
            
            user.REIDP_Mobile_Wallet__c = false;
            update user;
            
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(ApplicationException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('Unknown exception ocurred');
        }
    }
    
    @AuraEnabled
    public static REIDP_PAApi.QuestionsWrap getUserSecurityQuestions(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
            REIDP_PAApi.QuestionsWrap qw = REIDP_PAApi.getCustomerSecurityQuestions(customerInfo);
           	List<REIDP_PAApi.Question> questions = qw.questions;
            qw.questions = questions;
            return qw;
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred while retrieving security questions');
        }
    }
    
    @AuraEnabled
    public static List<REIDP_PAApi.Question> getAvailableSecurityQuestions(String accountId) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
            return REIDP_PAApi.getAvailableSecurityQuestions(customerInfo);
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException('An unexpected error occurred while retrieving security questions');
        }
    }
    
     @AuraEnabled
    public static Boolean submitNewSecurityQuestions(String accountId, String questions) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
			System.debug('retrieved user, deserializing...');
            List<REIDP_PAApi.QuestionAnswer> ls = (List<REIDP_PAApi.QuestionAnswer>) JSON.deserialize(questions, List<REIDP_PAApi.QuestionAnswer>.class);
			Map<String,REIDP_PAApi.QuestionAnswer> l = new Map<String,REIDP_PAApi.QuestionAnswer>();
            for(Integer i = 0; i < ls.size(); i++) {
                if(ls[i].answer != null && ls[i].answer != '')
                	l.put(ls[i].question, ls[i]);
            }
            List<REIDP_PAApi.QuestionAnswer> ret = new List<REIDP_PAApi.QuestionAnswer>();
            ret = (List<REIDP_PAApi.QuestionAnswer>) l.values();
            Boolean retb = REIDP_PAApi.submitNewSecurityQuestions(customerInfo, ret);
            for (REIDP_PAApi.QuestionAnswer q : ret)
                q.answer = null;
            REIDP_PAAdminLog.adminLog('Update security question', 'User email: '+ user.Email + 'questions: ' + JSON.serialize(ret) + '  outcome: ' + retb, user.ContactId);
            return retb;
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean authenticateSecurityQuestions(String accountId, String questions) {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
			System.debug('retrieved user, deserializing...');
            List<REIDP_PAApi.QuestionAnswer> ls = (List<REIDP_PAApi.QuestionAnswer>) JSON.deserialize(questions, List<REIDP_PAApi.QuestionAnswer>.class);
            Map<String,REIDP_PAApi.QuestionAnswer> l = new Map<String,REIDP_PAApi.QuestionAnswer>();
            for(Integer i = 0; i < ls.size(); i++) {
                if(ls[i].answer != null && ls[i].answer != '')
                	l.put(ls[i].question, ls[i]);
            }
            List<REIDP_PAApi.QuestionAnswer> ret = new List<REIDP_PAApi.QuestionAnswer>();
            ret = (List<REIDP_PAApi.QuestionAnswer>) l.values();
            System.debug('submiting...');
            Boolean retb = REIDP_PAApi.authenticateSecurityQuestions(customerInfo, ret);
            REIDP_PAAdminLog.adminLog('Validate security question', 'User email: '+ user.Email + ' outcome: ' + retb, user.ContactId);
            return retb;
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<REIDP_PAApi.CustomerTransaction> getConsumerTransactions(String accountId, 
                                                                                String num, 
                                                                                String startDate,
                                                                                String endDate,
                                                                                String status) 
    {
        try {
            List<User> uList = [SELECT Email, ContactId FROM User WHERE Contact.AccountId = :accountId];
            if(uList.size() == 0)
                throw new REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException('Account has not User associated in Salesforce.');       
            User user = uList.get(0);
            
            
            REIDP_PARetrieveCustomerLookUpInfo.CustomerLookUpInfo customerInfo = 
                REIDP_PAApi.retrieveUser(user.Email);
            
             REIDP_PARetrieveCustomerTransactions.SearchParams sp = new  REIDP_PARetrieveCustomerTransactions.SearchParams();
            sp.endDate = endDate;
            sp.startDate = startDate;
            sp.status = status;
            if(num == null) num = '1';
            return REIDP_PAApi.getCustomerTransactions(customerInfo, Integer.valueOf(num), sp);
        }
        catch(REIDP_PARetrieveCustomerLookUpInfo.UserNotFoundException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    


    
   
    
    
    /* other classes */
    public class ApplicationException extends Exception{}
    public class ConsumerDetails {
        @AuraEnabled                                
        public String paydiantId;
        @AuraEnabled
        public String salesforceId;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public DateTime modifiedDate;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public Boolean locked;
        @AuraEnabled
        public List<REIDP_PAApi.Question> securityQuestions;
        
        @AuraEnabled
        public List<REIDP_PAApi.Device> devices;    
        
        
        
        
        public ConsumerDetails(String sfId, 
                               REIDP_PARetrieveCustomerLookupInfo.CustomerLookUpInfo consumerInfo, 
                               DateTime modifiedDate
                              ) 
        {
            this.paydiantId = consumerInfo.customerId;
            this.salesforceId = sfId;
            if(consumerInfo.createDate != null) 
                this.createdDate = REIDP_PAApi.toDateTime(consumerInfo.createDate);
            this.modifiedDate = modifiedDate;
            this.firstName = consumerInfo.firstName;
            this.lastName = consumerInfo.lastName;
            this.email = consumerInfo.email;
            this.phoneNumber = consumerInfo.phone;
            this.active = consumerInfo.active;
            this.locked = consumerInfo.locked;
            this.devices = consumerInfo.devices;
        }        
    }
    /* end of other classes */
}