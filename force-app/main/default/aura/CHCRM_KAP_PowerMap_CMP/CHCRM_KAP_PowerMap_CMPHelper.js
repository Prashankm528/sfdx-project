({
    initHelper : function(component) {
        var action = [
            { label: 'Edit', name: 'edit' },
        ];
        var powerMapColumns = [
            { type: 'action', typeAttributes: { rowActions: action }},             
            { label: '客户名称', fieldName: 'accountUrl', type: 'url', typeAttributes: { label: { fieldName: 'accountName'}},initialWidth: 250},
            { label: '渠道', fieldName: 'channel', type: 'text' ,initialWidth: 150},
            { label: '职位', fieldName: 'position', type: 'text' ,initialWidth: 150},
            { label: '角色', fieldName: 'role', type: 'text'  ,initialWidth: 150},
            { label: '联系人名称', fieldName: 'contact', type: 'text' ,initialWidth: 150},
            { label: '联系方式', fieldName: 'contactWay', type: 'text',initialWidth: 150 },
            { label: '决策权限', fieldName: 'decisionFatigue', type: 'text',initialWidth: 150},
            { label: '目前关系', fieldName: 'relationship', type: 'text',initialWidth: 150},
            { label: '目标关系', fieldName: 'targetRelationship', type: 'text',initialWidth: 150},
            { label: '关系提升方式', fieldName: 'improveRelationship', type: 'text',initialWidth: 150},
            { label: '嘉实多对应职位', fieldName: 'castrolPosition', type: 'text',initialWidth: 250},
            { label: '嘉实多对应人', fieldName: 'castrolOwner', type: 'text',initialWidth: 250},
            { label: '备注', fieldName: 'remark', type: 'text',initialWidth: 500}
        ];
        component.set('v.powerMapColumns',powerMapColumns); 
        var action = component.get("c.initDataList");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.powerMapDatatable',response.getReturnValue().powerMapDataList);
                component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);
    }
})