import { LightningElement, api, wire ,track } from 'lwc';
import Packaging_Best_Practice from '@salesforce/resourceUrl/AITM_Packaging_Best_Practice';
import Packaging_Tool_Practice from '@salesforce/resourceUrl/AITM_Packaging_Tool';
import clonelocationLineItems from '@salesforce/apex/AITM_AddTenderPackage.clonelocationLineItems';
import deletelocationLineItems from '@salesforce/apex/AITM_AddTenderPackage.deletelocationLineItems';
import updatelocationLineItems from '@salesforce/apex/AITM_AddTenderPackage.updatelocationLineItems';
import fillWrapperToShowUpdatedLineItems from '@salesforce/apex/AITM_AddTenderPackage.fillWrapperToShowUpdatedLineItems';
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
import PACKAGE_ROUND from '@salesforce/schema/AITM_Tender_Package__c.AITM_Round__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Package__c.Id';
let mapOfUpdatedPackage =  new Map();
export default class AITM_CreatePackage extends NavigationMixin(LightningElement) {

    @api recordId; //Tender Id
    @api packId; //  package id passed from table

    @track mapkeyValueStatus= []; //map of location and status
    @track mapkeyValueStore = []; 
    currentRound
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
    AllLocations;
    locationBycountry =[];
    locationByManager = [];
   


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

    oldvalue(event){
        console.log('test' +event.oldValue);
        console.log('old value is ' + event.target.value);
        this.oldValue = event.target.value;
    }

    handlePackageName(event){
        this.packName = event.target.value;
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        if(this.oldValue !=  this.packName ){
            //this.isLoading = true; 
           
            if(mapOfUpdatedPackage.has(selectedPackageId)){
                let valtoUpdate = mapOfUpdatedPackage.get(selectedPackageId);
                valtoUpdate.packageId = selectedPackageId;
                valtoUpdate.packName = this.packName;
                mapOfUpdatedPackage.set(selectedPackageId,valtoUpdate);
            }
            else{
                mapOfUpdatedPackage.set(selectedPackageId,{packName:this.packName, packageId: selectedPackageId})
            }
        }
    }

    handleDescription(event){
        this.description = event.target.value;
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        if(this.oldValue !=  this.packName ){
            //this.isLoading = true; 
           
            if(mapOfUpdatedPackage.has(selectedPackageId)){
                let valtoUpdate = mapOfUpdatedPackage.get(selectedPackageId);
                valtoUpdate.packageId = selectedPackageId;
                valtoUpdate.description = this.description;
                mapOfUpdatedPackage.set(selectedPackageId,valtoUpdate);
            }
            else{
                mapOfUpdatedPackage.set(selectedPackageId,{description:this.description, packageId: selectedPackageId})
            }
        }
    }

