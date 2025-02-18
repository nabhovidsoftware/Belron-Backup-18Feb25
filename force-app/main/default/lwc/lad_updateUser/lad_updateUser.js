import { LightningElement, api, track, wire } from 'lwc';
import Toast from 'lightning/toast';

export default class Lad_updateUser extends LightningElement {
    @api recordId;
    @api status;
    @track flowStarted=false;
    @track showModal=false;
    @track InputVariables = [];
    @track state=true;

    connectedCallback(){  
       this.InputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
        if(this.status=="Pending"){
            this.state=false;
        }
        else{
            this.state=true;
        }
   }
    onClickHandler(){
        this.flowStarted=true;
        this.showModal = true;
        console.log('Flow started');
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
                message:'Changes submitted successfully.',
                variant: 'success',
                mode: 'sticky'
            }); 
            this.dispatchEvent();         
        }
        else if(status === 'ERROR' || status === 'ERROR_SCREEN')
        {
            setTimeout(()=>{window.location.reload();},3000);
        }
    }
}