import { LightningElement,api ,track} from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';
export default class Lad_reusableFlowContainer extends LightningElement {

    @api accountId;
    @track accId;
    @api flowApiName;
    showFlow = true;

    // Setting flow input variables,
    // hard coded only for demo purpose


    connectedCallback()
    {   
        getAccId({userid:Id})
        .then(result => {
            this.accId=result;
          
        })
        .catch(error=>{
            console.log(error);
        })
    }

    get flowInputVariables() {
            return [
                {
                    name: "effectiveAccountId",
                    type: "String",
                    value: effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accId
                }
            ];
     

       
    }

  

    handleFlowStatusChange(event) {
        console.log("flow status", event.detail.status);
        if (event.detail.status === "FINISHED") {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Flow Finished Successfully",
                    variant: "success"
                })
            );
        }
    }
}