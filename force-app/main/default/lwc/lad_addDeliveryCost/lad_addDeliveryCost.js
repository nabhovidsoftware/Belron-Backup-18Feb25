import { LightningElement } from 'lwc';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import Id from '@salesforce/user/Id';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import addCost from '@salesforce/apex/LAD_addDeliveryCostHandler.addCost';
import returnDeliveryCost from '@salesforce/apex/LAD_addDeliveryCostHandler.returnDeliveryCost';
import checkInternalPortalEligibility from '@salesforce/apex/LAD_addDeliveryCostHandler.returnInternalPortalViability';
import Toast from 'lightning/toast';

export default class Lad_addDeliveryCost extends LightningElement {
    isShowModal = false;
    deliveryCost = 0;
    internalPortalEligibility = false;
    isProcessing = false;
    
    handleClick() {
        this.isShowModal = true;
        console.log('showModal', this.isShowModal);
    }

    hideModalBox() {
        this.isShowModal = false;

    }
    handleDeliveryCost(event) {
        this.deliveryCost = event.target.value;
    }

    handleSubmit() {
        
        let regex = /[$€£\s]+/g;
        let cleanedString = this.deliveryCost.replace(regex, '').replace(' ', '').trim();
        if (cleanedString == '' || cleanedString == null) {
           
            Toast.show({
                label: 'Error',

                message:'Please enter an appropriate delivery cost.',
                mode: 'dismissible',
                variant: 'error'
            }, this);
        } else {

            this.isProcessing = true;
            let obj = { userId: Id, accountId: effectiveAccount.accountId, deliveryCost: cleanedString };

            console.log('CLASS INPUTS>>>', obj);
            addCost(obj)
                .then(result => {
                    console.log(result);
                    window.location.reload();
                })
                .catch(error => {
                    console.log(error);
                    this.isProcessing = false;
                })
        }
    }

    /**
    * helper class that checks if we are in site preview mode
    */
    isInSitePreview() {
        let url = document.URL;

        return (url.indexOf('sitepreview') > 0
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0
            || url.indexOf('lightning') > 0);
    }

    connectedCallback() {
        let obj = { userId: Id, accountId: effectiveAccount.accountId, deliveryCost: this.deliveryCost };
        checkInternalPortalEligibility({ userId: Id })
            .then(result => {
                this.internalPortalEligibility = result && InternalPortal;
            })
            .catch(error => {
                console.log(error);
            })
        returnDeliveryCost(obj)
            .then(result => {
                if (result != null) {
                    this.deliveryCost = result;
                }
            }).catch(error => {
                console.log(error);
            })


    }
}