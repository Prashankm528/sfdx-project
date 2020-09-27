import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import label1 from '@salesforce/label/c.clientId';
import label2 from '@salesforce/label/c.clientsecret';
export default class NavigationToSevice extends NavigationMixin(LightningElement) {
    @track  cliendId = label1;

    label = {
        label1,
        label2,
    };


    openGoogle(){
        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes: {
                url : 'https://www.google.com'
            }
        });
    }

    openAccountHome(){
        this[NavigationMixin.Navigate]({
            type : 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            }
        });
    }

    createNewContact(){
        this[NavigationMixin.Navigate]({
            type : 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            }
        });
    }

    openOppListView(){
        this[NavigationMixin.Navigate]({
            type : 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'list'
            }
        });
    }

    openCaseRecord(){
        this[NavigationMixin.Navigate]({
            type : 'standard__recordPage',
            attributes: {
                recordId: "5006F00002lKTzEQAW",
                objectApiName: 'Case', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    openContact(){
        this[NavigationMixin.Navigate]({
            type : 'standard__navItemPage', 
            attributes: {
                apiName: 'Contacts'
            }
        });
    }

    
    }

