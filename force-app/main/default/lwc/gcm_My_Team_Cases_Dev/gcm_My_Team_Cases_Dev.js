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
import gcmRedFlag from '@salesforce/resourceUrl/GCMRedFlag';
import gcmYellowFlag from '@salesforce/resourceUrl/GCMYelloFlag';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class gcm_My_Cases extends NavigationMixin(LightningElement) {
    // Declarations
    usertimezone = TIME_ZONE;
    @api recordId;
    @track cases = [];
    @track allCases = [];
    @track pageCurrent = 0;
    @track pageSize = 0;
    @track recordsPerPage = 5;
    @track myTeamCasesListViewId;
    @track todayMinusDueDate=0;
    redFlag=gcmRedFlag;
    yellowFlag =gcmYellowFlag;

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
            'soql' : 'select Id, CaseNumber, Owner.Name, AccountId, Account.Name, Due__c, Type, Area__c, Sub_Area__c, Status,Sub_Status__c,GCM_Case_Channel__c,GCM_Service_Level_Priority__c,Due_Date_Difference__c,LastModifiedDate from Case where Due__c!=null and GCM_My_Team__c=true and Status != \'Closed\' and Status != \'Cancelled\' order by Due__c,createdDate asc limit 15'
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
                    var currentCase=this.cases[count];
                    currentCase.slaMissed=false;
                    currentCase.nearingSla=false;

                    if(this.allCases[count].Due_Date_Difference__c<0){
                        //SLA Missed
                        currentCase.slaMissed=true;
                        currentCase.slaNearingPercent=0;
                    }else{
                        var dateDiff=Math.abs(currentCase.Due_Date_Difference__c);                       
                        if(dateDiff>3 && dateDiff<=4){
                            currentCase.nearingSla=true;
                            currentCase.slaNearingPercent=20;
                        }else if(dateDiff>2 && dateDiff<=3){
                            currentCase.nearingSla=true;
                            currentCase.slaNearingPercent=40;
                        }else if(dateDiff>1 && dateDiff<=2){
                            currentCase.nearingSla=true;
                            currentCase.slaNearingPercent=60;
                        }else if(dateDiff>0.5 && dateDiff<=1){
                            currentCase.nearingSla=true;
                            currentCase.slaNearingPercent=80;
                        }else if(dateDiff>=0 && dateDiff<=0.5){
                            currentCase.nearingSla=true;
                            currentCase.slaNearingPercent=90;
                        }
                    }
                }
            }
        })
        .catch(error => {
            this.error = error;
        });

        //My Team's Cases ListViewName //new###
       var myTeamCasesListViewQuery = 'select id,Name from ListView WHERE SobjectType=\'Case\' AND name=\'My Teams Cases\'';
       query({'recordId' : USER_ID, 'soql' : myTeamCasesListViewQuery})
       .then(result => {
           console.log('result--->', result);
           this.myTeamCasesListViewId = result[0].Id;
        })
       .catch(error => {
            this.error=error;
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

    // Navigation to List View of All open cases //new###
    navigateToMyTeamCasesListView(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: this.myTeamCasesListViewId
            },
        });
    }
}