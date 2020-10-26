/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 15-APR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Case On Timer
 * Modifications  : 15-APR-2020 SYAP - Initial
 ****************************************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import query from '@salesforce/apex/GCM_Query.query';
import USER_ID from '@salesforce/user/Id'; 

export default class gcm_Case_On_Timer extends LightningElement {
    // Declarations
    @track caseNumber = null;
    @track startTime = null;

    // Error Handler
    handleError(error) {
        // Error Handler
        this.error = 'Unknown Error';
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }        
        console.log(this.error);
    }

    // Component Inserted Into DOM Event Handler
    connectedCallback() {
        // Check For Missing User Information
        query({'recordId' : USER_ID, 'soql' : 'select CreatedDate, GCM_Case__r.CaseNumber from GCM_Case_Duration__c where GCM_End_Time__c = null and OwnerId = \'{!Id}\' limit 1'})
        .then(result => {
            var data = result;
            if (data.length > 0) {
                this.caseNumber = data[0].GCM_Case__r.CaseNumber;
                this.startTime = data[0].CreatedDate;
            }
            else {
                this.caseNumber = null;
                this.startTime = null;
            }
        })
        .catch(error => {
            this.handleError(error);
            return;
        });
    }
}