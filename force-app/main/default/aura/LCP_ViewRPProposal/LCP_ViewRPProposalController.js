({
    doInit : function(component, event , helper) {
        helper.fetchTemplateValues(component);
    },
    handleTemplatevalues : function(component, event , helper) {
        component.set("v.rpSelected","false"); 
        helper.fetchRpValues(component);
    },
    handleRPChange : function(component, event , helper){
        var selectedrpPicklist= component.find('rpPicklist').get('v.value');
        if(selectedrpPicklist != '--None--'){
            component.set("v.rpSelected","true"); 
            helper.fetchRPProposalHelper(component);
        }else{
            component.set("v.rpSelected","false"); 
        }
    },
    RpProposeChanges : function(component, event , helper){
        helper.createRPProposeChanges(component);
    }
})