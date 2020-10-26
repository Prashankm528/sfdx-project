/************************************************************************************************************
* Description : Test class for CALCF_OptOutContactController
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2017-AUG-10   1.0                 Frantisek Kolacny   Initial version
* 2020-APR-21   2.0                 Rahma Belghouti     Test isOptedOut()
*************************************************************************************************************/
@isTest
private class CALCF_OptOutContactControllerTest {
	
	
	/***********************************************************************************
    * Data Preparation Method 
    * ---------------------------- 
    *
    ***********************************************************************************/    
    @testSetup static void setUp(){
    	
    	Account acc = new Account();
        acc.Name = 'David Gilmour';
        acc.Integration_Id__c = '12345020UK010203';
        
        insert acc;
            
        Contact con = new Contact();
        con.FirstName = 'David';
        con.LastName = 'Gilmour';
        con.AccountId = acc.Id;
        con.Email = 'david@ibm.com';
        con.Home_Location__c = 'United Kingdom';
        con.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        con.Preferred_Language__c = 'English-British';
        con.Contact_Deduplication_Id__c = 'DAVIDGILMOURDAVID@IBM.COM';
        con.Last_Surveyed_Date__c = datetime.now().addDays(-1).date();
        
        insert con;

    }
    
   	/***********************************************************************************
	* Test Method
	*--------------
	* Method will test getting email flag of Contact
    ***********************************************************************************/
    static testmethod void hasAnEmailTest(){
    	
    	// Arrange 
    	Contact con = [SELECT Id FROM Contact Where FirstName = 'David'];    	
    	
    	// Act
    	boolean result = CALCF_OptOutContactController.hasAnEmail(con.Id);
    	
    	// Assert
    	System.assertEquals(true, result);
    	
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will test getting email flag of Contact
    ***********************************************************************************/
    static testmethod void hasAnEmailNegativeTest(){
    	
    	// Arrange 
    	Contact con = [SELECT Id FROM Contact Where FirstName = 'David'];
    	con.Email = '';
    	update con;    	
    	
    	// Act
    	boolean result = CALCF_OptOutContactController.hasAnEmail(con.Id);
    	
    	// Assert
    	System.assertEquals(false, result);
    	
    }
     
	/***********************************************************************************
	* Test Method
	*--------------
	* Method will test getting email of Contact
    ***********************************************************************************/
    static testmethod void getEmailTest(){
    	
    	// Arrange 
    	Contact con = [SELECT Id FROM Contact Where FirstName = 'David'];    	
    	
    	// Act
    	String result = CALCF_OptOutContactController.getEmail(con.Id);
    	
    	// Assert
    	System.assertEquals('david@ibm.com', result);
    	
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will test if contact was opted out. 
    ***********************************************************************************/
    static testmethod void optOutTest(){
    	
    	// Arrange 
    	Contact con = [SELECT Id FROM Contact Where FirstName = 'David'];    	
    	
    	// Act
    	CALCF_OptOutContactController.optOut(con.Id);
    	
    	// Assert
    	Contact result = [SELECT Id, Survey_Opt_Out__c FROM Contact Where Id =:con.Id];   
    	System.assertEquals(true, result.Survey_Opt_Out__c);
    	
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will test negative case of checking Permission set.
	* Negative test is here because we are unable to signt permission set in apex.
	* This test providing code coverage only. 
    ***********************************************************************************/
    static testmethod void checkPermissionSetNegativeTest(){
    	
    	
    	Profile profile = [Select Id From Profile where Name = 'System Administrator' limit 1];
		//all other required field.
        
     	User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com.ibm223',
                           ProfileId = profile.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
		insert usr;
		
		System.runAs(usr){
			
		// Act
    	Boolean result = CALCF_OptOutContactController.checkPermissionSet();	 	
    	
    	// Assert;   
    	System.assertEquals(false, result);
    				
		}
    	
    }
    
    /***********************************************************************************
	* Test Method
	*--------------
	* Method will test if contact with no email was opted out. 
    ***********************************************************************************/
    static testmethod void optOutNoEmailContactTest(){
    	
    	// Arrange 
    	Contact con = [SELECT Id, Email FROM Contact Where FirstName = 'David'];   
    	con.Email = '';
    	update con;
    	
    	// Act
    	CALCF_OptOutContactController.optOut(con.Id);
    	
    	// Assert
    	Contact result = [SELECT Id, Survey_Opt_Out__c FROM Contact Where Id =:con.Id];   
    	System.assertEquals(true, result.Survey_Opt_Out__c);

    }
    
    
    @isTest static void testIsOptOut(){
        Contact con = [SELECT Id, Survey_Opt_Out__c FROM Contact Where FirstName = 'David'];
        System.assertEquals(false, CALCF_OptOutContactController.isOptedOut(con.Id));
        
        con.Survey_Opt_Out__c = true;
        update con;
        System.assertEquals(true, CALCF_OptOutContactController.isOptedOut(con.Id));
    }
}