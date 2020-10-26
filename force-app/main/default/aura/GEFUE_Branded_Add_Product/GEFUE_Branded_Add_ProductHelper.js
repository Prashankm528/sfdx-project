({
    helperSearchTable : function(component) {
        //data showing in table  
        var data = component.get("v.data");  
        // all data featched from apex when component loaded  
        var allData = component.get("v.UnfilteredData"); 
        //Search terms  
        var searchKey = component.find("searchKey").get("v.value");
      // check is data is not undefined and its lenght is greater than 0  
        
        if(data!=undefined){  
            if ( data.length>0){
            // filter method create a new array tha pass the test (provided as function)  
            var filtereddata = allData.filter(word => (!searchKey) || word.hiddenJoinProduct.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
            component.set("v.data", filtereddata); 
            }
        }  
        // set new filtered array value to data showing in the table.  
         
        // check if searchKey is blank  
        if(searchKey==''){  
            // set unfiltered data to data in the table.  
            component.set("v.data",component.get("v.UnfilteredData"));  
        }  
    },
    
    removeBook: function (cmp, row) {
        var rows = cmp.get('v.selectedRows');
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        cmp.set('v.selectedRows', rows);
    },
    
    onCancel : function(component,event,helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.parentId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})