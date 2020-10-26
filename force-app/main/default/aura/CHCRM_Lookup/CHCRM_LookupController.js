({
    doInit : function(component, event, helper) {
        var transMap = component.get("v.translationMap");
        transMap['Account'] = '客户';
        transMap['Opportunity'] = '业务机会';
        transMap['User'] = '用户';
        transMap['Contact'] = '联系人';
        transMap['HQ Monthly Assignment'] = '总部月度任务';
        transMap['客户'] = 'Account';
        transMap['用户'] = 'User';
        transMap['联系人'] = 'Contact';
        transMap['总部月度任务'] = 'HQ Monthly Assignment';
        transMap['业务机会'] = 'Opportunity';
        component.set("v.translationMap",transMap);

        var objItems = component.get("v.objectItems");
        var transObjItems = [];
        objItems.forEach(element=>{
            transObjItems.push(transMap[element]);
        });
        component.set("v.transObjectItems",transObjItems);
        component.set("v.transObjName",transMap[component.get("v.objName")]);
        console.log(transObjItems);
    },

    handleOnKeyUp: function(component, event, helper){
        
        var queryTerm = event.target.value;
        helper.searchAccount(component, queryTerm);            
        
    },
    handleSelectItem : function (component, event, helper) {
        event.stopPropagation();
        helper.initSelectedItem(component);
        var transMap = component.get("v.translationMap");
        var target = event.target;
        var transSN = target.getAttribute('title');
        var sn = transMap[transSN];
        var si = target.getAttribute('id');
        
        
        //component.set('v.selectedName', sn);
        component.set('v.selectedName', transSN);
        component.set('v.selectedId',si);
        var compEvent = component.getEvent("LookupEvent");
        compEvent.setParams({"selectedName" : sn, "selectedId":si , "objName": component.get('v.objName'), "extId":component.get('v.extId'),"fieldName":component.get('v.fieldName')});  
        compEvent.fire();
    },
    
    handleSelectObject : function (component, event, helper) {
        event.stopPropagation();
        helper.initSelectedItem(component);
        //helper.initSelectedItem(component);
        var target = event.target;
        var transMap = component.get("v.translationMap");
        var obj = target.getAttribute('title');
        console.log('target',event.currentTarget.getAttribute('title'));
        if(obj != null) {
            component.set("v.transObjName",obj);
            component.set('v.objName', transMap[obj]);
        }
        console.log('Title', obj);
    },    
    
    
    handleBlur : function (component, event, helper) {
        event.stopPropagation();
        console.log('blur');
        helper.closeDropDownList(component);
    },
    handleObjectSelectBlur : function (component, event, helper) {
        event.stopPropagation();
        console.log('blur');
        helper.closeObjectList(component);
    },    
    
    handleOpenObjectSelect : function (component, event, helper) {
        event.stopPropagation();
        helper.openObjectList(component);
        //helper.closeObjectList(component);
    }    
})