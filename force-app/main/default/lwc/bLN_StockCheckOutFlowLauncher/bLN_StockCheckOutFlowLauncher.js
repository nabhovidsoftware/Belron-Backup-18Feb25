import { LightningElement, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation'; 

export default class bLN_StockCheckOutFlowLauncher extends NavigationMixin(LightningElement) {
    @api userId;
    
    //connectedCallback() {
    //    this.UserId = USER_ID;
    //    window.location=`com.salesforce.fieldservice://v1/sObject/${this.UserId}/flow/StockCheckOut`;
    //}
    connectedCallback() {
        this.userId = USER_ID;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `com.salesforce.fieldservice://v1/sObject/${this.userId}/flow/StockCheckOut`,
            },
        });
    } 
}