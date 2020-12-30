import { LightningElement, api , track} from 'lwc';
import getTenderLocationAdd from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationAddPackage';
import getTenderLocationEdit from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationEditPackage';
let managerSet = new Set();
let countrySet = new Set();
let selectedLocationset = new Set();
export default class AITM_PackageLocation extends LightningElement {

    
    @api package;
    @api packId;
    @api tenderId;
    @track Options;
    globalmySet ;
    value='All Locations'
    isLoading =false;  
    tenderLocation;
    tenderLocationSelected = [];
    selectedAvailableActions;
    AllLocations ;
    locationBycountry;
    locationByManager;
    locationBySearch;
    searchOptions =[];
    selectedValue1 =  [];
    selectedValue =  [];
    selectedItem = '';
    checkbox = false;
    selectedCheckboxes = []; 
    searchValue;
    error;
    filterSearch;
    isSearch = false;
    lengthOfLocations;


    connectedCallback(){     
        this.globalmySet = new Set();
        this.getTenderLocationAdd();  
    } 

   // when all location filetr changes
    handleChange(event){
        //this.isSearch = true;
        this.template.querySelector('[data-id="search"]').value = '';
        if(this.AllLocations){
            this.tenderLocation = this.AllLocations;
        }
        else if(this.filterSearch){
            alert('1');
            this.tenderLocation = this.filterSearch;
        } 
        this.selectedAvailableActions = event.detail.value;
        this.AllLocations = [...this.tenderLocation];
        console.log('All' +this.AllLocations);
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
        }

            // after serach witholding the selected checkbox
        if(this.globalmySet){
            for(let i=0; i< this.tenderLocation.length; i++){
                console.log(this.tenderLocation[i].Id)
                let targetId = this.tenderLocation[i].Id
                if(this.globalmySet.has(targetId)){
                    console.log('set contains' +targetId);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).checked = true);
                    
                }
            }
        }
        // after serach witholding the selected checkbox
        if(this.tenderLocationSelected){
            for(let i=0; i< this.tenderLocation.length; i++){
                console.log(this.tenderLocation[i].Id)
                let targetId = this.tenderLocation[i].Id
                if(this.tenderLocationSelected.includes(targetId)){
                    console.log('set contains' +targetId);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).checked = true);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).disabled = true);
                   
                }
            }
        }
        // added 22-12
        
        this.selectedCheckboxes = [];
        let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
        for( let i=0; i<checkboxes.length; i++) {
            if(checkboxes[i].checked == true){
            this.selectedCheckboxes.push(checkboxes[i]);
            console.log(this.selectedCheckboxes.length + ''+ checkboxes.length + '' +this.tenderLocation.length);
                    if((this.selectedCheckboxes.length == checkboxes.length) && (this.lengthOfLocations == checkboxes.length)){
                        let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
                        checkboxes1.checked = true;
                    }    
                    else{
                        let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
                        checkboxes1.checked = false;
                    }
            }
            
        }   
             
   }

// to get the location data
    getTenderLocationAdd(){
    //getting all tender location available in the Tender
    let round;
        getTenderLocationAdd({TenderId: this.tenderId})
        .then(result=>{
            this.tenderLocation = JSON.parse(JSON.stringify(result));; // all location by default
            console.log('Tender location are' +this.tenderLocation);
            for(let i=0; i<this.tenderLocation.length;i++){
                this.tenderLocation[i].locationName = this.tenderLocation[i].AITM_IATA_ICAO__c + ' - ' + this.tenderLocation[i].AITM_Location__r.Name;
                round = this.tenderLocation[i].AITM_Round__c;
                console.log('location anme is ' +this.tenderLocation);
                this.dispatchEvent(new CustomEvent('round', {detail:round}));  
            }
            this.availableAction(this.tenderLocation);
            this.lengthOfLocations = this.tenderLocation.length;
            this.error= undefined;
        })
        .catch(error=>{
            this.tenderLocation = undefined;
            this.error= error;
        })
        //getting all selected  tender location available in the Tender
        if(this.packId){
            getTenderLocationEdit({TenderId: this.tenderId, PackId : this.packId})
            .then(result=>{
                this.isLoading =true;
                this.tenderLocationSelected = result;
                console.log(' Selected Tender location are' + JSON.stringify(this.tenderLocationSelected));
                //globalmySet.add(this.tenderLocationSelected);
                setTimeout(()=> this.selectedLocation(this.tenderLocationSelected), 1000);
                this.error= undefined;   
            })
            .catch(error=>{
            this.tenderLocationSelected = undefined;
            this.error= error;
            })    
        }
    }
   
