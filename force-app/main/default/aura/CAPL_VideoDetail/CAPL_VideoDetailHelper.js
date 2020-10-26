({
	fetchVideoDetails : function(component, videoId) {
		var action = component.get("c.fetchVideoDetails");

		console.log('getVideoDetails ');

		action.setParams({"videoId": videoId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var video = response.getReturnValue();

                var createdDate = new Date(video.CreatedDate).getTime();
                video.CreatedDate = createdDate;

                video.RelativeTime = this.timeDifference(component, Date.now(), createdDate);

            	component.set("v.video", video);
            }
        });
        $A.enqueueAction(action);
	},

	fetchAttachedDocumentId : function(component, videoId) {
		var action = component.get("c.fetchAttachedDocumentId");

        action.setParams({"videoId": videoId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var documentId = response.getReturnValue();

                component.set("v.documentId", documentId);
                console.log('documentId -> ' + documentId);

                var myVideo = document.getElementById('videoPlayer');

                function checkLoad() {
                    console.log('myVideo.readyState -> ' + myVideo.readyState);
                    if (myVideo.readyState === 0) {
                        myVideo.load();
                        setTimeout(checkLoad, 5000);
                    } 
                }

                checkLoad();
				
            }
        });
        $A.enqueueAction(action);
	},

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