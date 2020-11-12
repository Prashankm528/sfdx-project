import { LightningElement, api, wire ,track } from 'lwc';
import getTenderLocationLineItems from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationLineItems';
import getTenderLocationAdd from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationAddPackage';
import getTenderLocationEdit from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationEditPackage';
import { getRecord, getFieldValue, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import NAME_FIELD1 from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/AITM_Tender__c.Name';
import PACKAGE_OBJECT from '@salesforce/schema/AITM_Tender_Package__c';
import PACKAGE_NAME from '@salesforce/schema/AITM_Tender_Package__c.Name';
import PACKAGE_DESCRIPTION from '@salesforce/schema/AITM_Tender_Package__c.AITM_Description__c';
import PACKAGE_NOTES from '@salesforce/schema/AITM_Tender_Package__c.AITM_Internal_Notes__c';
import PACKAGE_TENDER from '@salesforce/schema/AITM_Tender_Package__c.AITM_Tender__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Package__c.Id';


export default class AITM_CreatePackage extends NavigationMixin(LightningElement) {

    @api recordId; //Tender Id
    @api packId; //  package id passed from table
    selectedValueList = [];
    @track mapkeyValueStore = []; 
    Name;
    @track mapkeyValueStatus= []; //map of location and status
    // Fields needed to create package
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
    //selectedLocationset = new set();

    

    // To get the package detail on edit with Packid - package id on edit
    @wire(getRecord, { recordId: '$packId', fields: [PACKAGE_NAME, PACKAGE_DESCRIPTION, PACKAGE_NOTES]})
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
    

    handlePackageName(event){
        this.packName = event.target.value;
    }

    handleDescription(event){
        this.description = event.target.value;
    }

    handleNotes(event){
        this.notes = event.target.value;
    }

    connectedCallback(){
      
        //this.getTenderLocationAdd();     
   }

// to get the location data
  /* getTenderLocationAdd(){
    getTenderLocationAdd({TenderId: this.recordId})
      .then(result=>{
        this.tenderLocation = result;
        console.log('Tender location are' + JSON.stringify(this.tenderLocation));
        setTimeout(()=>this.template.querySelector('c-a-i-t-m_-package-location').availableAction(this.tenderLocation));
        this.error= undefined;
      })
      .catch(error=>{
        this.tenderLocation = Undefined;
        this.error= error;
      })
    
      if(this.packId){
        getTenderLocationEdit({TenderId: this.recordId, PackId : this.packId})
        .then(result=>{
            this.tenderLocationSelected = result;
            this.locationAlreadySelected = result;
            console.log(' Selected Tender location are' + JSON.stringify(this.locationAlreadySelected));
            console.log(' Selected Tender location are' + JSON.stringify(this.tenderLocationSelected));
            setTimeout(()=>this.template.querySelector('c-a-i-t-m_-package-location').selectedLocation(this.tenderLocationSelected));
            this.error= undefined;
        })
        .catch(error=>{
            this.tenderLocationSelected = Undefined;
            this.error= error;
        }) 
        
    }

   }*/

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
        this.template.querySelector('c-a-i-t-m_-package-location').locationEnabled();
       // this.template.querySelector("c-a-i-t-m_-package-location").locationEnabled();

        if(!this.PackageId && !this.packId ){
            if(this.packName){
                const fields = {};
                fields[PACKAGE_NAME.fieldApiName] = this.packName;
                fields[PACKAGE_DESCRIPTION.fieldApiName] = this.description;
                fields[PACKAGE_TENDER.fieldApiName] = this.recordId;
                fields[PACKAGE_NOTES.fieldApiName] = this.notes;
                const recordInput = { apiName: PACKAGE_OBJECT.objectApiName, fields };

                createRecord(recordInput)
                    .then(packages => {
                        this.PackageId = packages.id;
                        this.isLoading = false;
                        console.log(this.PackageId);
                    
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
            //fields[ID_FIELD.fieldApiName] =  this.packId;
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
     //  this.TenderLocationLineItems = [];
      // this.inEditPackageCase = []
        //this.LocationList = event.detail;
        console.log('Pacakge Id edit' + this.packId);
        console.log('Pacakge Id edit' + this.PackageId);
       // console.log('set size is ' + event.detail.globalmySet);
        console.log('global set size is ' + event.detail.globalmySet.size );
        for (var item of event.detail.globalmySet.values()){
            
            this.LocationList.push(item);
            }
            console.log('List from set' +  this.LocationList ); // All selected locations from location page
       
        this.inEditPackageCase =  (this.packId || this.PackageId)  ? event.detail.locationAlreadySelected : null ;
       console.log('Edit location line item Id value are' + this.inEditPackageCase);
       if(this.inEditPackageCase){
           for(let i=0; i< this.inEditPackageCase.length; i++){
                this.selectedValueList.push(this.inEditPackageCase[i]);
           }
       }
     // alert('tset' +this.selectedValueList);
     // alert('Kunal')
      //JSON.stringify(this.selectedValueList[0])
        //getting tender location items on basis og tender id, tender location and package Id
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
           /* for(var key in result){

                this.mapkeyValueStore.push({key:key,value:result[key]});
                this.mapkeyValueStatus.push({key:key,value:'Priced'});
               } */
              this.isLoading = false;
             // console.log('MapkeyValueStatus is :' +  JSON.stringify(this.mapkeyValueStatus));
            console.log('MapkeyValue is :' +  JSON.stringify(this.mapkeyValueStore));
            //this.error= undefined;
          })
          .catch(error=>{
            //this.TenderLocationLineItems = undefined;
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
       
        //this.isLoading = true;
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