/**
* @author Amir Hafeez
* @company Saasforce LTD
* @date 9/2019
*
* @description Returns a list of records to use in the SFO_RecordChoice aura component.
*/
public virtual with sharing class SFO_RecordChoiceController {
    @TestVisible
    private static BPG_FieldService FieldService = BPG_FieldService.getInstance();
    @TestVisible
    private static SFO_RecordChoiceController Controller = new SFO_RecordChoiceController();

    /**
    * Constructs a query from provided params and returns a list of records with value and metadata
    * attached like label and type.
    * This is used to determine how to render a field based on its type value.
    *
    * @param sObjectName the api name of the object i.e Account, OpportunityLineItem.
    * @param fields at set of field api names comma separated to render information onto the choice tile.
    * @param filters SOQL filter clause to return specific records.
    * @param sortBy SOQL order by clause.
    * @param recordLimit The amount of records to return.
    *
    * @return JSON List<Object> [{field: 'Name', type: 'TEXT', label: 'Name', value: 'Test Account', visible: true}]
    */
    @AuraEnabled(cacheable=true)
    public static Object getRecords(String sObjectName, String fields, String filters,
                                        String valueField, String sortBy, Integer recordLimit) {

        List<Object> records = new List<Object>();
        DescribeFieldResult fieldDescribe = null;

        //Parse fields and remove any duplicates.
        Set<String> fieldsToQuery = new Set<String>(fields.split(','));
        fieldsToQuery.add(valueField);

        //Get records from query and build field metadata.
        for (SObject record :Controller.query(sObjectName, fieldsToQuery, filters, sortBy, recordLimit)) {
            List<Object> attributes = new List<Object>();
            fieldDescribe = FieldService.getField(sObjectName, 'Id').getDescribe();

            //Always add the id.
            attributes.add(new Map<String, Object>{
                'field' => 'Id',
                'value' => record.get('Id'),
                'type' => fieldDescribe.getType(),
                'label' => fieldDescribe.getLabel(),
                'visible' => true
            });

            //Add all fields to the record and attach metadata.
            for (String field :fieldsToQuery) {
                fieldDescribe = FieldService.getField(sObjectName, field).getDescribe();

                attributes.add(new Map<String, Object>{
                    'field' => field,
                    'value' => FieldService.getFieldValue(record, field),
                    'type' => fieldDescribe.getType(),
                    'label' => fieldDescribe.getLabel(),
                    'visible' => field != valueField
                });
            }

            records.add(attributes);
        }

        //Serialise response to JSON, as type field does not get returned, when used in aura.
        return JSON.serialize(records);
    }

    /**
    * Returns a list records from a constructed query from the provided params.
    */
    public virtual List<SObject> query(String sObjectName, Set<String> fieldsToQuery, String filters,
                                            String sortBy, Integer recordLimit) {

        String query = 'SELECT ' + String.join((Iterable<String>)fieldsToQuery, ', ') + ' FROM ' + sObjectName
                            + (String.isNotBlank(filters) ? ' WHERE ' + filters : '')
                            + (String.isNotBlank(sortBy) ? ' ' + sortBy : '')
                            + (recordLimit != null ? ' LIMIT ' + recordLimit : ' LIMIT 50');

        System.debug(query);
        return Database.query(query);
    }
}