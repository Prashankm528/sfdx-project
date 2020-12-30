import { LightningElement, api,track } from 'lwc';
import getTenderLocationAdd from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationAddPackage';

export default class AITM_PackageCustomer extends LightningElement {
    value = 'All Locations';
    @api locationLineItem ;
    @api locationStatus;
    @api tenderId;
    @api package;
    @api packId;
    @track Options;
    AllLocations ;
    tenderLocation;
    locationBycountry;
    locationByManager;
    searchOptions =[];
    updateSelectAction;
    managerSet = new Set();
    countrySet =  new Set();
    searchValue;

    connectedCallback(){   
         
        //this.getTenderLocationAdd();   
        //this.getAvailableActions();
    } 

    @api
    getAvailableActions(locationLineItemCountry){
        
        this.updateSelectAction = locationLineItemCountry;
        console.log('locationLineItemCountry is ' + locationLineItemCountry);

        
        for(let i=0; i<locationLineItemCountry.length; i++){
           
            this.countrySet.add(locationLineItemCountry[i].locationCountry);
            this.managerSet.add(locationLineItemCountry[i].locationManager);
        }
        for (var item of this.managerSet.values()){
            this.searchOptions.push(item);
        } 
        for (var item of this.countrySet.values()){
            this.searchOptions.push(item);
        }
            
        
        this.Options = this.searchOptions.map(type => {
            return {label: type, value: type}
        });
        this.Options.unshift({ label: 'All Package Locations', value: 'All Locations' });
        console.log('options are' + this.Options);
    }

    handleSearch(event){
        this.template.querySelector('[data-id="Available"]').value = 'All Locations';
        this.searchValue = event.target.value;
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').searchCustomer(this.searchValue);
    }
   /* getTenderLocationAdd(){
    
        getTenderLocationAdd({TenderId: this.tenderId})
        .then(result=>{
            this.tenderLocation = result; // all location by default
            console.log('Tender location are' + JSON.stringify(result));
            this.availableAction(this.tenderLocation);
            
        })
        .catch(error=>{
            console.log('Test Log' +error);
        })
   }

    availableAction(Availableoptions){
    
        console.log('Location items are in packagelocatuion options test' + Availableoptions);
        for(let i=0; i<Availableoptions.length; i++){
            managerSet.add(Availableoptions[i].AITM_Location_Manager__r.Name);
            countrySet.add(Availableoptions[i].AITM_Location__r.AITM_Country__c);
        }
        for (var item of managerSet.values()){
            this.searchOptions.push(item);
        } 
        for (var item of countrySet.values()){
            this.searchOptions.push(item);
        }
        console.log('Available options are ' + this.searchOptions);
        this.Options = this.searchOptions.map(type => {
            return {label: type, value: type}
        });
        this.Options.unshift({ label: 'All Locations', value: 'All Locations' });
        console.log('options are' + this.Options);
    } */

    handleChange(event){
       // alert('test');
        this.template.querySelector('[data-id="search"]').value = '';
        let selectedValue = event.detail.value;
        console.log('Prashank');
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').handleCustomerFilter(selectedValue, this.managerSet , this.countrySet);
        
       /* if(this.AllLocations){
            this.tenderLocation = this.AllLocations;
        }    
        this.selectedAvailableActions = event.detail.value;
        this.AllLocations = [...this.tenderLocation];
        if(this.selectedAvailableActions=='All Locations'){
            this.tenderLocation = this.AllLocations;
        }
        else if(countrySet.has( this.selectedAvailableActions)){
            this.locationBycountry = this.tenderLocation.filter(progress=>   
                progress.AITM_Location__r.AITM_Country__c == this.selectedAvailableActions);
            this.tenderLocation = this.locationBycountry;
            
        }
        else if(managerSet.has( this.selectedAvailableActions)){
            this.locationByManager = this.tenderLocation.filter(progress=>   
                progress.AITM_Location_Manager__r.Name == this.selectedAvailableActions);
                this.tenderLocation = this.locationByManager;
            
            } */

    }

    deleteRecord(){
       
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').deleteCustomerLocation();
       
       
    }

    clonecustomer(){
       
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').cloneLineItems();
        
        
    }

    addCustomer(){
        this.template.querySelector('c-a-i-t-m_-add-customer-modal').openModal();
    }

    handleSave(){
        
       // let params = {"selectedValue" : selectedValue, "managerSet":managerSet, "countrySet":countrySet}
       this.template.querySelector('c-a-i-t-m_-package-customer-tile').saveLineItems();
       // this.dispatchEvent(new CustomEvent('save')); 
    }

    showLocationScreenWithChecked(){
        this.dispatchEvent(new CustomEvent('back'));   
    }
}