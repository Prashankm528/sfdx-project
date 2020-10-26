import { LightningElement, wire, track } from 'lwc';
import fetchAccPrefrenceValue from '@salesforce/apex/ISTCP_UserPreferenceController.fetchAccPrefrenceValue';
import saveAccNotificationInfo from '@salesforce/apex/ISTCP_UserPreferenceController.saveAccNotificationInfo';
import {
    getRecord
} from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
 
export default class Istcp_userNotificationPreference extends LightningElement {

    @track selectedAccValue;
    @track selectedSysValue;
    @track selectedBpValue;

    @track error;
    @track email; 
    @track name;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            this.email = data.fields.Email.value;
            this.name = data.fields.Name.value;
        }
    }

    get options() {
        console.log('selectedvalueinoption: ' + this.selectedAccValue);
        return [
            { label: 'Portal and email', value: 'Account - Portal and email' },
            { label: 'Portal only', value: 'Account - Portal only' },
        ];
    }

    get sysoptions() {
        return [
            { label: 'Portal and email', value: 'System - Portal and email' },
            { label: 'Portal only', value: 'System - Portal only'},
        ];
    }
    
    get bpAnnouncementoptions() {
        return [
            { label: 'Portal and email', value: 'BP - Portal and email' },
            { label: 'Portal only', value: 'BP - Portal only' },
            { label: 'None', value: 'None' },
        ];
    }

    @wire(fetchAccPrefrenceValue) 
    Listpreferences({data,error}) {
        if(data){
            for(var i = 0; i<data.length; i++) {
                this.selectedAccValue = (data[i].ISTCP_Account_Notification_Preferences__c.length == 0) ? undefined : "Account - " + data[i].ISTCP_Account_Notification_Preferences__c;
                this.selectedSysValue = (data[i].ISTCP_System_Notification_Preferences__c.length == 0) ? undefined : "System - " + data[i].ISTCP_System_Notification_Preferences__c;
                this.selectedBpValue = (data[i].ISTCP_BP_Announcements_Notifications__c.length == 0) ? undefined : "BP - " + data[i].ISTCP_BP_Announcements_Notifications__c;
            }
        } else {
            window.console.log(error);
        }
    }

    handleSelected(event){
        this.selectedAccValue = event.target.value;
        saveAccNotificationInfo({ preference: this.selectedAccValue, source: 'AccNotification'})
        .then(result => {
            window.console.log('result ====> ' +result);
        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
        });
    }

    handleSystemSelected(event){
        this.selectedSysValue = event.target.value;
        console.log('sysselectedvalue:' + this.selectedSysValue);
        saveAccNotificationInfo({ preference: this.selectedSysValue, source: 'SysNotification'})
        .then(result => {
            window.console.log('result ====> ' +result);
        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
        });
    }

    handleBpSelected(event){
        this.selectedBpValue = event.target.value;
        console.log('bpselectedvalue:' + this.selectedBpValue);
        saveAccNotificationInfo({ preference: this.selectedBpValue, source: 'BPNotification'})
        .then(result => {
            window.console.log('result ====> ' +result);
        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
        });
    }
}