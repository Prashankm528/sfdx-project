({
	doInit : function(component, event, helper) {
		helper.fetchAdviceOfTheWeek(component);
		helper.fetchAdviceBackgroud(component);
	},

	goToDetailPage : function(component, event, helper) {
		var videoId = event.target.id;

		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": videoId
        });
        navEvt.fire();
	}
})