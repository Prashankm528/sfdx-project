({
    /** remove split amount record **/  
    removeSplit : function(component, event, helper) {
        var target = event.target;   //event.target
        var eleId = target.name;
        var childRecords = component.get('v.childRecords');
        var sumAmountsMap = component.get('v.sumAmountsMap');
        console.log(JSON.stringify(sumAmountsMap)); 
        if(childRecords && eleId) {
            if(childRecords[eleId])
                if(sumAmountsMap[eleId]) {
                    console.log(JSON.stringify(sumAmountsMap[eleId])); 
                    var cmpEvent = component.getEvent("CDM_AmountChangeEvt");
                    if (cmpEvent) {
                        cmpEvent.setParams({ sumAmount :  parseInt(component.get('v.sumAmount')) - parseInt(sumAmountsMap[eleId])});
                        cmpEvent.fire();
                    }
                }
            
            childRecords.splice(eleId,1);
            component.set('v.childRecords',childRecords);
            
        }
    },
    /** doInit system event  **/
    doInit : function(component, event, helper) {
        // var fieldPicklistMap = component.get('v.fieldPicklistMap');
        var taxCodes = component.get('v.taxCodes');
        var country = component.get('v.country');
        if(country) {
            component.set("v.Optvalues", taxCodes);
        }
        var sumAmountsMap = new Map();//component.get('v.sumAmountsMap');
        var childRecords = component.get('v.childRecords');
        for(var k in childRecords){
            if(childRecords[k]) {
                sumAmountsMap[k] = childRecords[k].CDM_Sub_Net_Amount__c;
            }
        }
        console.log(JSON.stringify(sumAmountsMap));
        component.set('v.sumAmountsMap',sumAmountsMap);
        
        setTimeout(function() {
            var pCenter = component.find("ProfitCenter");
            var cCenter = component.find("CostCenter");
            //debugger;
            if(Array.isArray(pCenter)) {
                for(var p in pCenter) 
                    if(pCenter[p].get('v.value'))
                        cCenter[p].set('v.disabled',true);
            } else {
                if(pCenter && cCenter) {
                    if(pCenter.get('v.value')) {
                        cCenter.set('v.disabled',true);
                    }
                }
            }
            
            if(Array.isArray(cCenter)) {
                for(var p in cCenter) 
                    if(cCenter[p].get('v.value'))
                        pCenter[p].set('v.disabled',true);
            } else {
                if(cCenter && pCenter) {
                    if(cCenter.get('v.value'))
                        pCenter.set('v.disabled',true);
                }
            }
            
        },5000);
    },
    /* get input data from split amount line record  **/
    getData : function(component, event, helper) {
        var eventId = event.getSource();
        var fieldValue = eventId.get("v.value");
        var fieldName = eventId.get('v.id');
        var fieldLabel = eventId.get("v.label");
        var fieldIndex = eventId.get("v.name");
        var sumAmountsMap = component.get('v.sumAmountsMap');
        //sumAmountsMap = component.get('v.sumAmountsMap');
        var pCenter = component.find("ProfitCenter");
        var SubGrossAmount = component.find("SubGrossAmount");
        var SubTaxAmount = component.find("SubTaxAmount");
        var SubNetAmount = component.find("SubNetAmount");
        var cCenter = component.find("CostCenter");
        
        if(fieldValue) {
            if(fieldLabel == 'Sub Net Amount') {
                sumAmountsMap[fieldName] = fieldValue;
                component.set('v.sumAmountsMap',sumAmountsMap);
                var sumAmount= 0;
                for(var key in sumAmountsMap) { 
                    if(typeof sumAmountsMap[key] != 'Map' && typeof sumAmountsMap[key] != 'object' && sumAmountsMap[key] && sumAmountsMap[key]!= 'Map') {
                        sumAmount = sumAmount + parseFloat(sumAmountsMap[key]);
                    }
                }
                component.set('v.sumAmount', sumAmount);
                console.log('fieldValue1'+Math.ceil(sumAmount* 100) / 100);
                var cmpEvent = component.getEvent("CDM_AmountChangeEvt");
                if (cmpEvent) {
                    cmpEvent.setParams({ sumAmount :  Math.ceil(sumAmount* 100) / 100});
                    console.log('fieldValue11'+sumAmount);
                    cmpEvent.fire();
                }
                if(SubGrossAmount)
                    if(Array.isArray(SubGrossAmount)) {
                        for(var k in SubGrossAmount)
                        {
                            if(SubGrossAmount[k].get('v.name') == fieldIndex) {
                                	var grossAmount = parseFloat(fieldValue) + parseFloat(SubTaxAmount[k].get('v.value'));
                                    console.log('grossAmount :'+grossAmount);
                                    SubGrossAmount[k].set('v.value', Math.ceil(grossAmount * 100) / 100);
                                	
                            }
                        }
                    } else {
                           var grossAmount = parseFloat(fieldValue) + parseFloat(SubTaxAmount.get('v.value'));
                           console.log('grossAmount :'+grossAmount);	
                           SubGrossAmount.set('v.value', Math.ceil(grossAmount * 100) / 100);
                        } 
            }
            
            if(fieldLabel == 'Profit Center') {
                if(cCenter) 
                    if(Array.isArray(cCenter)) {
                        for(var k in cCenter)
                            if(cCenter[k].get('v.name') == fieldIndex)
                                cCenter[k].set('v.disabled',true);
                    } else 
                        cCenter.set('v.disabled',true);
                
            }
            if(fieldLabel == 'Sub Tax Amount') {
                if(SubGrossAmount)
                    if(Array.isArray(SubGrossAmount)) {
                        
                        for(var k in SubGrossAmount)
                        {
                            if(SubGrossAmount[k].get('v.name') == fieldIndex) {
                                
                              var grossAmount = parseFloat(fieldValue) + parseFloat(SubNetAmount[k].get('v.value'));
                              SubGrossAmount[k].set('v.value', Math.ceil(grossAmount * 100) / 100);
                                
                            }
                        }
                    } else {
                        
                        var grossAmount = parseFloat(fieldValue) + parseFloat(SubNetAmount.get('v.value'));
                        SubGrossAmount.set('v.value', Math.ceil(grossAmount * 100) / 100);
                        
                    }
            }
            
            if(fieldLabel == 'Cost Center') {
                if(pCenter)
                    if(Array.isArray(pCenter)) {
                        for(var k in pCenter)
                            if(pCenter[k].get('v.name') == fieldIndex)
                                pCenter[k].set('v.disabled',true);
                    } else pCenter.set('v.disabled',true);
            }
        } else {
            if(fieldLabel == 'Profit Center') 
                if(cCenter) 
                    if(Array.isArray(cCenter)) {
                        for(var k in cCenter)
                            if(cCenter[k].get('v.name') == fieldIndex)
                                cCenter[k].set('v.disabled',false);
                    } else  cCenter.set('v.disabled',false);  
            
            if(fieldLabel == 'Cost Center') 
                if(pCenter)
                    if(Array.isArray(pCenter)) {
                        for(var k in pCenter)
                            if(pCenter[k].get('v.name') == fieldIndex)
                                pCenter[k].set('v.disabled',false);
                    } else pCenter.set('v.disabled',false);
            
        }
        
    },
})