    handleNotes(event){
        this.notes = event.target.value;
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        if(this.oldValue !=  this.packName ){
            //this.isLoading = true; 
           
            if(mapOfUpdatedPackage.has(selectedPackageId)){
                let valtoUpdate = mapOfUpdatedPackage.get(selectedPackageId);
                valtoUpdate.packageId = selectedPackageId;
                valtoUpdate.notes = this.notes;
                mapOfUpdatedPackage.set(selectedPackageId,valtoUpdate);
            }
            else{
                mapOfUpdatedPackage.set(selectedPackageId,{notes:this.notes, packageId: selectedPackageId})
            }
        }
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

    refreshLineItems(event){
        
      
        let  listoflineItemsToDelete = event.detail.listoflineItemsToDelete;
        //let  listofLocationsToDelete = event.detail.listofLocationsToDelete;
        console.log('agter event is ' +JSON.stringify(this.mapkeyValueStore));
        console.log(listoflineItemsToDelete);
        
        if(listoflineItemsToDelete.length>0 ){
            if (confirm('Are you sure you want to delete selected location line Items ?')) {
                this.isLoading = true; 
                let selectedPackageId = this.packId ? this.packId : this.PackageId ;
                this.AllLocations =[];
                this.mapkeyValueStore = [];
                deletelocationLineItems({packageId: selectedPackageId, tenderId:this.recordId , listOfLineItems:listoflineItemsToDelete})
                .then(result=>{
                    console.log('result is' + result);
                    this.mapkeyValueStore = result;
                    this.AllLocations = result;
                    this.ShowToastNotification('Success', 'Line Items Deleted Successfully', 'success');
                    this.isLoading = false; 
                })
                .catch(error=>{
                    console.log('error while cloning' + JSON.stringify(error) );
                    this.ShowToastNotification('Success', 'error while deleting', 'success');
                    this.isLoading = false; 
                })
            }
            else{
                this.isLoading = false; 
            }
            

          /*          
        //deleting location
                    for( let i=0;i< listofLocationsToDelete.length; i++){
                        for(let j=0;j< this.mapkeyValueStore.length; j++){
                            let idToDelete = this.mapkeyValueStore[j].locationId;
                            if(idToDelete === listofLocationsToDelete[i]){
                                let index =this.mapkeyValueStore.indexOf( this.mapkeyValueStore[j]);
                                console.log(this.mapkeyValueStore.indexOf( this.mapkeyValueStore[j]));
                                if (index > -1) {  
                                    this.isLoading = true;  
                                    this.mapkeyValueStore.splice(index, 1);   
                                    this.isLoading = false; 
                                }
                            }
                        }
                    }
                        //deleting locationline item
                    for( let i=0;i< listoflineItemsToDelete.length; i++){
                        for(let j=0;j< this.mapkeyValueStore.length; j++){
                            for(let k=0;k< this.mapkeyValueStore[j].locationLineItemsList.length; k++){
                                console.log('id is ' + this.mapkeyValueStore[j].locationLineItemsList[k].Id);
                                let idToDelete = this.mapkeyValueStore[j].locationLineItemsList[k].Id;
                                if(idToDelete === listoflineItemsToDelete[i]){   
                                    let index =this.mapkeyValueStore[j].locationLineItemsList.indexOf( this.mapkeyValueStore[j].locationLineItemsList[k]);
                                    console.log(this.mapkeyValueStore[j].locationLineItemsList.indexOf( this.mapkeyValueStore[j].locationLineItemsList[k]));
                                    if (index > -1) {    
                                        this.isLoading = true; 
                                        this.mapkeyValueStore[j].locationLineItemsList.splice(index, 1);    
                                        this.isLoading = false; 
                                    }
                                }
                            }
                        }
                    }
                */  
        }
        else{
            alert('Please select an item to delete');
            this.isLoading = false; 
        }
        
    }

    cloneLocationLineItem(event){
       console.log("event detail is" + event.detail.listoflineItemsToClone);
        let locationItemsToClone = event.detail.listoflineItemsToClone;
        console.log('size is ' + locationItemsToClone);
        if(locationItemsToClone.length >0){
            if (confirm('Are you sure you want to clone selected location line Items ?')) {
                this.isLoading = true; 
                let selectedPackageId = this.packId ? this.packId : this.PackageId ;
                this.AllLocations =[];
                this.mapkeyValueStore = [];
                clonelocationLineItems({packageId: selectedPackageId, tenderId:this.recordId , listOfLineItems:locationItemsToClone})
                .then(result=>{
                    console.log('result is' + result);
                    this.mapkeyValueStore = result;
                    this.AllLocations = result;
                    this.ShowToastNotification('Success', 'Line Items Cloned Successfully', 'success');
                    this.isLoading = false; 
                })
                .catch(error=>{
                    console.log('error while cloning' + JSON.stringify(error) );
                    this.ShowToastNotification('error', 'error while Cloning', 'error');
                    this.isLoading = false; 
                })
            }
            else{
                this.isLoading = false; 
            }
        }
        else{
            alert('Please select an item to clone');
            this.isLoading = false; 
        }
        
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

    currentround(event){
      
        this.currentRound = event.detail;
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
                fields[PACKAGE_ROUND.fieldApiName] = this.currentRound;
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

    filterCustomer(event){
        
       
        let countrySet = new Set(event.detail.countrySet);
        let managerSet = new Set(event.detail.managerSet);
        let selectedValue = event.detail.selectedValue;

       
        console.log('value is ' + selectedValue);
        if(this.AllLocations){
            console.log('1');
            this.mapkeyValueStore = this.AllLocations;
        }
        
        this.AllLocations = [...this.mapkeyValueStore];
        console.log('All' +this.AllLocations);
        if(selectedValue=='All Locations'){
            console.log('2');
            this.mapkeyValueStore = this.AllLocations;
        }
        else if(countrySet.has(selectedValue)){
            console.log('3');
            this.locationBycountry = this.mapkeyValueStore.filter(progress=>   
            progress.locationCountry == selectedValue);
            this.mapkeyValueStore = this.locationBycountry;     
        }
        else if(managerSet.has(selectedValue)){
            this.locationByManager = this.mapkeyValueStore.filter(progress=>   
            progress.locationManager == selectedValue);
            this.mapkeyValueStore = this.locationByManager;   
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
            this.template.querySelector('c-a-i-t-m_-package-customer').getAvailableActions(this.mapkeyValueStore);
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

    saveLineItem(event){
        
        this.isLoading = true;
        let packageChanges = [];
        let listoflId = event.detail.listoflId;
        let  listoflineItemtoUpdate = event.detail.listoflineItemtoUpdate;
        let locationToUpdate = event.detail.locationToUpdate;
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        
        packageChanges = Array.from(mapOfUpdatedPackage.values());
        //this.packageChanges.selectedPackageId = selectedPackageId;
        console.log('Package changes are' + JSON.stringify(packageChanges));
        console.log('Id List' + listoflId);
        console.log('list values are' + JSON.stringify(listoflineItemtoUpdate));
        updatelocationLineItems({ packageId: selectedPackageId, tenderId:this.recordId, listoflineItemtoUpdate:JSON.stringify(listoflineItemtoUpdate), 
            locationToUpdate:JSON.stringify(locationToUpdate) , packagetoupdate:JSON.stringify(packageChanges)})
        .then(result=>{
            console.log('result is' + result);
            this.mapkeyValueStore = result;
            this.ShowToastNotification('Success','Changes saved succesfully', 'success');
            //this.AllLocations = result;
            this.isLoading = false; 
        })
        .catch(error=>{
            
            console.log('error while cloning' + JSON.stringify(error) );
            this.ShowToastNotification('error' ,'Error while saving', 'error');
            //this.ShowToastNotification(Error, error.message, error);
            this.isLoading = false; 
        })


        
    }
    refreshlineItemview(event){
        this.isLoading = true; 
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        this.AllLocations =[];
        this.mapkeyValueStore = [];
        fillWrapperToShowUpdatedLineItems({packageId: selectedPackageId, tenderId:this.recordId })
        .then(result=>{
            console.log('result is' + result);
            this.mapkeyValueStore = result;
            this.AllLocations = result;
            this.ShowToastNotification('Success', 'Line Items added Successfully', 'success');
            this.isLoading = false; 
        })
        .catch(error=>{
            console.log('error while cloning' + JSON.stringify(error) );
            this.ShowToastNotification('error', 'error while adding line item', 'error');
            this.isLoading = false; 
        })
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