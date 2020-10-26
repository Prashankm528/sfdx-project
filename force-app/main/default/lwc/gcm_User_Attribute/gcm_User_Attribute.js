/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 09-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for User Attribute Form
 * Modifications  : 09-MAR-2020 SYAP - Initial
 ****************************************************************************************************/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import query from '@salesforce/apex/GCM_Query.query';
import getValueSet from '@salesforce/apex/GCM_Query.getValueSet';
import updateRecord from '@salesforce/apex/GCM_Update_Record.updateRecord';
import USER_ID from '@salesforce/user/Id'; 

export default class gcm_User_Attribute extends LightningElement {
    // Declarations
    @track organisation = []; // Combo Box Key Value Pair
    @track business = []; // Combo Box Key Value Pair
    @track manager = []; // Combo Box Key Value Pair
    @track team = []; // Combo Box Key Value Pair
    @track chosenOrganisation = '';
    @track chosenBusiness = '';
    @track chosenBusinesses = [];
    @track chosenBusinessLabels = [];    
    @track chosenManager = '';
    @track chosenTeam = '';
    @track userRoleId = '';
    @track visible = false;
    @track callCenterId = null;
    @track callCenter = false;
    @track optionsManager = [];
    @track optionsManagerAll = [];
    @track optionsManagerVisible = false;
    @track chosenManagerId = null;
    @track chosenManagerName = null;
    @track profileName = null;

    // Save Sales Organisation Value Chosen In Combo Box
    handleChangeOrganisation(event) {
        this.chosenOrganisation = event.detail.value;
    }

    // Add Business Unit Value Chosen
    handleAddBusiness(event) {
        var value = event.detail.value;
        if (!value) return;
        var result = this.chosenBusinesses.find(item => {return item === value});
        if (typeof result === 'undefined') {
            this.chosenBusinesses.push(value);
        }
    }

    // Remove Business Unit Value Clicked
    handleRemoveBusiness(event) {
        var value = event.target.value;
        if (!value) return;
        this.chosenBusinesses = this.chosenBusinesses.filter(item => {return item !== value});
    }

    // Save Team Value Chosen In Combo Box
    handleChangeTeam(event) {
        this.chosenTeam = event.detail.value;
    }

    // Filter Manager Pick List
    handleSearchManager(event) {
        this.optionsManager = [];
        this.optionsManagerVisible = false;
        if (!event.detail.value) {
            this.chosenManagerId = null;
            this.chosenManagerName = null;
            return;
        }
        for (var count = 0; count < this.optionsManagerAll.length; count++) {
            if (this.optionsManagerAll[count].Name.includes(event.detail.value)) {
                this.optionsManager.push(this.optionsManagerAll[count]);
                this.optionsManagerVisible = true;
                
                // Limit 10 Options
                if (this.optionsManager.length === 10) return;
            }
        }
    }

