({
    doInit: function (cmp, event, helper)
        {
            //calling helper method to get parent AccountId
            helper.getParentAccountHelper(cmp, event, helper);
            
            //expand all nested items.
            //var tree = cmp.find('treegrid_async');
            //tree.expandAll();   
          
           var columns = [
            {
                type: 'url',
                fieldName: 'AccountURL',
                label: 'Account Name',
                initialWidth: 250,
                typeAttributes: {
                   // label: { fieldName: 'accountName' }
                    label: { fieldName: 'Name' }
                }
            },
            /*{
                type: 'text',
                fieldName: 'Industry',
                label: 'Industry',
                initialWidth: 100
            },*/
            {
                type: 'type',
                fieldName: 'Type',
                label: 'Type',
                initialWidth: 100,
                 typeAttributes: {
                    label: { fieldName: 'Type' }
                }
            },
            {
                type: 'type',
                fieldName: 'PCRM_Inco_Terms__c',//incoterms
                label: 'Inco Terms',
                initialWidth: 70,
                 typeAttributes: {
                    //label: { fieldName: 'PCRM_Inco_Terms__c' }
                }
            },
            {
                type: 'type',
                fieldName: 'PCRM_Inco_Terms_2__c', //incoterms 2
                label: 'Inco Terms 2',
                initialWidth: 70,
                 typeAttributes: {
                   // label: { fieldName: 'PCRM_Inco_Terms_2__c' }
                }
            }   
            
        ];
           cmp.set('v.gridColumns', columns);    
               
    },

    handleRowToggle: function(cmp, event, helper)
    {
        // retrieve the unique identifier of the row being expanded
        //sonar q issue
        //var rowName = event.getParam('varKeyField');

        // the new expanded state for this row
        //var isExpanded = event.getParam('isExpanded');

        // does the component have children content for this row already?
        //var hasChildrenContent = event.getParam('hasChildrenContent');

        // the complete row data
        // sonar q issue
        //var row = event.getParam('row');

        // the row names that are currently expanded
        //var expandedRows = cmp.find('treegrid_async').getCurrentExpandedRows();
        cmp.find('treegrid_async').getCurrentExpandedRows();

        
        cmp.find('treegrid_async').getSelectedRows();

    },
   
    handleRowSelection : function (cmp,event,helper) 
    {
      helper.handleRowSelectionHelper(cmp,event,helper); 
    },
    
    
})