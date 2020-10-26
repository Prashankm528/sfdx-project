({  
    init: function (cmp) {   
        var action = cmp.get("c.initData");
        action.setParams({accountName : '0715_shape'});
        action.setCallback(this, function(actionResult) {
            cmp.set("v.items", actionResult.getReturnValue().items);
            cmp.set("v.mapping", actionResult.getReturnValue().mapping);
        });
        $A.enqueueAction(action);        
    },
    handleSelect: function (cmp, event) {
        event.preventDefault();
        var action = cmp.get("c.findSKUByProductId");
        action.setParams({productId : event.getParam('name')});
        action.setCallback(this, function(actionResult) {
            cmp.set("v.skuList", actionResult.getReturnValue().skuList);
        });
        $A.enqueueAction(action);        
    },
    onGroup :function (cmp, event) {
        //cmp.set('v.selectedId',event.getSource().get("v.name"));
        //cmp.set('v.selectedName',event.getSource().get("v.label"));
        console.log(event.currentTarget.getAttribute('id'));
        console.log(event.currentTarget.getAttribute('value'));
        cmp.set('v.selectedId',event.currentTarget.getAttribute('value'));
        cmp.set('v.selectedName',event.currentTarget.getAttribute('id'));
    }
})