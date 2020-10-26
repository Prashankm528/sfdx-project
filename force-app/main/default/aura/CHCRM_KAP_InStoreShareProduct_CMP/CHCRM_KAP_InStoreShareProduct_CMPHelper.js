({
    init : function(component) {
        var tableAction = [
            { label: 'Edit', name: 'edit' }
        ];
        var columns = [
            { label: '供应商', fieldName: 'supplierUrl', type: 'url', editable: false ,typeAttributes: { label: { fieldName: 'supplier'}}},
            { label: 'Oil Stage', fieldName: 'oilStage', type: 'text' , editable: false },
            { label: 'Oil Type', fieldName: 'oilType', type: 'text' , editable: false },
            { label: 'Product Category', fieldName: 'productCategory', type: 'text' , editable: false },
            { label: 'Share of wallet (VOL)%', fieldName: 'shareOfWalletVol', type: 'number' , editable: false }  
        ];
        var action = component.get("c.initInShoreShareProducts");
        action.setParams({ kapId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set('v.tableData',response.getReturnValue().inStoreShareList); 
                component.set('v.tableDataSize',response.getReturnValue().inStoreShareList.length);
                var isDraft = response.getReturnValue().isDraftFlag;
                component.set('v.isDraft',isDraft);
                if(isDraft){
                    //columns[1].editable = true;
                    //columns[2].editable = true;
                    columns[4].editable = true;
                    columns.push({ type: 'action', typeAttributes: { rowActions: tableAction }});
                }
                component.set('v.columns',columns); 
            }
        });
        $A.enqueueAction(action);
        component.set('v.isloading',false);
    },
    updateDataList : function(component,event) {
        var draftValues = event.getParam('draftValues');
        console.log('draftValues-> ' + JSON.stringify(draftValues));
        if(!this.validateTable(component,draftValues)){
            this.prepareSuccessNotify(component,'失败','您输入的 Share of wallet (VOL)% 总计不等于 100% !','error');
            event.preventDefault();
            return;
        }
        var action = component.get("c.updateRecords");
        action.setParams({ records : draftValues });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.init(component);
                this.prepareSuccessNotify(component,'成功','保存成功','success');
            }
        });
        $A.enqueueAction(action);
    },
    validateTable : function(component , draftValues){
        var tableData = component.get('v.tableData');        
        for(var i = 0 ; i < draftValues.length ; i ++){
            if($A.util.isEmpty(draftValues[i].shareOfWalletVol)){
                draftValues[i].shareOfWalletVol = 0;
            }
            for(var d = 0 ; d < tableData.length ; d ++){
                if(tableData[d].id == draftValues[i].id){
                    tableData[d].shareOfWalletVol = draftValues[i].shareOfWalletVol;
                    continue;
                }
            }
        }
        console.log(JSON.stringify(tableData));
        var checkResult = 0;
        for(var d = 0 ; d < tableData.length ; d ++){            
            checkResult = parseFloat(checkResult) + parseFloat(tableData[d].shareOfWalletVol);
            console.log(checkResult);           
        }
        if(checkResult != 100){
            return false;
        }
        return true;
        
    },
    prepareSuccessNotify : function(component,title , message , variant) {
        var config ={
            title: title,
            message: message,
            variant: variant
        }
        this.showNotification(component, config);

    },
    showNotification : function(component, config) {
        component.find('notifLib').showToast(config);
    }
    
})