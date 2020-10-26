/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/****************************************************************************************************
 *  Date          : 09-MAR-2020
 *  Author        : Sunny Yap
 *  Description   : Controller for User Profile
 * Modifications  : 09-APR-2020 SYAP - Initial
 ****************************************************************************************************/
import { LightningElement, track } from 'lwc';
import query from '@salesforce/apex/GCM_Query.query';   
import USER_ID from '@salesforce/user/Id'; 

export default class gcm_Manager_Profile extends LightningElement {
    // Declarations
    @track userFirstName = '';
    @track userPictureURL = '';
    @track casesBacklogMyTeam = 0;
    @track emailsAwaitingMyTeam = 0;
    @track casesOverdueMyTeam = 0;
    @track myBacklogCases=0;
    @track isCSRUser=false;
    @track myEmailsAwaiting=0;
    @track isGSYSUser=false;
    @track isGSYSCSRUser=false;
    

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
        // Get Picture
        query({'recordId' : USER_ID, 'soql' : 'select FirstName, FullPhotoUrl, Profile.Name from User where Id = \'{!Id}\''})
        .then(result => {
            var data = result;
            if (data.length > 0) {
                this.userFirstName = data[0].FirstName;
                this.userPictureURL = data[0].FullPhotoUrl;
                if(data[0].Profile.Name==='GCM_Fuels_CSR' || data[0].Profile.Name==='GCM_CMD_CSR' || data[0].Profile.Name==='GCM_AR_CSR' ||  data[0].Profile.Name==='GCM_Credit_CSR' || data[0].Profile.Name==='GCM_Lubes_CSR' || data[0].Profile.Name==='GCM_Chemicals_CSR' || data[0].Profile.Name==='GCM_Cards_CSR' || data[0].Profile.Name==='GCM_MX02_Fuels_Dealer'){
                    this.isCSRUser=true;
                }
                 if( data[0].Profile.Name==='GCM_Lubes_TL_GSYS' || data[0].Profile.Name==='GCM_Fuels_TL_GSYS'){
                    this.isGSYSUser=true;
                }
                 if(data[0].Profile.Name==='GCM_Lubes_CSR_GSYS' || data[0].Profile.Name==='GCM_Fuels_CSR_GSYS'){
                    this.isGSYSCSRUser=true;
                    this.isCSRUser=true;
                    this.isGSYSUser=true;
                }
                /*else if(data[0].Profile.Name==='GCM_Fuels_TL' || data[0].Profile.Name==='GCM_Lubes_TL'|| data[0].Profile.Name==='GCM_MX02_Fuels_Dealer_TL' ){
                    isTLUser=true;
                } */
            }
        })
        .catch(error => {
            this.handleError(error);
        });

        //My Team's Unread Emails //new###
        var emailsAwaitingQuery='Select Id from EmailMessage where Incoming=true and IsOpened=false and Status=\'0\' and ParentId!=null and Parent.GCM_My_Team__c=true';
        query({'recordId' : USER_ID, 'soql' : emailsAwaitingQuery})
        .then(result => {
            this.emailsAwaitingMyTeam = result.length;
        })
        .catch(error => {
            this.handleError(error);
        });

        //My Team's Open Cases //new###
        var backlogCasesQuery='Select Id from Case where GCM_My_Team__c=true AND Status!=\'Cancelled\' AND Status!=\'Closed\'';
        query({'recordId' : USER_ID, 'soql' : backlogCasesQuery})
        .then(result => {
            this.casesBacklogMyTeam = result.length;
        })
        .catch(error => {
            this.handleError(error);
        });

        //My Team's Overdue Cases //new###
        var overdueCasesQuery='SELECT Id FROM Case WHERE SLA_Missed__c=true AND Status!=\'Cancelled\' AND Status !=\'Closed\' AND GCM_My_Team__c=true';
        query({'recordId' : USER_ID, 'soql' : overdueCasesQuery})
        .then(result => {
            this.casesOverdueMyTeam = result.length;
        })    
        .catch(error => {
            this.handleError(error);
        });

        //Number of emails awaiting for you //new###
        var myEmailsAwaitingQuery='Select Id from EmailMessage where Incoming=true and IsOpened=false and Status=\'0\' and ParentId!=null and Parent.OwnerId=\''+USER_ID+'\'';
        query({'recordId' : USER_ID, 'soql' : myEmailsAwaitingQuery})
        .then(result => {
            this.myEmailsAwaiting = result.length;
        })    
        .catch(error => {
            this.handleError(error);
        });

        //Number of cases awaiting for you //new###
        var caseQueryBacklog='SELECT Id FROM Case WHERE OwnerId=\'' + USER_ID + '\' AND Status!=\'Cancelled\' AND Status !=\'Closed\'';
        query({'recordId' : USER_ID, 'soql' : caseQueryBacklog})
        .then(result => {
            this.myBacklogCases = result.length;
        })    
        .catch(error => {
             this.handleError(error);
        });

        //Number of overdue cases assigned to you //new###  
        var myOverdueCasesQuery='SELECT Id FROM Case WHERE OwnerId=\'' + USER_ID + '\' AND Status!=\'Cancelled\' AND Status !=\'Closed\' AND SLA_Missed__c=true';
        query({'recordId' : USER_ID, 'soql' : myOverdueCasesQuery})
        .then(result => {
            this.myOverdueCases = result.length;
       })    
       .catch(error => {
            this.handleError(error);
       });
    }
}