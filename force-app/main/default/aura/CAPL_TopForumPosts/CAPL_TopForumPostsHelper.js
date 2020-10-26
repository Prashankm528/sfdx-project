({
	timeDifference : function(component, current, previous) {
	    var msPerMinute = 60 * 1000;
	    var msPerHour = msPerMinute * 60;
	    var msPerDay = msPerHour * 24;
	    var msPerMonth = msPerDay * 30;
	    var msPerYear = msPerDay * 365;

	    var elapsed = current - previous;

	    if (elapsed < msPerMinute) {
	        return Math.round(elapsed / 1000) + ' ' + component.get("v.secondsAgo");
	    } else if (elapsed < msPerHour) {
	        if (Math.round(elapsed / msPerMinute) == 1) {
	            return Math.round(elapsed / msPerMinute) + ' ' + component.get("v.minuteAgo");
	        } else {
	            return Math.round(elapsed / msPerMinute) + ' ' + component.get("v.minutesAgo");
	        }
	    } else if (elapsed < msPerDay) {
	        if (Math.round(elapsed / msPerHour) == 1) {
	            return Math.round(elapsed / msPerHour) + ' ' + component.get("v.hourAgo");
	        } else {
	            return Math.round(elapsed / msPerHour) + ' ' + component.get("v.hoursAgo");
	        }
	    } else if (elapsed < msPerMonth) {
	        if (Math.round(elapsed / msPerDay) == 1) {
	            return Math.round(elapsed / msPerDay) + ' ' + component.get("v.dayAgo"); 
	        } else {
	            return Math.round(elapsed / msPerDay) + ' ' + component.get("v.daysAgo");
	        }
	    } else if (elapsed < msPerYear) {
	        if (Math.round(elapsed / msPerMonth) == 1) {
	            return Math.round(elapsed / msPerMonth) + ' ' + component.get("v.monthAgo");
	        } else {
	            return Math.round(elapsed / msPerMonth) + ' ' + component.get("v.monthsAgo"); 
	        }
	    } else {
	        if (Math.round(elapsed / msPerYear) == 1) {
	            return Math.round(elapsed / msPerYear) + ' ' + component.get("v.yearAgo"); 
	        } else {
	            return Math.round(elapsed / msPerYear) + ' ' + component.get("v.yearsAgo");
	        }
	    }
	}
})