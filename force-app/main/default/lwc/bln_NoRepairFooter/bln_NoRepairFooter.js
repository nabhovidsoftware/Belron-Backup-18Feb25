import { LightningElement, api} from 'lwc';
import backLabel from '@salesforce/label/c.BLN_PdsBack';
import finishLabel from '@salesforce/label/c.BLN_Finish';
import selectAdditionalGlassLabel from '@salesforce/label/c.BLN_SelectAdditionalGlass';
import continueLabel from '@salesforce/label/c.BLN_Continue';
import { FlowNavigationFinishEvent, FlowAttributeChangeEvent , FlowNavigationNextEvent ,updateScreen ,FlowNavigationBackEvent} from 'lightning/flowSupport';
export default class Bln_NoRepairFooter extends LightningElement {
    label = {
       
        backLabel,
        finishLabel,
        selectAdditionalGlassLabel,
        continueLabel,

    };

    @api availableActions = [];
    @api IsAdditionalGlass = false;
    @api IsContinue;
        
        
        handleContinue(event){
        var actionClicked = event.target.name;
        if(actionClicked){
            this.dispatchEvent(new FlowAttributeChangeEvent('IsContinue',true));
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


    handleBack(){
        if(this.availableActions.find((action)=> action ==='BACK')){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent)
        }
    }

    // handleFinish(){
    //     if(this.availableActions.find((action)=> action ==='FINISH')){
    //         const navigateFinishEvent = new FlowNavigationFinishEvent();
    //         this.dispatchEvent(navigateFinishEvent)
    //     }
    // }
}