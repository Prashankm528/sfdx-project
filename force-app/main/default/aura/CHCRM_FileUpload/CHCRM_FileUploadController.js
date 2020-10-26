({  
    doInit:function(component,event,helper){  
       helper.getuploadedFiles(component);
    },      
    
    previewFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },  
    
    UploadFinished : function(component, event, helper) {
        helper.getuploadedFiles(component);         
        component.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message": "文件上传成功！",
            closeCallback: function() {}
        });
    }, 
    
    delFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    }
 })