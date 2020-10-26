/**
 * @author			Venkatesh Muniyasamy
 * @date			24/04/2020
 * @group			CAJBP
 * @description		Validate whether the latest scorecard values are entered.
 *
 * history
 * 24/04/2020 	Venkatesh Muniyasamy	Created
 */
({
    checkYTDMonth : function(component)
    {
        let months    = ['January','February','March','April','May','June','July','August','September','October','November','December'];
        let currentDate = new Date();
        let ytdMonth = months[currentDate.getMonth()-1];
        var apexProvider = component.find('apexProvider');
        var action = component.get('c.confirmYTDMonth');

        apexProvider.execute(action, {jbpId: component.get('v.recordId')}, function(error, result)
        {

            if (error) {
                console.error(error.message);
            } else {

            if(result)
                    {
                        component.set('v.showYTDConfirm', true);
                    }
            }
        });
        component.set("v.ytdMonth",ytdMonth);
    },

    updateYTDMonth : function(component)
    {
        var apexProvider = component.find('apexProvider');
        var action = component.get('c.updateYTDMonth');
        apexProvider.execute(action, {jbpId: component.get('v.recordId')}, function(error, result)
        {

            if (error) {
                console.error(error.message);
            } else {

            if(result)
                    {
                        console.log('YTD Month Record Saved');
                        var showToast = $A.get("e.force:showToast");
                        showToast.setParams({
                            "title": "Success!",
                            "message": "YTD Month has been updated successfully.",
                            "type": "success"
                        });
                        showToast.fire();

                        $A.get('e.c:CAJBP_RefreshScorecardEvent').fire();
                    }
            }
        });
    }
})