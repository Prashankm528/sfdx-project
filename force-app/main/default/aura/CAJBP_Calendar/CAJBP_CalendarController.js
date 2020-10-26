({
    doInit: function(component, event, helper) {
        helper.getJbpActivities(component);
    },

    destroy: function (component, event, helper) {
        const cmp = event.getParam('value');
        const calendarInstance = cmp.get('v.calendarInstance');

        if (calendarInstance) {
            calendarInstance.destroy();
        }
    },

    handleLayoutToggle: function (component, event, helper) {
        //helper.observeCalendar(component);
    },

    calendarDataOptions : function(component,event,helper)
    {
        var option = event.getParam('option');
        var paidBy = event.getParam('paidBy');
        var type = event.getParam('type');
        var ownership = event.getParam('ownership');
        var jbpId = event.getParam('jbpId');
        var jbpIdObjectType = event.getParam('jbpIdObjectType');
        var ownerName = event.getParam('ownerName');
        var country = event.getParam('country');
        var countryObjectType = event.getParam('countryObjectType');
        var ownerObjectType = event.getParam('ownerObjectType');
        let activityList = component.get('v.activityList');

        if(paidBy.length > 0 || type.length > 0 || option.length > 0 || ownership.length > 0 || jbpId != 'Select' || country != 'Select' || ownerName != 'Select')
        {
            if(paidBy.length > 0)
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return paidBy.includes(item.extendedProps.paidBy);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return paidBy.includes(item.extendedProps.paidBy);
                    }
                    else
                    {
                        return item;
                    }

                });
            }

            if(type.length > 0)
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return type.includes(item.extendedProps.type);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return type.includes(item.extendedProps.type);
                    }
                    else
                    {
                        return item;
                    }
                });
            }

            if(ownership.length > 0)
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return ownership.includes(item.extendedProps.ownership);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return ownership.includes(item.extendedProps.ownership);
                    }
                    else
                    {
                        return item;
                    }

                });
            }

            if(option.length > 0)
            {
                activityList = activityList.filter(function(item)
                {
                    if(type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && jbpId == 'Select' && country == 'Select' && ownerName == 'Select')
                    {
                        return option.includes(item.extendedProps.objectType);
                    }
                    //jbpId Start
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && jbpId != 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (jbpId + option[0]).includes(item.extendedProps.jbpIdObjectType) || (jbpId + option[1]).includes(item.extendedProps.jbpIdObjectType);
                        }
                        else {
                            return (jbpId + option).includes(item.extendedProps.jbpIdObjectType);
                        }
                    }
                    //This is for the global calendar to ignore the activities
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && jbpId != 'Select') && item.extendedProps.objectType=='Activity')
                    {
                            return option.includes(item.extendedProps.jbpIdObjectType);
                    }
                    else if (((type.length > 0 || paidBy.length || 0 || ownership.length >0) && jbpId != 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (jbpId + option[0]).includes(item.extendedProps.jbpIdObjectType) || (jbpId + option[1]).includes(item.extendedProps.jbpIdObjectType);
                        }
                        else {
                            return (jbpId + option).includes(item.extendedProps.jbpIdObjectType);
                        }
                    }
                    //jbpId End

                    //country Start (country is selected and owner is not selected)
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && country != 'Select' && ownerName == 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (country + option[0]).includes(item.extendedProps.countryObjectType) || (country + option[1]).includes(item.extendedProps.countryObjectType);
                        }
                        else {
                            return (country + option).includes(item.extendedProps.countryObjectType);
                        }
                    }
                    //This is for the global calendar to ignore the activities
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && country != 'Select' && ownerName == 'Select') && item.extendedProps.objectType=='Activity')
                    {
                            return option.includes(item.extendedProps.countryObjectType);
                    }
                    else if (((type.length > 0 || paidBy.length || 0 || ownership.length >0) && country != 'Select' && ownerName == 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (country + option[0]).includes(item.extendedProps.countryObjectType) || (country + option[1]).includes(item.extendedProps.countryObjectType);
                        }
                        else {
                            return (country + option).includes(item.extendedProps.countryObjectType);
                        }
                    }
                    //country End

                    //jbpOwner Start (owner is selected and country is not selected)
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && ownerName != 'Select' && country == 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (ownerName + option[0]).includes(item.extendedProps.ownerObjectType) || (ownerName + option[1]).includes(item.extendedProps.ownerObjectType);
                        }
                        else {
                            return (ownerName + option).includes(item.extendedProps.ownerObjectType);
                        }
                    }
                    //This is for the global calendar to ignore the activities
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && ownerName != 'Select' && country == 'Select') && item.extendedProps.objectType=='Activity')
                    {
                            return option.includes(item.extendedProps.ownerObjectType);
                    }
                    else if (((type.length > 0 || paidBy.length || 0 || ownership.length >0) && ownerName != 'Select' && country == 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return (ownerName + option[0]).includes(item.extendedProps.ownerObjectType) || (ownerName + option[1]).includes(item.extendedProps.ownerObjectType);
                        }
                        else {
                            return (ownerName + option).includes(item.extendedProps.ownerObjectType);
                        }
                    }
                    //jbpOwner End

                    //(owner and country are selected)
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && ownerName != 'Select' && country != 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return ((ownerName + option[0]).includes(item.extendedProps.ownerObjectType) || (ownerName + option[1]).includes(item.extendedProps.ownerObjectType)) && ((country + option[0]).includes(item.extendedProps.countryObjectType) || (country + option[1]).includes(item.extendedProps.countryObjectType));
                        }
                        else {
                            return (ownerName + option).includes(item.extendedProps.ownerObjectType) && (country + option).includes(item.extendedProps.countryObjectType);
                        }
                    }
                    //This is for the global calendar to ignore the activities
                    else if ((type.length <= 0 && paidBy.length <= 0 && ownership.length <=0 && ownerName != 'Select' && country != 'Select') && item.extendedProps.objectType=='Activity')
                    {
                            return option.includes(item.extendedProps.ownerObjectType);
                    }
                    else if (((type.length > 0 || paidBy.length || 0 || ownership.length >0) && ownerName != 'Select' && country != 'Select') && item.extendedProps.objectType!='Activity')
                    {
                        if(option.length > 1){
                            return ((ownerName + option[0]).includes(item.extendedProps.ownerObjectType) || (ownerName + option[1]).includes(item.extendedProps.ownerObjectType)) && ((country + option[0]).includes(item.extendedProps.countryObjectType) || (country + option[1]).includes(item.extendedProps.countryObjectType));
                        }
                        else {
                            return (ownerName + option).includes(item.extendedProps.ownerObjectType) && (country + option).includes(item.extendedProps.countryObjectType);
                        }
                    }
                    //jbpOwner End

                    else if ((type.length > 0 || paidBy.length > 0 || ownership.length >0) && item.extendedProps.objectType!='Activity')
                    {
                        return option.includes(item.extendedProps.objectType);
                    }
                    else
                    {
                        return item;
                    }
                });
            }

            if(jbpId != 'Select')
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return jbpId.includes(item.extendedProps.jbpId);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return jbpId.includes(item.extendedProps.jbpId);
                    }
                    else
                    {
                        return item;
                    }

                });
            }

            if(ownerName.length > 0 && ownerName != 'Select')
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return ownerName.includes(item.extendedProps.ownerName);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return ownerName.includes(item.extendedProps.ownerName);
                    }
                    else
                    {
                        return item;
                    }

                });
            }

            if(country != 'Select')
            {
                activityList = activityList.filter(function(item)
                {
                    if(option.length <= 0)
                    {
                        return country.includes(item.extendedProps.country);
                    }
                    else if (option.length > 0 && item.extendedProps.objectType=='Activity')
                    {
                        return country.includes(item.extendedProps.country);
                    }
                    else
                    {
                        return item;
                    }

                });
            }
        }

        helper.setCalendar(component,activityList);
    },

    displayFilter: function(component)
    {
        component.set("v.showFilter",!component.get("v.showFilter"));
    }
})