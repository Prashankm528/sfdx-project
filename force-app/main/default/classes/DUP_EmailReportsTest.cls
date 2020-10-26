@isTest(SeeAllData=false)
public class DUP_EmailReportsTest {
    
    static testmethod void schedulerTest() 
    {
       Test.startTest();
        Integer invocationsPreTest = Limits.getEmailInvocations();
        DUP_Emailreports abc = new DUP_Emailreports(); 
		abc.execute(null);
        Integer invocationsPost = Limits.getEmailInvocations();
        Test.stopTest();        
        system.assertEquals(invocationsPost,1);        
        system.assertEquals(invocationsPreTest,0);        
    }
}