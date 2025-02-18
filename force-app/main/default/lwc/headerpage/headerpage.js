import { LightningElement, api } from 'lwc';
import BLN_LOGO from '@salesforce/resourceUrl/BLN_AutoglassLogo';


export default class Headerpage extends LightningElement {
    @api logoUrl;
    connectedCallback(){
        this.logoUrl = BLN_LOGO;
       
        if(this.CheckoutjsLoaded){
            return;
        }
    }
}