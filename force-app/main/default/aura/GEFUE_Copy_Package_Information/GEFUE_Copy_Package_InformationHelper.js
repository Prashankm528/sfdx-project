({
	showSuccessToast : function() {
		var sMsg = 'The Package Opportunity Information has been copied to Site Opportunities';
       console.log('helper method');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Success',
            message: sMsg,
            type : 'success'
        });
        toastEvent.fire();
    }
})