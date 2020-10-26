/****************************************************************************************************
 *  Date          : 23-JAN-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Case Timer Web Component
 * Modifications  : 23-JAN-2020 SYAP - Initial
 ****************************************************************************************************/
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable no-console */
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DUE from '@salesforce/schema/Case.Due__c';
import STATUS from '@salesforce/schema/Case.Status';
const fields = [DUE, STATUS];

export default class gcm_Case_Timer extends LightningElement {
    // Declarations
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    // Due Date Getter
    get due() {
        return getFieldValue(this.case.data, DUE);
    }

    // Status Getter
    get status() {
        return getFieldValue(this.case.data, STATUS);
    }

    // Called After Loading The Component
    // Create Callback Function - Invoked Every Second
    renderedCallback() {
        let element = this.template.querySelector(".gcm_text_left");
        let timerElement = this.template.querySelector(".loader");
        var status = this.status;
        if (status !== "Closed" && status !== "Cancelled" && this.due != null) {
            timerElement.style.display = '';
            var countDownDate = new Date(this.due).getTime();
            // Count Down Every Second
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setInterval(function() {
                // Current Timestamp
                var now = new Date().getTime();
        
                // Calculate Time Remaining / Overdue
                var distance = countDownDate - now;

                // Split Time By Days, Hours, Minutes, Seconds
                var days = parseInt(distance / (1000 * 60 * 60 * 24), 10);
                var hours = parseInt((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60), 10);
                var minutes = parseInt((distance % (1000 * 60 * 60)) / (1000 * 60), 10);
                var seconds = parseInt((distance % (1000 * 60)) / 1000, 10);

                if (distance > 0) {
                    // Display Results - Time Remaining
                    var timeRemaining = "";
                    if (days !== 0) timeRemaining += days + " days ";
                    if (hours !== 0) timeRemaining += hours + " hr ";
                    if (minutes !== 0) timeRemaining += minutes + " min ";
                    timeRemaining += seconds + " sec remaining";
                    this.message = timeRemaining;
                    if (typeof element !== "undefined") {
                        element.innerHTML = timeRemaining;
                    }
                }
                if (distance < 0) {
                    // Display Results - Time Overdue
                    var timeOverdue = "";
                    if (days !== 0) timeOverdue += (-days) + " days ";
                    if (hours !== 0) timeOverdue += (-hours) + " hr ";
                    if (minutes !== 0) timeOverdue += (-minutes) + " min ";
                    timeOverdue += (-seconds) + " sec overdue"; 
                    if (typeof element !== "undefined") {
                        element.innerHTML = timeOverdue;
                    }
                }
            }, 1000);
        }
        else if (this.due == null) {
            element.innerHTML = "No milestones to show.";
            timerElement.style.display = 'none';
        }
        else {
            if (typeof element !== "undefined") {
                element.innerHTML = "You completed all the milestones.";
                timerElement.style.display = 'none';
            }
        }
    }
}