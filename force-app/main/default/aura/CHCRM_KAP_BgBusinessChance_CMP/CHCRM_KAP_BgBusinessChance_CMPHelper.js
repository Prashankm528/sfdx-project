({
    initDatable : function(component) {
        var caltrolAllColumns = [];
        var action = component.get("c.getKAPInformationById");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var yearHeader = response.getReturnValue().yearHeader;
                var caltrolTableData = response.getReturnValue().dataList;                                
                var action = component.get("c.initStatus");
                action.setParams({ recordId : component.get("v.recordId") });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var action = [
                            { label: 'Edit', name: 'edit' }
                        ];        
                        //嘉实多业务总量 
                        caltrolAllColumns = [            
                            { label: '业务指标', fieldName: 'opTarget', type: 'text' },
                            { label: yearHeader[0], fieldName: 'lastYear3', type: 'text' },
                            { label: yearHeader[1], fieldName: 'lastYear2', type: 'text' },
                            { label: yearHeader[2], fieldName: 'lastYear', type: 'text'  },
                            { label: yearHeader[3], fieldName: 'curYear', type: 'text' },
                            { label: yearHeader[4], fieldName: 'nextYear', type: 'text' },
                            { label: yearHeader[5], fieldName: 'nextYear2', type: 'text' , editable: false}                  
                        ];
                        component.set('v.isDraft',response.getReturnValue().isDraftFlag); 
                        if(component.get('v.isDraft')){
                            caltrolAllColumns.push({ type: 'action', typeAttributes: { rowActions: action } });
                        }
                        component.set('v.caltrolAllColumns',caltrolAllColumns);
                        component.set('v.yearHeader',yearHeader); 
                        component.set('v.caltrolTableData',caltrolTableData); 
                    }
                });
                $A.enqueueAction(action);                            
            }
        });
        $A.enqueueAction(action);
        
    },
    
    saveHelper : function(component) {
        /*var isError = this.validation(component);
        console.log('isError:'+isError);
        if(isError){
            component.set('v.inputError',true);
            return;
        }*/
        var action = component.get("c.save");
        action.setParams({ editRow : component.get("v.editRow")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.initDatable(component);
                component.set('v.isEditForm',false);
                component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);
    },
    validation : function(component) {
        var editRow = component.get("v.editRow");
        var errorMessage = [];
        var errorFlag = false;
        var yearHeader = component.get('v.yearHeader');
        var errorMsg = '输入项 : ';
        if(editRow.index == '4' || editRow.index == '5'){            
            if(this.isNumber(editRow.curYear) || editRow.curYear > 100){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[3] +',';
            }
            if(this.isNumber(editRow.nextYear) || editRow.nextYear > 100){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[4] +',';
            }
            if(this.isNumber(editRow.nextYear2) || editRow.nextYear2 > 100){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[5] +',';
            }
            if(errorFlag){
                errorMsg = errorMsg + ' 输入类型不正确， 或者输入的数据大于100 ， 请重新输入！';
                errorMessage.push(errorMsg);
            }                      
        }else{            
            if(this.isNumber(editRow.curYear)){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[3] +',';
            }
            if(this.isNumber(editRow.nextYear)){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[4] +',';
            }
            if(this.isNumber(editRow.nextYear2)){
                errorFlag = true;
                errorMsg = errorMsg + yearHeader[5] +',';
            }
            console.log('errorFlag :' + errorFlag);
            if(errorFlag){
                errorMsg = errorMsg + ' 输入类型不正确， 请重新输入整数！';
                errorMessage.push(errorMsg);
            }            
        }
        if(errorFlag){
            component.set('v.errorMessage',errorMessage); 
        }
        return errorFlag;
    },
    isNumber : function(inputValue){
        if(inputValue == null || inputValue == ''){
            return true;
        }
        return false;
    }
    
    
})