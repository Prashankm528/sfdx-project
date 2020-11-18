import { LightningElement, api,track } from 'lwc';
import getTenderLocationAdd from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationAddPackage';
let managerSet = new Set();
let countrySet = new Set();
export default class AITM_PackageCustomer extends LightningElement {
    @api locationLineItem ;
    @api locationStatus;
    AllLocations ;
    tenderLocation;
    locationBycountry;
    locationByManager;
   
    @api tenderId;
    @track Options;
    searchOptions =[];
    
   

    connectedCallback(){
       // alert('test');
        this.getTenderLocationAdd();   
        
       
   } 

  getTenderLocationAdd(){
    //alert('test1');
    //getting all tender location available in the Tender
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
    //alert('test2');
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
 }

 handleChange(event){
    //alert('tes3');
    if(this.AllLocations){
        this.tenderLocation = this.AllLocations;
       }
        
        console.log('selected value is ' +event.detail.value);
        this.selectedAvailableActions = event.detail.value;
        
        this.AllLocations = [...this.tenderLocation];
        console.log('All' +this.AllLocations);

        if(this.selectedAvailableActions=='All Locations'){
            this.tenderLocation = this.AllLocations;
           // this.selectedLocation(this.tenderLocationSelected)
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
              //  this.selectedLocation(this.tenderLocationSelected)
            }

        }

    deleteRecord(){
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').deleteCustomerLocation();
    }

    showLocationScreenWithChecked(){
        //alert('inside parent');
        this.dispatchEvent(new CustomEvent('back'));   
        //this.template.querySelector('c-a-i-t-m_-package-customer-tile').checkedCustomerScreen();
        //this.dispatchEvent(new CustomEvent('back', {detail:globalmySet}));   
    }
}