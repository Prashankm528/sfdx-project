/**
 * @author  Santosh Verma
 * @company IBM Company
 * @date 09/2019
 *  Test class for ICRM_FeedCheck class.
 */
@isTest(SeeAllData=False)
public class ICRM_FeedCheckTest {
    
@isTest
Public static void clearMessagesTest() {
    /* test feed for Event and Task objects */ 
        Test.startTest();
        	boolean EventFC1 = ICRM_FeedCheck.checkEventfeed();
    		boolean TaskFC1 = ICRM_FeedCheck.checkTaskfeed();
		    system.debug('EventTest=' + EventFC1); 
    		system.debug('TaskTest=' + TaskFC1); 
        Test.stopTest();
    system.assertEquals(EventFC1,True,'Event objects FEED is disable'); 
    system.assertEquals(TaskFC1,True,'Task objects FEED is disable'); 
    } 
}