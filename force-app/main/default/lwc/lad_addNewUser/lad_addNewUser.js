import { LightningElement,track,api } from 'lwc';
import Toast from 'lightning/toast';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';

export default class lad_addNewUser extends LightningElement {
    @api accountId;
    @track flowStarted=false;
    @track showModal=false;
    @track accId = []; 

    connectedCallback(){
        getAccId({userid:Id})
        .then(result => {
            this.accountId=result;
            this.setAccount();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    setAccount(){
        let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        this.accId = [
            {
                name: 'accountId',
                type: 'String',
                value: variable
            }
        ];
    }
    onClickHandler(){
        this.flowStarted=true;
        this.showModal = true;
        console.log('Flow started');
    }

    handleCloseModal(){
        this.showModal = false;
    }

    handleStatuschange(event){
        const { status } = event.detail;
        console.log('Flow status changed:', status);
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            setTimeout(()=>{window.location.reload();},3000);
            this.flowStarted = false;
            this.showModal = false;
            Toast.show({
                label: 'Success',
                message:'New user successfully created',
                variant: 'success',
                mode: 'sticky'
            });         
        }
        else if(status === 'ERROR' || status === 'ERROR_SCREEN'){
                setTimeout(()=>{window.location.reload();},3000);
        }
    }
        
}