({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchUserProfile");

	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	            	var user = response.getReturnValue();

	            	var currentUserId = user.Id;
	            	var userId = component.get("v.userId");

	            	console.log(currentUserId + ' ' + userId);

	            	var isShowButton = currentUserId.includes(userId) 
	            		&& (user.Profile.Name == 'System Administrator' 
	            				|| user.Profile.Name == 'Castrol_CAPLCommunityAdmin'
	            				|| user.Profile.Name == 'Castrol_CAPLCommunityModerator');

	            	if (isShowButton) {
	            		component.set("v.isShowButton", true);
	            	}
	            } 
	        });
	        $A.enqueueAction(action);
	},

    downloadUsersList : function(component, event, helper) {
        var action = component.get("c.fetchUsers");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            	var usersList = response.getReturnValue();

            	for (var i = 0; i < usersList.length; i++) {
	            	console.log('usersList -> ' + usersList[i].Username);
	            }
           
		        var csv = helper.convertUsersToCSV(component,usersList);  
		        
		        if (csv == null){return;} 
		            
			    var linkToDownload = document.createElement('a');
		        linkToDownload.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
		        linkToDownload.target = '_self'; // 
		        linkToDownload.download = 'ExportedListOfUsers.csv'; 
		        document.body.appendChild(linkToDownload); 
		    	linkToDownload.click(); 
            } else if (state === "ERROR") {console.log('error');}
        });
        $A.enqueueAction(action);
    }
})