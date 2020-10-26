import {LightningElement, api, track} from 'lwc';

/*
* Individual accordion section, only supports multiple sections being opened.
*/
export default class CAJBP_AccordionSection extends LightningElement {
    @api
    name = 'CAJBP_AccordionSection';
    @api
    label = null;
    @api
    summary = null;
    @api
    animation = null;
    @api
    wrap = false
    @api
    unlink = false;
    @track
    isOpen = false;
    //Trigger setting defaults once on initial render.
    isRendered = false;


    constructor() {
        super();
    }

    expand(event) {
        event.preventDefault();

        this.isOpen = !this.isOpen;
        this.template.querySelector('section').classList.toggle('slds-is-open');
        this.template.querySelector('button').setAttribute('aria-expanded', this.isOpen);
    }

    renderedCallback() {
        if (!this.isRendered) {
            if (this.unlink) {
                this.template.querySelector('button').classList.add('reset-link');
            }

            if (this.wrap) {
                this.template.querySelector('span.summary').classList.add('slds-wrap');
            }

            if (this.animation && this.animation.length > 0) {
                this.template.querySelector('li.item').classList.add('animated', this.animation);
            }

            this.isRendered = true;
        }
    }
}