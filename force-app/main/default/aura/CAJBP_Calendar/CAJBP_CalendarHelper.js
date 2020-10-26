/**
 * @author			Venkatesh Muniyasamy
 * @date			14/01/2020
 * @group			CAJBP
 * @description		Renders Custom Calendar.
 *
 * history
 * 14/01/2020	Venkatesh Muniyasamy	    Custom Calendar
 * 15/07/2020   Abhinit Kohar               Updated for Global Calendar
 */
({
    /*observeCalendar: function(component, rectX) {
        const lastRectX = rectX || 0;
        const currentRectX = component.find('fullCalendar').getElement().clientWidth;
        const calendar = component.get('v.calendarInstance');
        const self = this;

        calendar.updateSize();

        if (lastRectX != currentRectX) {
            window.setTimeout($A.getCallback(function() {
                self.observeCalendar(component, currentRectX);
            }), 100);
        }
    },*/

    getJbpActivities : function(component) {
        var apexProvider = component.find('apexProvider');
        var action = component.get('c.getData');
        var self = this;

        apexProvider.execute(action, {jbpId : component.get('v.recordId'), allJBPs : component.get('v.AllJBPs')}, function(error, result) {
            if (error) {
                console.log(error.message);
            } else {
                component.set('v.activityList', result.activities);
                self.setCalendar(component, result.activities, result.api_key);
            }
        });
    },

    setCalendar: function (component, result, apiKey) {
        const destroyCalendar = component.get('v.calendarInstance');

        if (destroyCalendar) {
            destroyCalendar.destroy();
        }

        const activities = result.map(function(item) {
            return {
                id: item.id,
                start: item.startDateTime,
                end: item.endDateTime,
                title: item.name,
                allDay: item.allDay,
                borderColor: item.colour,
                backgroundColor: item.colour,
                extendedProps: item.extendedProps
            };
        });

        const calendarInstance = new FullCalendar.Calendar(component.find('fullCalendar').getElement(), {
            schedulerLicenseKey: apiKey,
            plugins: ['dayGrid','timeGrid','list','bootstrap','timeline'],
            views: {
                timelineYear: {
                    slotDuration: {months : 1}
                }
            },
            eventTimeFormat: {
                hour: '2-digit',
                minute: '2-digit',
                meridiem: 'short',
                hour12: false
            },
            nextDayThreshold: '00:00:00',
            defaultView: component.get('v.calendarView'),
            minTime: '08:00:00',
            maxTime: '18:00:00',
            themeSystem: 'bootstrap',
            weekNumbers: true,
            header: {
                left : 'prev,next,today',
                center : 'title',
                right : 'timelineYear,dayGridMonth,timeGridWeek,timeGridDay,listWeek'
            },
            locale: $A.get('$Locale.language'),
            viewSkeletonRender: function() {
                component.set('v.calendarView',calendarInstance.view.type);
            },
            eventMouseEnter: $A.getCallback(function (info) {
               component.set('v.event', info.event);
            }),
            eventRender: $A.getCallback(function(info) {
                info.el.style.cssText += 'height: 27px;';

                var instance = tippy(info.el, {
                    animation: 'perspective',
                    arrow: true,
                    boundary: 'window',
                    ignoreAttributes: true,
                    allowHTML: true,
                    interactive: true,
                    theme: 'event',
                    offset: '0,0',
                    distance: '4',
                    trigger: 'click',
                    zIndex: 9,
                    appendTo: document.body,
                    onShow(instance) {
                        tippy.hideAll({exclude: instance});

                        window.setTimeout(function() {
                            instance.setContent(component.find('template').getElement().innerHTML);
                            var closeBtn = info.el._tippy.popper.getElementsByClassName('event-close')[0];
                            var recordDetail = info.el._tippy.popper.getElementsByClassName('event-title')[0];
                            var objective = info.el._tippy.popper.getElementsByClassName('event-objective')[0];

                            if(recordDetail) {
                                recordDetail.onclick = function(event) {
                                    event.preventDefault();
                                    info.el._tippy.hide();

                                    $A.get('e.force:navigateToSObject').setParams({
                                        'recordId': info.event.id
                                    }).fire();
                                }
                            }

                            if(objective) {
                                objective.onclick = function(event) {
                                    event.preventDefault();
                                    info.el._tippy.hide();

                                    $A.get('e.force:navigateToSObject').setParams({
                                        'recordId': info.event.extendedProps.objectiveId
                                    }).fire();
                                }
                            }

                            if (closeBtn) {
                               closeBtn.onclick = function (event) {
                                   event.preventDefault();
                                   info.el._tippy.hide();
                               };
                            }
                        }, 50);
                    }
                });

                component.set('v.tippy', instance);
            }),
            contentHeight: 500,
            events: activities
        });

        calendarInstance.render();

        component.set('v.calendarInstance', calendarInstance);
        component.set('v.isLoaded', true);

        window.setTimeout($A.getCallback(function() {
            calendarInstance.render();
            calendarInstance.updateSize();
        }), 100);
    }
})