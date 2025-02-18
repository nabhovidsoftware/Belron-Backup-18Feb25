import { LightningElement } from 'lwc';
import cartURL from '@salesforce/label/c.LAD_CartURL';
import helpURL from '@salesforce/label/c.LAD_HelpURL';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';

export default class LAD_GoToCartButton extends LightningElement {

    isHidden = false;

    get internalUser() {
        return InternalPortal;
    }

    get buyerUser() {
        return Buyer || BuyerManager;
    }

    connectedCallback() {
        // if (!this.internalUser && this.buyerUser) {
        //     this.isHidden= false;
        // }
        if (this.internalUser) {
            this.isHidden= true;
        }
    }

    handleClick()
    {
        window.location.href=cartURL;
    }

    handleonClick()
    {
        window.location.href=helpURL;
    }
}