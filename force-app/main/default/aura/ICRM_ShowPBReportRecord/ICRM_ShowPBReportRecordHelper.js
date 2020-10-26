({
    // get the columns data for the Table 
    getPBListHandler : function(component,event) {
        var action = component.get('c.getPowerBIRecords');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var pageSize = component.get("v.pageSize");
                component.set('v.PBData', response.getReturnValue());
                // get size of all the records and then hold into an attribute "totalRecords"
                component.set("v.totalRecords", component.get("v.PBData").length);
                // set startpage as 0
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PBIReportList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.PBData").length> i)
                        PBIReportList.push(response.getReturnValue()[i]);    
                }
                component.set('v.PBIReportList', PBIReportList);
            }else {
                $A.get("e.force:showToast")
                .setParams({
                    'title' : 'Message',
                    'message' : 'Something went wrong contact your System Admin',
                    'type' : 'Error'
                })
                .fire();
            }
        });
        $A.enqueueAction(action);
    },
    // handle next click
    next : function(component, event){
        var sObjectList = component.get("v.PBData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PBIReportList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                PBIReportList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PBIReportList', PBIReportList);
    },
    // handle previous click 
    previous : function(component, event){  
        var sObjectList = component.get("v.PBData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PBIReportList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                PBIReportList.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PBIReportList', PBIReportList);
    }
})