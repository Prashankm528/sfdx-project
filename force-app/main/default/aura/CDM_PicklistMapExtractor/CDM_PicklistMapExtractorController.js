({
    /** doInit System Event **/
    doInit: function(component, event, helper) {
       
        event.stopPropagation();
        var key = component.get("v.key");
        var value = component.get("v.value");
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
        var recPicklistMap = new Map();
        recPicklistMap = component.get("v.recPicklistMap");
        var depPicklistMap = component.get("v.depPicklistMap");
        var picklists = component.get("v.recPicklistMap");
        console.log('Picklists :' +JSON.stringify(picklists));
        
        var country = component.get("v.country");
               
        if (depPicklistMap && value.CDM_Controlling_Field__c)
            if (fieldsMetaDatamap[value.CDM_Controlling_Field__c])
                if (fieldsMetaDatamap[value.CDM_Controlling_Field__c].Fieldvalue) {
                    for (var k in depPicklistMap[value.CDM_Target_Field__c])
                        if (k == fieldsMetaDatamap[value.CDM_Controlling_Field__c].Fieldvalue) {
                            component.set(
                                "v.Optvalues",
                                depPicklistMap[value.CDM_Target_Field__c][
                                    fieldsMetaDatamap[value.CDM_Controlling_Field__c].Fieldvalue
                                ]
                            );
                            return null;
                        }
                }
        if (country) {
           
            for (var k in fieldsMetaDatamap) {
               if(fieldsMetaDatamap[k])
                if (
                    fieldsMetaDatamap[k].ControllingField &&
                    value.CDM_Target_Field__c == k
                ) {
                   
                    component.set("v.Optvalues", depPicklistMap[k][country]);
                    return null;
                }
            }
        }
      //  console.log(key)
       // console.log('recPicklistMap'+JSON.stringify(recPicklistMap));
        
        if (recPicklistMap) {
            if(key == 'CurrencyIsoCode' && (country == 'Australia' || country == 'New Zealand')) 
                component.set("v.Optvalues", $A.get("$Label.c.CDM_ANZ_Currencys").split(';'));
            else                
                component.set("v.Optvalues", recPicklistMap[key]);
          
            if(value) {
                if(country == 'Netherlands' && (value.CDM_DefaultValue__c == null || value.CDM_DefaultValue__c == '')){
                    value.CDM_DefaultValue__c = 'M-Manual Bank Transfer';
                    fieldsMetaDatamap[value.CDM_Target_Field__c].Fieldvalue = 'M-Manual Bank Transfer';
                    component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);
                    /*value.CDM_DefaultValue__c = '';
                    fieldsMetaDatamap[value.CDM_Target_Field__c].Fieldvalue = '';
                    component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);*/
                }
           }
        }
        //var optvalue = component.get("v.Optvalues");
        //console.log('optvalue :'+optvalue);
       
        component.set('v.value',value);
            
    },
    /** get data from user input  **/
    getData: function(component, event, helper) {
        var eventId = event.getSource();
        var recData = component.get("v.value");
        var fieldLabel = eventId.get("v.label");
        var fieldName = recData.CDM_Target_Field__c;
        var fieldValue = eventId.get("v.value");
        var taxEndUse = component.get('v.taxEndUse');
        var fieldsMetaDatamap = component.get("v.fieldsMetaDatamap");
         var salesDocTypeVal = component.get('v.salesDocTypeVal');
        console.log('fieldLabel'+fieldLabel);
        console.log('taxEndUse'+JSON.stringify(taxEndUse));
         if(fieldValue && fieldValue!= '') {
            if(fieldLabel == 'Distribution Channel') {
                var fVals = fieldValue.split(" ");
                if(fVals.length>=1) {
                    var channelCode = fVals[0].trim();
                    component.set('v.channelCode',channelCode);
        			fieldsMetaDatamap['CDM_ChannelCode__c'].Fieldvalue = channelCode;
                     console.log('channelCode==+'+channelCode);
                      if(salesDocTypeVal == 'ZNOI') { // hide tax end use field
                        if(channelCode != '06' && channelCode != '07') 
                            component.set('v.taxEndUseflg',false);
                         else
                             component.set('v.taxEndUseflg',true);
                    }   else
                             component.set('v.taxEndUseflg',true);
                    if(channelCode && taxEndUse) {
                        console.log('channelCode==+'+channelCode);
                         console.log('channelCode==+'+JSON.stringify(taxEndUse));
                        console.log('channelCode==+'+JSON.stringify(taxEndUse[channelCode]));
                        component.set('v.taxEndUseOpts',taxEndUse[channelCode]);
                    }
                   // component.set('v.channelCode',fVals[0].trim());
                }
               fieldsMetaDatamap[fieldName].Fieldvalue = fVals[0].trim(); 
            } else {
            fieldsMetaDatamap[fieldName].Fieldvalue = fieldValue;
            }
         }
        
        if (recData.Name == "Country" && fieldValue) {
            component.set("v.country", fieldValue);
            var cmpEvent = component.getEvent("CDM_setDependentPicklist");
            if (cmpEvent) {
                cmpEvent.setParams({ controlleringField: recData.CDM_Target_Field__c });
                cmpEvent.fire();
            }
        }
         if (recData.Name == "Company Code" && fieldValue) {
              component.set("v.companyCode", fieldValue);
         }
        if(fieldsMetaDatamap && fieldValue) {
            fieldsMetaDatamap[fieldName].Fieldvalue = fieldValue;
            component.set("v.fieldsMetaDatamap", fieldsMetaDatamap);
        }
        
         if (recData.Name == "Bulk Upload" && fieldValue) {
              component.set("v.parentCDMFlg", fieldValue);
         }  //Bulk_Upload
        
        //parentCDMFlg
        if (recData.Name == "Split Required") {
             var cmpEvent = component.getEvent("CDM_AmountSplitEvt");
            if (fieldValue == "Yes") {
                component.set("v.splitAmount", true);
                component.set('v.splitRequired','Yes');
          		cmpEvent.setParams({ splitAmount: true });
                cmpEvent.fire();
             }else {
                component.set("v.splitAmount", false);
                component.set('v.splitRequired',fieldValue);
                cmpEvent.setParams({ splitAmount: false });
                cmpEvent.fire();
            }
          }
        
        var cmpEvent = component.getEvent("CDM_ShowHideEvent");  //depParent
        if (cmpEvent) {
            cmpEvent.setParams({ depParent: fieldName,
                                depParentValue:fieldValue});
            cmpEvent.fire();
            
        }
    },
   /** if split required, than call event to cdm form component  **/ 
    splitRequired: function(component, event, helper) {
        var recData = component.get("v.value");
     
        if (recData.Name == "Split Required") {
         
           // var splitAmount = component.get("v.splitAmount");
          
            var cmpEvent = component.getEvent("CDM_AmountSplitEvt");
            //if (splitAmount) {
                if (cmpEvent) {
                    cmpEvent.setParams({ splitAmount: true });
                    cmpEvent.fire();
                }
            //}
        }
    }
});