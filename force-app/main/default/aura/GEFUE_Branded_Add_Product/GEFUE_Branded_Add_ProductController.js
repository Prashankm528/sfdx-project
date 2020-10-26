({
    doInit: function (cmp, event, helper) {
        
        
        var parentId= cmp.get("v.pageReference").state.c__oppId;
        var terminalId= cmp.get("v.pageReference").state.c__terminalId;
        if(terminalId==""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Enter Terminal details before selecting products.',
                messageTemplate: 'Mode is pester ,duration is 4sec and Message is overrriden',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": parentId,
                "slideDevName": "Detail"
            });
            navEvt.fire();
            component.set("!v.terminalValidation",false);   
            
        }
        
        cmp.set("v.parentId",parentId);
        cmp.set('v.columns', [
            { label: 'Product Name', fieldName: 'prodLink', type: 'url', typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'}},
            { label: 'Product Code', fieldName: 'productCode', type: 'text', typeAttributes:{disabled: true} },
            { label: 'Branded/Unbranded', fieldName: 'brandedUnbranded', type: 'text' },
            { label: 'Product Description', fieldName: 'productDescription', type: 'text' }
            
        ]);
        var action = cmp.get("c.fetchData");
        action.setParams({
            recordId : parentId,
            terminalId: terminalId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                record.forEach(function(record){
                    record.prodLink = '/'+record.productId;
                    record.hiddenJoinProduct = record.productName+' '+record.productDescription+' '+record.productCode;
                });
                cmp.set("v.data", record);
                cmp.set("v.UnfilteredData", record);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleRowAction : function(cmp, event, helper){
        var selRows = event.getParam('selectedRows');
        if(selRows.length>0){
            cmp.set("v.isRowSelected","false");    
        }else
        {
            cmp.set("v.isRowSelected","true"); 
        }
        cmp.set("v.selectedRows",selRows);
        
    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    onNext : function(cmp, event, helper){
        cmp.set("v.onNext","false");
        
        cmp.set('v.oliColumns', [
            { label: 'Product', fieldName: 'prodLink', type: 'url', typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'}},
            { label: 'Quantity', fieldName: 'Quantity', type:'decimal', editable: true ,typeAttributes: { required: true }},
            {label: 'Line Description', fieldName:'productDescription',type:'text',editable: true},
            { type: 'button-icon', initialWidth:20 ,typeAttributes: {name: 'delete', iconName: 'action:delete'}}
            
        ]);
    },
    handleSelectedRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name == 'delete'){
            helper.removeBook(cmp, row);
        }
    },
    
    
    
    onCancel : function(component,event,helper){
        helper.onCancel(component);
        
    },
    
    searchTable : function(cmp,event,helper) {
        helper.helperSearchTable(cmp);
        
    },
    
    handleSaveEdition : function(cmp, event, helper) {
        
        var draftValues = event.getParam('draftValues');
        var selectedRow = cmp.get("v.selectedRows");
        var parentId= cmp.get("v.pageReference").state.c__oppId;
        
        var draftedRowCount = 0;
        for(var i= 0; i<selectedRow.length;i++) { 
            if(draftValues[i] === undefined ){
                
                console.log("No quantity ");
            }
            else{
                if(draftValues[i].Quantity >0){
                    draftedRowCount++;
                }
                
            }
            
        }
        if(draftedRowCount == selectedRow.length){
            cmp.set("v.hideOnSave","true");
            cmp.set("v.hide","false");
            var action = cmp.get("c.insertOppLineItem");
            action.setParams({
                productList : JSON.stringify(selectedRow),
                draftedValues : JSON.stringify(draftValues),
                oppId : parentId
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message:'Opportunity Product is successfully created',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                    helper.onCancel(cmp); 
                }
                
                else{ 
                    helper.onCancel(cmp);
                }
            });
            
            $A.enqueueAction(action);
        }
        else{
            
            cmp.set("v.errors", {
                rows: {
                    
                    title: 'Field require',
                    messages: [
                        'Enter a Quantity'
                    ],
                    fieldNames: ['Quantity']
                    
                },
                table: {
                    title: 'Quantity required',
                    messages: [
                        'Enter Quantity in number for the selected products'
                    ]
                }
            });
        }
    }
})