import { LightningElement, track, wire, api } from 'lwc';
import FAQ_results from '@salesforce/apex/DUP_FAQ_RecordsController.getRelatedRecords';
import FAQ_SearchResults from '@salesforce/apex/DUP_FAQ_RecordsController.getSearchedRecords';
import FAQ_viewUpdate from '@salesforce/apex/DUP_FAQ_RecordsController.updateRecordViews';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Questions', fieldName: 'DUP_Title__c', type: 'text'},
    {
        type:'button-icon',
        initialWidth: 60,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View'
        }
    }
];

export default class DUP_FAQ_RecordsLWC extends NavigationMixin(LightningElement) {
    @track FAQrecords;
    //@api record;
    @track error;
    columns = columns;

    //Initial records
    @wire (FAQ_results) 
    FAQlist({error,data}){
        if(data){
            this.FAQrecords = data;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
            this.FAQrecords = undefined;
        }
    }
    
    //search records
    handleSearch(event){
        let searchTerm = event.target.value;
        console.log(searchTerm);
        if(searchTerm.length >= 3){
            FAQ_SearchResults({searchTerm})
                .then(result =>{
                    this.FAQrecords = result;
                    this.error = undefined;
                })
                .catch(error =>{
                    this.error = error;
                    this.FAQrecords = undefined;
                })
        }
        else{
            //Initial records
            FAQ_results()
            .then(result =>{
                this.FAQrecords = result;
                this.error = undefined;
            })
            .catch(error =>{
                this.error = error;
                this.FAQrecords = undefined;
            }) 
        }
    }

    //Navigate to record
    navigateToRecordViewPage(event) {
        let record = event.detail.row;

        //Updating records views
        FAQ_viewUpdate({FAQ_recordid: record.Id})
        .then(result =>{
            this.record = result;
            this.error = undefined;
        })
        .catch(error =>{
            this.error = error;
        })

       this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: record.Id,
                //objectApiName: 'DUP_FAQ__c',
                actionName: 'view'
            }
        });
    }

}