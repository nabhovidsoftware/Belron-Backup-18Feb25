import { LightningElement } from 'lwc';
import returnDeliveryCost  from '@salesforce/apex/LAD_addDeliveryCostHandler.returnDeliveryCostCheckout';
import Id from '@salesforce/user/Id';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
export default class Lad_showDeliveryCost extends LightningElement {
    deliveryCost;
    connectedCallback(){
        let obj={userId:Id,accountId:effectiveAccount.accountId,deliveryCost:this.deliveryCost};

        returnDeliveryCost(obj)
        .then(result=>{
            if(result!=null){
                console.log('DELIVERYCOST>>'+result);
                this.deliveryCost=result;
            }
        })
    }
}