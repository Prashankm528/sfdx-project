import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import ANIMATE_CSS from '@salesforce/resourceUrl/AnimateCss';

/*
* Custom accordion component, mainly used to further customise the look and feel.
*/
export default class CAJBP_Accordion extends LightningElement {

    /*
    * Load the animated css styles.
    */
    connectedCallback() {
        loadStyle(this, ANIMATE_CSS).then(() => {
        }).catch(error => {
            console.log(error);
        });
    }
}