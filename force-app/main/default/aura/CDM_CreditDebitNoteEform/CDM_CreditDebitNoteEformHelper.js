({  
    /** check required when you out onfocus on input field */
    checkRequired : function(component, event, helper) {
        var fieldsMetaDatamap =  component.get('v.fieldsMetaDatamap');
       var  splitRequired = component.get('v.splitRequired');
        var country = component.get('v.country');
        var parentCDMFlg = component.get('v.parentCDMFlg');
       // alert('required');
        for (var key in fieldsMetaDatamap){
            var rec = fieldsMetaDatamap[key];
            if(rec && parentCDMFlg != 'Yes') {
                if(rec.Show) {
                    
                    if((rec.FieldName == 'Ship-To Party' || rec.FieldName == 'Payer' || rec.FieldName == 'Billto')  && rec.Fieldvalue && rec.Pattern) {
                        var patt = new RegExp(rec.Pattern);
                      
                        if(patt.test(rec.Fieldvalue) == false) {
                            helper.setToastMessage(component, event, helper, rec.PatternMessage);// rec.FieldName +" field is allow 8 digits and starts with 5 only") 
                            return 'ERROR';
                        }
                    }
                    if (rec.FieldName == 'Invoice Date'){
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        //alert(today);
                        if (rec.Fieldvalue > today){
                            helper.setToastMessage(component, event, helper, rec.FieldName +" cannot be set to future date");
                            return 'ERROR';
                        }
                    }
                    
                    if (rec.FieldName == 'Operation Date' && country == 'Spain'){
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        if (rec.Fieldvalue > today){
                            helper.setToastMessage(component, event, helper, rec.FieldName +" cannot be set to future date");
                            return 'ERROR';
                        }
                        if (rec.Fieldvalue > fieldsMetaDatamap['CDM_Invoice_Date__c'].Fieldvalue){
                            helper.setToastMessage(component, event, helper, rec.FieldName +" cannot be set to greater than Invoice date");
                            return 'ERROR';
                        }
                    }                    
                    if(country != 'Switzerland')  
                        if(rec.FieldName == 'Profit Center' && splitRequired != 'Yes' && rec.Fieldvalue && rec.Fieldvalue!='') {
                            var patt = new RegExp(rec.Pattern);
                            if(patt.test(rec.Fieldvalue) == false) {
                                helper.setToastMessage(component, event, helper, rec.FieldName +" field is allow 7 digits only") 
                                return 'ERROR';
                            }
                        }
                    if(country != 'Switzerland') {
                        if(rec.FieldName == 'Cost Center' && splitRequired != 'Yes' && rec.Fieldvalue && rec.Fieldvalue!='') {
                            var patt = new RegExp(rec.Pattern);
                            if(patt.test(rec.Fieldvalue) == false) {
                                helper.setToastMessage(component, event, helper, rec.FieldName +" field is allow 10 digits only") 
                                return 'ERROR';
                            }
                        }
                    }
                }
                if(rec.Show && rec.Required) {
                    if(rec.Fieldvalue && rec.Fieldvalue!='' && rec.Fieldvalue!=null) {
                        console.log(rec.Fieldvalue);
                    } else {
                        var  splitRequired = component.get('v.splitRequired');
                        if(splitRequired == 'Yes') {
                            if(rec.FieldName != 'Tax Code' && rec.FieldName != 'Tax Amount' && rec.FieldName != 'Gross Amount' && rec.FieldName != 'Item Text' && rec.FieldName != 'Tax Rate') {
                                helper.setToastMessage(component, event, helper,rec.FieldName + " Field is required");
                                return 'ERROR';  
                            }
                        }
                            
                            else {
                                helper.setToastMessage(component, event, helper,rec.FieldName + " Field is required");
                                return 'ERROR'; 
                            }
                         
                    }
                }
            }
        }
                         
                         var splitAmountRecs = component.get('v.splitAmountRecs');
                         if(splitAmountRecs && splitRequired == 'Yes') {
                             for(var k in splitAmountRecs){
                                 if(splitAmountRecs[k].CDM_Sub_Gross_Amount__c || splitAmountRecs[k].CDM_Sub_Gross_Amount__c == 0){
                                      console.log(k);
                                 }else{
                                     helper.setToastMessage(component, event, helper," Sub Gross Amount Field is required") 
                                 	 return 'ERROR';
                                 }
                                 if(splitAmountRecs[k].CDM_Sub_Net_Amount__c || splitAmountRecs[k].CDM_Sub_Net_Amount__c == 0){
                                     console.log(k);
                                 }else{
                                      helper.setToastMessage(component, event, helper," Sub Net Amount Field is required") 
                                 	  return 'ERROR';
                                 }
                                 if(splitAmountRecs[k].CDM_Sub_Tax_Amount__c  || splitAmountRecs[k].CDM_Sub_Tax_Amount__c == 0){
                                     console.log(k);
                                 }else{
                                      helper.setToastMessage(component, event, helper," Sub Tax Amount Field is required") 
                                	  return 'ERROR';
                                 }
                                 if(splitAmountRecs[k].CDM_GL_Account__c){
                                     console.log(k);
                                 }else{
                                    //  helper.setToastMessage(component, event, helper," GL Account Field is required") 
                                 	//  return 'ERROR';
                                 }
                                 if(country != 'Switzerland') { 
                                     if(splitAmountRecs[k].CDM_Profit_Center__c) {
                                         console.log(k);
                                         console.log(splitAmountRecs[k].CDM_Profit_Center__c);
                                         var patt = new RegExp("^[a-zA-Z0-9]{7}$");
                                         var res = patt.test(splitAmountRecs[k].CDM_Profit_Center__c);
                                         if(res == false) {
                                             helper.setToastMessage(component, event, helper," Profit Center field is allow 7 digits only") 
                                             return 'ERROR';
                                         }
                                     } 
                                 }
                                 if(country != 'Switzerland') {
                                     if(splitAmountRecs[k].CDM_Cost_Center__c) {
                                         var patt = new RegExp("^[a-zA-Z0-9]{10}$");
                                         var res = patt.test(splitAmountRecs[k].CDM_Cost_Center__c);
                                         console.log('patt'+splitAmountRecs[k].CDM_Cost_Center__c);
                                         if(res == false) {
                                             helper.setToastMessage(component, event, helper," Cost Center field is allow 10 characters only") 
                                             return 'ERROR';
                                         }
                                     } 
                                 }
                                 
                                 if(splitAmountRecs[k].CDM_Sub_Item_Text__c || splitAmountRecs[k].CDM_Sub_Item_Text__c == 0) {
                                     console.log(k);
                                 } else {
                                     if(country == 'Netherlands' || country == 'Spain') {
                                         console.log('val3'+splitAmountRecs[k].CDM_Sub_Item_Text__c);
                                         helper.setToastMessage(component, event, helper," Sub Item Text Field is required") 
                                         return 'ERROR';
                                     }
                                 }
                                console.log('splitAmountRecs[k].CDM_Sub_Tax_Rate__c'+splitAmountRecs[k].CDM_Sub_Tax_Rate__c); 
                                 if(splitAmountRecs[k].CDM_Sub_Tax_Rate__c || splitAmountRecs[k].CDM_Sub_Tax_Rate__c == 0) {
                                     console.log(k);
                                 } else {
                                     if(country == 'Netherlands' || country == 'Spain') {
                                         console.log('val3'+splitAmountRecs[k].CDM_Sub_Tax_Rate__c);
                                         helper.setToastMessage(component, event, helper," Sub Tax Rate Field is required") 
                                         return 'ERROR';
                                     }
                                 }
                                 
                                 
                                 
                                 if(splitAmountRecs[k].CDM_Sub_Tax_Code__c){
                                     console.log(k);
                                 }else{
                                     helper.setToastMessage(component, event, helper," Sub Tax Code Field is required") 
                                     return 'ERROR';
                                 }
                                     
                             }
                         }
           return 'NoERROR';
    
},
    /* show toast message method */
    setToastMessage : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error Message!",
            "message":  message + ""
        });
        toastEvent.fire();
        return 'ERROR';
    },
   
     /** This helper used for Show/Hide for field,sections **/
    showHideLogicFieldChange :  function(component, event, helper,depParent,fieldValue) {
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var field;
        var dateField = component.find('dependentFields');
        var dateField1 = component.find("dateFields1");
        var fieldRuleMap = component.get("v.eFormFieldRule");
        var requestType = component.get('v.requestType');
        //alert(depParent);
        
        if(depParent == 'CDM_Posting_Period__c' && fieldValue == 'Previous'){
            //alert(dateField.get('v.id'));
            var today = new Date();            
            var tobeDate = new Date();
            var presentMonth = today.getMonth();
            //alert(presentMonth);
            if(presentMonth == '0'){
                tobeDate.setFullYear(today.getFullYear()-1,11,31);
            }
            if(presentMonth == '1'){
                tobeDate.setFullYear(today.getFullYear(),0,31);
            }
            if(presentMonth == '2'){
                tobeDate.setFullYear(today.getFullYear(),1,28);
            }
            if(presentMonth == '3'){
                tobeDate.setFullYear(today.getFullYear(),2,31);
            }
            if(presentMonth == '4'){
                tobeDate.setFullYear(today.getFullYear(),3,30);
            }
            if(presentMonth == '5'){
                tobeDate.setFullYear(today.getFullYear(),4,31);
            }
            if(presentMonth == '6'){
                tobeDate.setFullYear(today.getFullYear(),5,30);
            }
            if(presentMonth == '7'){
                tobeDate.setFullYear(today.getFullYear(),6,31);
            }
            if(presentMonth == '8'){
                tobeDate.setFullYear(today.getFullYear(),7,31);
            }
            if(presentMonth == '9'){
                tobeDate.setFullYear(today.getFullYear(),8,30);
            }
            if(presentMonth == '10'){
                tobeDate.setFullYear(today.getFullYear(),9,31);
            }
            if(presentMonth == '11'){
                tobeDate.setFullYear(today.getFullYear(),10,30);
            }
            var finalTobeDate = $A.localizationService.formatDate(tobeDate, "YYYY-MM-DD");
            //alert(finalTobeDate);
            if(dateField && dateField.length>0)
            {                
                for(var t in dateField) { 
                    if(dateField) {
                        if(dateField[t]) {                                    
                            if(dateField[t].get('v.id') == 'CDM_Posting_Date__c') {                                   
                                dateField[t].set('v.value',finalTobeDate);
                                dateField[t].set('v.disabled',true);
                                fieldsMetaDatamap[dateField[t].get('v.id')].Fieldvalue = finalTobeDate;                                
                            }
                            if(dateField[t].get('v.id') == 'CDM_Tax_Report_Date__c') {                                                
                                dateField[t].set('v.value',finalTobeDate);
                                dateField[t].set('v.disabled',true);
                                fieldsMetaDatamap[dateField[t].get('v.id')].Fieldvalue = finalTobeDate;                                
                            }							
                        }
                    }                   
                }                                
            }
            if(dateField1 && dateField1.length>0)
            {                
                for(var t in dateField1) { 
                    if(dateField1) {
                        if(dateField1[t]) {  
                            if(dateField1[t].get('v.id') == 'CDM_Operation_Date__c') {                                 
                                dateField1[t].set('v.value',finalTobeDate);
                                dateField1[t].set('v.disabled',true);
                                fieldsMetaDatamap[dateField1[t].get('v.id')].Fieldvalue = finalTobeDate;                                
                            }
                            if(dateField1[t].get('v.id') == 'CDM_Invoice_Date__c') {                                                
                                dateField1[t].set('v.value',finalTobeDate);
                                dateField1[t].set('v.disabled',true);
                                fieldsMetaDatamap[dateField1[t].get('v.id')].Fieldvalue = finalTobeDate;                                
                            }							                            
                        }
                    }                   
                }                                
            }
        }
        if(depParent == 'CDM_Posting_Period__c' && fieldValue == 'Current'){
        	if(dateField1 && dateField1.length>0)
            {                
                for(var t in dateField1) { 
                    if(dateField1) {
                        if(dateField1[t]) {                                    
                            if(dateField1[t].get('v.id') == 'CDM_Operation_Date__c') {                                                                 
                                dateField1[t].set('v.disabled',false);                                   
                            }
                            if(dateField1[t].get('v.id') == 'CDM_Invoice_Date__c') {                                                                                
                                dateField1[t].set('v.disabled',false);                                     
                            }
                            if(dateField[t].get('v.id') == 'CDM_Posting_Date__c') {                                   
                                dateField[t].set('v.value',null);
                                //dateField[t].set('v.disabled',false);
                                fieldsMetaDatamap[dateField[t].get('v.id')].Fieldvalue = null;                                
                            }
                            if(dateField[t].get('v.id') == 'CDM_Tax_Report_Date__c') {                                                
                                dateField[t].set('v.value',null);
                                //dateField[t].set('v.disabled',false);
                                fieldsMetaDatamap[dateField[t].get('v.id')].Fieldvalue = null;                                
                            }
                        }
                    }                   
                }                                
            }   
        }
        field = fieldsMetaDatamap[depParent]; 
        if(field!=null) {
            if(field.DataType == 'REFERENCE') {
                field.Fieldvalue = field.LookVal;
            }   
            
            if(fieldRuleMap && field && fieldRuleMap[depParent]) { 
                var fieldRule = fieldRuleMap[depParent];
                for(var k in fieldRule) {
                    var parentField = fieldRule[k].CDM_Parent_Field__r.CDM_Target_Field__c;
                    var showField = fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c;
                    console.log('parentField'+parentField);
                    console.log('field.TargetField'+depParent);
                    if(depParent && fieldRule[k] && parentField == depParent) {
                        var fieldId = document.getElementById(fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c+'Div');
                        console.log('fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c'+fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c);
                        if(fieldId) {
                            
                            if(fieldRule[k].CDM_Parent_Field_Value__c && field.Fieldvalue) {
                                console.log('field.Fieldvalue'+field.Fieldvalue);
                                console.log('field.Fieldvalue'+fieldRule[k].CDM_Parent_Field_Value__c);
                                
                                if(field.Fieldvalue == fieldRule[k].CDM_Parent_Field_Value__c || 
                                   field.Fieldvalue.toString() == fieldRule[k].CDM_Parent_Field_Value__c) {
                                    if(requestType == 'Credit Note') {
                                        switch(showField) {
                                            case 'CDM_Admin_Fee_Credit_Amount__c': {
                                                fieldId.style.display = "inline";
                                                fieldsMetaDatamap[showField].Show = true; 
                                                fieldsMetaDatamap[showField].Required = true;
                                            }
                                                break;
                                            case 'CDM_Net_Amount__c': {
                                                fieldId.style.display = "inline";
                                                fieldsMetaDatamap[showField].Show = true; 
                                                fieldsMetaDatamap[showField].Required = true;
                                            }
                                                break;
                                            case 'CDM_Quantity__c': {
                                                
                                                fieldId.style.display = "none";
                                                fieldsMetaDatamap[showField].Show = false; 
                                                fieldsMetaDatamap[showField].Required = false;
                                                var fId = document.getElementById('CurrencyIsoCode');
                                                if(fId)
                                                    fId.style.display = "inline";
                                            }
                                                break;
                                            default: {
                                                console.log('showField==+'+showField);
                                                fieldId.style.display = "inline"; 
                                                
                                            }
                                                
                                        }
                                    } 
                                    
                                    if(requestType == 'Debit Note') {
                                        switch(showField) {
                                            case 'CDM_Admin_Fee_Credit_Amount__c': {
                                                fieldId.style.display = "none";
                                                fieldsMetaDatamap[showField].Show = false; 
                                                fieldsMetaDatamap[showField].Required = false;
                                            }
                                                break;
                                            case 'CDM_Net_Amount__c': {
                                                
                                                fieldId.style.display = "none"; 
                                                fieldsMetaDatamap[showField].Show = false; 
                                                fieldsMetaDatamap[showField].Required = false;   
                                            }
                                                break;
                                            case 'CDM_Quantity__c': {
                                                fieldId.style.display = "inline";
                                                fieldsMetaDatamap[showField].Show = true; 
                                                fieldsMetaDatamap[showField].Required = true;
                                                var fId = document.getElementById('CurrencyIsoCode');
                                                console.log('fId'+fId);
                                                if(fId)
                                                    fId.style.display = "none";
                                            }
                                                break;
                                            default: {
                                                console.log('showField==+'+showField);
                                                fieldId.style.display = "inline"; 
                                                
                                            }
                                                
                                        }
                                    }
                                    
                                    // fieldId.style.display = "inline";
                                } else {
                                    console.log('showField==='+showField);
                                    if(showField =='CDM_Net_Amount__c') {
                                        fieldId.style.display = "inline";
                                    }
                                    if(showField !='CDM_Net_Amount__c') {
                                        fieldId.style.display = "none";
                                        fieldsMetaDatamap[showField].Show = false; 
                                        fieldsMetaDatamap[showField].Required = false;
                                        
                                    }
                                    if(showField == 'CDM_Tax_End_Use__c' && (field.Fieldvalue == '07 Marine' || field.Fieldvalue == '06 Air')) {
                                        fieldId.style.display = "inline";
                                        fieldsMetaDatamap[showField].Show = true; 
                                        fieldsMetaDatamap[showField].Required = false;
                                    }
                                }
                                
                                
                            } else {
                                if(showField =='CDM_Net_Amount__c') {
                                    fieldId.style.display = "inline";
                                }
                                if(showField !='CDM_Net_Amount__c') {
                                    fieldId.style.display = "none";
                                    fieldsMetaDatamap[showField].Show = false; 
                                    fieldsMetaDatamap[showField].Required = false;	    
                                }
                                
                            }
                        }
                        
                    }
                    
                }       
                
                
            }
        }
      component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
    },
   
     /** This helper used for Show/Hide for field,sections **/
    showHidePageLoad :  function(component, event, helper,material) {
     	
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var field;
        var fieldRuleMap = component.get("v.eFormFieldRule");
        console.log('fieldRuleMap'+JSON.stringify(fieldRuleMap));
        var requestType = component.get('v.requestType');
     
        for(var attrId in fieldsMetaDatamap) {
            
            field = fieldsMetaDatamap[attrId]; 
            if(field!=null) {
                if(field.DataType == 'REFERENCE')
                    field.Fieldvalue = field.LookVal;
                  console.log('field.TargetField+'+field.TargetField);
                if(fieldRuleMap && field && fieldRuleMap[field.TargetField]) { 
                
                        var fieldRule = fieldRuleMap[field.TargetField];
                        console.log('fieldRule'+JSON.stringify(fieldRule));
                        for(var k in fieldRule) {
                            var showField = fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c;
                             var parentField = fieldRule[k].CDM_Parent_Field__r.CDM_Target_Field__c;
                         																																								  
                            if(field.TargetField && fieldRule[k] && parentField == field.TargetField) {
					   
                                var fieldId = document.getElementById(fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c+'Div');
                                //debugger;
                                if(fieldId) {
                                    
                                    if(fieldRule[k].CDM_Parent_Field_Value__c && field.Fieldvalue) {
                                        console.log('field.Fieldvalue'+field.Fieldvalue);
                                        console.log('field.Fieldvalue'+fieldRule[k].CDM_Parent_Field_Value__c);
                                     
                                       if(field.Fieldvalue == fieldRule[k].CDM_Parent_Field_Value__c || 
                                          field.Fieldvalue.toString() == fieldRule[k].CDM_Parent_Field_Value__c) {
                                            if(requestType == 'Credit Note') {
                                               switch(showField) {
                                                   case 'CDM_Admin_Fee_Credit_Amount__c': {
                                                       
                                                       fieldId.style.display = "inline";
                                                       fieldsMetaDatamap[showField].Show = true; 
                                                       fieldsMetaDatamap[showField].Required = true; 
                                                   }
                                                       break;
                                                   case 'CDM_Net_Amount__c': {
                                                       fieldId.style.display = "inline";
                                                       fieldsMetaDatamap[showField].Show = true; 
                                                       fieldsMetaDatamap[showField].Required = true; 
                                                   }
                                                       break;
                                                   case 'CDM_Quantity__c': {
                                                       
                                                       fieldId.style.display = "none";
                                                       fieldsMetaDatamap[showField].Show = false; 
                                                       fieldsMetaDatamap[showField].Required = false; 
                                                       var fId = document.getElementById('CurrencyIsoCode'+'Picklist');
                                                       console.log('fId'+fId);
                                                       if(fId)
                                                           fId.style.display = "inline";                                                           
                                                   }
                                                       break;
                                                   default: {
                                                       console.log('showField==+'+showField);
                                                       fieldId.style.display = "inline"; 
                                                       
                                                   }
                                                   
                                               }
                                           } 
                                           
                                           if(requestType == 'Debit Note') {
                                               switch(showField) {
                                                   case 'CDM_Admin_Fee_Credit_Amount__c': {
                                                       
                                                       fieldId.style.display = "none";
                                                       fieldsMetaDatamap[showField].Show = false; 
                                                       fieldsMetaDatamap[showField].Required = false;   
                                                   }    
                                                       break;
                                                   case 'CDM_Net_Amount__c': {
                                                       
                                                       fieldId.style.display = "none"; 
                                                       fieldsMetaDatamap[showField].Show = false; 
                                                       fieldsMetaDatamap[showField].Required = false;   
                                                   }
                                                       break;
                                                   case 'CDM_Quantity__c': {
                                                       
                                                       fieldId.style.display = "inline";
                                                       var fId = document.getElementById('CurrencyIsoCode'+'Picklist');
                                                       console.log('fId'+fId);
                                                       if(fId)
                                                           fId.style.display = "none";
                                                       
                                                   }
                                                       break;
                                                   default: {
                                                       console.log('showField==+'+showField);
                                                       fieldId.style.display = "inline"; 
                                                       
                                                   }
                                                       
                                               }
                                           }
                                                
                                              
                                       } else {
                                           if(showField =='CDM_Net_Amount__c') { 
                                               fieldId.style.display = "inline";
                                           }
                                           if(showField !='CDM_Net_Amount__c') {
                                               fieldId.style.display = "none";
                                               fieldsMetaDatamap[showField].Show = false; 
                                               fieldsMetaDatamap[showField].Required = false;
                                               
                                           }
                                       }
                                               
                                            
                                    } else {

                                         var showfield = fieldRule[k].CDM_Show_Field__r.CDM_Target_Field__c;
                                        if(material) {
                                      
                                            // GL Account Enabled
                                            if(material.CDM_GL_Editable__c && material.CDM_GL_Editable__c == true || material.CDM_GL_Editable__c == 'true') {
                                                if(!fieldRule[k].CDM_Parent_Field_Value__c) {
                                                    if(showfield == 'CDM_GL_Account__c' || showfield == 'CDM_Profit_Center__c' || showfield == 'CDM_Cost_Centre__c') {
                                                        fieldId.style.display = "inline";
                                                        component.set('v.GLmaterialFlg',false);
                                                        
                                                    }
                                                }
                                            } 
                                            
                                            if(showField =='CDM_Quantity__c') {
                                                fieldId.style.display = "none";
                                                fieldsMetaDatamap[showField].Show = false; 
                                                fieldsMetaDatamap[showField].Required = false;
                                                
                                            }
                                            if(showfield =='CDM_Net_Amount__c') {
                                                fieldId.style.display = "inline";
                                                fieldsMetaDatamap[showField].Show = true; 
                                                fieldsMetaDatamap[showField].Required = true;
                                            }
                                        } else {
                                            
                                            //component.set('v.GLmaterialFlg',false);
                                            component.set('v.GLmaterialFlg',true);
                                            if(showField =='CDM_Net_Amount__c') { 
                                                fieldId.style.display = "inline";
                                            }
                                            if(showField !='CDM_Net_Amount__c') {
                                                fieldId.style.display = "none";
                                                fieldsMetaDatamap[showField].Show = false; 
                                                fieldsMetaDatamap[showField].Required = false;
                                                
                                            }
                                            
                                        }
                                       
                                        
                                    }
                            }
                        }       
                    }
              
				
            }
		 
        } 
        }
        component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
    },
        
  
    /** get record types map  **/
    getRecordTypes : function(component, event, helper) {
     
         var action = component.get("c.getRecordTypesMap");
       
         action.setCallback(this, function(response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                 component.set("v.recTypeMap",response.getReturnValue());
                 var recTypeOpts = [];
                 var recTypeMap = response.getReturnValue();
                 for(var key in recTypeMap) {
                     var opt ={'label':recTypeMap[key]  , 'value': key};
                     recTypeOpts.push(opt)                       
                 }
                 component.set('v.recTypeOpts',recTypeOpts);
             }
         });
         $A.enqueueAction(action);
    },
    
    getContryWiseRequiredFiels : function(component, event, helper) {
        
        
    },
    /** get eform template meta data or with data  **/
    getTemplateData : function(component, event, helper,countryChange) {
        //event.stopPropagation();
          var spinner = component.find('spinner');
             $A.util.removeClass(spinner, 'slds-hide');
         var action = component.get("c.getFieldsMetaData");
         var recId = component.get("v.recordId");
         var recTypeId = component.get('v.recordTypeId');
        var country = component.get('v.country');
    
        action.setParams({
            recId: recId, 
            country: country,
            recTypeId: recTypeId
          
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
         
            if (state === "SUCCESS") {
                var fieldsMetaDataWrp = response.getReturnValue();
                var fieldsMetaDatamap = new Map();
                
                if (fieldsMetaDataWrp) {
                  fieldsMetaDataWrp.cdnFormTemplate.forEach(function(item, index) {
                   
                     item.CDM_DefaultValue__c = item.Name == 'Country'? country ? country : item.CDM_DefaultValue__c : item.CDM_DefaultValue__c;
                      item.CDM_DefaultValue__c = item.Name == 'Posting Period'?  item.CDM_DefaultValue__c? item.CDM_DefaultValue__c : 'Current': item.CDM_DefaultValue__c;
                      item.CDM_DefaultValue__c = item.Name == 'Billing Date' || item.Name == 'Operation Date' || item.Name == 'Invoice Date' ? item.CDM_DefaultValue__c ? item.CDM_DefaultValue__c : component.get('v.today') : item.CDM_DefaultValue__c;
                     
                     if(item.Name == 'Split Required') {
                         component.set('v.splitRequired',item.CDM_DefaultValue__c);
                       
                     }
                      if(item.Name == 'Country' && !component.get('v.country')) {
                          component.set('v.country',item.CDM_DefaultValue__c);
                          
                      }
                      if(item.Name =='Company Code') {
                         component.set('v.companyCode',item.CDM_DefaultValue__c);
                      }
                    //console.log('recTypeId'+recTypeId);
                     var recdata = {
                            FieldName: item.Name,
                            Fieldvalue: item.CDM_Target_Field__c == 'RecordTypeId' && !recId? recTypeId: item.CDM_DefaultValue__c,
                            TargetObject: item.CDM_Target_Object__c,
                            DataType: item.CDM_DataType__c,
                            DepDataType: item.CDM_Dependent_Field_DataType__c,
                            FieldId: "",
                            ControllingField: item.CDM_Controlling_Field__c,
                            TargetField: item.CDM_Target_Field__c,
                            MinVal: item.CDM_Min_Length__c,
                            MaxVal: item.CDM_Max_Length__c,
                            Required: item.CDM_Required__c,
                            ReadOnly: item.CDM_Read_Only__c,
                            Show: item.CDM_Show__c,
                            LookValId: item.CDM_DataType__c == 'REFERENCE'? item.CDM_Target_Field__c == 'RecordTypeId' && !recId? recTypeId : item.CDM_DefaultValue__c : '' ,
                            LookVal:  item.CDM_Look_Up_Field_Value__c,
                            LookUpFilter: item.CDM_Look_Up_Filter__c,
                            SupportingNotes : item.CDM_Supporting_Notes__c,
                        	PlaceHolderValue: item.Place_Holder_Value__c,
                         	PatternMessage: item.CDM_Pattern_Message__c
                           
                        };
                   
                      if(item.Name == 'Approval Status' && item.CDM_DefaultValue__c) {
                            component.set('v.approvalStatus',item.CDM_DefaultValue__c);
                      }
                       
                      if(item.Name == 'Net Amount' && country != 'Australia' && country != 'New Zealand') {
                           component.set('v.sumAmount',item.CDM_DefaultValue__c);
                      }
                      if(item.Name == 'CDM Form Status' && item.CDM_DefaultValue__c) {
                           component.set('v.cdmStatus',item.CDM_DefaultValue__c);
                      }
                     
                       if(recId && item.CDM_Required__c) {
                          if(!item.CDM_DefaultValue__c)
                              recdata.Required = false;
                      }
                      
                      if(item.Name == 'Type of Request') {
                         component.set('v.requestType',item.CDM_Look_Up_Field_Value__c);
                      }
                      
                      if(item.Name == 'Bulk Upload') {
                         component.set('v.parentCDMFlg',item.CDM_DefaultValue__c);
                      }
                              
                      if(item.Name == 'Sales Organisation' || item.Name == 'Company Code') {
                          if(country == 'Australia')
                              recdata.Fieldvalue = 'AU0A';
                          if(country == 'New Zealand')
                              recdata.Fieldvalue = 'NZ0A';
                          
                      }
                      if(!recId && item.Name == 'Currency') {
                          if(country == 'Australia' || country == 'New Zealand') {
                              if(country == 'Australia') {
                                  item.CDM_DefaultValue__c = 'AUD';
                                  recdata.Fieldvalue = 'AUD';
                              }
                               if(country == 'New Zealand') {
                                  item.CDM_DefaultValue__c = 'NZD';
                                  recdata.Fieldvalue = 'NZD';
                              }
                          } else {
                              item.CDM_DefaultValue__c = 'EUR';
                              recdata.Fieldvalue = 'EUR';
                          }
                      }
                     
                           //console.log('recdata'+JSON.stringify(recdata));  
                      if(item.Name == 'Quantity') {
                            recdata.Required = false;
                      }
                      
                      if( fieldsMetaDatamap[item.CDM_Target_Field__c]) {
                            if(recdata.Show)
                                fieldsMetaDatamap[item.CDM_Target_Field__c] = recdata;
                      }else
                        fieldsMetaDatamap[item.CDM_Target_Field__c] = recdata;
                     
                    });
                   
                    component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);
                    if(fieldsMetaDataWrp.recPicklistMap) {
                        component.set("v.taxCodes",fieldsMetaDataWrp.recPicklistMap['CDM_Tax_Code__c']);
                    }
                    //console.log(JSON.stringify(fieldsMetaDataWrp.recPicklistMap));
                  
                    component.set("v.fieldPicklistMap", fieldsMetaDataWrp.recPicklistMap);
                    component.set("v.depPicklistMap", fieldsMetaDataWrp.depPicklistMap);  
                    component.set("v.eFormFieldRule", fieldsMetaDataWrp.fieldRule);
                    component.set("v.fieldsMetaData", fieldsMetaDataWrp.cdnFormTemplate); 
                    component.set("v.salesDocType", fieldsMetaDataWrp.cdnFormSalesDocType); 
                    component.set("v.taxEndUse", fieldsMetaDataWrp.cdnFormTaxEndUse);
                    component.set('v.selectedMaterial',fieldsMetaDataWrp.material);
                    component.set("v.recordEditAccess", fieldsMetaDataWrp.recordEditAccess);
                    
                    if(fieldsMetaDataWrp.splitAmountRecs && recId) {
                        component.set('v.splitAmountRecs',fieldsMetaDataWrp.splitAmountRecs);
                        
                        var sumAmount = component.get('v.sumAmount');
                        if(!sumAmount)
                            sumAmount = 0;
                        
                        // set sales org for ANZ
                        for(var key in fieldsMetaDataWrp.splitAmountRecs)
                            sumAmount = sumAmount+ fieldsMetaDataWrp.splitAmountRecs[key].CDM_Sub_Net_Amount__c;
                        
                        component.set('v.sumAmount',sumAmount);
                        component.set('v.splitAmount',true);
                    } else {
                        
                        component.set('v.splitAmount',true);
                    }
                    if(recId) {
                        component.set("v.viewRecord", true);
                        
                    }else
                        component.set("v.viewRecord", false);
                  
                     $A.util.addClass(spinner, 'slds-hide');
                   
                    
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    

    
})