    // Handle Select Manager
    handleSelectManager(event) {
        if (!event.target.value) return;
        this.chosenManagerId = event.target.value;
        this.chosenManagerName = event.target.label;
        this.optionsManager = [];
        this.optionsManagerVisible = false;
    }
    // Handle Call Center Check Box Event
    handleChangeCallCenter(event) {
        this.callCenter = event.target.checked;
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

    // Query Value Sets
    getValueSets() {
        // Get Sales Organisation Value Set
        getValueSet({'objectName' : 'User', 'fieldName' : 'Sales_Organisation__c'})
        .then(result => {
            var data = result;
            console.log('result length - sales org: '+result.length);
            for (var count = 0; count < data.length; count++)  {
                console.log('data['+count+']: '+data[count].Value);
                this.organisation = this.organisation.concat([{label: data[count].Label, value: data[count].Value}]);
            }
        })
        .catch(error => {
            console.log(error);
        });

        // Get Business Unit Value Set
        getValueSet({'objectName' : 'User', 'fieldName' : 'Business_Unit__c'})
        .then(result => {
            var data = result;
            for (var count = 0; count < data.length; count++)  {
                this.business = this.business.concat([{label: data[count].Label, value: data[count].Value}]);
            }
        })
        .catch(error => {
            console.log(error);
        });

        // Get Team Name
        getValueSet({'objectName' : 'User', 'fieldName' : 'GCM_User_Team__c'})
        .then(result => {
            var data = result;
            for (var count = 0; count < data.length; count++)  {
                this.team = this.team.concat([{label: data[count].Label, value: data[count].Value}]);
            }
        })
        .catch(error => {
            console.log(error);
        });

        // Query Call Center
        query({'recordId' : '', 'soql' : 'select Id from CallCenter where Name = \'SoftphoneCTI\' limit 1'})
        .then(result => {
            if (result.length === 1) {
                this.callCenterId = result[0].Id;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    // Component Inserted Into DOM Event Handler
    connectedCallback() {
        // Check For Missing User Information
        query({'recordId' : '', 'soql' : 'select Id, ManagerId, Manager.Name, Sales_Organisation__c, Business_Unit__c, GCM_User_Team__c, UserRoleId, CallCenterId, Profile.Name from User where Id = \'' + USER_ID + '\' and (Sales_Organisation__c = null or Business_Unit__c = null or GCM_User_Team__c = null or ManagerId = null)'})
        .then(result => {
            var data = result;
            console.log('connected callback result**************************************'+data);
            if (data.length > 0) {
                this.visible = true;
                this.chosenOrganisation = data[0].Sales_Organisation__c;
                this.chosenBusiness = data[0].Business_Unit__c;
                if (this.chosenBusiness) {
                    this.chosenBusinesses = this.chosenBusiness.split(';');
                }
                this.chosenTeam = data[0].GCM_User_Team__c;
                this.chosenManagerId = data[0].ManagerId;
                if(this.chosenManagerId) this.chosenManagerName = data[0].Manager.Name;
                if (data[0].CallCenterId) this.callCenter = true;
                this.userRoleId = data[0].UserRoleId;
                this.profileName = data[0].Profile.Name;

                if (this.chosenOrganisation && this.chosenBusiness && this.chosenTeam) {
                    if (this.profileName.includes('CSR')) {
                        if (this.chosenManagerId) return;
                    }
                }
                

                // Get Manager Value Set
                // Users In Same Center Share Common Role
                query({'recordId' : '', 'soql' : 'select Id, Name from User where UserRoleId = \'' + this.userRoleId + '\' and IsActive = true order by Name'})
                .then(resultManager => {
                    this.optionsManagerAll = resultManager;
                })
                .catch(error => {
                    console.log(error);
                });

                console.log('aconnecteCallback called');
                this.getValueSets();
                //return;
            }
        })
        .catch(error => {
            console.log(error);
            //return;
        });

    }

    // Rendered Callback
    renderedCallback() {
        var checkBoxes = this.template.querySelectorAll('input[type=\'checkbox\']');
        console.log('True' + checkBoxes + ' ' + checkBoxes.length);
        if (checkBoxes.length === 1 && this.callCenter) checkBoxes[0].checked = true;
    }

    // Save User Attributes
    saveUser() {
        // Construct Multi-Value Field Value
        this.chosenBusiness = '';
        if (this.chosenBusinesses.length > 0) {
            this.chosenBusiness = this.chosenBusinesses.join(';');
        }

        // Validate Manager
        var managerSet = true;
        if (this.profileName.includes('CSR')) {
            if (!this.chosenManagerId) managerSet = false;
        }
        console.log('### ' + this.chosenOrganisation + ' ' + this.chosenBusiness + ' ' + this.chosenTeam + ' ' + managerSet);
        // Validate Form Data
        if (!this.chosenOrganisation || !this.chosenBusiness || !this.chosenTeam || !managerSet) {
            this.showToastMessage('', 'Please specify a value for all fields.', 'error');
            return;
        }

        //let message = this.template.querySelector('.gcm_message');

        // AJAX Call - Update Record
        var fieldMap = {
            'Sales_Organisation__c' : this.chosenOrganisation,
            'Business_Unit__c' : this.chosenBusiness,
            'GCM_User_Team__c' : this.chosenTeam,
            'ManagerId' : this.chosenManagerId,
            'CallCenterId' : this.callCenter ? this.callCenterId : null
        }
        updateRecord({'recordId' : USER_ID, 'fieldMap' : fieldMap, 'throwException' : true})
        .then(result => {
            // Do Nothing
            // No Return Value
            console.log(result);
            this.showToastMessage('', 'Record Saved', 'success');
            this.visible = false;
        })
        .catch(error => {
            console.log(error);
            // Display Error Message
            //message.innerHTML = this.error; //need to work on this
        });
    }
}