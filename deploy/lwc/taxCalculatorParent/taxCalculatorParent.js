import { LightningElement, track } from 'lwc';

export default class TaxCalculatorParent extends LightningElement {

    @track variant1 = 'Neutral';
    @track variant2 = 'Brand';

    handleClick(event){
        this.variant1 = 'Brand';
        this.variant2 = 'Neutral';
    }

    handleClick1(event){
        this.variant1 = 'Neutral';
        this.variant2 = 'Brand';
    }
}