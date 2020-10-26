import { LightningElement, api } from 'lwc';

export default class AITM_PackageCustomer extends LightningElement {
    @api locationLineItem ;
    
    get options() {
        return [
            { label: 'All Locations', value: '' },
            { label: 'Customers', value: 'Customers' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    deleteRecord(){
        this.template.querySelector('c-a-i-t-m_-package-customer-tile').deleteCustomerLocation();
    }

    showLocationScreenWithChecked(){
        alert('inside parent');
        this.dispatchEvent(new CustomEvent('back'));   
        //this.template.querySelector('c-a-i-t-m_-package-customer-tile').checkedCustomerScreen();
        //this.dispatchEvent(new CustomEvent('back', {detail:globalmySet}));   
    }
}
