import { LightningElement,api,track } from 'lwc';

import BLN_LOGO from '@salesforce/resourceUrl/BLN_ChatLogo';
import BLN_LOGO1 from '@salesforce/resourceUrl/BLN_PhoneLogo';

export default class Changepasswordlwcpage extends LightningElement {
    @api chatUrl;
    @api phUrl;

    connectedCallback() {
        this.chatUrl = BLN_LOGO;
        this.phUrl = BLN_LOGO1;
       
       
    }
}