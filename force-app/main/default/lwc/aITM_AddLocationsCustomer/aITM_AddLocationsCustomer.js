import { LightningElement, api } from 'lwc';

export default class AITM_AddLocationsCustomer extends LightningElement {
    @api Locations ;
    @api key;
    showVolume = false;

  /*  connectedCallback(){
        alert('inside child');
        console.log('location in child' + this.Locations);
    } */

  

    @api
    ItemClicked(locationId){
        console.log('location id in child' + locationId);
        console.log('location in child' + this.Locations);
        this.showVolume = true;

    }
    @api
    hideItemClicked(locationId){
        console.log('location id in child' + locationId);
        this.showVolume = false;
    }


    
}