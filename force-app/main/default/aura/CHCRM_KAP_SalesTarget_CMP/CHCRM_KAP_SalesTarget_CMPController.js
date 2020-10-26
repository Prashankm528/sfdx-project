({
    init: function(component, event, helper) {
        helper.initDatatable(component);
    },
    //table1 function
    addFWSNewRow : function(component, event, helper) {
        var subChannleSubAccountList = component.get('v.subChannleSubAccountList');
        if(subChannleSubAccountList != null){
            for(var index = 0 ; index < subChannleSubAccountList.length ; index ++){
                subChannleSubAccountList[index].selected = null;
            }
            component.set('v.subChannleSubAccountList',subChannleSubAccountList);            
        }        
        component.set('v.selectSubCode','');
        component.set("v.rowObjectId", "");
        component.set("v.selectedId", '');
        component.set("v.selectedName", '');
        component.set("v.billToName", '');
        component.set("v.isEditFWSForm", true);
        component.set('v.currentPage',1);
    },
    onSubmit1 : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isloading',true);
        var fields = event.getParam('fields');
        fields.CHCRM_Key_Account_Plan__c = component.get('v.recordId'); // modify a field
        fields.CHCRM_Category__c = 'PBV';        
        //fields.CHCRM_Product_Brand_Variance__c = component.get('v.selectedId');
        fields.CHCRM_PBV__c = component.get('v.selectedId');
        fields.CHCRM_Sub_Channel_Sub_Account__c = component.get('v.selectSubCode');
        fields.CHCRM_Sub_Channel_Account__c = component.get('v.subChannelAccountId');
        component.find('form1').submit(fields);                
    },
    handleFWSRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.rowObjectId", row.id);
        component.set("v.selectedId", row.productId);
        component.set("v.selectedName", row.productName);
        component.set("v.billToName", row.billToName);
        component.set('v.currentPage',2);
        var subChannleSubAccountList = component.get('v.subChannleSubAccountList');
        if(subChannleSubAccountList != null){
            for(var index = 0 ; index < subChannleSubAccountList.length ; index ++){
                if(subChannleSubAccountList[index].Name == row.subCode){
                    subChannleSubAccountList[index].selected = true;
                    component.set('v.selectSubCode',subChannleSubAccountList[index].Id);
                    break;
                }
            }
            component.set('v.subChannleSubAccountList',subChannleSubAccountList);
        }
        if(action.name == 'edit'){            
            component.set("v.isEditFWSForm", true);
        }else if(action.name == 'delete'){            
            component.set("v.isEditFWSForm", true);
            component.set("v.isDeleteFWSForm", true);
        }
    },
    closeFWSEdit : function(component, event, helper) {
        helper.initDatatable(component);
        component.set("v.isEditFWSForm", false);
        component.set("v.isDeleteFWSForm", false);
        component.set('v.currentPage',1);        
    },
    delete1 : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.deleteTable1(component);
    },
    //table2 function
    addotherNewRow : function(component, event, helper) {
        var subChannleSubAccountList = component.get('v.subChannleSubAccountList');
        if(subChannleSubAccountList != null){
            for(var index = 0 ; index < subChannleSubAccountList.length ; index ++){
                subChannleSubAccountList[index].selected = null;
            }
            component.set('v.subChannleSubAccountList',subChannleSubAccountList);
        }
        component.set('v.selectSubCode','');
        component.set("v.rowObjectId", "");
        component.set("v.selectedId", '');
        component.set("v.selectedName", '');
        component.set("v.billToName", '');
        component.set("v.isEditotherForm", true);
        component.set('v.currentPage',1);
    },
    onSubmit2 : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isloading',true);
        var fields = event.getParam('fields');
        fields.CHCRM_Key_Account_Plan__c = component.get('v.recordId'); // modify a field
        fields.CHCRM_Category__c = 'SKU';
        //fields.CHCRM_Product_Brand_Variance__c = component.get('v.selectedId');
        fields.CHCRM_SKU_Detail__c = component.get('v.selectedId');
        fields.CHCRM_Sub_Channel_Sub_Account__c = component.get('v.selectSubCode');
        fields.CHCRM_Sub_Channel_Account__c = component.get('v.subChannelAccountId');
        component.find('form2').submit(fields);                
    },
    handleotherRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.rowObjectId", row.id);
        component.set("v.selectedId", row.skuId);
        component.set("v.selectedName", row.skuCode);
        component.set("v.billToName", row.billToName);
        component.set('v.currentPage',2);
        var subChannleSubAccountList = component.get('v.subChannleSubAccountList');
        if(subChannleSubAccountList != null){
            for(var index = 0 ; index < subChannleSubAccountList.length ; index ++){
                if(subChannleSubAccountList[index].Name == row.subCode){
                    subChannleSubAccountList[index].selected = true;
                    component.set('v.selectSubCode',subChannleSubAccountList[index].Id);
                    break;
                }
            }
            component.set('v.subChannleSubAccountList',subChannleSubAccountList);
        }
        if(action.name == 'edit'){            
            component.set("v.isEditotherForm", true);
        }else if(action.name == 'delete'){            
            component.set("v.isEditotherForm", true);
            component.set("v.isDeleteotherForm", true);
        }
    },
    closeOtherEdit : function(component, event, helper) {
        helper.initDatatable(component);
        component.set("v.isEditotherForm", false);
        component.set("v.isDeleteotherForm", false);
        component.set('v.currentPage',1);
        component.set('v.selectSubCode','');
    },
    delete2 : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.deleteTable2(component);
    },
    nextPage : function(component, event, helper) {
        component.set('v.currentPage',2);
    },
    backPage : function(component, event, helper) {
        component.set('v.currentPage',1);
    },
    selectSubCodeChange : function(component, event, helper) {
        var subChannleSubAccountList = component.get('v.subChannleSubAccountList');
        if(subChannleSubAccountList != null){
            var selectSubCode = component.get('v.selectSubCode');
            for(var i = 0 ; i < subChannleSubAccountList.length ; i++){
                if(subChannleSubAccountList[i].Id == selectSubCode){
                    component.set('v.billToName', subChannleSubAccountList[i].billToName);
                }
            }
        }
    }
})