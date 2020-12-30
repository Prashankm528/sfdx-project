import { LightningElement, track , api} from 'lwc';
import getTenderLocation from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationToAddCustomer';
import getTenderLocationEdit from '@salesforce/apex/AITM_AddTenderPackage.getTenderLocationEditPackage';
import savelocationLineitems from '@salesforce/apex/AITM_AddTenderPackage.savelocationLineitems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
let mapOfLocationlineItemToCreate =  new Map();
export default class AITM_AddCustomerModal extends LightningElement {

    @track isModalOpen = false;
    @api tenderId;
    @api package;
    @api packId;
    @track tenderlocationlist = new Array();
    @track locationVolume = [];
    @track showChild = false;
    changedVolume;
    customerId;
    //showlocation =false;
    tenderLocationSelectedId =[];
    startDate;
    endDate;
    defaultStartDate;
    defaultEndDate;
    //showVolume =false;
  
    get showlocation(){
        if(this.tenderlocationlist.length>0){
            
            return true;
        }
    }

    get showDivHTML() {
        return this.showChild ? true : false;
    }

    handleDisable(event){
        let locationId = event.target.dataset.value;
        let standAloneLocationId = event.target.dataset.id;
        console.log('id is ' +locationId);
        for(let i=0; i<this.tenderlocationlist.length;i++){
           
            let tenderddId = this.tenderlocationlist[i].Id;
            if(tenderddId === locationId){
                if(event.target.checked){
                    this.tenderlocationlist[i].isDisabled = true;
                    if(mapOfLocationlineItemToCreate.has(locationId)){
                        let valtoUpdate = mapOfLocationlineItemToCreate.get(locationId);
                        valtoUpdate.locationId = locationId;
                        valtoUpdate.adHoc = true;
                        valtoUpdate.requestedVolumeUom = null;
                        valtoUpdate.standAloneLocationId = standAloneLocationId;
                        mapOfLocationlineItemToCreate.set(locationId,valtoUpdate);
                    }
                    else{
                        mapOfLocationlineItemToCreate.set(locationId,{requestedVolumeUom:null, locationId:locationId,standAloneLocationId: standAloneLocationId, adHoc:true})
                    }
                    break;
                }
                else{
                    this.tenderlocationlist[i].isDisabled = false;
                    if(mapOfLocationlineItemToCreate.has(locationId)){
                        let valtoUpdate = mapOfLocationlineItemToCreate.get(locationId);
                        valtoUpdate.locationId = locationId;
                        valtoUpdate.adHoc = false;
                        valtoUpdate.standAloneLocationId = standAloneLocationId;
                        mapOfLocationlineItemToCreate.set(locationId,valtoUpdate);
                    }
                    else{
                        mapOfLocationlineItemToCreate.set(locationId,{volume:this.changedVolume, locationId:locationId, standAloneLocationId: standAloneLocationId, adHoc:false})
                    }
                }
            }
        }
    }

    handleChangeVolume(event){
        let locationId = event.target.dataset.value;
        let standAloneLocationId = event.target.dataset.id;
        this.changedVolume =event.target.value;
        if(mapOfLocationlineItemToCreate.has(locationId)){
            let valtoUpdate = mapOfLocationlineItemToCreate.get(locationId);
            valtoUpdate.locationId = locationId;
            valtoUpdate.requestedVolumeUom = this.changedVolume;
            valtoUpdate.adHoc = false;
            valtoUpdate.standAloneLocationId = standAloneLocationId;
            mapOfLocationlineItemToCreate.set(locationId,valtoUpdate);
        }
        else{
            mapOfLocationlineItemToCreate.set(locationId,{requestedVolumeUom:this.changedVolume, locationId:locationId,standAloneLocationId: standAloneLocationId, adHoc:false})
        }
        
    }

    handleStartDate(event){
        let locationId = event.target.dataset.value;
        let standAloneLocationId = event.target.dataset.id;
        console.log('standAloneLocationId' +standAloneLocationId);
        this.startDate =event.target.value;
        if(mapOfLocationlineItemToCreate.has(locationId)){
            let valtoUpdate = mapOfLocationlineItemToCreate.get(locationId);
            valtoUpdate.locationId = locationId;
            valtoUpdate.startDate = this.startDate;
            valtoUpdate.adHoc = false;
            valtoUpdate.standAloneLocationId = standAloneLocationId;
            mapOfLocationlineItemToCreate.set(locationId,valtoUpdate);
        }
        else{
            mapOfLocationlineItemToCreate.set(locationId,{startDate:this.startDate, locationId: locationId,standAloneLocationId: standAloneLocationId, adHoc:false})
        }
    }

    handleEndDate(event){
        let locationId = event.target.dataset.value;
        let standAloneLocationId = event.target.dataset.id;
        this.endDate =event.target.value;
        if(mapOfLocationlineItemToCreate.has(locationId)){
            let valtoUpdate = mapOfLocationlineItemToCreate.get(locationId);
            valtoUpdate.locationId = locationId;
            valtoUpdate.endDate = this.endDate;
            valtoUpdate.adHoc = false;
            valtoUpdate.standAloneLocationId = standAloneLocationId;
            mapOfLocationlineItemToCreate.set(locationId,valtoUpdate);
        }
        else{
            mapOfLocationlineItemToCreate.set(locationId,{endDate:this.endDate, locationId: locationId,standAloneLocationId: standAloneLocationId, adHoc:false})
        }
    }

