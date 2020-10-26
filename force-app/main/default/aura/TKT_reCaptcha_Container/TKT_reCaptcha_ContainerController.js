({
    
    doInit: function (cmp, evt, helper){
        let vfOrigin = $A.get("$Label.c.TKT_CurrentUrl");
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            } 
            if (event.data==="Unlock"){            	
              cmp.set("v.isVerified", true);
            } 
            if (event.data==="Expired"){            	
              cmp.set("v.isVerified", false);
            }             
        }, false);                
    }  
 
})