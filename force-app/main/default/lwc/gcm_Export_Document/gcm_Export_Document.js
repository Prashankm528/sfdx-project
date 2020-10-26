/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 14-FEB-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Generate Document
 * Modifications  : 14-FEB-2020 SYAP - Initial
 ****************************************************************************************************/
import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getDocument from '@salesforce/apex/GCM_Document_Generator.getDocument';
import getTemplates from '@salesforce/apex/GCM_Document_Generator.getTemplates';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
const fields = [CASE_NUMBER];

export default class App extends LightningElement {
    // Declarations
    @api recordId;
    @track items = []; // Combo Box Key Value Pair
    @track value = ''; // Initialise Combo Box Value
    @track chosenValue = '';

    @wire(getRecord, {recordId: '$recordId', fields}) case;

    // Case Number Getter
    get caseNumber() {
        return getFieldValue(this.case.data, CASE_NUMBER);
    }

    // Get Template Names
    @wire(getTemplates)
    wiredTemplates({error, data}) {
        if (data) {
            for(var count = 0; count < data.length; count++)  {
                this.items = this.items.concat([{label: data[count].GCM_Display_Name__c, value: data[count].Name}]);                                   
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.items = undefined;
        }
    }

    // Combo Box Options Getter
    get options() {
        return this.items;
    }

    // Save Value Chosen In Combo Box
    handleChange(event) {
        this.chosenValue = event.detail.value;
    }

    // Invoke Apex Class
    generateDocument() {
        if (this.chosenValue === '') return;
        // Call AJAX
        // Input Arguments In JSON Format
        getDocument({'templateName' : this.chosenValue, 'recordId' : this.recordId})
        .then(result => {
            var sourceHTML = result;
            var source = 'data:application/vnd.ms-word;charset=utf-8,' + encodeURIComponent(sourceHTML);
            var fileDownload = document.createElement("a");
            document.body.appendChild(fileDownload);
            fileDownload.href = source;
            var now = new Date();
            fileDownload.download = this.caseNumber + '_' + now.getTime() + '.doc';
            fileDownload.click();
            document.body.removeChild(fileDownload);
        })
        .catch(error => {
            this.error = error;
        });
    }
}