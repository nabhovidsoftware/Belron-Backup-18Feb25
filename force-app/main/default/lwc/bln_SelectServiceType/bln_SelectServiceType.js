import { LightningElement,track, api, wire } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import checkVehicleValues from '@salesforce/apex/BLN_SelectServiceTypeController.checkVehicleValues';
import valueMissingErrorLabel from '@salesforce/label/c.BLN_MissingVehicleFieldsError';
import { getFocusedTabInfo,closeTab } from 'lightning/platformWorkspaceApi';
import Close from '@salesforce/label/c.BLN_CLoseLabel';

export default class Bln_SelectServiceType extends LightningElement {
    
@api vehicleId;
@track openmodel = true;
@api isReplacement = '';
@api isRepair = '';
@track vechicleValuesFilled = true;
valueMissingError = valueMissingErrorLabel;
closeLabel = Close;

    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    } 
    handleReplacement(){
        console.log(this.vehicleId, ' ID');

        checkVehicleValues({vehicleId: this.vehicleId})
        .then((result) => {
            this.isReplacement = 'true';
            if(result==true){
                this.vechicleValuesFilled = true;

                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
            }
            else{
                this.openmodel = false;
                this.vechicleValuesFilled = false;
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleRepair(){
        this.isReplacement = 'false';
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    closeErrorModal(event) {
        getFocusedTabInfo().then((tabInfo) => {
            closeTab(tabInfo.tabId);
        });
    }
}