// @api
// filling the available action picklist with country and location manager  filters
    availableAction(Availableoptions){
       
        
        console.log('Location items are in packagelocatuion options' + Availableoptions);
        for(let i=0; i<Availableoptions.length; i++){
            console.log('Manager' + Availableoptions[i].AITM_Location_Manager__r.Name);
            console.log('Country' + Availableoptions[i].AITM_Location__r.AITM_Country__c);
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
    }

    handleSearch(event){
        
        //this.availableAction(this.tenderLocation);
        this.template.querySelector('[data-id="Available"]').value = 'All Locations';
        if(this.AllLocations){
            console.log('inside all locations'+ this.AllLocations)
            this.tenderLocation = this.AllLocations;
            
        }
        else if(this.filterSearch){
            console.log('inside all filters'+ this.filterSearch)
            this.tenderLocation = this.filterSearch;
           
        } 
      /*  if(!this.isSearch){
            if(this.filterSearch){
                console.log('inside all filters'+ this.filterSearch)
                this.tenderLocation = this.filterSearch;
            }
        }*/
       
        //let filterSearch = this.tenderLocation? this.tenderLocation : this.AllLocations;
        console.log('locations are' +  JSON.stringify(this.filterSearch));
        console.log('locations are filter' +  JSON.stringify(this.filterSearch));
        this.searchValue = event.target.value;
        //this.tenderLocation = this.AllLocations;
        this.locationBySearch = this.tenderLocation.filter(progress=>   
        progress.AITM_Location__r.Name.toLowerCase().includes(this.searchValue.toLowerCase()));
        this.filterSearch = this.tenderLocation;
        this.tenderLocation = this.locationBySearch;
       
        console.log('Tender location value are' +this.tenderLocation); 
        if(this.globalmySet){
            for(let i=0; i< this.tenderLocation.length; i++){
                console.log(this.tenderLocation[i].Id)
                let targetId = this.tenderLocation[i].Id
                if(this.globalmySet.has(targetId)){
                    console.log('set contains' +targetId);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).checked = true);
                    
                }
            }
        }
        // after serach witholding the selected checkbox
        if(this.tenderLocationSelected){
            for(let i=0; i< this.tenderLocation.length; i++){
                console.log(this.tenderLocation[i].Id)
                let targetId = this.tenderLocation[i].Id
                if(this.tenderLocationSelected.includes(targetId)){
                    console.log('set contains' +targetId);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).checked = true);
                    setTimeout(()=> this.template.querySelector(`[data-record-id="${targetId}"]`).disabled = true);
                   
                }
            }
        }
        
    }
   
    renderedCallback(){ 
        if(!this.package && !this.packId){
            this.template.querySelector('div').classList.add('disabledbutton');
        }
    }
    @api
    selected(locationList){
        this.isLoading = true;
        console.log('After previous Initial' +this.tenderLocationSelected);
        if(this.package){
            for(let i=0; i<locationList.length;i++){
                selectedLocationset.add(locationList[i]);
            }
            console.log('selected location set size is ' + selectedLocationset.size);
            for (var item of selectedLocationset.values()){
                this.tenderLocationSelected.push(item);
            }
            console.log('After previous' +this.tenderLocationSelected);
            setTimeout(()=>this.selectedLocation(this.tenderLocationSelected), 1000);  
        }     
    }

    @api
    locationEnabled(){
       this.template.querySelector('div').classList.remove('disabledbutton');   
    }

  @api
    selectedLocation(tenderLocationSelected){
        console.log('selected Location value' + tenderLocationSelected);
        if(tenderLocationSelected){
            console.log('inside selected');
            let locations = this.template.querySelectorAll('[data-id="checkboxAll"]');
            console.log( 'location length' +locations.length);
                for(let i=0; i<locations.length; i++){
                    if(tenderLocationSelected.indexOf(locations[i].value) !== -1){
                        locations[i].checked = true;
                        locations[i].disabled = true;   
                    }
                this.isLoading = false;
                }
                if(locations.length == tenderLocationSelected.length){
                    let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');            
                    checkboxes1.checked = true;
                    checkboxes1.disabled = true;
                }
            }

        else if(this.globalmySet){  
            let locations = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for(let i=0; i<locations.length; i++){
                if(this.globalmySet.has(locations[i].value)){
                    locations[i].checked = true;
                    locations[i].disabled = true;   
                }    
            }
            this.globalmySet.clear();  
        } 
    }

//next
    handleCustomer(){
        console.log('already selected value are' +this.tenderLocationSelected);
        console.log('set size is ' + this.globalmySet.size);
        if(this.tenderLocationSelected && this.globalmySet.size >0){  
           for(let i=0; i< this.tenderLocationSelected.length; i++){
                this.globalmySet.delete(this.tenderLocationSelected[i]);
                console.log('set size is ' + this.globalmySet.size);
           }   
        }
        let params = {"globalmySet" : this.globalmySet, "locationAlreadySelected": this.tenderLocationSelected,
        "optionsValue": this.Options}
        this.dispatchEvent(new CustomEvent('next', {detail:params}));   
   }

   selectAllCheckbox(event){   
        if(event.target.checked){   
            //to check all the checkboxes 
            let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for( let i=0; i<checkboxes.length; i++) {
                if(!checkboxes[i].disabled){
                    checkboxes[i].checked = event.target.checked;
                }
            }
          
            for(let i=0;i<this.tenderLocation.length; i++){
                this.globalmySet.add(this.tenderLocation[i].Id);

            }
        }
        else{
            let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for( let i=0; i<checkboxes.length; i++) {
                if(!checkboxes[i].disabled){
                    checkboxes[i].checked = false;
                }
            }
            for(let i=0;i<this.tenderLocation.length; i++){    
                this.globalmySet.delete(this.tenderLocation[i].Id);
            }
        }
    }

    handleItemClicked(event) {
        console.log('Location items are in package location' + this.tenderLocation);
        this.selectedCheckboxes=[];
        if(event.target.checked){
            this.selectedItem = event.target.dataset.recordId;
            this.globalmySet.add(this.selectedItem);
            let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for( let i=0; i<checkboxes.length; i++) {
                if(checkboxes[i].checked == true){
                this.selectedCheckboxes.push(checkboxes[i]);
                console.log(this.selectedCheckboxes.length);
                        if(this.selectedCheckboxes.length == checkboxes.length){
                            let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
                            checkboxes1.checked = true;
                        }    
                }
                else{
                    let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
                    checkboxes1.checked = false;
                }
            }   
        }
        else{ 
            let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
            checkboxes1.checked = false; 
            this.selectedItem = event.target.dataset.recordId;
            this.globalmySet.delete(this.selectedItem);    
        }
    }
}