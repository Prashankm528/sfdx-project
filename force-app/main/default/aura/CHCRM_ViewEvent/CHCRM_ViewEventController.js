({
    doInit : function(component, event, helper) {
		helper.queryEvent(component);
    },
    doRefresh : function(component, event, helper) {
      helper.queryEvent(component);
    },
    navigateToDetailPage : function(component,event){
      var targetRecId = event.currentTarget.dataset.record;
      console.log(targetRecId);
      var navigateEvt = $A.get("e.force:navigateToSObject");
      navigateEvt .setParams({
        "recordId": targetRecId  ,
        "slideDevName": "detail"
      });
      navigateEvt.fire(); 
    },
})