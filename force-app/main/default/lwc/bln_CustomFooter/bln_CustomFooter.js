import { LightningElement,api } from 'lwc';
import backLabel from '@salesforce/label/c.BLN_PdsBack';
import continueLabel from '@salesforce/label/c.BLN_Continue';
import finishLabel from '@salesforce/label/c.BLN_Finish';
import selectAdditionalGlassLabel from '@salesforce/label/c.BLN_SelectAdditionalGlass';
import {FlowAttributeChangeEvent , FlowNavigationNextEvent, FlowNavigationBackEvent} from 'lightning/flowSupport';
export default class Bln_CustomFooter extends LightningElement {
    label={
        backLabel,
        continueLabel,
        selectAdditionalGlassLabel,
        finishLabel
    };

    @api availableActions = [];
    @api IsAdditionalGlass = false;
    @api IsFinished;

    /*Back button to navigate previous screen */
    handleBack(){
        if(this.availableActions.find((action)=> action ==='BACK')){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent)
        }
    }
    
    /*Finish button to finish the flow and navigate to case record*/
    handleFinish(event){
        var actionClicked = event.target.name;
        if(actionClicked){
            this.dispatchEvent(new FlowAttributeChangeEvent('IsFinished', true));
            if (this.availableActions.find((action) => action === 'NEXT')) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent)
            }
        }
    }

    /* Additional Glass button to select another glass after repair or damage too small screen*/
    handleAdditionalGlass(event){
        var actionClicked = event.target.name;
        if (actionClicked) {
            this.dispatchEvent(new FlowAttributeChangeEvent('IsAdditionalGlass', true));
            if (this.availableActions.find((action) => action === 'NEXT')) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent)
            }
        }
    }
}