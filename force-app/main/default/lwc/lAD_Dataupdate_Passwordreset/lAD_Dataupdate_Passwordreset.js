import { LightningElement, track } from 'lwc';

export default class LAD_Dataupdate_Passwordreset extends LightningElement {
    @track flowStarted=false;
    @track showModal=false;
    onClickHandler(){
        this.flowStarted=true;
        this.showModal = true;
        console.log('Flow started');
    }
    handleStatuschange(event){
        const { status } = event.detail;
        console.log('Flow status changed:', status);
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            this.flowStarted = false;
            this.showModal = false;
            console.log('Flow finished, reloading page');
            window.location.reload(); // Refresh the web page immediately
        }
    }
}