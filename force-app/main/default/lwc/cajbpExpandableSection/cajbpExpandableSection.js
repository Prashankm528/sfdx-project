import {LightningElement, api, track} from 'lwc';

export default class CAJBP_ExpandableSection extends LightningElement {
    @api
    id = null;
    @api
    title = null;
    @api
    iconName = null;
    @api
    isOpen = false;
    @api
    readOnly = false;

    toggleSection(event) {
        event.preventDefault();
        this.isOpen = !this.isOpen;
    }

    get headerClass() {
        return 'slds-section' + (this.isOpen ? ' slds-is-open' : '');
    }

    get isClosed() {
        return !this.isOpen;
    }
}