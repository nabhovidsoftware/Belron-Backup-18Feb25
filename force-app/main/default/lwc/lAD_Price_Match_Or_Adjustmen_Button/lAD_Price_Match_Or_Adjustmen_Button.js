import { LightningElement, track } from 'lwc';
import buttonName from '@salesforce/label/c.LAD_Price_Match_Adjustment'
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';


export default class LAD_Price_Match_Or_Adjustmen_Button extends LightningElement {
    @track flowStarted = false;
    @track showModal = false;
    buttonLabel = buttonName;



    get flowInputVariables() {
        return [
            {
                name: "effectiveAccountId",
                type: "String",
                value: effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accId
            }
        ];
 

   
}

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


    handleExecuteFlow() {
        this.flowStarted = true;
        this.showModal = true;
        console.log('Flow started');
    }

    handleStatusChange(event) {
        const { status } = event.detail;
        console.log('Flow status changed:', status);
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            this.flowStarted = false;
            this.showModal = false;
            console.log('Flow finished, reloading page');
            window.location.reload(); // Refresh the web page immediately
        }
    }

    handleCloseModal() {
        this.showModal = false;
        console.log('Modal closed');
    }
}