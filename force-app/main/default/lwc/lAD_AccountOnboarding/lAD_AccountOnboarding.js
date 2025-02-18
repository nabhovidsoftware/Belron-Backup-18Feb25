import { LightningElement, track } from 'lwc';

export default class LAD_AccountOnboarding extends LightningElement {

    @track flowStarted=false;
    @track showModal=false;
    onClickHandler(){
        this.flowStarted=true;
        this.showModal = true;
        console.log('Flow started');
    }

    renderedCallback(){
        try {
            window.addEventListener('scroll', event => {
                if (this.initialized && this.pressedFlowButton) {
                    const topDiv = this.template.querySelector('.flow-iteration');
                    topDiv.scrollIntoView({block: "start", inline: "nearest"});
                    this.pressedFlowButton = false; // to let user scroll freely after the return-scroll initiated by this
                }
            });
        } catch (error) {
            console.log('this is error: ',error);
        }
    }

    handleFlowStatusChange(event){
        console.log(event.detail.status);
    
        if (this.initialized) {
            this.pressedFlowButton = true;
        } else {
            this.initialized = true; // when the flow starts, is triggers a flowStatusChange and sets initialized to true
        }
        
           
    }




    // handleStatuschange(event){
    //     const { status } = event.detail;
    //     console.log('Flow status changed:', status);
    //     if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
    //         this.flowStarted = false;
    //         this.showModal = false;
    //         console.log('Flow finished, reloading page');
    //        // window.location.reload(); // Refresh the web page immediately
    //     }
    // }

}