import { LightningElement ,wire} from 'lwc';

import { effectiveAccount } from 'commerce/effectiveAccountApi';

export default class LAD_effectiveaccountDetails extends LightningElement {
    accountName;
  
    connectedCallback(){
        this.accountName = effectiveAccount.accountName;


    }
   
}