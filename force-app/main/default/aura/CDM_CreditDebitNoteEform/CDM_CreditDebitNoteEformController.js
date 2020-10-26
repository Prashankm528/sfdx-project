({
    /* doInit system event get eform field tempalte meta or meta data with record data*/
    doInit: function(component, event, helper) {
        console.log("doinit");
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            component.set('v.userRole',response.getReturnValue());
        });
        var action1 = component.get("c.fetchadminPermSet");
        action1.setCallback(this, function(response) {
            component.set('v.adminPermissionSet',response.getReturnValue());
            console.log('adminPermissionSet :'+response.getReturnValue());
        });        
        
        var recordId = component.get("v.recordId");
        var recTypeId = component.get("v.recordTypeId");
        var country = component.get('v.country');
        console.log('country+++'+country);
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        if(!recordId && !recTypeId && !country) {
            var recModal =  component.find('recMadal');
            $A.util.removeClass(recModal, 'slds-hide'); 
            helper.getRecordTypes(component, event, helper);
        } else {
            helper.getTemplateData(component, event, helper,false);
            
        }
        if(!component.get('v.userRole')) {
            $A.enqueueAction(action);
        }
        if(component.get('v.adminPermissionSet') === false){
             $A.enqueueAction(action1);
        }
        // set make as read only and show/hide
        setTimeout(function() {
            var material = component.get('v.selectedMaterial'); 
            var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
            var a = component.find("material");
            console.log('++++a++++'+JSON.stringify(a));
            if(country != 'Switzerland')
                if(a && a.lenght>0) {
                    for(var k in a) {
                        if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                            var fieldValue = fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue;
                        }
                    }
                    if(fieldValue) {
                        for(var k in a) {
                            if(a[k].get('v.id') == 'CDM_Cost_Center__c')
                                a[k].set('v.disabled',true); 
                        }
                    }
                    for(var k in a) {
                        if(a[k].get('v.id') == 'CDM_Cost_Center__c') {
                            var fieldValue = fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue;
                        }
                    }
                    if(fieldValue) {
                        for(var k in a) {
                            if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                                a[k].set('v.disabled',true); 
                            }
                        }
                    }
                }
            var country = component.get('v.country');
            console.log('country++__++'+country);
            if(country == 'Australia' || country == 'New Zealand')
                helper.showHidePageLoad(component, event, helper,material);
        }, 5000);
        
    },
    
    clickEditLoad: function(component, event, helper) { 
        
        var material = component.get('v.selectedMaterial'); 
        var country = component.get('v.country');
        var viewRecord = component.get('v.viewRecord');
        console.log(material);
        console.log(country);
        console.log(viewRecord);  
        // set make as read only and show/hide 
        setTimeout(function() {
            
            if(country) {
                if(country == 'Australia' || country == 'New Zealand') {
                    if(viewRecord && viewRecord  == true) {
                        helper.showHidePageLoad(component, event, helper,material);
                    }
                }
            }
        },2000);
    },
    /* Set tax end use based on ChannelCode and SalesOrg, Using CDM_TaxEndUseEvt  */
    setTaxEndUseOpts: function(component, event, helper) {
        
        
    },
    /* get eform field template based on contry  */
    getDataOnContry:  function(component, event, helper) {
        
        var country = component.get('v.country');
        var recordId = component.get("v.recordId");
        console.log(country);
        
        if(country && !recordId) {
            helper.getTemplateData(component, event, helper,true);
        }
        
    },
    // after select material value from material look up
    materialType : function(component, event, helper) {
        var material = event.getParam('material');
        component.set('v.selectedMaterial',material);
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var materialType,salesDocType;
        var channelCode = component.get('v.channelCode');
        if(material) {
            var a = component.find("material");
            console.log(JSON.stringify(a));
            for(var k in a) {
                // material number
                
                if(a[k].get('v.id') == 'CDM_Material_Number__c')  {
                    a[k].set('v.value',material.Name);
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = material.Name;                    
                }
                // material type
                
                if(material.CDM_Type1__c) {                  
                    fieldsMetaDatamap['CDM_Material_Type1__c'].Fieldvalue = material.CDM_Type1__c;
                }
                if(material.CDM_Type2__c) {
                    materialType = material.CDM_Type2__c;
                    fieldsMetaDatamap['CDM_Material_Type2__c'].Fieldvalue = material.CDM_Type2__c;
                }
                
                // description
                if(a[k].get('v.id') == 'CDM_Material_Description__c') {
                    a[k].set('v.value',material.CDM_Description__c); 
                    
                    if(material.CDM_Overwrite__c) {
                        a[k].set('v.disabled',false);  
                    }    
                    
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = material.CDM_Description__c;                    
                }
                //plant
                if(a[k].get('v.id') == 'CDM_Plant__c') {  // plant field
                    var salesOrg = fieldsMetaDatamap['CDM_Sales_Organisation__c'].Fieldvalue;
                    if(salesOrg == 'AU0A'){
                        a[k].set('v.value',material.CDM_AU0APlant__c);
                        fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = material.CDM_AU0APlant__c;                      
                    }
                    if(salesOrg == 'NZ0A') {
                        a[k].set('v.value',material.CDM_NZ0APlant__c);
                        fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = material.CDM_NZ0APlant__c;                      
                    }
                }
                
                //sales doc type
                if(a[k].get('v.id') == 'CDM_Sales_Doc_Type__c') {  
                    var sDocType = component.get('v.salesDocType');
                    var reqType = component.get('v.requestType');
                    
                    for(var key in sDocType)  {
                        if(sDocType[key].CDM_Material_Type__c ==  materialType && sDocType[key].CDM_Request_Type__c ==  reqType) {
                            a[k].set('v.value',sDocType[key].MasterLabel);
                            salesDocType = sDocType[key].MasterLabel;
                            component.set('v.salesDocTypeVal',salesDocType);
                            if(salesDocType == 'ZNOI') {// hide tax end use field
                                if(channelCode != '06' && channelCode != '07') 
                                    component.set('v.taxEndUseflg',false);
                                else
                                    component.set('v.taxEndUseflg',true);
                            } else
                                component.set('v.taxEndUseflg',true);
                         fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = sDocType[key].MasterLabel;
                        }
                    }  
                }
            } 
            component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
        } else {
            
            var a = component.find("material");
            
            // material number
            for(var k in a) {
                if(a[k].get('v.id') == 'CDM_Material_Number__c')  {
                    a[k].set('v.value','');
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = null;                    
                }
                
                // description
                if(a[k].get('v.id') == 'CDM_Material_Description__c') {
                    a[k].set('v.value','');  
                    a[k].set('v.disabled',true);  
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = null;                    
                }
                
                if(a[k].get('v.id') == 'CDM_Plant__c') {  // plant field
                    a[k].set('v.value','');
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = null;                      
                } 
                // sales doc type
                if(a[k].get('v.id') == 'CDM_Sales_Doc_Type__c') {  // plant field
                    a[k].set('v.value','');
                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = null;
                    
                    component.set('v.taxEndUseflg',true);
                    component.set('v.salesDocTypeVal',null);
                }
                
            }
            fieldsMetaDatamap['CDM_Material_Type1__c'].Fieldvalue = null;//material.CDM_Type1__c;
            
            fieldsMetaDatamap['CDM_Material_Type2__c'].Fieldvalue = null; //material.CDM_Type2__c;
            component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
        } 
        
        //helper.showHideLogicFieldChange(component, event, helper,fieldName);
        helper.showHidePageLoad(component, event, helper,material);
        //  
    },
    
    
    /* Split amount custom event CDM_AmountSplitEvt**/
    splitAmount : function(component, event, helper) {
        var splitAmountRecs = component.get('v.splitAmountRecs');
        var splitAmount = event.getParam('splitAmount');
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var country = component.get("v.country");
        //alert(country);
        if(splitAmountRecs.length > 4 && (country == 'Spain' || country == 'France'))
        {
        	alert('Only 5 Line Items are allowed per CDM Record.');    
        }
        else if(splitAmountRecs.length > 9 && country == 'Netherlands'){
            alert('Only 10 Line Items are allowed per CDM Record.');  
        }
        else
        {
            if(splitAmount && splitAmount == true) {
                splitAmountRecs.push({'sobjectType':'CDM_Split_Amount__c'});
                component.set('v.splitAmountRecs',splitAmountRecs);
                ///alert(splitAmountRecs.length);
                component.set('v.splitRequired','Yes');
                
                if(fieldsMetaDatamap['CDM_Gross_Amount__c'].FieldName == 'Gross Amount') {
                    
                    fieldsMetaDatamap['CDM_Gross_Amount__c'].Fieldvalue = null;
                    
                    component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);
                }
            } else {
                splitAmountRecs = [];
                
                component.set('v.splitAmountRecs',splitAmountRecs);
            }
    	}
        
    },
    /** Amount change custom component event CDM_AmountChangeEvt  **/
    sumAmount : function(component, event, helper) {
        var sumAmount = event.getParam('sumAmount');
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        if(sumAmount) {
            component.set('v.sumAmount',sumAmount);
        }
        console.log('sumAmount :'+sumAmount);
        var a = component.find("amount");
        if(fieldsMetaDatamap) {
            if(Array.isArray(a)) {
            	if(a && a.length>0) {
                    for(var k in a) {
                        if(a) {
                            if(a[k]) {
                                console.log('Updating Value :' +a[k].get('v.id'));
                                if(a[k].get('v.id') == 'CDM_Net_Amount__c') {
                                    //console.log('Updating Value :' +a[k].get('v.id'));
                                    a[k].set('v.value',sumAmount);
                                    fieldsMetaDatamap[a[k].get('v.id')].Fieldvalue = sumAmount;
                                }
                            }
                        }
                    } 
            	}
            }
            else
            {
                if(a) {
                    if(a.get('v.id') == 'CDM_Net_Amount__c') {
                        a.set('v.value',sumAmount);
                        fieldsMetaDatamap[a.get('v.id')].Fieldvalue = sumAmount;
                    }
                    
                }
            }            
        }
        
    },
    /** when we change value for any input type field **/
    getData: function(component, event, helper) {
        var eventId = event.getSource();
        var fieldName = eventId.get("v.id");
        var fieldLabel = eventId.get("v.label");
        var fieldValue = eventId.get("v.value");
        var checkVal = eventId.get("v.checked");
        var splitRequired = component.get('v.splitRequired');
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        console.log('+++fieldsMetaDatamap'+JSON.stringify(fieldsMetaDatamap));
        
        if(fieldsMetaDatamap[fieldName].DataType == 'BOOLEAN' || fieldsMetaDatamap[fieldName].DepDataType == 'BOOLEAN') {
            fieldsMetaDatamap[fieldName].Fieldvalue = checkVal;
            helper.showHideLogicFieldChange(component, event, helper,fieldName,fieldValue);
            
        } else {
            if(fieldValue && fieldValue!= '') {
                if(fieldLabel == 'Distribution Channel') {
                    var fVals = str.split(" ");
                    if(fVals.length>=1) {
                        fieldsMetaDatamap['CDM_ChannelCode__c'].Fieldvalue = fVals[0].trim();
                        component.set('v.channelCode',fVals[0].trim());
                    }
                    fieldsMetaDatamap[fieldName].Fieldvalue = fVals[0].trim(); 
                } else {
                    fieldsMetaDatamap[fieldName].Fieldvalue = fieldValue;
                }
              } else {
                fieldsMetaDatamap[fieldName].Fieldvalue = null;
              }// make gross amount sum
            if((fieldName == 'CDM_Net_Amount__c' || fieldName == 'CDM_Tax_Amount__c') && splitRequired != 'Yes') {
                var amt = component.find("amount");
                var sumAmount = 0;
                sumAmount = parseFloat(fieldsMetaDatamap['CDM_Net_Amount__c'].Fieldvalue? fieldsMetaDatamap['CDM_Net_Amount__c'].Fieldvalue : 0) + parseFloat(fieldsMetaDatamap['CDM_Tax_Amount__c'].Fieldvalue? fieldsMetaDatamap['CDM_Tax_Amount__c'].Fieldvalue: 0);
                sumAmount = parseFloat(sumAmount).toFixed(2);
                //sumAmount.toFixed(2);
                //var sumAmountFormatted = new Intl.NumberFormat('en-IN', { maximumFractionDigits: 2 }).format(sumAmount);
                if(splitRequired != 'Yes')
                    if(amt && amt.length>0) {
                        for(var k in amt) { // make sum value of net amount and tax amount
                            if(amt) {
                                if(amt[k]) {
                                    if(amt[k].get('v.id') == 'CDM_Gross_Amount__c') {
                                        
                                        amt[k].set('v.value',sumAmount);
                                        fieldsMetaDatamap[amt[k].get('v.id')].Fieldvalue = sumAmount;
                                        console.log('sumAmount :'+sumAmount);
                                    }
                                }
                            }
                        } 
                    }
                
            }
        }
        
        var a = component.find("material");
        var country = component.get('v.country');
        
        if(country != 'Switzerland') {
            
             for(var k in a) { // make sum value of net amount and tax amount
                if(a[k])
                    if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                        if(a[k].get('v.id') == fieldName)  {
                            if(fieldValue) {
                                for(var k in a) {
                                    if(a[k].get('v.id') == 'CDM_Cost_Center__c')
                                        a[k].set('v.disabled',true); 
                                }
                            } else {
                                for(var k in a) {
                                    if(a[k].get('v.id') == 'CDM_Cost_Center__c')
                                        a[k].set('v.disabled',false); 
                                }
                            }
                        }
                    }
            }
            
            for(var k in a) {
                if(a[k])
                    if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                        if(a[k].get('v.id') == fieldName)  {
                            if(fieldValue) {
                                for(var k in a) {
                                    if(a[k].get('v.id') == 'CDM_Cost_Center__c')
                                        a[k].set('v.disabled',true); 
                                }
                            } else {
                                for(var k in a) {
                                    if(a[k].get('v.id') == 'CDM_Cost_Center__c')
                                        a[k].set('v.disabled',false); 
                                }
                            }
                        }
                    }
            }
            for(var k in a) {
                if(a[k]) {
                    if(a[k].get('v.id') == 'CDM_Cost_Center__c') {
                        if(a[k].get('v.id') == fieldName)  {
                            if(fieldValue) {
                                for(var k in a) {
                                    if(a[k]) {
                                        if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                                            a[k].set('v.disabled',true); 
                                        }
                                    }
                                }
                            } else {
                                for(var k in a) {
                                    if(a[k]) {
                                        if(a[k].get('v.id') == 'CDM_Profit_Center__c') {
                                            a[k].set('v.disabled',false);
                                        } 
                                    }    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);
        
    },
    /** get dependent fields **/
    setDepEventField:function(component, event, helper) {
        if(event.getParams('controlleringField')) {
            var controllingField = event.getParams('controlleringField');
            var recPicklistMap = component.get('v.fieldPicklistMap');
            var depPicklistMap = component.get('v.depPicklistMap');
            var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
            var cField = controllingField.controlleringField;
            var value;
            //var dependentField;
            
            for(var k in fieldsMetaDatamap) {
                if(fieldsMetaDatamap[k]) {
                    if(fieldsMetaDatamap[k].ControllingField == cField) {
                        value = fieldsMetaDatamap[k];
                    }
                }
            }
            console.log('value'+value);
            if(value)
                if(depPicklistMap && value.ControllingField && fieldsMetaDatamap[value.ControllingField].Fieldvalue) {
                    for(var k in depPicklistMap[value.TargetField]) 
                        if(k ==fieldsMetaDatamap[value.ControllingField].Fieldvalue) {
                            recPicklistMap[value.TargetField] = depPicklistMap[value.TargetField][fieldsMetaDatamap[value.ControllingField].Fieldvalue];
                            component.set('v.fieldPicklistMap',recPicklistMap);
                            return null;
                        } 
                }        
        } 
    },
    
    
    /** set record type when you select record type selection window  **/
    selectRecordType : function(component, event, helper) {
        var selValue = event.getParam("value");
        component.set("v.recordTypeId",selValue);
    },
    /** cancel method, it can used for show form read only  **/
    onCancel: function(component, event, helper) {
        // component.set("v.viewRecord", true);
        var recordId = component.get("v.recordId");
        if(!recordId) {
            window.location.href = "/lightning/o/CDM_Credit_Debit_Note__c/list"
                
        } else
            window.location.href = "/lightning/r/CDM_Credit_Debit_Note__c/" + recordId + "/view";
        
    },
    /** when close record type modal than return to list view page  **/
    closeRecordTypeModal : function(component, event, helper) {
        var recModal =  component.find('recMadal');
        $A.util.addClass(recModal, 'slds-hide'); 
        var urlEvent = $A.get("e.force:navigateToURL");
        if(urlEvent) {
            urlEvent.setParams({
                url: "/lightning/o/CDM_Credit_Debit_Note__c/list",
                isredirect: false
            });
            urlEvent.fire();
        }
    },
    /** show and hide field when page load **/
    showHidePageLoad1 : function(component, event, helper) {
        
        var fieldName = event.getParam("depParent");
        var fieldValue = event.getParam("depParentValue");
        
        helper.showHideLogicFieldChange(component, event, helper,fieldName,fieldValue);
    },
    /** when click on save, saving eform date into cdm eform  **/  
    onSave: function(component, event, helper) {
        //  alert(event.target.name);
        var btnName = event.target.name;
        var valid = helper.checkRequired(component, event, helper);
        
        if(valid == 'ERROR'){
            return;
        }
        var requestType = component.get('v.requestType');
        var country = component.get("v.country")
        var recordId = component.get("v.recordId");
        var action = component.get("c.saveEformData");
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var splitAmountRecs = component.get('v.splitAmountRecs');
        var recDataMap = new Map();
        
        for (var key in fieldsMetaDatamap) {
            if(fieldsMetaDatamap[key]) {
                if(fieldsMetaDatamap[key].PlaceHolderValue && !fieldsMetaDatamap[key].Fieldvalue)
                    fieldsMetaDatamap[key].Fieldvalue = fieldsMetaDatamap[key].PlaceHolderValue;
                if(fieldsMetaDatamap[key].TargetField == 'CDM_Dedicated_to_Document_type__c' && country == 'France') {
                    if(requestType == 'Debit Note') {
                        fieldsMetaDatamap[key].Fieldvalue = 'DN';
                    }    
                    if(requestType == 'Credit Note') {
                        fieldsMetaDatamap[key].Fieldvalue = 'CN';
                    }
                }
                if(fieldsMetaDatamap[key].TargetField == 'CDM_Bline_Date__c'){
					if(fieldsMetaDatamap['CDM_Due_Date__c'].Fieldvalue != null)
                        fieldsMetaDatamap[key].Fieldvalue = fieldsMetaDatamap['CDM_Due_Date__c'].Fieldvalue;
                	else
                    	fieldsMetaDatamap[key].Fieldvalue = component.get("v.today");
                }
                if((country == 'Australia' || country == 'New Zealand') && key == 'CDM_Form_Status__c' && requestType == 'Debit Note' && fieldsMetaDatamap[key].Fieldvalue == 'Draft') {
                    fieldsMetaDatamap[key].Fieldvalue = 'Approved';
                }    
                recDataMap[key] = JSON.stringify(fieldsMetaDatamap[key]);
            }
            
        }
        var recData = {
            recDataMap : recDataMap, 
            recordId : recordId,
            splitAmountRecs : JSON.stringify(splitAmountRecs),
            btnName: btnName
        };
        
        action.setParams({
            recData: JSON.stringify(recData)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (!recordId) {
                    var recId = response.getReturnValue();
                    window.location.href = "/lightning/r/CDM_Credit_Debit_Note__c/" + recId + "/view";
                  
                    } else {
                        helper.getTemplateData(component, event, helper,false);
                        window.location.href = "/lightning/r/CDM_Credit_Debit_Note__c/" + recordId + "/view";
                        //setTimeout(function(){ component.set("v.viewRecord", true); }, 1000);
                    }
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error Message!",  
                        "message":  $A.get("{!$Label.c.CDM_Service_Form_Error_Msg}")
                    });
                    toastEvent.fire();
                }
            });
        
        $A.enqueueAction(action);
        
    },
    /**when you try to create new record in split record  */
    newRecord : function(component, event, helper) {
        var recordTypeId = component.get("v.recordTypeId");
        
        if(recordTypeId) {
            var recModal =  component.find('recMadal');
            $A.util.addClass(recModal, 'slds-hide'); 
            helper.getTemplateData(component, event, helper);
        }
    },
    
});