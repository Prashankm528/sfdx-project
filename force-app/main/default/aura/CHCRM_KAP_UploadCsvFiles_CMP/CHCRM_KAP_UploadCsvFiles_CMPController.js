({
    init : function(component, event, helper) {
        var action = component.get("c.checkRoleCanView");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.canView',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    uploadSave : function(component, event, helper) {
        component.set("v.errorMsg","");
        component.set("v.isError",false);
        component.set("v.showInfo",false);
        component.set('v.isDisabled',true);        
        var fileInput = component.find("fileId").get("v.files");
        if(!fileInput){
            component.set("v.errorMsg","上传文件不能为空");
            component.set("v.isError",true);
            component.set('v.isDisabled',false); 
            return;
        }
        var file = fileInput[0];//csv file
        if(!file){
            component.set("v.errorMsg","上传文件不能为空");
            component.set("v.isError",true);
            component.set('v.isDisabled',false); 
            return;
        }
        var templateType = component.get('v.templateType');
        if(templateType == ""){
            component.set("v.errorMsg","请选择 数据模板类型");
            component.set("v.isError",true);
            component.set('v.isDisabled',false); 
            return;
        }
        if(component.get('v.emails').replace(/\s+/g,"") != ''){
            var emails = component.get('v.emails').split(';');
            if(emails.length == 1 && emails[0] == ""){
                component.set("v.errorMsg","请填写通知邮箱");
                component.set("v.isError",true);
                component.set('v.isDisabled',false); 
                return;
            }
            var pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
            for(var index = 0 ; index < emails.length ; index ++){
                if(emails[index] == ""){continue;}
                if(!pattern.test(emails[index])){
                    component.set("v.errorMsg","通知邮箱不符合格式要求，请重新填写");
                    component.set("v.isError",true);
                    component.set('v.isDisabled',false); 
                    return;
                } 
            }
        }
        var reader = new FileReader();
        //reader.readAsBinaryString(file);
        component.set("v.showInfo",true);
        reader.readAsText(file,'gbk');        
        //component.set('v.isDisabled',false); 
        reader.onload = function(evt) {
            var csv = evt.target.result;
            var action = component.get("c.uploadFile");
            action.setParams({"file":csv,"emails":component.get('v.emails'),"templateType":templateType});
            /*action.setCallback(this, $A.getCallback(function (response) {
                
            }))*/
            $A.enqueueAction(action);
        }
    },
    handleFilesChange : function (component, event, helper) {
        var fileName = '没有选中文件';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    refreshView :function (component, event, helper) {
      window.location.reload();
    }
})