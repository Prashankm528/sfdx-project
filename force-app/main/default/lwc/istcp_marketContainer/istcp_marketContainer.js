import { LightningElement } from 'lwc';

export default class Istcp_marketContainer extends LightningElement {
    marketValue = 'nymex';
    electronicPitValue = 'electronic';
    
    get marketOptions() {
        return [
            { label: 'NYMEX', value: 'nymex' },
            { label: 'Market 2', value: 'market2' },
            { label: 'Market 3', value: 'market3' },
        ];
    }

    get options() {
        return [
            { label: 'Electronic', value: 'electronic' },
            { label: 'Pit', value: 'pit' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}