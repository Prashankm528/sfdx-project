/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 06-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for Email Sender
 * Modifications  : 06-MAR-2020 SYAP - Initial
 ****************************************************************************************************/
import {LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import query from '@salesforce/apex/GCM_Query.query';
import updateRecord from '@salesforce/apex/GCM_Update_Record.updateRecord';
import USER_ID from '@salesforce/user/Id'; 

export default class gcm_Email_Sender extends LightningElement {
    // Declarations
    @api recordId;
    @track items = []; // Combo Box Key Value Pair
    @track value = ''; // Initialise Combo Box Value
    @track chosenValue = '';
    @track userTeam = '';
    @track emailList = []; // List Of Emails In Dropdown - Used For Validation
    @track visible = false;

    // Combo Box Options Getter
    get options() {
        return this.items;
    }

    // Save Value Chosen In Combo Box
    handleChange(event) {
        this.chosenValue = event.detail.value;
        this.saveEmailSender(false);
    }

    // Get User Default Sender Email
    getDefaultSenderEmail() {
        var soql = 'select GCM_Target__c from GCM_Data_Map__mdt where GCM_Active__c = true and GCM_Type__c = \'EmailSenderDefault\' and GCM_Source__c = \'' + this.userTeam + '\'';
        query({'recordId' : '', 'soql' : soql})
        .then(result => {
            if (result) {
                if (result.length === 1) {
                    this.chosenValue = result[0].GCM_Target__c;
                    this.saveEmailSender(true);
                }
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    // Get Case Default Sender Email
    getCaseSenderEmail() {
        query({'recordId' : this.recordId, 'soql' : 'select GCM_Mailbox_Reference__c from Case where Id = \'{!Id}\''})
        .then(result => {
            if (result) {
                if (result.length === 1) {
                    var caseSenderEmail = result[0].GCM_Mailbox_Reference__c;
                    if (caseSenderEmail) {
                        if (this.emailList.includes(caseSenderEmail)) {
                            this.chosenValue = caseSenderEmail;
                            this.saveEmailSender(true);
                        }
                        else {
                            this.getDefaultSenderEmail();    
                        }
                    }
                    else {
                        this.getDefaultSenderEmail();
                    }
                }
                else {
                    console.log('Unexpected Error: Case Not Found, Id =' + recordId);                    
                }
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    // Get Sender Email List Displayed In Dropdown
    getSenderEmailList() {
        // Populate Email Dropdown
        var soql = 'select GCM_Target__c from GCM_Data_Map__mdt where GCM_Type__c = \'EmailSender\' and GCM_Active__c = true and GCM_Source__c = \'' + this.userTeam + '\' order by GCM_Target__c';
        query({'recordId' : '', 'soql' : soql})
        .then(result => {
            var data = result;
            for(var count = 0; count < data.length; count++)  {
                this.items = this.items.concat([{label: data[count].GCM_Target__c, value: data[count].GCM_Target__c}]);
                this.emailList.push(data[count].GCM_Target__c);
            }
            this.getCaseSenderEmail();
        })
        .catch(error => {
            console.log(error);
        });
    }

    // Component Inserted Into DOM Event Handler
    connectedCallback() {
        query({'recordId' : USER_ID, 'soql' : 'select GCM_User_Team__c, GCM_Sender_Email__c from User where Id = \'{!Id}\''})
        .then(result => {
            if (result) {
                if (result.length === 1) {
                    if (result[0].GCM_Sender_Email__c) {
                        this.userTeam = result[0].GCM_User_Team__c;
                        this.getSenderEmailList();
                        this.visible = true;
                    }
                }
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    // Show Toast Message
    // type = error, warning, success, other
    showToastMessage(titleText, messageText, variantText) {
        const event = new ShowToastEvent({
            title : titleText,
            message : messageText,
            variant : variantText,
            mode : 'dismissable'            
        });
        this.dispatchEvent(event);
    }

    // User Requested Save Email Sender
    saveEmailSenderByUser() {
        this.saveEmailSender(false);
    }

    // Invoke Apex Class
    saveEmailSender(silent) {
        // AJAX Call - Update Record
        var fieldMap = {
            'GCM_Sender_Email__c' : this.chosenValue
        }
        updateRecord({'recordId' : USER_ID, 'fieldMap' : fieldMap, 'throwException' : true})
        .then(result => {
            // Do Nothing
            // No Return Value
            if (!silent) {
                this.showToastMessage('', 'Sender Email Address Set', 'success');
            }
        })
        .catch(error => {
            console.log(error);
            // Display Error Message
            message.innerHTML = error;
        });
    }
}