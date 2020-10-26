({
    handleClick: function(component) {
             
        var action = component.get("c.download");

        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            var title;
            var message;
            
            if (response.getState() === "SUCCESS") 
            {              
                if (result == 0)
                {
                    title = "Error";
                    message = "There were no leads to export";
                }
                else if (result == 1)
                {
                    title = "1 Lead Exported"
                    message = "Navigate to the 'Files' tab to download the file.";
                }
                else if (result > 1)
                {
                    title = result +" Leads Exported"
                    message = "Navigate to the 'Files' tab to download the file.";                    
                }      
            }
            else
            {
                title = "Error";
                message = "Something went wrong.  Please contact a system administrator";
            }
            
            $A.get('e.force:refreshView').fire();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": title,
                "message": message
            }); 
            resultsToast.fire();
    
        });
        
        $A.enqueueAction(action);
        
        
    }
})