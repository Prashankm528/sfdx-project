/**
* @author     Santosh Verma
* @date       05/08/2019
* @description    Test class for Committee meeting trigger and helper class  
* 
* History
*  
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_ComMeetTriggerHandlerTest {
    
    /**
* @description - test setup method for creating test data
*/
    @testSetup static void testdataSetup() {
        
        ICRM_Committee_Meetings__c  CMMObj1 = new ICRM_Committee_Meetings__c();     
        CMMobj1.name = 'Cmeeting-001-Test'; 
        Datetime myDate = Datetime.newInstance(2019, 2, 17);
        CMMobj1.ICRM_Meeting_Date__c= myDate;
        CMMobj1.ICRM_Type__c= 'DGB';
        CMMobj1.ICRM_Offline__c= true;
        CMMobj1.ICRM_RB__c= 'GOA';
        
        insert CMMobj1; 
        
        //Check the updated Text Date for the inserted record (before insert trigger)
        
        list<ICRM_Committee_Meetings__c>  CMMObj = new list<ICRM_Committee_Meetings__c>(); 
        CMMObj =  [Select ID,name,ICRM_Meeting_Date__c,ICRM_Text_Date__c from ICRM_Committee_Meetings__c where name = 'GOA DGB 2019/02/17 Offline' ];   
                
        //Check the updated Text Date for the updated record(before update trigger)
        
        Datetime myDate1 = Datetime.newInstance(2019, 2, 17);
        CMMObj[0].ICRM_Meeting_Date__c = myDate1;
        update CMMObj;
        
        
    }
    
    /**
* @description - test method
*/
    @istest
    public static void testTrigger(){
              
        Test.startTest();
        list<ICRM_Committee_Meetings__c>  CMMObjNew = new list<ICRM_Committee_Meetings__c>();    
        CMMObjNew =  [Select ID,name,ICRM_Meeting_Date__c,ICRM_Text_Date__c from ICRM_Committee_Meetings__c where name = 'GOA DGB 2019/02/17 Offline' ]; 
        Test.stopTest();
        System.assertEquals(string.valueof(CMMobjNew.get(0).ICRM_Meeting_Date__c), CMMobjNew.get(0).ICRM_Text_Date__c,'The test class is not pass');
        
        
    }
}