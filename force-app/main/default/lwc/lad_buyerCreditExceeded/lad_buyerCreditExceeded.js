import { LightningElement } from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import Id from '@salesforce/user/Id';
import returnBuyerCreditExceededCheck from '@salesforce/apex/Lad_buyerCreditExceededHandler.returnBuyerCreditExceededCheck';
export default class Lad_buyerCreditExceeded extends LightningElement {

    showError=false;
    connectedCallback() {
        console.log(Id,effectiveAccount.accountId);
        returnBuyerCreditExceededCheck({userId:Id,effectiveAccountId:effectiveAccount.accountId})
        .then(result=>{
            this.showError=result;
            console.log(12,result);
        })
        .catch(error=>{
            console.log(error);
        })
    }
    get url(){

        const url = new URL(window.location.href);

        const baseUrl = `${url.protocol}//${url.host}${url.pathname.substring(0, url.pathname.lastIndexOf('/') + 1)}`;
        console.log(baseUrl); 
        return baseUrl+'invoice';

    }
    
}