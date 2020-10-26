/****************************************************************************************************
 *  Date          : 13-APR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for My Cases Lightning Web Component
 * Modifications  : 13-APR-2020 SYAP - Initial
 ****************************************************************************************************/
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import query from '@salesforce/apex/GCM_Query.query';
import USER_ID from '@salesforce/user/Id';

export default class gcm_My_Approved_Cases extends NavigationMixin(LightningElement) {
    // Declarations
    @api recordId;
    @track cases = [];
    @track allCases = [];
    @track pageCurrent = 0;
    @track pageSize = 0;
    @track recordsPerPage = 3;
    @track substatusvalue;   
    @track recordData;
    @track mapData;
    @track dataArray = [];
    @track processedArray = [];

    handlePage(event) {
        var increment = event.target.value;
        if (increment > 0) {
            if (this.pageCurrent < this.pageSize) {
                this.pageCurrent++;
            }
        }
        else if (increment < 0) {
            if (this.pageCurrent > 0) this.pageCurrent--;
        }

        // Repopulate Array Displayed On Page
        var lowerLimit = this.pageCurrent * this.recordsPerPage;
        this.cases = [];
        for (var count = 0; count < this.recordsPerPage; count++) {
            if (lowerLimit + count < this.allCases.length) {
                this.cases[count] = this.allCases[lowerLimit + count];
                this.cases[count].showBorder = count > 0;
            }
        }
    }

  
    // Event Handler After Component Rendered
    connectedCallback() {
        this.pageCurrent = 0;
        query({
            'recordId' : USER_ID,
            'soql' : 'select Id, CaseNumber, AccountId, Account.Name, Due__c, Type, Area__c, Sub_Area__c, Status,Sub_Status__c from Case where OwnerId = \'{!Id}\' and Status != \'Closed\' and Status != \'Cancelled\' and (Sub_Status__c = \'Pending - Int Approval\' or Sub_Status__c = \'Approved\') order by Due__c asc limit 20'
        })
        .then(result => {
            this.pageSize = 0;
            this.pageCurrent = 0;            
               
            if (result.length > 0) {
                this.allCases = result;
                       
                
                this.pageSize = Math.floor((this.allCases.length - 1) / this.recordsPerPage);
                var upperLimit = this.allCases.length > this.recordsPerPage ? this.recordsPerPage : this.allCases.length;
                this.cases = [];
                for (var count = 0; count < upperLimit; count++) {
                    this.cases[count] = this.allCases[count];
                    this.cases[count].showBorder = count > 0;
                }
            }
        })
        .catch(error => {
            this.error = error;
        });
    }  

    // Navigate Link
    handleNavigateCase(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Case',
                actionName: 'view',
            },
        });
    }

    // Navigate Link Account
    handleNavigateAccount(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }
}