    handleItemClicked(event){
       
        let locationId = event.target.dataset.value;
        console.log('id is ' +locationId);
        for(let i=0; i<this.tenderlocationlist.length;i++){
           
            let tenderddId = this.tenderlocationlist[i].Id;
            if(tenderddId === locationId){
                if(event.target.checked){
                    this.tenderlocationlist[i].isSelected = true;
                    break;
                }
                else{
                    this.tenderlocationlist[i].isSelected = false;
                   
                }
            }
        }
        //console.log('is check ' + this.template.querySelector(`[data-value="${locationId}"]`).checked)
     // this.template.querySelector(`[data-value="${locationId}"]`).checked = true;

        //console.log('location id in parent' + locationId);
      /* for(let i=0; i<this.tenderlocationlist.length;i++){
            console.log('Clicked checkbox Id: '+event.currentTarget.dataset.value);
            console.log('tenderid: '+this.tenderlocationlist[i].Id);
            let locationValue = event.currentTarget.dataset.value;
            let tenderddId = this.tenderlocationlist[i].Id;
            if(tenderddId === locationValue){
                this.locationVolume.push(locationValue);
                this.showChild = true;
                console.log('I am inside both ids same');
                break;
            }else{
                this.locationVolume.pop(locationValue);
                this.showChild = false;
            }
        }*/
       /* if(event.target.checked){
            this.template.querySelector('c-a-i-t-m_-add-locations-customer').ItemClicked(locationId);
        }
        else{
            this.template.querySelector('c-a-i-t-m_-add-locations-customer').hideItemClicked(locationId);
        }*/
        // let locationValue = event.currentTarget.dataset.value;
        // //let iidd = event.currentTarget.dataset.Id;
        // console.log('selected location value is '+locationValue);
        // //console.log('Id '+iidd);
        // console.log('true or false: '+event.target.checked);
        // if(event.target.checked){
        //     console.log('our child should true');
        //     this.showChild = true;
        //     this.locationVolume.push(locationValue);
        //     //this.template.querySelector('c-a-i-t-m_-add-locations-customer').ItemClicked(locationId);
            
        // }
        // else{
        //     this.locationVolume.pop(locationValue);
        //     //this.template.querySelector('c-a-i-t-m_-add-locations-customer').hideItemClicked(locationId);
        // }
        // console.log('this.locationVolume: '+this.locationVolume);
    }
    handlelocation(event){
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
        this.customerId = event.detail.selectedAccount;
        console.log('customerId is ' +this.customerId + ''+selectedPackageId);
        
        getTenderLocationEdit({TenderId: this.tenderId, PackId : selectedPackageId})
        .then(result=>{
            this.isLoading =true;
            console.log('result is ' + JSON.stringify(result));
            this.tenderLocationSelectedId = result;
            this.getTenderLocationForAddingCustomer(this.tenderLocationSelectedId, this.customerId, selectedPackageId);

            
            
             
        })
        .catch(error=>{
            console.log(error);
        })    
    }

    handleremove(event){
       
        this.tenderlocationlist = [];
    }

    getTenderLocationForAddingCustomer(tenderLocationSelectedId,  customerId, selectedPackageId){
       
        getTenderLocation({packageId:selectedPackageId,tenderId:this.tenderId , AccountId:customerId, listOfSelectedLocationIds: tenderLocationSelectedId  })
        .then(result=>{
            this.tenderlocationlist = result;
            console.log('result value is ' + this.tenderlocationlist);
            for(let i=0; i<this.tenderlocationlist.length;i++){
                this.tenderlocationlist[i].locationName = this.tenderlocationlist[i].AITM_IATA_ICAO__c + ' - ' + this.tenderlocationlist[i].AITM_Location__r.Name;
               // this.showlocation = true;

               this.tenderlocationlist[i].isSelected = false;
               this.tenderlocationlist[i].isDisabled = false;
               this.defaultStartDate = this.tenderlocationlist[i].AITM_Tender__r.AITM_Start_Date__c;
               this.defaultEndDate = this.tenderlocationlist[i].AITM_Tender__r.AITM_End_Date__c;
               console.log('locationName to be shown' +  JSON.stringify( this.tenderlocationlist[i].locationName));
            }
            console.log('list to be shown' +  JSON.stringify(this.tenderlocationlist));
        })
        .catch(error=>{
            console.log(error);
        })
    }
    @api
    openModal() {
        // to open modal set isModalOpen tarck value as true
//this.locationLineItemId = locationLineItemId;
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.tenderlocationlist = [];
        this.isModalOpen = false;

    }
    submitDetails() {
        //let locationLineItemsToInsert =[];
        let selectedPackageId = this.packId ? this.packId : this.PackageId ;
       console.log('json value is ' + mapOfLocationlineItemToCreate);
        let locationLineItemsToInsert= Array.from(mapOfLocationlineItemToCreate.values());
        for (const item of locationLineItemsToInsert) {
            console.log(item);
          }
        console.log('line item to insert' + JSON.stringify(locationLineItemsToInsert));
        savelocationLineitems({tenderId:this.tenderId , packageId:selectedPackageId, lineitemsToInsert: JSON.stringify(locationLineItemsToInsert),
            startDate: this.defaultStartDate , endDate: this.defaultEndDate , customerId: this.customerId})
        .then(result=>{
            console.log('lineItems Succesfully insert' +result);
            this.tenderlocationlist = [];
           // let params = {"listoflineItemsToClone" : listoflineItemsToClone}

        this.dispatchEvent(new CustomEvent('add', {bubbles: true, composed: true})); 
            this.dispatchEvent(    
                new ShowToastEvent({     
                    title: 'Success',
                    message: 'Line item inserted successfully!',
                    variant: 'Success'
                })    
            );
        })
        .catch(error=>{
            console.log('error saving line items ' + JSON.stringify(error));
            this.dispatchEvent(    
                new ShowToastEvent({     
                    title: 'Error',
                    message: 'error while Inserting!',
                    variant: 'error'
                })    
            );
        })
        
        this.isModalOpen = false;
    }
}