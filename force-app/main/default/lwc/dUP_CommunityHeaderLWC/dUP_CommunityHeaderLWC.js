import {
    api,
    LightningElement,
    wire,
    track
} from 'lwc';
import {
    getRecord
} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import DUP_PrivacyPageLogo from '@salesforce/resourceUrl/DUP_PrivacyPageLogo';
import BPISTDUPBaseUrl from '@salesforce/label/c.BPISTDUPBaseUrl';

export default class DUP_CommunityHeaderLWC extends LightningElement {

    
    @api bplogo = DUP_PrivacyPageLogo;
    label = {
        BPISTDUPBaseUrl             
    };

    @api bp_url = BPISTDUPBaseUrl + '/s/portal-guide';
    @api logout_url = 'https://dupdev-bpcustomer.cs87.force.com/DUP/services/auth/sp/saml2/logout';
    @api logout_url2 = BPISTDUPBaseUrl+'/secur/logout.jsp?retUrl='+BPISTDUPBaseUrl;
    @track error ;
    @track name;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }

}