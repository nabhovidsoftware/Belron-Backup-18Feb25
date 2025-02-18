/*import { LightningElement, track } from 'lwc';
export default class LAD_PriceAdjustmentComponent extends LightningElement {
    @track flowStarted = false;

    handleExecuteFlow() {
        this.flowStarted = true;
    }
    handleStatusChange(event) {
        const {status}= event.detail;
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            this.flowStarted = false;
            window.location.reload();
    }else{
        console.log('flow status',status);
    }

    
}
}*/


import { LightningElement, track } from 'lwc';

export default class LAD_PriceAdjustmentComponent extends LightningElement {
    @track flowStarted = false;
    @track showModal = false;

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