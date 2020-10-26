({
	uploadHelper : function(component, event) {
		  var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
         var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
             var base64 = 'base64,';
             var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            
             var action = component.get("c.saveEformsData");
            action.setParams({
                csvFileBody : encodeURIComponent(fileContents)  
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
          
            if (state === "SUCCESS") {
                var approvers = response.getReturnValue();
                if(approvers) {
                var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent) {
                        toastEvent.setParams({
                            "title": "Approvers Update Success!",
                            "message":  approvers.length + " Approvers Updated Successfully "
                        });
                        toastEvent.fire();
                    } 
                   // component.set('v.fileName',)
                }
            }
            });
            
              $A.enqueueAction(action);
        });
 
        objFileReader.readAsDataURL(file);
	},
    
})