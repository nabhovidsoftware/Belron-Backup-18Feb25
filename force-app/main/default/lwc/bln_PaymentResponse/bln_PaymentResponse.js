import { LightningElement, track, api, wire } from 'lwc';
import decodeWorldPayResponse from '@salesforce/apex/BLN_DecodeWorldPayMobileResponse.decodeWorldPayResponse';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

export default class Bln_PaymentResponse extends LightningElement {
    returnResp;
    woliId;
    returnMessageString;
    @track isSuccess;
    @track isDeclined;
    @track isShowSpinner= true;
    isWireCalled=false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.isWireCalled == false) {
            this.isWireCalled = true;
            this.returnResp = currentPageReference.state?.returnResp;
            this.woliId = currentPageReference.state?.woliId;
            this.isShowModal = true;
            
            this.getdecodeWorldPayResponse();
            
        }
    }

    // connectedCallback(){
    //     this.isShowSpinner = true;
    // }

    async getdecodeWorldPayResponse() {
        try {
            const result = await decodeWorldPayResponse({ returnResp: this.returnResp, woliId: this.woliId });
            if (result === true) {
                this.returnMessageString = 'Success';
                this.isSuccess = true;
                this.isDeclined = false;
            } else if (result === false) {
                this.returnMessageString = 'Decline';
                this.isDeclined = true;
                this.isSuccess = false;
            }
            this.isShowSpinner = false;
        } catch (error) {
            console.error('Error thrown while generating payment response:', error);
            this.isShowSpinner = false;
        }
    }

    hideModalBox() {
        this.closeComponent();
    }
    closeComponent() {
        // Dispatches the event to close the LWC screen
        this.dispatchEvent(new CloseActionScreenEvent());
      }
}