import { LightningElement, api } from 'lwc';
let globalmySet = new Set();
export default class AITM_PackageLocation extends LightningElement {

    @api locationItems;
    @api package;
    @api packId;
     
    selectedValue1 =  [];
    selectedValue =  [];
    selectedItem = '';
    checkbox = false;
    selectedCheckboxes = [];
   

    get options() {
        return [
            { label: 'All Locations', value: '' },
            { label: 'Customers', value: 'Customers' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    renderedCallback(){
        if(!this.package && !this.packId){
          this.template.querySelector('div').classList.add('disabledbutton');
        }
    }

    @api
    locationEnabled(){
       // this.template.querySelector(".disabledbutton").classList.remove('disabledbutton');
       this.template.querySelector('div').classList.remove('disabledbutton');
    }

   @api 
    selectedLocation(tenderLocationSelected){
        alert(tenderLocationSelected);

        if(tenderLocationSelected){
            alert('editable view');
            console.log('selected tender location' + JSON.stringify(tenderLocationSelected))
            let locations = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for(let i=0; i<locations.length; i++){
                console.log('location values are' + locations[i].value);
                if(tenderLocationSelected.indexOf(locations[i].value) !== -1){
                    alert('value found');
                    locations[i].checked = true;
                    locations[i].disabled = true;   
                }

            }
            if(locations.length == tenderLocationSelected.length){
                alert('Lengths are equal');
                let checkboxes1 = this.template.querySelector('[data-id="checkbox"]');
                        
                checkboxes1.checked = true;
                checkboxes1.disabled = true;
            }
        }

        else if(globalmySet){
            alert('Non editable view');
            console.log('set value is ')
        let locations = this.template.querySelectorAll('[data-id="checkboxAll"]');
        for(let i=0; i<locations.length; i++){
            if(globalmySet.has(locations[i].value)){
                locations[i].checked = true;
                locations[i].disabled = true;   
            }
        }
    } 
 

    }

    

    handleCustomer(){
       this.dispatchEvent(new CustomEvent('next', {detail:globalmySet}));   
   }

   selectAllCheckbox(event){
       
        if(event.target.checked){
            alert('inside check');
            //to check all the checkboxes 
            let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for( let i=0; i<checkboxes.length; i++) {
               checkboxes[i].checked = event.target.checked;
            }
           // this.checkbox= true;
          
            for(let i=0;i<this.locationItems.length; i++){
                globalmySet.add(this.locationItems[i].Id);

            }
        }
        else{
            let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
            for( let i=0; i<checkboxes.length; i++) {
               checkboxes[i].checked = false;
            }
            for(let i=0;i<this.locationItems.length; i++){    
                globalmySet.delete(this.locationItems[i].Id);

            }
        }
    }

    
 
    handleItemClicked(event) {
        this.selectedCheckboxes=[];
        if(event.target.checked){
            this.selectedItem = event.target.dataset.recordId;
            globalmySet.add(this.selectedItem);

                let checkboxes = this.template.querySelectorAll('[data-id="checkboxAll"]');
                for( let i=0; i<checkboxes.length; i++) {

                if(checkboxes[i].checked == true){
                   this.selectedCheckboxes.push(checkboxes[i]);
                   console.log(this.selectedCheckboxes.length);
                        if(this.selectedCheckboxes.length == checkboxes.length){
                            alert('AllCheckboxes checked');
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
            globalmySet.delete(this.selectedItem);
            
        }
    }
}