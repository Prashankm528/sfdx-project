({  
    init: function (cmp) {
        var action = cmp.get("c.initData");
        action.setCallback(this, function(actionResult) {
            cmp.set("v.items", actionResult.getReturnValue().items);
            cmp.set("v.mapping", actionResult.getReturnValue().mapping);
        });
        $A.enqueueAction(action);        
    },
    handleSelect: function (cmp, event) {
        event.preventDefault();
        //var mapping = cmp.get('v.mapping');
        //cmp.set('v.selectedId',event.getParam('name'));
        //cmp.set('v.selectedName',mapping[event.getParam('name')]);
        var pbId = event.getParam('name');
        var action = cmp.get("c.findPBVByPBCode");
        action.setParams({pbId : pbId});
        action.setCallback(this, function(actionResult) {
            cmp.set("v.pbvList", actionResult.getReturnValue().items);
        });
        $A.enqueueAction(action);
        
    },
    onGroup : function (cmp, event) {
        cmp.set('v.selectedId',event.currentTarget.getAttribute('value'));
        cmp.set('v.selectedName',event.currentTarget.getAttribute('id'));
    }
})