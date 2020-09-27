import { LightningElement, api , track } from 'lwc';

export default class TaxCalculationchild extends LightningElement {
    @track inHandSalary;
    @track TotalDeduction;
    @api 
    taxDetails(taxValue){
        alert(JSON.stringify(taxValue));
        this.inHandSalary = taxValue.handSalary ;
        this.TotalDeduction = taxValue.totalTax;
    }
    

}