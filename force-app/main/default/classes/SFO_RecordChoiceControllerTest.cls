/**
* @author Amir Hafeez
* @company Saasforce LTD
* @date 9/2019
*
* @description  Test class for SFO_RecordChoiceController.
*/
@IsTest
private class SFO_RecordChoiceControllerTest {
    //Service helper for creating data and generating ids.
    private static final BPG_TestDataService.SObjectCreator SObjectCreator = new BPG_TestDataService.SObjectCreator();

    /**
    * Mock version for SFO_RecordChoiceController.
    */
    public class MockController extends SFO_RecordChoiceController {

        /**
        * Overrides the query method in SFO_RecordChoiceController and returns 10 accounts.
        */
        public override List<SObject> query(String sObjectName, Set<String> fieldsToQuery, String filters,
                                                String sortBy, Integer recordLimit) {

            super.query(sObjectName, fieldsToQuery, filters, sortBy, recordLimit);
            List<SObject> mockRecords = new List<SObject>();

            //Return a list of 10 accounts with name and description.
            for (Integer i = 0; i < 10; i ++) {
                mockRecords.add(new Account(
                    Id = SObjectCreator.generateId(Account.getSObjectType()),
                    Name = 'SFO_RecordChoiceController_' + i,
                    Description = 'SFO_RecordChoiceController_'
                ));
            }

            return mockRecords;
        }
    }

    /**
    * Verifies controller returns 10 choice records with attached metadata.
    */
    @IsTest
    private static void itShouldReturnRecordChoices() {
        SFO_RecordChoiceController.Controller = new MockController();

        Test.startTest();
            //Call get records on account data set before.
            List<Object> records = (List<Object>)JSON.deserializeUntyped(
                (String)SFO_RecordChoiceController.getRecords(
                'Account',
                'Name,Description',
                '',
                'Id',
                '',
                10
            ));

            //Verify 10 records were returned.
            System.assertEquals(10, records.size());

            //Verify correct metadata was returned.
            List<Object> attributes = ((List<Object>)records[0]);
            System.assertEquals(4, attributes.size());

            Map<String, Object> item = (Map<String, Object>)attributes[0];
            System.assertEquals('Id', (String)item.get('field'));

            item = (Map<String, Object>)attributes[1];
            System.assertEquals('Name', (String)item.get('field'));

            item = (Map<String, Object>)attributes[2];
            System.assertEquals('Description', (String)item.get('field'));
    }
}