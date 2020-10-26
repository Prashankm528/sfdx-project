/**
 * @author			Venkatesh Muniyasamy
 * @date			11/12/2019
 * @group			CAJBP
 * @description		Renders JAF fields based on the recordtype choosen.
 *
 * history
 * 11/12/2019	Venkatesh Muniyasamy	    New JAF
 */
({
    cancelJAF: function(component,event,helper)
    {
        $A.get("e.force:closeQuickAction").fire();
    },
    closeJAF: function (component,event,helper)
    {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
})