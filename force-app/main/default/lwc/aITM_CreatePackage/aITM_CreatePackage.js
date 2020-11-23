import { LightningElement, api, wire ,track } from 'lwc';
import Packaging_Best_Practice from '@salesforce/resourceUrl/AITM_Packaging_Best_Practice';
import Packaging_Tool_Practice from '@salesforce/resourceUrl/AITM_Packaging_Tool';
import getTenderLocationLineItems from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationLineItems';
import deletePackage from '@salesforce/apex/AITM_AddTenderPackage.deletePackage';
import getPackageCounter from '@salesforce/apex/AITM_AddTenderPackage.getPackageCounter';
import { getRecord, getFieldValue, createRecord, updateRecord ,deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import NAME_FIELD1 from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/AITM_Tender__c.Name';
import PACKAGE_OBJECT from '@salesforce/schema/AITM_Tender_Package__c';
import PACKAGE_NAME from '@salesforce/schema/AITM_Tender_Package__c.Name';
import PACKAGE_DESCRIPTION from '@salesforce/schema/AITM_Tender_Package__c.AITM_Description__c';
import PACKAGE_NOTES from '@salesforce/schema/AITM_Tender_Package__c.AITM_Internal_Notes__c';
import PACKAGE_COUNTER from '@salesforce/schema/AITM_Tender_Package__c.AITM_Package_Counter__c';
import PACKAGE_TENDER from '@salesforce/schema/AITM_Tender_Package__c.AITM_Tender__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Package__c.Id';

export default class AITM_CreatePackage extends NavigationMixin(LightningElement) {

    @api recordId; //Tender Id
    @api packId; //  package id passed from table

    @track mapkeyValueStatus= []; //map of location and status
    @track mapkeyValueStore = []; 

    Name;
    selectedValueList = [];
    // Fields needed to create package
    packageCounter;
    packName;
    description;
    notes;
    // Fields needed to create package ends
    tenderRecord;
    showLocation = true;
    showCustomer = false;
    searchOptions; //options for Available Options
    currentStep;
    PackageId; // created Package Id
    isLoading = false;
    userId = Id;
    disableSave =false;
    tenderLocation;
    tenderLocationSelected;
    TenderLocationLineItems;
    error;
    LocationList = [];
    disableLocation=true; //to disable the location part till the time package got saved
    selectedLocationValue = [];
    locationAlreadySelected =[];
    disableCreate =false;
    inEditPackageCase =[];
    FileToDowload;
    IncaseEdit = false;
    initialUrl;


    // to get Tender details
    @wire(getRecord, { recordId: '$recordId', fields:NAME_FIELD })
    Tender({error, data}){
        if(error){
            console.log('error is ' +error);
        }
        if(data){
            this.tenderRecord = data;
            this.Name =  this.tenderRecord.fields.Name.value;
        }
    }

    // To get the package detail on edit with Packid - package id on edit
    @wire(getRecord, { recordId: '$packId', fields: [PACKAGE_NAME, PACKAGE_DESCRIPTION, PACKAGE_NOTES, PACKAGE_COUNTER]})
    Package;

    get PackageName(){
        return getFieldValue(this.Package.data, PACKAGE_NAME);
    }

    get PackageDescription(){
        return getFieldValue(this.Package.data, PACKAGE_DESCRIPTION);
    }

    get PackageNotes(){
        return getFieldValue(this.Package.data, PACKAGE_NOTES);
    }

    get PackageCounter(){
        return getFieldValue(this.Package.data, PACKAGE_COUNTER);
    }

    connectedCallback(){
        if(!this.packId){
            this.getPackageCounter();     
        }
    }
    
    deletePackage(){
        let recordToDelete;
        if (confirm('Are you sure you want to delete this Package ?')) {
            if(this.packId){
                recordToDelete = this.packId;
            }
            if(this.PackageId){
                recordToDelete = this.PackageId;
            }
            deletePackage({packageId : recordToDelete })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                        
                    );
                    var close = true;
                    const closeclickedevt = new CustomEvent('closeclicked', {
                    detail: { close },
                 });
                this.dispatchEvent(closeclickedevt);
                    
                })
                .catch(error => {
                    console.log('error while deleting Package::' +error);
                })
        } 
        else {
            console.log('Thing was not saved to the database.');
        }   
    }

    handlePackageName(event){
        this.packName = event.target.value;
    }

    handleDescription(event){
        this.description = event.target.value;
    }

    handleNotes(event){
        this.notes = event.target.value;
    }

    getPackageCounter(){
        getPackageCounter({TenderId: this.recordId})
        .then(result=>{
            this.packageCounter = result;
            this.error= undefined;
        })
        .catch(error=>{
            this.packageCounter = undefined;
            this.error= error;
        })
    }

    //download the file in static resource
    DownloadFile(){
        let downloadLink = document.createElement("a");
        downloadLink.href =  Packaging_Tool_Practice;
        downloadLink.target = "_self";
        downloadLink.download = "Packaging Tool Practices";
        downloadLink.click();  
    }

    downloadPpt(event){
        event.preventDefault();
        let downloadLink = document.createElement("a");
        downloadLink.href =  Packaging_Best_Practice;
        downloadLink.target = "_self";
        downloadLink.download = "Packaging Best Practices";
        downloadLink.click(); 
    }

    // navigate to tender record 
    getTender(event){
        event.preventDefault();
        let rId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId ,
                objectApiName: 'AITM_Tender__c',
                actionName: 'view'
            },
        });
    }

   createPackage(){  
        this.isLoading = true; 
        this.disableCreate =true;
        if(!this.PackageId && !this.packId ){
            if(this.packName){
                const fields = {};
                fields[PACKAGE_NAME.fieldApiName] = this.packName;
                fields[PACKAGE_DESCRIPTION.fieldApiName] = this.description;
                fields[PACKAGE_TENDER.fieldApiName] = this.recordId;
                fields[PACKAGE_NOTES.fieldApiName] = this.notes;
                fields[PACKAGE_COUNTER.fieldApiName] = this.packageCounter;
                const recordInput = { apiName: PACKAGE_OBJECT.objectApiName, fields };

                createRecord(recordInput)
                    .then(packages => {
                        this.PackageId = packages.id;
                        console.log(this.PackageId);
                        this.template.querySelector('c-a-i-t-m_-package-location').locationEnabled();
                        this.ShowToastNotification('Success', 'Package created', 'success');
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.ShowToastNotification('Error creating record',  'error occured', 'error');
                    });  
            } 
            else{
                this.ShowToastNotification('Error creating record',  'Please fill the package Name', 'error');
            }
        }
        else{
            const fields = {};
            fields[ID_FIELD.fieldApiName] =  this.PackageId;
            fields[PACKAGE_NAME.fieldApiName] = this.packName;
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.ShowToastNotification('Success', 'Package Updated', 'success');
            })
            .catch(error => {
                this.isLoading = false;
                this.ShowToastNotification('Error creating record',  'error occured', 'error');
            });
        }     
    } 

    // customer screen with the clone record
    showCustomerScreen(event){
        this.isLoading = true;
        this.LocationList =[];
        this.mapkeyValueStore = []
        console.log('Pacakge Id edit' + this.packId);
        console.log('Pacakge Id edit' + this.PackageId); 
        console.log('global set size is ' + event.detail.globalmySet.size );
        for (var item of event.detail.globalmySet.values()){ 
            this.LocationList.push(item);
        }
        console.log('List from set' +  this.LocationList ); // All selected locations from location page
        this.inEditPackageCase =  (this.packId || this.PackageId)  ? event.detail.locationAlreadySelected : null ;
        console.log('Edit location line item Id value are' + this.inEditPackageCase);//tenderlocation 
        if(this.inEditPackageCase){
            for(let i=0; i< this.inEditPackageCase.length; i++){
                this.selectedValueList.push(this.inEditPackageCase[i]);
            }
        }
        getTenderLocationLineItems({    
            TenderId: this.recordId,   
            newTenderLocationtoInsert : this.LocationList,
            TenderLocationAlreadyInserted : this.selectedValueList,
            PackageId : this.PackageId,
            editPackageId : this.packId
        })
        .then(result=>{
            this.TenderLocationLineItems = result;
            console.log('location Line item list is' +  this.TenderLocationLineItems);
            for(let i=0; i< this.TenderLocationLineItems.length; i++){
                this.mapkeyValueStore.push(this.TenderLocationLineItems[i]);
            }
            this.mapkeyValueStore.sort(function(a, b){
                if(a.iATAWithlocationName < b.iATAWithlocationName) { return -1; }
                if(a.iATAWithlocationName > b.iATAWithlocationName) { return 1; }
                return 0;
            })
            this.isLoading = false;
            console.log('MapkeyValue is :' +  JSON.stringify(this.mapkeyValueStore));
           
        })
        .catch(error=>{
            console.log(error);
            this.error= error;
        })
        this.showLocation = false;
        this.showCustomer = true;
        this.showSave = true;
        this.showNext =false;
        this.currentStep = "2";
    }

    showLocationScreen(event){
        this.IncaseEdit = false;
        this.showLocation = true;
        this.showCustomer = false;
        this.currentStep = "1";
        if(this.PackageId){
            setTimeout(()=>this.template.querySelector('c-a-i-t-m_-package-location').selected(this.LocationList));
        }   
    }

    ShowToastNotification(title, message, variant){
        this.dispatchEvent(    
            new ShowToastEvent({     
                title: title,
                message: message,
                variant: variant
            })    
        );
        this.isLoading = false;
        if(!this.packName){
            this.disableCreate =false;
        }
    }
}